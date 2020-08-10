//
//  PhotoCaptureProcessor.swift
//  dRAWer
//
//  Created by Francesco Piraneo G. on 08.08.20.
//  Copyright © 2020 Francesco Piraneo G. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
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
            }
            
        }
    }
}
