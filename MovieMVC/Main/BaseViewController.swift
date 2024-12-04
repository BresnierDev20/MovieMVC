//
//  ViewController.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }

    func hideBackButton() {
        self.navigationItem.setHidesBackButton(true, animated: true)
    }

    func setupBackButton() {
        let backButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(self.backButtonClickedDismiss(sender:)))
        backButtonItem.tintColor = UIColor.blue
        backButtonItem.width = 10
       
        self.navigationItem.leftBarButtonItem = backButtonItem
    }

    @objc func backButtonClickedDismiss(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
