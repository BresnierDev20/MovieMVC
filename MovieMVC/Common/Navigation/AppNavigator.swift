//
//  AppNavigator.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import UIKit

// MARK: - Tipos de Presentación
enum PresentType {
    case root, push, present, presentWithNavigation, modal, modalWithNavigation
}

// MARK: - Protocolo de Router
protocol INavigator {
    var scene: UIViewController? { get }
}

// MARK: - Extensión de UIViewController para Navegación
extension UIViewController {

    // Inicializa un módulo desde un IRouter
    static func initialModule<T: INavigator>(module: T) -> UIViewController {
        guard let viewController = module.scene else {
            fatalError("No se pudo inicializar el módulo.")
        }
        return viewController
    }
    
    // Maneja la navegación según el tipo de presentación
    func navigate(to module: INavigator, type: PresentType = .push, completion: ((UIViewController) -> Void)? = nil) {
        guard let viewController = module.scene else { return }

        switch type {
        case .root:
            setRootViewController(viewController)
            completion?(viewController)
            
        case .push:
            navigationController?.pushViewController(viewController, animated: true)
            completion?(viewController)
            
        case .present:
            present(viewController, animated: true) {
                completion?(viewController)
            }
            
        case .presentWithNavigation, .modalWithNavigation:
            let navController = UINavigationController(rootViewController: viewController)
            configureModalStyle(for: navController, type: type)
            present(navController, animated: true) {
                completion?(viewController)
            }
            
        case .modal:
            configureModalStyle(for: viewController, type: type)
            present(viewController, animated: true) {
                completion?(viewController)
            }
        }
    }

    // Configura el estilo de transición para presentaciones modales
    private func configureModalStyle(for viewController: UIViewController, type: PresentType) {
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
    }

    // Cambia la raíz del controlador de vista
    private func setRootViewController(_ controller: UIViewController) {
        guard let window = UIApplication.shared.delegate?.window ?? nil else { return }
        window.setRootViewController(controller, options: .init(direction: .fade, style: .easeInOut))
    }
    
    // Dismiss con opción de navegar a un controlador específico
    func dismiss(to module: INavigator? = nil, completion: (() -> Void)? = nil) {
        if let targetVC = module?.scene {
            navigationController?.popToViewController(targetVC, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
        completion?()
    }

    // Vuelve al controlador raíz
    func backToRoot(completion: (() -> Void)? = nil) {
        navigationController?.popToRootViewController(animated: true)
        completion?()
    }
}

// MARK: - Extensión para manejar el UIWindow
extension UIWindow {
    struct TransitionOptions {
        enum Curve {
            case linear, easeIn, easeOut, easeInOut
            var function: CAMediaTimingFunction {
                switch self {
                case .linear: return CAMediaTimingFunction(name: .linear)
                case .easeIn: return CAMediaTimingFunction(name: .easeIn)
                case .easeOut: return CAMediaTimingFunction(name: .easeOut)
                case .easeInOut: return CAMediaTimingFunction(name: .easeInEaseOut)
                }
            }
        }
        
        enum Direction {
            case fade, toTop, toBottom, toLeft, toRight
            func transition() -> CATransition {
                let transition = CATransition()
                transition.type = .push
                transition.subtype = {
                    switch self {
                    case .fade: return nil
                    case .toLeft: return .fromLeft
                    case .toRight: return .fromRight
                    case .toTop: return .fromTop
                    case .toBottom: return .fromBottom
                    }
                }()
                return transition
            }
        }

        var duration: TimeInterval = 0.20
        var direction: Direction = .toRight
        var style: Curve = .linear

        var animation: CATransition {
            let transition = direction.transition()
            transition.duration = duration
            transition.timingFunction = style.function
            return transition
        }
    }

    func setRootViewController(_ controller: UIViewController, options: TransitionOptions = TransitionOptions()) {
        self.layer.add(options.animation, forKey: kCATransition)
        self.rootViewController = controller
        self.makeKeyAndVisible()
    }
}

// MARK: - Extensión UIApplication para obtener el controlador superior
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .flatMap { $0.windows }
                                    .first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}

// MARK: - Protocolo Delegado para Picker
protocol IDataPickerDelegate: AnyObject {
    func didDataPicker<T>(_ data: T?)
}
