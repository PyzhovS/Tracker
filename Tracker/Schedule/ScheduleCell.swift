import Foundation
import UIKit

final class ScheduleCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .label
        return label
    }()
    
    private let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .ypBlue
        return switchControl
    }()
    
    var switchValueChanged: ((Bool) -> Void)?
    
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
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        [titleLabel, switchControl].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        selectionStyle = .none
    }
    
    private func applyTheme() {

        if traitCollection.userInterfaceStyle == .dark {
            backgroundColor = .secondarySystemBackground
            contentView.backgroundColor = .secondarySystemBackground
        } else {
            backgroundColor = .backgroundDay
            contentView.backgroundColor = .backgroundDay
        }
        titleLabel.textColor = .label
    }
    
    @objc private func switchChanged() {
        switchValueChanged?(switchControl.isOn)
    }
    
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        switchControl.isOn = isSelected
    }
}
