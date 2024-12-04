//
//  DetailViewController.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 7/11/24.
//

import UIKit

class DetailViewController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var languajesLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UITextView!
    @IBOutlet weak var imageDetailView: SWImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var moviesData: Movies?
   
    var movie: [Movies] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialData(movies: moviesData)
        
        movie = CoreDataManager.shared.fetchMovies()
        setupBackButton()
        
        // Verificar si la película está en favoritos
        isButtonFavorite()
        
        // Actualizar la imagen del botón basado en el estado inicial
        actualizarImagenBoton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        isButtonFavorite()
    }
  
    
    func isButtonFavorite() {
        MVSettings.current.isButtonFavorite = movie.contains { $0.id == moviesData?.id }
        
        actualizarImagenBoton()
    
    }
    
    func loadInitialData(movies: Movies?) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        if let posterPath = movies?.poster_path {
            let imageUrl = "https://image.tmdb.org/t/p/w500/\(posterPath)"
            ImageCacheManager.shared.loadImage(
                with: imageUrl,
                imageView: imageDetailView,
                placeholder: UIImage(named: "placeholder_image")
            )
        }
        
        averageLabel.text = String(movies!.vote_average)
        titleLabel.text = movies?.original_title
        languajesLabel.text = movies?.original_language
        votesLabel.text = String(movies!.vote_count)
        popularityLabel.text = String(movies!.popularity)
        synopsisLabel.text = movies?.overview
        
        if let date = dateFormatterGet.date(from: "\(movies?.release_date ?? "")") {
            releaseLabel.text = dateFormatterPrint.string(from: date)
        } else {
            print("There was an error decoding the string")
        }
    }
    
    func actualizarImagenBoton() {
        let nuevaImagen = UIImage(systemName: MVSettings.current.isButtonFavorite  ? "bookmark.fill" : "bookmark")
        favoriteButton.setImage(nuevaImagen, for: .normal)
    }
    
    @IBAction func favoriteActionOnClick(_ sender: UIButton) {
        guard let movieList = moviesData else { return }

        if MVSettings.current.isButtonFavorite  {
            // Eliminar la película de favoritos
            CoreDataManager.shared.deleteMovieFromCoreData(movie: movieList)
        } else {
            // Guardar la película en favoritos
            CoreDataManager.shared.saveData(movie: movieList)
        }
        
        // Cambiar el estado de favorito
        MVSettings.current.isButtonFavorite .toggle()
        // Actualizar la imagen del botón
        actualizarImagenBoton()
    }
}
