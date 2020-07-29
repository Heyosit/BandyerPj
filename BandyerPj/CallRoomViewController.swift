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
    
    // MARK: Setup
    
    override func loadView() {
        super.loadView()
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(cameraPreviewLayerView)
        view.addSubview(blurView)
        
        cameraPreviewLayerView.anchor(to: self.view)
        blurView.anchor(to: cameraPreviewLayerView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .black
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
                
            } else {
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
            } else {
                #warning("Todo no video device to add")
            }
        } catch {
            #warning("Todo error creating audio device")
        }
        
        session.commitConfiguration()
    }
    
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
    
    
    private func didUpdateCameraAuthStatus() {
        switch cameraAuthStatus {
        case .authorized:
            blurView.isHidden = true
        default:
            blurView.isHidden = false
        }
    }
}

