//
//  PushContentViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/03.
//

import UIKit

// View
class PushContentViewController: UIViewController {
    
    @IBOutlet weak var pushedImage: UIImageView!
    @IBOutlet weak var pushedComment: UITextField!

    var contentImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pushedImage.image = contentImage
    }
    
    @IBAction func shareSelected(_ sender: Any) {
        
        DatabaseManager.shared.uploadContent(image: pushedImage.image!, comment: pushedComment.text!) { success in
            if success {
                self.otherViewDidLoad()
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
            }
            else {
                let alert = UIAlertController(title: "업로드 실패", message: "게시물 업로드에 실패했습니다", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func otherViewDidLoad() {
        let homeVC = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeViewController
        let searchVC = self.storyboard?.instantiateViewController(identifier: "SearchVC") as! SearchViewController
        let profileVC = self.storyboard?.instantiateViewController(identifier: "ProfileVC") as! ProfileViewController
        homeVC.viewDidLoad()
        searchVC.viewDidLoad()
        profileVC.viewDidLoad()
    }
}
