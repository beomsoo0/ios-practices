//
//  SearchViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {

    var allContents: [ContentModel] = []
    
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
                    let content = ContentModel()

                    URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
                        content.image = UIImage(data: data!)
                        content.cuid = values["Cuid"] as? String
                        content.comment = values["Comment"] as? String
                        content.time = values["Time"] as? TimeInterval

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
                            self.searchCollectionView.reloadData()
                        }
                    }.resume()
                }
            }
        }
        
    }

}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allContents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as? SearchCell else {
            return UICollectionViewCell()
        }
        cell.searchImage.image = allContents[indexPath.item].image
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
