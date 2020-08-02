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
    
    // MARK: Enum
    
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
        
        var isNotAuthorized: Bool {
            switch self {
            case .notAuthorized:
                return true
            default:
                return false
            }
        }
    }
    
    private enum MicrophoneAuthStatus {
        case authorized
        case notAuthorized
        case notFound
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
        case notAuthorized = "Camera not authorized"
        case failed = "Something went wrong"
        case sessionRunOut = "Session run out"
        case sessionError = "Session error"
        case thermalStateCritical = "Device thermal state is too high"
        case usedByAnotherClient = "Camera is used by another client"
        case systemPressure = "Session stopped running due to shutdown system pressure level"
        case multipleForegroundApps = "Camere non available with multiple foreground apps"
        case appInBackground = "Camera not available in background"
    }
    
    //MARK: - Properties
    
    weak var delegate: CallRoomViewControllerDelegate?
    
    var contact: Contact?
    
    private let session = AVCaptureSession()
    private let captureSessionQueue = DispatchQueue(label: "captureSessionQueue")
    
    private var cameraAuthStatus: CameraAuthorizationStatus = .notAuthorized { didSet { didUpdateCameraAuthStatus() } }
    private var microphoneAuthStatus: MicrophoneAuthStatus = .notAuthorized { didSet { didUpdateMicrophoneAuthStatus() } }
    
    private var frontVideoDeviceInput: AVCaptureDeviceInput?
    private var backVideoDeviceInput: AVCaptureDeviceInput?
    @objc dynamic var currentVideoDeviceInput: AVCaptureDeviceInput?
    
    private var currentAudioDeviceInput: AVCaptureDeviceInput?
    
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var canFlipCamera: FlipCameraStatus = .off { didSet { didUpdateCanFlipCameraStatus() } }
    private var microphoneStatus: MicrophoneStatus = .off { didSet { didUpdateMicrophoneStatus() } }
    private var cameraStatus: CameraStatus = .off { didSet { didUpdateCameraStatus() } }
    
    private var cameraDisabledDescription = DescriptionText.notAuthorized
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
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
            cameraDisabledDescription = .notAuthorized
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
            cameraDisabledDescription = .noCameraAvailable
            return
        }
        
    }
    
    private func setupAudioDevices() {
        do {
            
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                microphoneAuthStatus = .notFound
                microphoneStatus = .off
                return
            }
            
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            
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
            self.addObservers()
            self.session.startRunning()
        }
    }
    
    // MARK: ViewWillDisappear
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSessionQueue.async {
            if self.cameraAuthStatus.isGranted {
                self.session.stopRunning()
                self.removeObservers()
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
        DispatchQueue.main.async {
            switch self.cameraStatus {
            case .on:
                self.blurView.isHidden = true
                self.delegate?.callRoomViewControllerDelegateSwitchButton(.video, shouldActivate: true)
            case .off:
                self.blurView.isHidden = false
                self.blurView.descriptionText = self.cameraDisabledDescription.rawValue
                self.delegate?.callRoomViewControllerDelegateSwitchButton(.video, shouldActivate: false)
            }
        }
    }
    
    //MARK: Observers
    
    private func addObservers() {
        let sessionRunningObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            self.cameraStatus = isSessionRunning && self.cameraAuthStatus.isGranted ? .on : .off
            self.cameraDisabledDescription = self.cameraAuthStatus.isNotAuthorized ? .notAuthorized : .sessionRunOut
            
        }
        keyValueObservations.append(sessionRunningObservation)
        
        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.checkThermalState),
                                                   name: ProcessInfo.thermalStateDidChangeNotification,
                                                   object: nil
            )
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: session)
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(sessionInterruptionEnded),
        name: .AVCaptureSessionInterruptionEnded,
        object: session)
        
        
    }
    
    @available(iOS 11.0, *)
    @objc func checkThermalState(notification: NSNotification) {
        let state = ProcessInfo.processInfo.thermalState
        switch state {
        case .serious, .critical:
            cameraStatus = .off
            cameraDisabledDescription = .thermalStateCritical
        case .fair, .nominal:
            cameraStatus = cameraAuthStatus.isGranted ? .on : .off
        @unknown default:
            break
        }
    }
    
    @objc func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        if error.code == .mediaServicesWereReset {
            cameraStatus = .off
            cameraDisabledDescription = .sessionError
        }
    }
    
    @objc func sessionWasInterrupted(notification: NSNotification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            if #available(iOS 11.1, *) {
                if reason == .videoDeviceNotAvailableDueToSystemPressure {
                    cameraDisabledDescription = .systemPressure
                }
            } else if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
                cameraDisabledDescription = .usedByAnotherClient
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                cameraDisabledDescription = .multipleForegroundApps
            } else if reason == .videoDeviceNotAvailableInBackground {
                cameraDisabledDescription = .appInBackground
            }
            cameraStatus = .off
        }
    }
    
    @objc func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
        
        cameraStatus = cameraAuthStatus.isGranted ? .on : .off
    }

    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
}

extension CallRoomViewController: CameraButtonsStackViewDelegate {
    
    func cameraButtonsStackViewDelegateDidTapVideoButton() {
        cameraDisabledDescription = .cameraDisabledByUser
        cameraStatus = cameraStatus == .on ? .off : .on
    }
    
    func cameraButtonsStackViewDelegateDidTapMicrophoneButton() {
        guard let currentAudioDeviceInput = currentAudioDeviceInput else {
            microphoneAuthStatus = .notFound
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
