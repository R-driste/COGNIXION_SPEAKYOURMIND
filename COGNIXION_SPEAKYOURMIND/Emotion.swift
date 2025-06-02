//
//  Emotion.swift
//  COGNIXION_SPEAKYOURMIND
//
//  Created by Dristi Roy on 6/1/25.
//

import Foundation
import AVFoundation
import Vision
import SwiftUI
import UIKit
import Mentalist

class CameraEmotionManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    @Published var detectedMood: VoiceMood = .calm
    
    var onMoodDetected: ((VoiceMood) -> Void)? //callback

    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        session.beginConfiguration()

        guard let camera = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("Camera not available.")
            return
        }

        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }

        session.commitConfiguration()
    }

    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }

    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    func capturePhoto() {
        startSession()
            //give small delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let settings = AVCapturePhotoSettings()
                self.photoOutput.capturePhoto(with: settings, delegate: self)
                //give substantial delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.stopSession()
                }
            }
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else {
            print("Error capturing photo: \(error?.localizedDescription ?? "unknown error")")
            return
        }
        detectEmotion(from: uiImage)
    }

    private func detectEmotion(from image: UIImage) {
        do {
            let mentalistImage = try Image(uiImage:image)
            let analysis = try Mentalist.analyze(image: mentalistImage).first!
            print("Detected Emotion: \(analysis)")
            
            let mappedMood = mapEmotionToMood(analysis.dominantEmotion.rawValue)
            print("mapped: \(mappedMood)")
            DispatchQueue.main.async {
                self.detectedMood = mappedMood
            }
        } catch {
            print("Emotion detection failed: \(error)")
            DispatchQueue.main.async {
                self.detectedMood = VoiceMood.calm
            }
        }
    }

    private func mapEmotionToMood(_ emotion: String) -> VoiceMood {
        print("input: \(emotion)")
        switch emotion.lowercased() {
            case "happy", "surprise": return .happy
            case "sad": return .sad
            case "angry", "disgust": return .angry
            case "neutral", "fear": return .calm
            default: return .calm
        }
    }

    func getSession() -> AVCaptureSession {
        return session
    }
}
