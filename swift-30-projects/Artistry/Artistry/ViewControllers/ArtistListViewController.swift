//
//  ViewController.swift
//  Artistry
//
//  Created by 김범수 on 2021/08/19.
//

import UIKit

class ArtistListViewController: UIViewController {

    let artists = Artist.fetchArtistsFormBundle()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        
        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: .none, queue: OperationQueue.main) { [weak self] _ in
          self?.tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AirtistDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            dest.selectedArtist = artists[indexPath.row]
        }
    }
}

