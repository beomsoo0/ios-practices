//
//  PushContentViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/03.
//

import UIKit

class PushContentViewController: UIViewController {

    var contentImage: UIImage?
    @IBOutlet weak var pushedImage: UIImageView!
    @IBOutlet weak var pushedComment: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pushedImage.image = contentImage
        
    }
    
    @IBAction func shareSelected(_ sender: Any) {
        let homeVC = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeViewController
        
        let content = Content(image: contentImage!, comment: pushedComment.text!)
        AuthManager.shared.updateContent(content: content)
        
        homeVC.readImage = contentImage
        homeVC.readComment = pushedComment.text!
        
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        homeVC.reloadInputViews()
    }
    

}
