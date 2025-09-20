import UIKit

final class CategoryListViewController: UIViewController {
    
    // MARK: - Properties
    let viewModel: CategoryViewModel
    private var selectedCategory: String?
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        table.delegate = self
        table.dataSource = self
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.separatorStyle = .none
        table.backgroundColor = .backgroundDay
        table.isScrollEnabled = false
        return table
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "error")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(selectedCategory: String? = nil, viewModel: CategoryViewModel = CategoryViewModel()) {
        self.selectedCategory = selectedCategory
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        viewModel.loadCategories()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .white
        title = "Категория"
        
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        view.addSubview(tableView)
        view.addSubview(placeholderStackView)
        view.addSubview(addButton)
        
        [tableView, placeholderStackView, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 150)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewHeightConstraint, 
            
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdate = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onError = { [weak self] errorMessage in
            self?.showError(errorMessage)
        }
    }
    
    private func updateUI() {
        let hasCategories = viewModel.hasCategories()
        
        tableView.isHidden = !hasCategories
        placeholderStackView.isHidden = hasCategories
        
        if hasCategories {
            let cellHeight: CGFloat = 75
            let totalHeight = CGFloat(viewModel.getCategoriesCount()) * cellHeight
            tableViewHeightConstraint.constant = totalHeight
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        tableView.reloadData()
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func addButtonTapped() {
        let addCategoryVC = AddCategoryViewController()
        addCategoryVC.onCategoryAdded = { [weak self] categoryName in
            self?.viewModel.addNewCategory(title: categoryName)
            self?.selectedCategory = categoryName
            self?.tableView.reloadData()
            self?.viewModel.selectCategory(categoryName)
        }
        
        navigationController?.pushViewController(addCategoryVC, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCategoriesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let categoryTitle = viewModel.getCategoryTitle(at: indexPath.row)
        let isSelected = categoryTitle == selectedCategory
        let isLastCell = indexPath.row == viewModel.getCategoriesCount() - 1
        
        cell.configure(with: categoryTitle, isSelected: isSelected, isLastCell: isLastCell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = viewModel.getCategoryTitle(at: indexPath.row)
        self.selectedCategory = selectedCategory
        tableView.reloadData()
        viewModel.selectCategory(selectedCategory)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
