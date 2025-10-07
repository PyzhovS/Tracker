import UIKit

final class StatisticsViewController: UIViewController {
    
    private let viewModel = StatisticsViewModel()
    private var items: [StatisticItem] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.Statistics.title
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.register(StatisticsCardCell.self, forCellReuseIdentifier: StatisticsCardCell.reuseIdentifier)
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 116
        return table
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "smill")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.Statistics.empty
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
        viewModel.load()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        [titleLabel, tableView, placeholderImageView, placeholderLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .empty:
                self.items = []
                self.tableView.isHidden = true
                self.placeholderImageView.isHidden = false
                self.placeholderLabel.isHidden = false
            case .data(let items):
                self.items = items
                self.tableView.isHidden = false
                self.placeholderImageView.isHidden = true
                self.placeholderLabel.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
}

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCardCell.reuseIdentifier, for: indexPath) as? StatisticsCardCell
        else { return UITableViewCell() }
        let item = items[indexPath.row]
        cell.configure(value: item.value, title: item.title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { false }
}
