//
//  EntityTableViewCell.swift
//  UI
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import UIKit


public final class EntityTableViewCell: UITableViewCell {
    public let titleLabel = UILabel()
    public let thumbImageView = UIImageView()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [thumbImageView, titleLabel])
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbImageView.widthAnchor.constraint(equalToConstant: 80),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
        ])
        
        contentView.addSubview(stackView)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
