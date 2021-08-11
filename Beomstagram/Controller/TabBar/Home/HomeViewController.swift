//
//  HomeViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var postTableView: UITableView!
    
    var allContentsModel = [AllContentModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Home ViewDidLoad")

        DatabaseManager.shared.fetchAllContents { [weak self] allContentsModel in
            self?.allContentsModel = allContentsModel
            DispatchQueue.main.async {
                self?.postTableView.reloadData()
            }
        }
       
        titleBarInsert()
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
        return allContentsModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell else {
            return UITableViewCell()
        }
        cell.profileImage.image = UIImage(named: "ong")
        cell.profileID.text = allContentsModel[indexPath.row].userInfo.id
        cell.postImage.image = allContentsModel[indexPath.row].content.image
        cell.likeCount.text = "좋아요 \(indexPath.row)개"
        cell.postComment.text = allContentsModel[indexPath.row].content.comment


        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: allContentsModel[indexPath.row].content.time ?? 0)
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

