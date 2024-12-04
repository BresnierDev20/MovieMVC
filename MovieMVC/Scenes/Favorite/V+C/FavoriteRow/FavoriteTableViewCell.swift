//
//  FavoriteTableViewCell.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 2/12/24.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    @IBOutlet weak var imageMovieFavorite: UIImageView!
    @IBOutlet weak var favoriteTitle: UILabel!
    @IBOutlet weak var numberCalafication: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    static let reuseIdentifier = "FavoriteViellCell"
       static let cellHeight: CGFloat = 100

       // Vista contenedora para el contenido de la celda
    

       override func awakeFromNib() {
           super.awakeFromNib()
           setupContainerView()
       }

       private func setupContainerView() {
           // Agregar la vista contenedora al contentView
           containerView.translatesAutoresizingMaskIntoConstraints = false
           contentView.addSubview(containerView)

           // Configurar restricciones para crear margen
           NSLayoutConstraint.activate([
               containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
               containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
               containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
               containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
           ])

           // Configurar fondo y bordes
//           containerView.backgroundColor = .white
           containerView.layer.cornerRadius = 12
           containerView.layer.masksToBounds = false

           // Configurar sombra
           containerView.layer.shadowColor = UIColor.black.cgColor
           containerView.layer.shadowOpacity = 0.2
           containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
           containerView.layer.shadowRadius = 4

           // Aplicar la sombra al contentView
           contentView.layer.masksToBounds = false
       }

       func configUI(movies: Movies) {
           if let posterPath = movies.poster_path {
               let imageUrl = "https://image.tmdb.org/t/p/w500/\(posterPath)"
               ImageCacheManager.shared.loadImage(
                   with: imageUrl,
                   imageView: imageMovieFavorite,
                   placeholder: UIImage(named: "placeholder_image")
               )
           }
           numberCalafication.text = String(movies.vote_average)
           favoriteTitle.text = movies.original_title
       }
   
}
