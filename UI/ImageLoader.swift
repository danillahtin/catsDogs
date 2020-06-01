//
//  ImageLoader.swift
//  UI
//
//  Created by Danil Lahtin on 01.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit


public protocol ImageLoader {
    func load(from url: URL, into imageView: UIImageView?)
}
