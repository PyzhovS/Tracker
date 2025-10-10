import UIKit

final class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let pageIndex: Int
    
    // MARK: - Init
    init(title: String, imageName: String, pageIndex: Int) {
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        backgroundImageView.image = UIImage(named: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        
        actionButton.setTitle(Localizable.Onboarding.actionButton, for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        actionButton.backgroundColor = .black
        actionButton.layer.cornerRadius = 16
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(actionButton)
        
        [backgroundImageView, titleLabel, actionButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -160),
            
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func actionButtonTapped() {
        if let pageViewController = parent as? OnboardingPageViewController {
            pageViewController.completeOnboarding()
        } else if let pageViewController = presentingViewController as? OnboardingPageViewController {
            pageViewController.completeOnboarding()
        }
    }
}

