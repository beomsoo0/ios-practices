//
//  ArtistListTableView.swift
//  Artistry
//
//  Created by 김범수 on 2021/08/19.
//

import UIKit

extension ArtistListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else { return UITableViewCell() }
        let artist = artists[indexPath.row]
        cell.artistImageView.image = artist.image
        cell.nameLabel.text = artist.name
        cell.bioLabel.text = artist.bio
        return cell
    }
    
}
