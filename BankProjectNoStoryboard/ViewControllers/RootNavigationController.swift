//
//  File.swift
//  BankProjectNoStoryboard
//
//  Created by Lukas Navickas on 2023-04-24.
//

import UIKit

class RootNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
//        navigationBar.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
