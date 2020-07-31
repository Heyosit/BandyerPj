//
//  CallRoomViewController.swift
//  BandyerPj
//
//  Created by Alessio Perrotti on 29/07/2020.
//  Copyright © 2020 Alessio Perrotti. All rights reserved.
//

import UIKit
import AVFoundation

protocol CallRoomViewControllerDelegate: class {
    func callRoomViewControllerDelegateShouldDisableButton(_ button: ButtonStyle, disable: Bool)
    func callRoomViewControllerDelegateSwitchButton(_ button: ButtonStyle, shouldActivate: Bool)
}

final class CallRoomViewController: UIViewController {
    
    // MARK: UI
    
    private var cameraPreviewLayerView: CameraPreviewLayerView = {
        let view = CameraPreviewLayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var blurView: BlurView = {
        let view = BlurView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameDescriptionLabelView: TitleSubtitleLabelView = {
        let view = TitleSubtitleLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomSheetVC = BottomSheetViewController()
    
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
    
    private enum MicrophoneAuthStatus {
        case authorized
        case notAuthorized
    }
    
    private enum FlipCameraStatus {
        case on
        case off
    }
    
    private enum MicrophoneStatus {
        case on
        case off
    }
    
    private enum CameraStatus {
        case on
        case off
    }
    
    private enum DescriptionText: String {
        case cameraDisabledByUser = "Camera has been disabled by the user"
        case noCameraAvailable = "No cameras available"
        case notAuthorized = "Use of camera not authorized"
        case failed = "Something went wrong"
    }
    
    weak var delegate: CallRoomViewControllerDelegate?
    
    var contact: Contact?
    
    private let session = AVCaptureSession()
    private let captureSessionQueue = DispatchQueue(label: "captureSessionQueue")
    
    private var cameraAuthStatus: CameraAuthorizationStatus = .notAuthorized { didSet { didUpdateCameraAuthStatus() } }
    private var microphoneAuthStatus: MicrophoneAuthStatus = .notAuthorized { didSet { didUpdateMicrophoneAuthStatus() } }
    
    private var frontVideoDeviceInput: AVCaptureDeviceInput?
    private var backVideoDeviceInput: AVCaptureDeviceInput?
    private var currentVideoDeviceInput: AVCaptureDeviceInput?
    
    private var currentAudioDeviceInput: AVCaptureDeviceInput?
    
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var canFlipCamera: FlipCameraStatus = .off { didSet { didUpdateCanFlipCameraStatus() } }
    private var microphoneStatus: MicrophoneStatus = .off { didSet { didUpdateMicrophoneStatus() } }
    private var cameraStatus: CameraStatus = .off { didSet { didUpdateCameraStatus() } }
    
    
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
        addGesture()
    }
    
    private func setup() {
        view.backgroundColor = .white
        nameDescriptionLabelView.config(title: contact?.name)
        addBottomSheetView()
        setupCameraPreviewLayerView()
    }
    
    private func addBottomSheetView() {
        
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        bottomSheetVC.configDelegate(with: self)
        delegate = bottomSheetVC.cameraButtonsStackView
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
        
        guard cameraAuthStatus.isGranted else {
            cameraStatus = .off
            canFlipCamera = .off
            return
        }
        
        backVideoDeviceInput = getCaptureDeviceInput(withPosition: .back)
        frontVideoDeviceInput = getCaptureDeviceInput(withPosition: .front)
        canFlipCamera = .off
        if let videoDeviceInput = backVideoDeviceInput, session.canAddInput(videoDeviceInput) {
            addVideoDeviceInput(videoDeviceInput: videoDeviceInput, with: .back)
            if let _ = frontVideoDeviceInput {
                canFlipCamera = .on
            }
            cameraStatus = .on
        }
        else if let videoDeviceInput = frontVideoDeviceInput, session.canAddInput(videoDeviceInput) {
            addVideoDeviceInput(videoDeviceInput: videoDeviceInput, with: .front)
            cameraStatus = .on
        }
        else {
            cameraAuthStatus = .notFound
            cameraStatus = .off
            return
        }
        
    }
    
    private func setupAudioDevices() {
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
                currentAudioDeviceInput = audioDeviceInput
                microphoneAuthStatus = .authorized
                microphoneStatus = .on
            }
            else {
                microphoneAuthStatus = .notAuthorized
                microphoneStatus = .off
            }
        } catch {
            microphoneAuthStatus = .notAuthorized
            microphoneStatus = .off
        }
    }
    
