//
//  HomeViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController {

    var readImage: UIImage?
    var readComment: String?
    
    let userModel = UserModel.shared
    let allUserModel = AllUserModel.shared
    
    @IBOutlet weak var postView: UITableView!
    
    @IBAction func reload(_ sender: Any) {
        postView.reloadData()
        //print("Home image count: ", userModel.contents.count)
        print("allUserModel : ", allUserModel.userModels.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseManager.shared.loadAllUserModel()
        titleBarInsert()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postView.reloadData()
    }

    func titleBarInsert () {
        let imageView = UIImageView(frame: CGRect(x: -100, y: 0, width: 60, height: 20))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "title")
        navigationItem.titleView = imageView
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let userCount = allUserModel.userModels.count
//        var allContentCount: Int = 0
//        var i: Int = 0
//        while i < userCount {
//            allContentCount += allUserModel.userModels[0].contents.count
//        }
//        print(allContentCount)
        if allUserModel.userModels.count >= 1 {
            let userCount = allUserModel.userModels.count
            var allContentCount: Int = 0
            var i: Int = 0
            while i < userCount {
                allContentCount += allUserModel.userModels[i].contents.count
                i += 1
            }
            return allContentCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        if allUserModel.userModels.count >= 1 {
            var allContentCount: Int = 0
            var user: Int = 0
            let userCount = allUserModel.userModels.count
            while user < userCount {
                var content: Int = 0
                let contentsCount: Int = allUserModel.userModels[user].contents.count
                while content < contentsCount {
                    if allContentCount == indexPath.row {
                        cell.profileID.text = allUserModel.userModels[user].userInfo?.id
                        cell.profileImage.image = UIImage(named: "ong")
                        cell.postImage.image = allUserModel.userModels[user].contents[content].image
                        cell.likeCount.text = "좋아요 123개"
                        cell.postComment.text = allUserModel.userModels[user].contents[content].comment
                    }
                    content += 1
                    allContentCount += 1
                }
                user += 1
            }
        }
        
        return cell
    }
    
    
}


class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileID: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var postComment: UILabel!
}
