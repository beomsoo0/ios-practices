//
//  AirtistDetailViewController.swift
//  Artistry
//
//  Created by 김범수 on 2021/08/19.
//

import UIKit

class AirtistDetailViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    var selectedArtist: Artist!
    let moreInfoText = "Select For More Info >"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        
//        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: .none, queue: OperationQueue.main) { [weak self] _ in
//          self?.tableView.reloadData()
//        }
    }

}

