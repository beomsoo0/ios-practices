//
//  ArtistDetailTableView.swift
//  Artistry
//
//  Created by 김범수 on 2021/08/19.
//

import UIKit

extension AirtistDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedArtist.works.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else { return UITableViewCell() }
        let work = selectedArtist.works[indexPath.row]
        cell.artistImageView.image = work.image
        cell.nameLabel.text = work.title
        cell.infoLabel.text = work.info
        return cell
    }
}
