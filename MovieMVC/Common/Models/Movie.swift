//
//  Movie.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 7/11/24.
//

import Foundation

struct Movies: Codable {
    let poster_path: String?
    let overview: String
    let release_date: String
    let id: Int
    let original_title: String
    let original_language: String
    let popularity: Double
    let vote_count: Int
    let vote_average: Double
}


enum MovieError: Error, CustomStringConvertible {
    case request
    case network(Error)
    case parse(Error)
    case server(description: String)
    
    var description: String {
        switch self {
        case .network(let error), .parse(let error):
            return error.localizedDescription
        case .request:
            return "Error request"
        case .server(let description):
            return description
        }
    }
}

