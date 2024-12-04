//
//  MovieCollectionViewCell.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var movieImagenView: SWImageView!
    @IBOutlet weak var qualificationLabel: UILabel!
    @IBOutlet weak var startImagen: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static let reuseIdentifier = "HomeViellCell"
    static let cellHeight: CGFloat = 200
    
    func configUI(movies: Movies) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        if let posterPath = movies.poster_path {
                   let imageUrl = "https://image.tmdb.org/t/p/w500/\(posterPath)"
                   ImageCacheManager.shared.loadImage(
                       with: imageUrl,
                       imageView: movieImagenView,
                       placeholder: UIImage(named: "placeholder_image") 
            )
        }
        qualificationLabel.text = String(movies.vote_average)
        titleLabel.text = movies.original_title
    }
}
