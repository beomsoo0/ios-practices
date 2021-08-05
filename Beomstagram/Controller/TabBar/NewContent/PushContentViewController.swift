//
//  PushContentViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/03.
//

import UIKit

// View
class PushContentViewController: UIViewController {

    var contentImage: UIImage?
    @IBOutlet weak var pushedImage: UIImageView!
    @IBOutlet weak var pushedComment: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pushedImage.image = contentImage
        
    }
    
    @IBAction func shareSelected(_ sender: Any) {
        shareContent()
    }
}

// View Model
extension PushContentViewController {
    private func shareContent() {
        DatabaseManager.shared.uploadContent(image: pushedImage.image!, comment: pushedComment.text!) { success in
            if success {
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
}
