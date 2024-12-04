//
//  TabBarController.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 1/12/24.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
    }

    func configureTabs() {
        let movieVC = MovieViewController()
        let favoriteVC = FavoriteViewController()

        // Asigna correctamente el UITabBarItem a cada vista antes de inicializar UINavigationController
        movieVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        favoriteVC.tabBarItem = UITabBarItem(
            title: "Favorite",
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )

        // Asegúrate de que cada controlador esté envuelto en un UINavigationController
        let navHome = UINavigationController(rootViewController: movieVC)
        let navFavorite = UINavigationController(rootViewController: favoriteVC)

        // Configura los controladores en UITabBarController
        setViewControllers([navHome, navFavorite], animated: true)

        // Configura la apariencia de la Tab Bar
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false) // Ocultamos la barra al mostrar el TabBar
    }
}
