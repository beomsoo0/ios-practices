//
//  EditProfileViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/10.
//

import UIKit
import Firebase
import FirebaseStorage

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var comment: UITextField!
    
    var receiveImage: UIImage?
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        setProfileImage()
    }
    
    @IBAction func completeSeleted(_ sender: Any) {
        DatabaseManager.shared.uploadProfile(image: receiveImage!, comment: comment.text ?? "") { success in
            if success {
                let profileVC = self.storyboard?.instantiateViewController(identifier: "ProfileVC") as! ProfileViewController
                profileVC.viewDidLoad()
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 4
            }
            else {
                let alert = UIAlertController(title: "업로드 실패", message: "프로필 업로드에 실패했습니다", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelSeleted(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func photoSeleted(_ sender: Any) {
    }
    
    func otherViewDidLoad() {
        let homeVC = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeViewController
        let searchVC = self.storyboard?.instantiateViewController(identifier: "SearchVC") as! SearchViewController
        let profileVC = self.storyboard?.instantiateViewController(identifier: "ProfileVC") as! ProfileViewController
        homeVC.viewDidLoad()
        searchVC.viewDidLoad()
        profileVC.viewDidLoad()
    }
    
    func setProfileImage() {
        DispatchQueue.main.async {
            if self.receiveImage == nil {
                self.profileImage.image = UIImage(named: "default_profile")
            } else {
                self.profileImage.image = self.receiveImage
            }
        }
    }
    
}
