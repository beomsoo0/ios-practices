//
//  EditProfileViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/10.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var comment: UITextField!
    
    let currentUser = UserModel.shared
    var changeImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Edit ViewDidLoad")
        setDefaultProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Edit ViewWillAppear")
        profileImage.image = changeImage
    }
    
    @IBAction func completeSeleted(_ sender: Any) {
        if profileImage.image == UIImage(named: "default_profile") || comment == nil || name == nil || id == nil {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "프로필 변경 실패", message: "프로필 변경 항목을 입력해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
       
        DatabaseManager.shared.editProfile(image: profileImage.image!, comment: comment.text!, name: name.text!, id: id.text!) { success in
            if success {
                DatabaseManager.shared.fetchCurrentUserModel(userModel: self.currentUser, completion: {
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                        self.tabBarController?.selectedIndex = 4
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "업로드 실패", message: "프로필 업로드에 실패했습니다", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func changeSeleted(_ sender: Any) {
        guard let GalleryVC = self.storyboard?.instantiateViewController(identifier: "GalleryVC") as? GalleryViewController else { return }
        GalleryVC.EditProfileViewControllerDelegate = self
        self.navigationController?.pushViewController(GalleryVC, animated: true)
    }
    
    
    @IBAction func cancelSeleted(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func photoSeleted(_ sender: Any) {
    }
    
    func setDefaultProfile() {
        changeImage = currentUser.content.image
        profileImage.image = currentUser.content.image
        name.text = currentUser.userInfo.name
        id.text = currentUser.userInfo.id
        comment.text = currentUser.content.comment
    }
    
}
