import UIKit

// Приватная ячейка с кастомным разделителем
private final class FilterOptionCell: UITableViewCell {
    static let reuseId = "FilterOptionCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 17)
        l.textColor = .label
        return l
    }()

    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        return v
    }()

    private var separatorHeightConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        applyTheme()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        applyTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(separatorView)
        [titleLabel, separatorView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        separatorHeightConstraint = separatorView.heightAnchor.constraint(equalToConstant: 0.5)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorHeightConstraint
        ])
    }

    private func applyTheme() {
        titleLabel.textColor = .label
        separatorView.backgroundColor = .separator
    }

    func configure(title: String, isLast: Bool, separatorHeight: CGFloat) {
        titleLabel.text = title
        separatorHeightConstraint.constant = separatorHeight
        separatorView.isHidden = isLast
    }
}

final class FiltersViewController: UIViewController {
    
    var onFilterSelected: ((FilterType) -> Void)?
    
    private let options: [(FilterType, String)] = [
        (.all, NSLocalizedString("filters.all", comment: "All trackers")),
        (.today, NSLocalizedString("filters.today", comment: "Today")),
        (.completed, NSLocalizedString("filters.completed", comment: "Completed")),
        (.incompleted, NSLocalizedString("filters.incompleted", comment: "Not completed"))
    ]
    
    private let selectedFilter: FilterType?
    
    // Возможность настраивать толщину разделителя между ячейками
    var separatorThickness: CGFloat = 0.5 {
        didSet { tableView.reloadData() }
    }
    
    // Таблица с контролируемой шириной и высотой по контенту
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.layer.cornerRadius = 16
        tv.layer.masksToBounds = true
        tv.separatorStyle = .none // отключаем системные сепараторы
        tv.tableFooterView = UIView()
        tv.isScrollEnabled = false
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        return tv
    }()
    
    private var tableHeightConstraint: NSLayoutConstraint!
    
    init(selectedFilter: FilterType?) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("filters.title", comment: "Filters")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        applyTheme()
        tableView.reloadData()
        updateTableHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        tableView.register(FilterOptionCell.self, forCellReuseIdentifier: FilterOptionCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func applyTheme() {
        view.backgroundColor = .systemBackground
        // Фон «карточки» таблицы: в темной теме затемняем
        if traitCollection.userInterfaceStyle == .dark {
            tableView.backgroundColor = .secondarySystemBackground
        } else {
            tableView.backgroundColor = .backgroundDay
        }
    }
    
    private func setupConstraints() {
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableHeightConstraint
        ])
    }
    
    private func updateTableHeight() {
        let rowHeight: CGFloat = 75
        let totalHeight = rowHeight * CGFloat(options.count)
        if tableHeightConstraint.constant != totalHeight {
            tableHeightConstraint.constant = totalHeight
        }
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterOptionCell.reuseId, for: indexPath) as? FilterOptionCell else {
            return UITableViewCell()
        }
        
        let (type, title) = options[indexPath.row]
        let isLast = indexPath.row == options.count - 1
        
        cell.configure(title: title, isLast: isLast, separatorHeight: separatorThickness)
        cell.tintColor = .systemBlue // цвет галочки
        
        if let selected = selectedFilter, selected.isActive, selected == type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selected = options[indexPath.row].0
        onFilterSelected?(selected)
        dismiss(animated: true)
    }
}
