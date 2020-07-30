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
        
        var isGranted: Bool {
            switch self {
            case .authorized:
                return true
            default:
                return false
            }
        }
    }
    
    var contact: Contact?
    
    private let session = AVCaptureSession()
    
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    private var cameraAuthStatus: CameraAuthorizationStatus = .notAuthorized { didSet { didUpdateCameraAuthStatus() } }
    
    private let captureSessionQueue = DispatchQueue(label: "captureSessionQueue")
    private var cameras: [AVCaptureDevice]?
    
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
        view.backgroundColor = .black
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
        
        do {
            cameras = AVCaptureDevice.devices(for: AVMediaType.video)
            
            guard let videoDevice = cameras?.first else {
                #warning("Todo video device")
                cameraAuthStatus = .failed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
            }
            else {
                #warning("Todo no video device to add")
                cameraAuthStatus = .failed
                session.commitConfiguration()
                return
            }
        } catch {
            #warning("Todo error creating video device")
            cameraAuthStatus = .failed
            session.commitConfiguration()
            return
        }
        
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            }
            else {
                #warning("Todo no video device to add")
            }
        } catch {
            #warning("Todo error creating audio device")
        }
        
        session.commitConfiguration()
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




