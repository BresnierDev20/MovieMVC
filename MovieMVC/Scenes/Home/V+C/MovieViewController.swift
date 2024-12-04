//
//  MovieViewController.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import UIKit

class MovieViewController: BaseViewController {
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var searchBar: SWTextField! {
        didSet {
            searchBar?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    private var searchTimer: Timer?
    private let searchQueue = DispatchQueue(label: "com.movieapp.search", qos: .userInitiated)
    
    //MARK: - Collection View
    let cellMoviesCollectionNibName = "MovieCollectionViewCell"
    let apiService: MovieServiceProtocol = MovieAPI()
    
    var moviesList: [Movies]?
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .red
        refreshControl.addTarget(self, action: #selector(fetchMovie), for: .valueChanged)
        return refreshControl
    }()
    
    var moviesFilter: [Movies] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.movieCollectionView.reloadData()
                // Imprimir el estado de la caché para debugging
                if let cacheStatus = self?.printCacheStatus() {
                    print("Cache status after filter: \(cacheStatus)")
                }
            }
        }
    }

    func printCacheStatus() -> String {
        return ImageCacheManager.shared.retrieveCacheSize()
    }
    
    var isFiltering: Bool {
        return searchBar?.text?.isEmpty == false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsCollectionView()
        fetchMovie()
        searchBar?.delegate = self
   
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false) // Ocultamos la barra de navegación en esta vista
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
            // Limpiar la caché de memoria cuando la vista desaparece
        ImageCacheManager.shared.clearMemoryCache()
       
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Limpiar caché cuando hay advertencia de memoria
        ImageCacheManager.shared.clearMemoryCache()
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        // Cancelar el timer anterior si existe
        searchTimer?.invalidate()
            
        // Crear un nuevo timer con un retraso
        if let text = textField.text, text.isEmpty {
            textField.resignFirstResponder() // Oculta el teclado si el texto está vacío
            movieCollectionView.reloadData()
        } else {
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                self?.search()
            }
        }
    }
    
    func search() {
        guard let text = searchBar?.text?.lowercased(), !text.isEmpty else {
            // Si el texto está vacío, limpia los resultados
            moviesFilter.removeAll()
            return
        }
            
        // Realizar la búsqueda en una cola en segundo plano
        searchQueue.async { [weak self] in
            guard let self = self, let moviesList = self.moviesList else { return }
                
            // realizar el filtrado
            let filtered = moviesList.filter { movie in
                return movie.original_title.lowercased().contains(text)
            }
                
            // Actualizar UI en el hilo principal
            DispatchQueue.main.async {
                self.moviesFilter = filtered
                // Limpiar caché de memoria si es necesario
                if filtered.count > 20 {
                    ImageCacheManager.shared.clearMemoryCache()
                }
            }
        }
    }
    
    func settingsCollectionView(){
        movieCollectionView.register(UINib(nibName: cellMoviesCollectionNibName, bundle: nil),
                                forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)
        movieCollectionView.refreshControl = refresher
    }
    
    @objc func fetchMovie() {
//        showLoading()
        refresher.endRefreshing()
        
        let request = MovieModels.MoviesList.Request(page_pagination: 1)
        apiService.getPopularMovie(request: request) { [weak self] result in
            guard let self else { return}
            switch result {
            case .success(let response):
                self.updateUI(with: response)
            case .failure(let error):
                self.showError(error)
            }
        }
    }
        
    func updateUI(with response: MovieModels.MoviesList.Response) {
        print("Success: \(response.results), Message: \(response.total_pages)")
//        hideLoading()
        refresher.endRefreshing()
        moviesList = response.results
        
        movieCollectionView.isHidden = moviesList?.count == 0
        
        movieCollectionView.reloadData()
    }
   
    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension MovieViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isFiltering ? moviesFilter.count : moviesList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = movieCollectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieCollectionViewCell else {
            fatalError()
        }
        
        // Obtener la película actual
        let movie = isFiltering ? moviesFilter[indexPath.row] : (moviesList?[indexPath.row])
        
        // Configurar la celda solo si está visible
        if let movie = movie {
            cell.configUI(movies: movie)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.moviesData = isFiltering ? moviesFilter[indexPath.row] : moviesList?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 190, height: MovieCollectionViewCell.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top:0, left: 0, bottom: 10, right: 0)
    }

}

extension MovieViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Oculta el teclado
        return true
    }
}
