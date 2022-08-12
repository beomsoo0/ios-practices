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
    @IBOutlet weak var storyCollectionView: UICollectionView!
    
    var homeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Home ViewDidLoad")

        homeViewModel.loadPostModel {
            DispatchQueue.main.async {
                self.postTableView.reloadData()
            }
        }
        homeViewModel.loadStoryModel {
            DispatchQueue.main.async {
                self.storyCollectionView.reloadData()
            }
        }
        titleBarInsert()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Home viewWillAppear")
        DispatchQueue.main.async {
            self.postTableView.reloadData()
            self.storyCollectionView.reloadData()
        }
    }

    @IBAction func profileIDSeleted(_ sender: UIButton) {
        let profileView = sender.superview
        let contentView = profileView?.superview
        let cell = contentView?.superview as! PostCell//UITableViewCell
        let idx = cell.idx
        print("@@@", idx)
    
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
        return homeViewModel.postModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell else {
            return UITableViewCell()
        }
        cell.profileImage.image = UIImage(named: "ong")
        //둥글게
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.width/3
        cell.profileImage.clipsToBounds = true
        
        cell.profileID.setTitle(homeViewModel.postModel[indexPath.row].userInfo.id, for: .normal)
        //text = homeViewModel.postModel[indexPath.row].userInfo.id
        cell.postImage.image = homeViewModel.postModel[indexPath.row].content.image
        cell.likeCount.text = "좋아요 \(indexPath.row)개"
        cell.postComment.text = homeViewModel.postModel[indexPath.row].content.comment


        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
        let date = Date(timeIntervalSince1970: homeViewModel.postModel[indexPath.row].content.time ?? 0)
        cell.postTime.text = dateFormatter.string(from: date)

        cell.idx = indexPath.row
        
        return cell
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeViewModel.storyModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as? StoryCell else {
            return UICollectionViewCell()
        }
        cell.storyProfile.image = homeViewModel.storyModel[indexPath.item].content.image
        cell.storyID.text = homeViewModel.storyModel[indexPath.item].userInfo.id

        //둥글게
        cell.storyProfile.layer.cornerRadius = cell.storyProfile.frame.width/3
        cell.storyProfile.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let itemSpacing: CGFloat = 10
        let height: CGFloat = collectionView.bounds.height * 2 / 3
        let width = height
        return CGSize(width: width, height: height)
    }
    
    
    
}

protocol PostCellDelegate {
    func profileIDSeleted()
}

class PostCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileID: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var postComment: UILabel!
    @IBOutlet weak var postTime: UILabel!
    
    var idx: Int = 0
    var delegate: PostCellDelegate?
    
}

class StoryCell: UICollectionViewCell {
    
    @IBOutlet weak var storyProfile: UIImageView!
    @IBOutlet weak var storyID: UILabel!
    
    
}
