//
//  UploadViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit

class UploadViewController: UIViewController {

    // MARK - Variables
    var recieveImage: UIImage?
    
    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = recieveImage
    }

    //MARK - Outlets
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var contentField: UITextField!
    
    @IBAction func cancelSelected(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func completeSelected(_ sender: Any) {
        
        guard let image = recieveImage else { return }
        let content = contentField.text
        
        DatabaseManager.shared.uploadPost(image: image, content: content) { success in
            if success {
                //curUser reparsing
                guard let uid = AuthManager.shared.currentUid() else { return }
                
                DatabaseManager.shared.fetchUser(uid: uid) { user in
                    User.currentUser = user
                    self.navigationPopToTabbarIdx(idx: 0)
                }
            }
            else {
                self.alertMessage(message: "게시물 업로드에 실패하였습니다")
            }
        }

    }
}
