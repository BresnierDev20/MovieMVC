//
//  MovieModels.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import Foundation


enum MovieModels {
    enum MoviesList {
        struct Request {
            let page_pagination   : Int
        
        }

        struct Response: Codable {
            
            let page: Int
            let results: [Movies]
            let total_pages: Int
            let total_results: Int

            enum CodingKeys: String, CodingKey {
                case page
                case results
                case total_pages
                case total_results
            }
        }
        
        struct ViewModel {
            let moviesList: [Movies]
        }
    }
    
}

