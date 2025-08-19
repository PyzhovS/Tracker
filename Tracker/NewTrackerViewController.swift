import Foundation
import UIKit

class NewTrackerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = .systemBackground
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    func setupUI() {
        
        view.addSubview(titleLabel)
           
        
        [titleLabel].forEach {$0.translatesAutoresizingMaskIntoConstraints = false}
        setupConstraint()
    }
    
    func setupConstraint() {
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -14),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
            
        ])
    }
}




