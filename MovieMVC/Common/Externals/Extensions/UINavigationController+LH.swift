//
//  UINavigationController+LH.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import Foundation
import UIKit

extension UINavigationController {
    func removeViewController(_ controller: UIViewController.Type) {
        if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            viewController.removeFromParent()
        }
    }
        
    func clearBackground(){
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.backgroundColor = .clear
        self.view.backgroundColor = .clear
    }
    
    func setBackground(){
        
        let color: UIColor = .red
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = false
        self.navigationBar.backgroundColor = color
        self.navigationBar.barTintColor = color
        self.view.backgroundColor = color
    }

}
