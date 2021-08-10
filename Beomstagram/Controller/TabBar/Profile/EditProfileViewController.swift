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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        print(receiveImage)
        profileImage.image = receiveImage
    }

    @IBAction func completeSeleted(_ sender: Any) {
        
        let uid = AuthManager.shared.currentUid()
        let cuid = ref.child("profileImage").child(uid!).childByAutoId().key
        let dataImage = (receiveImage?.jpegData(compressionQuality: 0.1)!)!
        let imageRef = Storage.storage().reference().child("profileImage").child(uid!).child(cuid!)
        
        // Upload Storage
        imageRef.putData(dataImage, metadata: nil) { (StorageMetadata, error) in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            imageRef.downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    print(error.debugDescription)
                    return
                }
                self.url = url
                return
            }
        }
  
        ref.child("userinfo").child(uid!).updateChildValues(["name": self.name.text as Any, "id": self.id.text, "comment": self.comment.text, "profileImageUrl": self.url?.absoluteString])
        self.navigationController?.popToRootViewController(animated: true)
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func photoSeleted(_ sender: Any) {
    }
}
