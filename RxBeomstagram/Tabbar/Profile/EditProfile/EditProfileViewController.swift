//
//  EditProfileViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//

import UIKit

class EditProfileViewController: UIViewController {

    // MARK - Variables
    var user = User.currentUser
    var changeImage: UIImage?

    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        setDefaultProfile()
        profileImage.layer.cornerRadius = profileImage.bounds.width * 0.5
    }
    
    // MARK - UI Functions
    func setDefaultProfile() {
        if let image = changeImage {
            profileImage.image = image
        } else {
            
            profileImage.image = user.profileImage
        }
        name.text = user.name
        id.text = user.id
        descriptionLabel.text = user.description
    }
    
    // MARK - Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var descriptionLabel: UITextField!
    
    @IBAction func completeSeleted(_ sender: Any) {
        guard profileImage.image != UIImage(named: "default_profile"), descriptionLabel.text != nil,
              name.text != nil, id.text != nil else {
            alertMessage(message: "프로필 변경 항목을 입력해주세요")
            return
        }
        DatabaseManager.shared.editProfile(image: profileImage.image!, description: descriptionLabel.text!, name: name.text!, id: id.text!) { success in
            if success {
                guard let uid = AuthManager.shared.currentUid() else { return }
                
                var curUser = User()
                var allPosts = [Post]()
                var allUsers = [User]()
                do{
                    curUser = try User.currentUserRx.value()
                    allPosts = try Post.allPostsRx.value()
                    allUsers = try User.allUserRx.value()
                } catch { }
                curUser.profileImage = self.profileImage.image!
                curUser.description = self.descriptionLabel.text!
                curUser.name = self.name.text!
                curUser.id = self.id.text!
                
                allPosts.forEach({ post in
                    if post.user.uid == uid {
                        post.user = curUser
                    }
                })
                
                allUsers = allUsers.filter { $0.uid != uid }
                allUsers.insert(curUser, at: 0)
                
                User.currentUserRx.onNext(curUser)
                Post.allPostsRx.onNext(allPosts)
                User.allUserRx.onNext(allUsers)
                
                self.navigationPopToTabbarIdx(idx: 4)
                
            } else {
                self.alertMessage(message: "프로필 업로드에 실패했습니다")
            }
        }
    }

    @IBAction func changeSeleted(_ sender: Any) {
        guard let GalleryVC = self.storyboard?.instantiateViewController(identifier: "GalleryVC") as? GalleryViewController else { return }
        GalleryVC.EditProfileViewControllerDelegate = self
        self.navigationController?.pushViewController(GalleryVC, animated: true)
    }
    
}
