//
//  SearchViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {

    var postContentModels = [PostContentsModel]()
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
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
                    self.searchCollectionView.reloadData()
                }
            }
        }
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchCollectionView.reloadData()
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postContentModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        cell.searchImage.image = postContentModels[indexPath.item].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 3
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
}

class SearchCell: UICollectionViewCell {
    
    @IBOutlet weak var searchImage: UIImageView!
    
   // var content: ContentModel
}
