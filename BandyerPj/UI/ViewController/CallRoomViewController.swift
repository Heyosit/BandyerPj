//
//  CallRoomViewController.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 29/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit
import AVFoundation

final class CallRoomViewController: UIViewController {
    
    // MARK: UI
    
    private var cameraPreviewLayerView: CameraPreviewLayerView = {
        let view = CameraPreviewLayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameDescriptionLabelView: TitleSubtitleLabelView = {
        let view = TitleSubtitleLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Data
    
    private enum CameraAuthorizationStatus {
        case authorized
        case notAuthorized
        case failed
        case notFound
        
        var isGranted: Bool {
            switch self {
            case .authorized:
                return true
            default:
                return false
            }
        }
    }
    
    private enum MicrophoneStatus {
        case authorized
        case notAuthorized
    }
    
    private enum FlipCameraStatus {
        case on
        case off
    }
    
    var contact: Contact?
    
    private let session = AVCaptureSession()
    
    
    
    private var cameraAuthStatus: CameraAuthorizationStatus = .notAuthorized { didSet { didUpdateCameraAuthStatus() } }
    
    private let captureSessionQueue = DispatchQueue(label: "captureSessionQueue")
    
    private var frontVideoDeviceInput: AVCaptureDeviceInput?
    private var backVideoDeviceInput: AVCaptureDeviceInput?
    private var currentVideoDeviceInput: AVCaptureDeviceInput?
    
    private var currentAudioDeviceInput: AVCaptureDeviceInput?
    
    private var microphoneStatus: MicrophoneStatus = .notAuthorized
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var canFlipCamera: FlipCameraStatus = .off
    
    
    // MARK: LoadView
    
    override func loadView() {
        super.loadView()
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(cameraPreviewLayerView)
        view.addSubview(blurView)
        view.addSubview(nameDescriptionLabelView)
        
        cameraPreviewLayerView.anchor(to: self.view)
        blurView.anchor(to: cameraPreviewLayerView)
        
        NSLayoutConstraint.activate([
            nameDescriptionLabelView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            nameDescriptionLabelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            view.trailingAnchor.constraint(equalTo: nameDescriptionLabelView.trailingAnchor, constant: 15),
            
        ])
    }
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .white
        nameDescriptionLabelView.config(title: contact?.name)
        setupCameraPreviewLayerView()
    }
    
    private func setupCameraPreviewLayerView() {
        cameraPreviewLayerView.session = self.session
        checkCameraAuthorization()
    }
    
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthStatus = .authorized
            break
            
        case .notDetermined:
            captureSessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                self.cameraAuthStatus = granted ? .authorized : .notAuthorized
                self.captureSessionQueue.resume()
            })
            
        default:
            cameraAuthStatus = .notAuthorized
        }
        
        captureSessionQueue.async {
            self.startSession()
        }
    }
    
    
    
    private func startSession() {
        guard cameraAuthStatus.isGranted else { return }
        
        session.beginConfiguration()
        session.sessionPreset = .high
        
        setupVideoDevices()
        setupAudioDevices()
        
        session.commitConfiguration()
    }
    
    private func getCaptureDeviceInput(withPosition position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        do {
            let devices = AVCaptureDevice.devices(for: AVMediaType.video)
            for device in devices {
                if device.position == position {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: device)
                    return videoDeviceInput
                }
            }
            return nil
        }
        catch {
            return nil
        }
    }
    
    private func addVideoDeviceInput(videoDeviceInput: AVCaptureDeviceInput, with position: AVCaptureDevice.Position) {
        session.addInput(videoDeviceInput)
        self.currentVideoDeviceInput = videoDeviceInput
        currentCameraPosition = .back
    }
    
    private func setupVideoDevices() {
        
        backVideoDeviceInput = getCaptureDeviceInput(withPosition: .back)
        frontVideoDeviceInput = getCaptureDeviceInput(withPosition: .front)
        canFlipCamera = .off
        if let videoDeviceInput = backVideoDeviceInput, session.canAddInput(videoDeviceInput) {
            addVideoDeviceInput(videoDeviceInput: videoDeviceInput, with: .back)
            if let _ = frontVideoDeviceInput {
                canFlipCamera = .on
            }
        }
        else if let videoDeviceInput = frontVideoDeviceInput, session.canAddInput(videoDeviceInput) {
            addVideoDeviceInput(videoDeviceInput: videoDeviceInput, with: .front)
        }
        else {
            cameraAuthStatus = .notFound
            return
        }
        
    }
    
    private func setupAudioDevices() {
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
                microphoneStatus = .authorized
            }
            else {
                microphoneStatus = .notAuthorized
            }
        } catch {
            microphoneStatus = .notAuthorized
        }
    }
    
    // MARK: ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSessionQueue.async {
            switch self.cameraAuthStatus {
            case .authorized:
                self.session.startRunning()
                
            default:
                #warning("Todo")
                self.session.startRunning()
                
            }
        }
    }
    
    // MARK: ViewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBottomSheetView()
    }
    
    private func addBottomSheetView() {
        let bottomSheetVC = BottomSheetViewController()
        
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        bottomSheetVC.configDelegate(with: self)
    }
    
    // MARK: ViewWillDisappear
    
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSessionQueue.async {
            if self.cameraAuthStatus.isGranted {
                self.session.stopRunning()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    
    private func didUpdateCameraAuthStatus() {
        DispatchQueue.main.async {
            switch self.cameraAuthStatus {
            case .authorized:
                self.blurView.isHidden = true
            default:
                self.blurView.isHidden = false
            }
        }
    }
    
    
}

extension CallRoomViewController: CameraButtonsStackViewDelegate {
    func cameraButtonsStackViewDelegateDidTapVideoButton() {
        
    }
    
    func cameraButtonsStackViewDelegateDidTapMicrophoneButton() {
        
    }
    
    func cameraButtonsStackViewDelegateDidTapFlipCameraButton() {
        guard let backCameraInput = backVideoDeviceInput, let frontCameraInput = frontVideoDeviceInput else {
            return
        }
        
        session.beginConfiguration()
        switch currentCameraPosition {
        case .back:
            changeVideoDeviceInput(with: frontCameraInput, position: .front)
        case .front:
            changeVideoDeviceInput(with: backCameraInput, position: .back)
        default:
            changeVideoDeviceInput(with: backCameraInput, position: .back)
        }
        session.commitConfiguration()
    }
    
    private func changeVideoDeviceInput(with newVideoDeviceInput: AVCaptureDeviceInput, position: AVCaptureDevice.Position) {
        guard let currentVideoDeviceInput = currentVideoDeviceInput else {
            return
        }
        if session.inputs.contains(currentVideoDeviceInput) == true {
            session.removeInput(currentVideoDeviceInput)
            session.addInput(newVideoDeviceInput)
            self.currentVideoDeviceInput = newVideoDeviceInput
            currentCameraPosition = position
        }
        else {
            canFlipCamera = .off
        }
    }
    
    func cameraButtonsStackViewDelegateDidTapExitButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
}




