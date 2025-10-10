
import UIKit

final class StatisticsCardCell: UITableViewCell {
    static let reuseIdentifier = "StatisticsCardCell"
    
    private let cardView = UIView()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    
    private let gradientBorderLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutGradientBorder()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        layoutGradientBorder()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setNeedsLayout()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 0
        cardView.layer.borderColor = nil
        
        valueLabel.font = UIFont.boldSystemFont(ofSize: 34)
        valueLabel.textColor = .label
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        gradientBorderLayer.type = .conic
        gradientBorderLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor,
            UIColor.systemRed.cgColor
        ]
        gradientBorderLayer.locations = [0.0, 0.5, 0.85, 1.0]
        gradientBorderLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientBorderLayer.needsDisplayOnBoundsChange = true
        gradientBorderLayer.contentsScale = UIScreen.main.scale
        gradientBorderLayer.zPosition = 999
        
        borderMaskLayer.fillColor = UIColor.clear.cgColor
        borderMaskLayer.strokeColor = UIColor.black.cgColor
        borderMaskLayer.lineWidth = 1.5
        borderMaskLayer.lineJoin = .round
        borderMaskLayer.lineCap = .round
        
        gradientBorderLayer.mask = borderMaskLayer
        
        contentView.addSubview(cardView)
        [valueLabel, titleLabel].forEach {
            cardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.addSublayer(gradientBorderLayer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            valueLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    private func layoutGradientBorder() {

        gradientBorderLayer.frame = cardView.bounds
        
        let inset: CGFloat = borderMaskLayer.lineWidth / 2
        let roundedRect = cardView.bounds.insetBy(dx: inset, dy: inset)
        borderMaskLayer.path = UIBezierPath(
            roundedRect: roundedRect,
            cornerRadius: cardView.layer.cornerRadius
        ).cgPath
        borderMaskLayer.frame = cardView.bounds
    }
    
    func configure(value: Int, title: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }
}
