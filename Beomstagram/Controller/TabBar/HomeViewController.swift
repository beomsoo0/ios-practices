//
//  HomeViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

class HomeViewController: UIViewController {

    var readImage: UIImage?
    var readComment: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleBarInsert()
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

class TableCell: UITableViewCell {
    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var like: UILabel!
    @IBOutlet weak var newComment: UILabel!
    
}
