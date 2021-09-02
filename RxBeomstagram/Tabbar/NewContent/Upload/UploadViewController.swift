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

                var curUser = User()
                var allPosts = [Post]()
                var allUsers = [User]()
                do{
                    curUser = try User.currentUserRx.value()
                    allPosts = try Post.allPostsRx.value()
                    allUsers = try User.allUserRx.value()
                } catch { }
                let post = Post(user: curUser, cuid: uid, image: image, content: content ?? "")
                curUser.posts.insert(post, at: 0)
                allPosts.insert(post, at: 0)
                allUsers.forEach({
                    if $0.uid == uid {
                        $0.posts.insert(post, at: 0)
                    }
                })
                
                User.currentUserRx.onNext(curUser)
                Post.allPostsRx.onNext(allPosts)
                User.allUserRx.onNext(allUsers)

                self.navigationPopToTabbarIdx(idx: 0)
            }
            else {
                self.alertMessage(message: "게시물 업로드에 실패하였습니다")
            }
        }

    }
}
