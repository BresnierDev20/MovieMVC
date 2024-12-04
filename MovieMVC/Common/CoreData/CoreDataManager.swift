//
//  CoreModel.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 1/12/24.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    func contexto() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    func fetchMovies() -> [Movies] {
        let contexto = contexto()
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "original_title", ascending: true)]
        
        do {
            let movieEntities = try contexto.fetch(fetchRequest)
            let movies = movieEntities.map { entity in
                Movies(
                    poster_path: entity.poster_path,
                    overview: entity.overview ?? "",
                    release_date: entity.release_date ?? "",
                    id: Int(entity.id),
                    original_title: entity.original_title ?? "",
                    original_language: entity.original_language ?? "",
                    popularity: entity.popularity,
                    vote_count: Int(entity.vote_count),
                    vote_average: entity.vote_average
                )
            }
            return movies
        } catch let error as NSError {
            print("Error al obtener películas: \(error.localizedDescription)")
            return []
        }
    }
    func deleteMovieFromCoreData(movie: Movies) {
        let context = contexto()
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movie.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let movieEntity = results.first {
                context.delete(movieEntity)
                try context.save()
                print("Película eliminada correctamente.")
            }
        } catch let error as NSError {
            print("Error al eliminar la película: \(error.localizedDescription)")
        }
    }
    func saveData(movie: Movies) {
        let context = CoreDataManager.shared.contexto()
        
        // Verificar si la película ya existe por su ID
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movie.id)
        
        do {
            let existingMovies = try context.fetch(fetchRequest)
            
            if existingMovies.isEmpty {
                // Si no existe, insertar la nueva película
                let entityMovie = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: context) as! Movie
                
                entityMovie.original_title = movie.original_title
                entityMovie.poster_path = movie.poster_path
                entityMovie.original_language = movie.original_language
                entityMovie.overview = movie.overview
                entityMovie.popularity = movie.popularity
                entityMovie.release_date = movie.release_date
                entityMovie.vote_average = movie.vote_average
                entityMovie.vote_count = Int32(movie.vote_count)
                entityMovie.id = Int32(movie.id)
                
                try context.save()
                print("Película guardada correctamente.")
            } else {
                // Mostrar un mensaje de que la película ya existe
                print("La película ya existe en la base de datos y no se guardará.")
            }
        } catch let error as NSError {
            print("Error al verificar o guardar la película: \(error.localizedDescription)")
        }
    }
    
}

