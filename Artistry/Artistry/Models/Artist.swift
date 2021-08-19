//
//  Artist.swift
//  Artistry
//
//  Created by 김범수 on 2021/08/19.
//

import UIKit

struct Artist {
    let name: String
    let bio: String
    let image: UIImage
    var works: [Work]
    
    init(name: String, bio: String, image: UIImage, works: [Work]) {
        self.name = name
        self.bio = bio
        self.image = image
        self.works = works
    }
    
    static func fetchArtistsFormBundle() -> [Artist] {
        
        var artists = [Artist]()
        
        guard let url = Bundle.main.url(forResource: "artists", withExtension: ".json") else {
            return artists
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard let rootObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return artists }
            
            guard let artistObjects = rootObject["artists"] as? [[String: AnyObject]] else { return artists }
            
            for artistObject in artistObjects {
                
                if let name = artistObject["name"] as? String,
                   let bio = artistObject["bio"] as? String,
                   let imageName = artistObject["image"] as? String,
                   let image = UIImage(named: imageName),
                   let workObjects = artistObject["works"] as? [[String: String]] {
                    var works = [Work]()
                    for workObejct in workObjects {
                        if let title = workObejct["title"],
                           let imageName = workObejct["image"],
                           let image = UIImage(named: imageName + ".jpg"),
                           let info = workObejct["info"] {
                            works.append(Work(title: title, image: image, info: info, isExpanded: false))
                        }
                    }
                    let artist = Artist(name: name, bio: bio, image: image, works: works)
                    artists.append(artist)
                }
            }
        } catch {
            return artists
        }
        return artists
        
    }
    
}
