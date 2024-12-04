//
//  MovieAPI.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import Foundation

protocol MovieServiceProtocol {
    func getPopularMovie(request: MovieModels.MoviesList.Request, completion: @escaping (Result<MovieModels.MoviesList.Response, MovieError>) -> Void)
}

class MovieAPI: MovieServiceProtocol {
    func getPopularMovie(request: MovieModels.MoviesList.Request, completion: @escaping (Result<MovieModels.MoviesList.Response, MovieError>) -> Void) {
        NetworkService.shared.request(endpoint: MovieEndpoint.getMoviePopular(page_pagination: request.page_pagination)) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(MovieModels.MoviesList.Response.self, from: data!)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(.parse(error)))
                }
            case .failure(let error):
                completion(.failure(.network(error)))
            }
        }
    }
}
