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
        
        DatabaseManager.shared.uploadContent(image: image, content: content) { success in
            if success {
                //curUser reparsing
                DatabaseManager.shared.fetchCurrentUser{
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                        self.tabBarController?.selectedIndex = 0
                    }
                }
            }
            else {
                self.alertMessage(message: "게시물 업로드에 실패하였습니다")
            }
        }

    }
}
