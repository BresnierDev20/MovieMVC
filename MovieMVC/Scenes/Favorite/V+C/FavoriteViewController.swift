//
//  FavoriteViewController.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 1/12/24.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var favoriteTableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    var isContainerView: Bool = false
    var movie: [Movies] = []
    var fetchResultController : NSFetchedResultsController<Movie>!
    let cellTableViewNibName = "FavoriteTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.isHidden = true
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        mostrarNotas()
        settingTableView()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mostrarNotas()
    }
 
    
    func mostrarNotas() {
        movie = CoreDataManager.shared.fetchMovies()
       
        validationView()
    }

    func validationView(){
        if movie.isEmpty {
            isContainerView = true
        }else {
            isContainerView = false
        }
        
        if isContainerView {
            containerView.isHidden = false
            favoriteTableView.isHidden = true
        }else {
            containerView.isHidden = true
            favoriteTableView.isHidden = false
            favoriteTableView.reloadData()
        }
        
     
    }
    
    func settingTableView() {
        favoriteTableView.register(UINib(nibName: cellTableViewNibName, bundle: nil), forCellReuseIdentifier: FavoriteTableViewCell.reuseIdentifier)
        favoriteTableView.rowHeight = UITableView.automaticDimension
        favoriteTableView.estimatedRowHeight = 150
    }
}

extension FavoriteViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isContainerView ? 0 : movie.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.reuseIdentifier, for: indexPath) as? FavoriteTableViewCell else {
            fatalError()
        }
        
        let movieList =  movie[indexPath.row]
        
        cell.configUI(movies: movieList)
        
        return cell
    }
   
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Eliminar") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            // Obtener la película que se va a eliminar
            let movieToDelete = self.movie[indexPath.row]
            
            // Eliminar la película de Core Data
            CoreDataManager.shared.deleteMovieFromCoreData(movie: movieToDelete)
            
            // Eliminar la película del array
            self.movie.remove(at: indexPath.row)
            
            // Eliminar la celda de la tabla
            self.favoriteTableView.deleteRows(at: [indexPath], with: .automatic)
//            validationView()
            // Llamar al completionHandler para indicar que la acción ha terminado
            
            validationView()
           
          
            completionHandler(true)
        }
        delete.image = UIImage(systemName: "trash")
        
        let editar = UIContextualAction(style: .normal, title: "Editar") { (_, _, completionHandler) in
            // Acción de editar
            completionHandler(true)
        }
        editar.backgroundColor = .systemBlue
        editar.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [editar, delete])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10 // Altura de la separación entre celdas
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FavoriteTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        let movieList =  movie[indexPath.row]
        
        vc.moviesData = movieList
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.favoriteTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.favoriteTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.favoriteTableView.reloadRows(at: [indexPath!], with: .fade)
        default:
            self.favoriteTableView.reloadData()
        }
        self.movie = controller.fetchedObjects as! [Movies]
    }
}
