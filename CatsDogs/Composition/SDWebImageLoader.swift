//
//  SDWebImageLoader.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit
import UI
import SDWebImage

final class SDWebImageLoader: ImageLoader {
    func load(from url: URL, into imageView: UIImageView?) {
        imageView?.sd_setImage(with: url, completed: nil)
    }
}
