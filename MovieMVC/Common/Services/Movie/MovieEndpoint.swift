//
//  MovieEndpoint.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import Alamofire

enum MovieEndpoint {
    case getMoviePopular(page_pagination: Int)
}

extension MovieEndpoint: IEndpoint {
    var method: HTTPMethod {
        switch self {
        case .getMoviePopular:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getMoviePopular(let page_pagination):
            return "popular?page=\(page_pagination)&api_key=27393eaeb2b4e83fc500a5019d7b300d"
           
        }
    }
    
    var parameter: Parameters? {
        switch self {
        case .getMoviePopular:
            return nil
        
        }
    }
    
    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
}
