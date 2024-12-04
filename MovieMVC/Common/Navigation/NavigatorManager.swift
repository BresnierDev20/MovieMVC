//
//  NavigatorManager.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import UIKit

enum NavigatorManager: INavigator {
    case home
    case detail
    case tab
}

extension NavigatorManager {
    var scene: UIViewController? {
        switch self {
        case .home:
            return MovieViewController()
        case .detail:
            return DetailViewController()
        case .tab:
            return TabBarController()
        }
    }
}
