//
//  ImageCacheManager.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 7/11/24.
//

import UIKit
import Kingfisher

// MARK: - URL Extension para obtener el tamaño del almacenamiento en disco
extension URL {
    var diskStorageSize: UInt64 {
        guard let enumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: [.totalFileAllocatedSizeKey]) else {
            return 0
        }
        
        var size: UInt64 = 0
        for case let url as URL in enumerator {
            guard let resourceValues = try? url.resourceValues(forKeys: [.totalFileAllocatedSizeKey]),
                  let fileSize = resourceValues.totalFileAllocatedSize else {
                continue
            }
            size += UInt64(fileSize)
        }
        return size
    }
}

// MARK: - ImageCacheManager para manejar la caché de imágenes con Kingfisher
@MainActor
class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    // Constructor privado para asegurar singleton
    private init() {
        setupCache()
    }
    
    // Configuración inicial del caché
    private func setupCache() {
        // Configura límites de memoria y disco
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024 // 300 MB en memoria
        cache.memoryStorage.config.countLimit = 100 // Máximo número de imágenes en memoria
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 1024 // 1 GB en disco
        
        // Configura el tiempo de expiración de caché
        cache.memoryStorage.config.expiration = .seconds(300) // 5 minutos en memoria
        cache.diskStorage.config.expiration = .days(7) // 7 días en disco
    }
    
    // Función para cargar una imagen de URL en una UIImageView con procesamiento
    func loadImage(with urlString: String, imageView: UIImageView, placeholder: UIImage? = nil) {
        guard let url = URL(string: urlString) else { return }
        
        // Configura el procesamiento de la imagen (reducción de tamaño) y opciones de caché
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
        
        let options: KingfisherOptionsInfo = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(0.2)),
            .cacheOriginalImage,
            .memoryCacheExpiration(.seconds(300)),
            .diskCacheExpiration(.days(7))
        ]
        
        // Cargar la imagen en el UIImageView
        imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: options
        ) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print("Error cargando imagen: \(error.localizedDescription)")
            }
        }
    }
    
    // Limpiar toda la caché (memoria y disco) en segundo plano
    func clearCache() {
        DispatchQueue.global(qos: .background).async {
            ImageCache.default.clearMemoryCache()
            ImageCache.default.clearDiskCache()
        }
    }
    
    // Limpiar únicamente la caché en memoria
    func clearMemoryCache() {
        DispatchQueue.global(qos: .background).async {
            ImageCache.default.clearMemoryCache()
        }
    }
    
    // Limpiar solo caché en disco que ya ha expirado
    func clearOldCache() {
        DispatchQueue.global(qos: .background).async {
            ImageCache.default.cleanExpiredDiskCache()
        }
    }
    
    // Función para obtener el tamaño actual de la caché en memoria y disco como cadena
    func retrieveCacheSize() -> String {
        let cache = ImageCache.default
        let memorySize = Double(cache.memoryStorage.config.totalCostLimit) / 1024.0 / 1024.0 // En MB
        let diskSize = Double(cache.diskStorage.directoryURL.diskStorageSize) / 1024.0 / 1024.0 // En MB
        return String(format: "Memory: %.2f MB, Disk: %.2f MB", memorySize, diskSize)
    }
}

// MARK: - Extension para SWImageView para simplificar el uso de ImageCacheManager
@MainActor
extension SWImageView {
    func setImage(urlString: String, placeholder: UIImage? = nil) {
        ImageCacheManager.shared.loadImage(with: urlString, imageView: self, placeholder: placeholder)
    }
}

