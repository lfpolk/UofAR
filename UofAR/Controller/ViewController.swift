//
//  ViewController.swift
//  UofAR
//
//  Created by Larson Polk on 11/21/20.
//

import UIKit

class ViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0,y: 0, width: 400, height: 400))
        imageView.image = UIImage(named: "arLaunch")
        return imageView
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.animateLaunch()
        })
    }

    // Launch screen logo animates itself out
    private func animateLaunch(){
        UIView.animate(withDuration: 1, animations: {
            let size = self.view.frame.size.width * 10
            let dx = size - self.view.frame.size.width
            let dy = self.view.frame.size.height - size
            self.imageView.frame = CGRect(x: -dx/2, y: dy/2, width: size, height: size)
            self.imageView.alpha = 0
        }, completion: {done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                let viewController = MainViewController()
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true)
                    
                })
            }
        })
    }

}

