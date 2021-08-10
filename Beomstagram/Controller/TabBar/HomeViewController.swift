//
//  HomeViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    var allContents: [ContentModel] = []
    
    @IBOutlet weak var postTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ref = Database.database().reference()

        ref.child("contents").observeSingleEvent(of: DataEventType.value) { (UidSnapshot) in
            for uidSnapshot in UidSnapshot.children.allObjects as! [DataSnapshot]{
                let puid = uidSnapshot.key
                print(puid)
                for cuidSnapshot in uidSnapshot.children.allObjects as! [DataSnapshot]{

                    let values = cuidSnapshot.value as! [String: Any]
                    var content = ContentModel()

                    URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
                        content.image = UIImage(data: data!)
                        content.cuid = values["Cuid"] as? String
                        content.comment = values["Comment"] as? String
                        content.time = values["Time"] as! TimeInterval

                        ref.child("userinfo").child(puid).observeSingleEvent(of: .value) { (DataSnapshot) in
                            let values = DataSnapshot.value as? [String: Any]

                            content.userInfo.email = values?["email"] as? String ?? "nil"
                            content.userInfo.id = values?["id"] as? String ?? "nil"
                            content.userInfo.name = values?["name"] as? String ?? "nil"
                            content.userInfo.follower = values?["follower"] as? Int ?? -1
                            content.userInfo.follow = values?["follow"] as? Int ?? -1
                        }
                        self.allContents.append(content)
                        DispatchQueue.main.async {
                            self.postTableView.reloadData()
                        }
                    }.resume()
                }
            }
        }

        titleBarInsert()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.postTableView.reloadData()
    }

    func titleBarInsert () {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "title")
        navigationItem.titleView = imageView
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell else {
            return UITableViewCell()
        }
        cell.profileImage.image = UIImage(named: "ong")
        cell.profileID.text = allContents[indexPath.row].userInfo.id
        cell.postImage.image = allContents[indexPath.row].image
        cell.likeCount.text = "좋아요 \(indexPath.row)개"
        cell.postComment.text = allContents[indexPath.row].comment
        

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: allContents[indexPath.row].time ?? 0)
        cell.postTime.text = dateFormatter.string(from: date)

        return cell
    }
    
}


class PostCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileID: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var postComment: UILabel!
    
    @IBOutlet weak var postTime: UILabel!
}

