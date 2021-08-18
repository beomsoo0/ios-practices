//
//  UploadViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit

class UploadViewController: UIViewController {

    var recieveImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = recieveImage
    }


    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var contentField: UITextField!
    @IBAction func cancelSelected(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func completeSelected(_ sender: Any) {
        guard let image = recieveImage, let content = contentField.text else { return }
        DatabaseManager.uploadContent(image: image, content: content) { success in
            if success {
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
            }
            else {
                self.alertMessage(title: "게시물 업로드 오류", message: "게시물 업로드에 실패하였습니다")
            }
        }
        
    }
}
