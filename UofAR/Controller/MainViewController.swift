//
//  MainViewController.swift
//  UofAR
//
//  Created by Larson Polk on 11/29/20.
//
import AVKit
import UIKit
import Vision


class MainViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var anchorLabels = [UUID: String]()
    private var identifierString = ""
    private var confidence: VNConfidence = 0.0
    var landmarks = [String: Landmark]()
    var message = ""
    let isUserInteractionEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()

        // Open camera
        
        let captureSession = AVCaptureSession()
        
        guard
            let captureDevice = AVCaptureDevice.default(for:
                .video) else { return }
        
        guard
            let input = try? AVCaptureDeviceInput(device:
                captureDevice) else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(preview)
        preview.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue:
            DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("Camera was able to capture a frame:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: UofAR().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            
            if let bestResult = results.first(where: { result in result.confidence > 0.5 }),
                let label = bestResult.identifier.split(separator: ",").first {
                self.identifierString = String(label)
                self.confidence = bestResult.confidence
                guard let landmark = self.landmarks[self.identifierString] else { return }
                self.message = landmark.description
            } else {
                self.message = "No object detected."
                self.confidence = 0
            }

        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    // Detect screen touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let landmark = self.landmarks[self.identifierString] else { return }
        
        if landmark.marked < 1 {
            self.showName(message: landmark.name)
            self.showDescription(message: landmark.description)
        }
        
        }
    
    
    // Retrieve data from landmarks.json
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "landmarks", withExtension: "json") else {
            fatalError("Unable to find JSON in bundle")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load JSON")
        }

        let decoder = JSONDecoder()

        guard let loadedLandmarks = try? decoder.decode([String: Landmark].self, from: data) else {
            fatalError("Unable to parse JSON.")
        }
        
        landmarks = loadedLandmarks

    }
    
    // Following two functions pop up UILabel with the information passed to it

    func showName(message: String){
        DispatchQueue.main.async {
            let toastLabel = UILabel()
            toastLabel.text = message
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont.systemFont(ofSize: 18)
            toastLabel.textColor = UIColor.white
            toastLabel.backgroundColor = UIColor.red.withAlphaComponent(0.6)
            toastLabel.numberOfLines = 0
            
            
            let textSize = toastLabel.intrinsicContentSize
            let labelHeight = ( textSize.width / self.view.frame.width ) * 35
            let labelWidth = min(textSize.width, self.view.frame.width - 40)
            let adjustedHeight = max(labelHeight, textSize.height + 20)
            
            toastLabel.frame = CGRect(x: 20, y: 120, width: labelWidth + 20, height: adjustedHeight)
            toastLabel.center.x = self.view.center.x
            toastLabel.layer.cornerRadius = 10
            toastLabel.layer.masksToBounds = true
                   self.view.addSubview(toastLabel)
                   
                   UIView.animate(withDuration: 4.0, delay: 10.0, options: .curveEaseInOut, animations: {
                       toastLabel.alpha = 0.0
                   }) { (isCompleted) in
                   toastLabel.removeFromSuperview()
               }
        }
    }
    
    func showDescription(message: String){
        DispatchQueue.main.async {
            let toastLabel = UILabel()
            toastLabel.text = message
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont.systemFont(ofSize: 18)
            toastLabel.textColor = UIColor.white
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.numberOfLines = 0
            
            
            let textSize = toastLabel.intrinsicContentSize
            let labelHeight = ( textSize.width / self.view.frame.width ) * 35
            let labelWidth = min(textSize.width, self.view.frame.width - 45)
            let adjustedHeight = max(labelHeight, textSize.height + 20)
            
            toastLabel.frame = CGRect(x: 20, y: (self.view.frame.height - 90 ) - adjustedHeight, width: labelWidth + 25, height: adjustedHeight)
            toastLabel.center.x = self.view.center.x
            toastLabel.layer.cornerRadius = 10
            toastLabel.layer.masksToBounds = true
                   self.view.addSubview(toastLabel)
                   
                   UIView.animate(withDuration: 4.0, delay: 10.0, options: .curveEaseInOut, animations: {
                       toastLabel.alpha = 0.0
                   }) { (isCompleted) in
                   toastLabel.removeFromSuperview()
               }
        }
       
    }

}
