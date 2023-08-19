//
//  LaunchScreenVC.swift
//  Mankepri
//
//  Created by Maulana Frasha on 17/08/21.
//

import Foundation
import UIKit
import LocalAuthentication

class MasukVC: UIViewController{
    
    
    @IBOutlet weak var buttonmasuk: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonmasuk.layer.cornerRadius = 20.0
    }
    
    @IBAction func buttonmasukaction(_ sender: Any) {
        faceidlogin()
    }
    
    
    //MARK: - faceid func
        func faceidlogin(){
            let contect = LAContext()
            var error: NSError? = nil
            if contect.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
                let reason = "Masuk dengan Face ID"
                contect.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                    [weak self] success, error in DispatchQueue.main.async {
                        guard success, error == nil else { return }
                        //show home screen
                        self?.performSegue(withIdentifier: "kehome", sender: self)}}
            } else {
                // dont have biometric
                let alert = UIAlertController(title: "Tidak bisa menggunakan Face ID", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: nil))
                present(alert, animated: true)
            }
        }//end of faceid func
    
}
