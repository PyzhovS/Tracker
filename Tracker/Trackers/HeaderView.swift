import Foundation
import UIKit

final class HeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        titleLabel.textColor = .label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
