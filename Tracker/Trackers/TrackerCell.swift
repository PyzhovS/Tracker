import Foundation
import UIKit

final class TrackerCell: UICollectionViewCell {
    var completionHandler: (() -> Void)?
    
    // MARK: - UI Elements
    private let coloredView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        [coloredView,
         emojiLabel,
         titleLabel,
         daysLabel,
         plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        
        let coloredViewHeight: CGFloat = 90
        
        NSLayoutConstraint.activate([
            coloredView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coloredView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coloredView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coloredView.heightAnchor.constraint(equalToConstant: coloredViewHeight),
            
            emojiLabel.topAnchor.constraint(equalTo: coloredView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: coloredView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: coloredView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: coloredView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: coloredView.bottomAnchor, constant: -12),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.topAnchor.constraint(equalTo: coloredView.bottomAnchor, constant: 16),
            
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    // MARK: - Configuration
    func configure(with title: String, emoji: String, color: UIColor, completedDays: Int, isCompleted: Bool,isActive: Bool) {
        titleLabel.text = title
        emojiLabel.text = emoji
        coloredView.backgroundColor = color
        daysLabel.text = "\(completedDays) дней"
        plusButton.setImage(UIImage(systemName: isCompleted ? "checkmark" : "plus"), for: .normal)
        plusButton.backgroundColor = coloredView.backgroundColor
        plusButton.isEnabled = isActive
        plusButton.alpha = isActive ? 1.0 : 0.3
    }
    
    @objc private func plusButtonTapped() {
        completionHandler?()
    }
}