    private func addGesture() {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGesture))
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func tapGesture(recognizer: UITapGestureRecognizer) {
        bottomSheetVC.showViewController()
    }
    
    // MARK: ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSessionQueue.async {
            self.session.startRunning()
        }
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
    
    //MARK: Update Methods
    
    private func didUpdateCameraAuthStatus() {
        DispatchQueue.main.async {
            switch self.cameraAuthStatus {
            case .authorized:
                self.blurView.isHidden = true
                self.delegate?.callRoomViewControllerDelegateShouldDisableButton(.video, disable: false)
            case .notFound:
                self.blurView.isHidden = false
                self.blurView.descriptionText = DescriptionText.noCameraAvailable.rawValue
                self.delegate?.callRoomViewControllerDelegateShouldDisableButton(.video, disable: true)
            case .notAuthorized:
                self.blurView.isHidden = false
                self.blurView.descriptionText = DescriptionText.notAuthorized.rawValue
                self.delegate?.callRoomViewControllerDelegateShouldDisableButton(.video, disable: true)
            case .failed:
                self.blurView.isHidden = false
                self.blurView.descriptionText = DescriptionText.failed.rawValue
                self.delegate?.callRoomViewControllerDelegateShouldDisableButton(.video, disable: true)
            }
        }
    }
    
    private func didUpdateMicrophoneAuthStatus() {
        DispatchQueue.main.async {
            switch self.microphoneAuthStatus {
            case .authorized:
                self.delegate?.callRoomViewControllerDelegateShouldDisableButton(.microphone, disable: false)
            default:
                self.delegate?.callRoomViewControllerDelegateShouldDisableButton(.microphone, disable: true)
            }
        }
    }
    
    private func didUpdateCanFlipCameraStatus() {
        switch canFlipCamera {
        case .on:
            delegate?.callRoomViewControllerDelegateShouldDisableButton(.flipCamera, disable: false)
        case .off:
            delegate?.callRoomViewControllerDelegateShouldDisableButton(.flipCamera, disable: true)
        }
    }
    
    private func didUpdateMicrophoneStatus() {
        switch microphoneStatus {
        case .on:
            delegate?.callRoomViewControllerDelegateSwitchButton(.microphone, shouldActivate: true)
        case .off:
            delegate?.callRoomViewControllerDelegateSwitchButton(.microphone, shouldActivate: false)
        }
    }
    
    private func didUpdateCameraStatus() {
        switch cameraStatus {
        case .on:
            delegate?.callRoomViewControllerDelegateSwitchButton(.video, shouldActivate: true)
        case .off:
            delegate?.callRoomViewControllerDelegateSwitchButton(.video, shouldActivate: false)
        }
    }
    
    
}

extension CallRoomViewController: CameraButtonsStackViewDelegate {
    
    func cameraButtonsStackViewDelegateDidTapVideoButton() {
        if cameraStatus == .on {
            cameraStatus = .off
            self.blurView.isHidden = false
            self.blurView.descriptionText = DescriptionText.cameraDisabledByUser.rawValue
        }
        else {
            cameraStatus = .on
            self.blurView.isHidden = true
        }
    }
    
    func cameraButtonsStackViewDelegateDidTapMicrophoneButton() {
        guard let currentAudioDeviceInput = currentAudioDeviceInput else {
            microphoneAuthStatus = .notAuthorized
            return
        }
        session.beginConfiguration()
        if session.inputs.contains(currentAudioDeviceInput) {
            session.removeInput(currentAudioDeviceInput)
            microphoneStatus = .off
        } else {
            session.addInput(currentAudioDeviceInput)
            microphoneStatus = .on
        }
        session.commitConfiguration()
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
    }
    
    func cameraButtonsStackViewDelegateDidTapExitButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
