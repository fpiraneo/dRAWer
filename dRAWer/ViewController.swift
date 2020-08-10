//
//  ViewController.swift
//  dRAWer
//
//  Created by Francesco Piraneo G. on 08.08.20.
//  Copyright © 2020 Francesco Piraneo G. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!

    var photoOutput = AVCapturePhotoOutput()
    var photoSettings: AVCapturePhotoSettings?
    var captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var previewFrameView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        runPreview()
        setupCamera()
    }

    private func runPreview() {
        // Get the back-facing camera for capturing videos
        self.captureSession = AVCaptureSession()
        
        guard let cam = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: cam) else {
            let alert = UIAlertController(title: "Camera unavailable", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { (action) in
                self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.captureDevice = cam
        
        // Set the input device on the capture session.
        captureSession.addInput(input)

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        videoPreviewLayer?.frame = cameraView.layer.bounds
        cameraView.layer.addSublayer(videoPreviewLayer!)
        captureSession.startRunning()

        if self.captureSession.canAddOutput(photoOutput) {
            self.captureSession.addOutput(photoOutput)
        }
    }
    
    private func setupCamera() {
        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }

        photoSettings?.flashMode = .off

//        photoSettings?.isAutoStillImageStabilizationEnabled = self.photoOutput.isStillImageStabilizationSupported
    }
    
    @IBAction func doShot(_ sender: Any) {
        shot()
    }
    
    private func shot() {
        DispatchQueue.main.async {
//            let captureProcessor = PhotoCaptureProcessor()
            self.photoOutput.capturePhoto(with: self.photoSettings!, delegate: self)
        }
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoData = photo.fileDataRepresentation() else {
            NSLog("Photo data not available!")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photoData, options: nil)
                
            }) { (success, error) in
                if success  {
                    NSLog("Successfully saved picture to gallery!")
                } else {
                    NSLog("Error saving to gallery: \(error?.localizedDescription ?? "No error description")")
                }
                
                self.setupCamera()
            }
            
        }
    }
}
