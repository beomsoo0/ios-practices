//
//  ViewController.swift
//  CandySearch
//
//  Created by 김범수 on 2021/08/19.
//

import UIKit

class CandyViewController: UIViewController {

    // MARK: - Variables
    var candies = [Candy]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCandy: [Candy] = []
    var isFiltered: Bool {
        let isActive = searchController.isActive == true
        let isSearchBarHasText = searchController.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        candies = [
            Candy(category:"Chocolate", name:"Chocolate Bar"),
            Candy(category:"Chocolate", name:"Chocolate Chip"),
            Candy(category:"Chocolate", name:"Dark Chocolate"),
            Candy(category:"Hard", name:"Lollipop"),
            Candy(category:"Hard", name:"Candy Cane"),
            Candy(category:"Hard", name:"Jaw Breaker"),
            Candy(category:"Other", name:"Caramel"),
            Candy(category:"Other", name:"Sour Chew"),
            Candy(category:"Other", name:"Gummi Bear")
        ]
        updateSearchUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination as? DetailViewController else { return }
        let indexPath = tableView.indexPathForSelectedRow
        detailVC.candy = candies[indexPath?.row ?? 0]
    }

    // MARK: - Search UI
    func updateSearchUI() {
        // scope bar
        searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
        searchController.searchBar.showsScopeBar = true
        
        // 검색 결과 self 업데이트
        searchController.searchResultsUpdater = self
        
        //title large
        self.navigationItem.title = "Candy Search"
        
        self.navigationItem.searchController = searchController
    }
    
}

extension CandyViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text?.lowercased()
        let scope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
        
        self.filteredCandy = candies.filter({ candy in
            scope == "All" || candy.category == scope
        }).filter({ candy in
            text == "" || candy.name.lowercased().contains(text!)
        })

        self.tableView.reloadData()
        dump(filteredCandy)
    }
    
    
}



extension CandyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltered ? filteredCandy.count : candies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CandyCell") else { return UITableViewCell() }
        
        let candy = isFiltered ? filteredCandy[indexPath.row] : candies[indexPath.row]
        cell.textLabel!.text = candy.name
        return cell
    }
    
}

