//
//  InfoVC.swift
//  Mankepri
//
//  Created by Maulana Frasha on 18/07/21.
//

import Foundation
import UIKit

class InfoVC: UIViewController {

    @IBOutlet weak var profilePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width/2
        
    }

}
