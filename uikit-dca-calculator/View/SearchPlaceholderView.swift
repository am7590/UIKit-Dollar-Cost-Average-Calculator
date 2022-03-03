//
//  SearchPlaceholderView.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/3/22.
//

import UIKit

class SearchPlaceholderView: UIView {
    
    // Image view
    private let imageView: UIImageView = {
        let image = UIImage(named: "imDca")
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit  // Scale
        return imageView
    }()
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Search comapnies to calculate potential returns via dollar cost averaging"
        label.font = UIFont(name: "AvenirNext-Medium", size: 14)!
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Add this view as part of the sub view
    private func setupViews() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            // Set width to 80% of SearchPlaceholderView
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 88)
        ])
    }
    
    
}
