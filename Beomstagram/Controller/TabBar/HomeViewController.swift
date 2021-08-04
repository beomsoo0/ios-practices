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
    
    let userModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //parsingUserInfo()
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let userInfoAddr = ref.child("users").child(uid!)
        let contentsAddr = Database.database().reference().child(uid!).child("contents")

        // User Info 불러오기 from Database
        userInfoAddr.observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                self.userModel.id = value?["id"] as? String ?? "No ID"
                self.userModel.name = value?["name"] as? String ?? "No Name"
                self.userModel.email = value?["email"] as? String ?? "No Email"
                self.userModel.follower = value?["follower"] as? Int ?? -1
                self.userModel.follow = value?["follower"] as? Int ?? -1
            })

        print(userModel.id)
        print(userModel.follow)
        titleBarInsert()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print(userModel.id)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
        
//        cell.id.text = "bumssooooo"
//        cell.profileImage.image = UIImage(named: "ong")
        cell.mainImage.image = self.readImage
        cell.newComment.text = self.readComment
        cell.like.text = "좋아요 100개"
        return cell
    }
    
    
}

/*
extension HomeViewController {
    
    func parsingUserInfo() {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let userInfoAddr = ref.child("users").child(uid!)
        //let contentsAddr = Database.database().reference().child(uid!).child("contents")
        
        // User Info 불러오기 from Database
        userInfoAddr.observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                self.userModel.id = value?["id"] as? String ?? "No ID"
                self.userModel.name = value?["name"] as? String ?? "No Name"
                self.userModel.email = value?["email"] as? String ?? "No Email"
                self.userModel.follower = value?["follower"] as? Int ?? -1
                self.userModel.follow = value?["follower"] as? Int ?? -1
            })
 
        
        // !!저장된 Content 불러오기!!
    }
}*/


class TableCell: UITableViewCell {
    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var newComment: UILabel!
    
}
