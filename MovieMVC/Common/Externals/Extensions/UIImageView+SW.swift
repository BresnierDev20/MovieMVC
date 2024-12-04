//
//  UIImageView+SW.swift
//  MovieMVC
//
//  Created by Bresnier Moreno on 5/11/24.
//

import UIKit
import Kingfisher

extension UIImage {
    func setImageJPEGValueBase64() -> String? {
         jpegData(compressionQuality: JPEGQuality.low.rawValue)?.base64EncodedString()
    }
    
    func setImagePNGValueBase64() -> String? {
        pngData()?.base64EncodedString()
    }
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UIImageView{
    func setImage(urlString: String?, imageView: UIImageView) {
        guard let urlString = urlString, !urlString.isEmpty, let imageURL = URL(string: urlString) else { return }
        
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size) |> RoundCornerImageProcessor(cornerRadius: 8)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: imageURL,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
    }
    
    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = tintedImage
        self.tintColor = color
    }
}

