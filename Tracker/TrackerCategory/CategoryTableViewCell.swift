import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .label // динамический (в светлой = черный)
        label.numberOfLines = 1
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .systemBlue
        imageView.isHidden = true
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        // цвет зададим в applyTheme(), чтобы отличать Light/Dark
        return view
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        applyTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(separatorView)
        
        [titleLabel, checkmarkImageView, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkImageView.leadingAnchor, constant: -8),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        selectionStyle = .none
    }
    
    private func applyTheme() {
        // Фон ячейки: в светлой — как раньше .backgroundDay, в темной — системный
        if traitCollection.userInterfaceStyle == .dark {
            backgroundColor = .secondarySystemBackground
            contentView.backgroundColor = .secondarySystemBackground
            separatorView.backgroundColor = .separator
        } else {
            backgroundColor = .backgroundDay
            contentView.backgroundColor = .backgroundDay
            separatorView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        }
        
        // Текст и чекмарка
        titleLabel.textColor = .label
        checkmarkImageView.tintColor = .systemBlue
    }
    
    // MARK: - Public Methods
    func configure(with title: String, isSelected: Bool, isLastCell: Bool = false) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
        separatorView.isHidden = isLastCell
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        checkmarkImageView.isHidden = true
        separatorView.isHidden = false
    }
}
