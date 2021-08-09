//
//  HomeViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    var readImage: UIImage?
    var readComment: String?
    
    var postContentModels = [PostContentsModel]()
    
    @IBOutlet weak var postTableView: UITableView!

    class PostContentsModel {
        var userInfo = UserInfo()
        
        var cuid: String?
        var image: UIImage?
        var comment: String?
        var like: Int?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Database.database().reference()
        
        ref.child("contents").observeSingleEvent(of: DataEventType.value) { (UidSnapshot) in
            for uidSnapshot in UidSnapshot.children.allObjects as! [DataSnapshot]{
                let puid = uidSnapshot.key
                print(puid)
                for cuidSnapshot in uidSnapshot.children.allObjects as! [DataSnapshot]{
                    
                    let values = cuidSnapshot.value as! [String: Any]
                    let postContentsModel = PostContentsModel()
                    
                    URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
                        DispatchQueue.main.async {
                            postContentsModel.image = UIImage(data: data!)
                            postContentsModel.cuid = values["Cuid"] as? String
                            postContentsModel.comment = values["Comment"] as? String
                            print("@@@@@", values["Cuid"] as? String)
                        }
                    }.resume()
                    
                    ref.child("user").child(puid).child("userinfo").observeSingleEvent(of: .value) { (DataSnapshot) in
                        let values = DataSnapshot.value as? [String: Any]
                        DispatchQueue.main.async {
                            postContentsModel.userInfo.email = values?["email"] as? String ?? "nil"
                            postContentsModel.userInfo.id = values?["id"] as? String ?? "nil"
                            postContentsModel.userInfo.name = values?["name"] as? String ?? "nil"
                            postContentsModel.userInfo.follower = values?["follower"] as? Int ?? -1
                            postContentsModel.userInfo.follow = values?["follow"] as? Int ?? -1
                            print("@@@@@", values?["id"] as? String ?? "nil")
                        }
                    }
                    self.postContentModels.append(postContentsModel)
                    self.postTableView.reloadData()
                }
            }
        titleBarInsert()
    }
        
    func titleBarInsert () {
        let imageView = UIImageView(frame: CGRect(x: -100, y: 0, width: 60, height: 20))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "title")
        navigationItem.titleView = imageView
    }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.postTableView.reloadData()
    }
        
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postContentModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        cell.profileImage.image = UIImage(named: "ong")
        cell.profileID.text = postContentModels[indexPath.row].userInfo.id
        cell.postImage.image = postContentModels[indexPath.row].image
        cell.likeCount.text = "좋아요 \(indexPath.row)개"
        cell.postComment.text = postContentModels[indexPath.row].comment
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

