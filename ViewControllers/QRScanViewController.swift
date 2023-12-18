//
//  QRScanViewController.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/13/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import UIKit
import AVFoundation

class QRScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    
    //The text attributes
    let defaultTextAttributes = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.strokeWidth : -4.0]
        as [NSAttributedString.Key : Any]
    
    let errorTextAttributes = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.red,
        NSAttributedString.Key.strokeWidth : -4.0]
        as [NSAttributedString.Key : Any]
    
    let goodTextAttributes = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.green,
        NSAttributedString.Key.strokeWidth : -4.0]
        as [NSAttributedString.Key : Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        var frame = self.view.layer.bounds
        frame.origin.y = 0
        frame.size.height = frame.size.height-self.tabBarController!.tabBar.frame.size.height
        previewLayer.frame = frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        //dismiss(animated: true)
    }

    func found(code: String) {}

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}


