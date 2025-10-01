import UIKit

final class FiltersViewController: UIViewController {
    
    var onFilterSelected: ((FilterType) -> Void)?
    
    private let options: [(FilterType, String)] = [
        (.all, NSLocalizedString("filters.all", comment: "All trackers")),
        (.today, NSLocalizedString("filters.today", comment: "Today")),
        (.completed, NSLocalizedString("filters.completed", comment: "Completed")),
        (.incompleted, NSLocalizedString("filters.incompleted", comment: "Not completed"))
    ]
    
    private let selectedFilter: FilterType?
    
    // Таблица с контролируемой шириной (отступы по 16) и фиксируемой высотой по контенту
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.layer.cornerRadius = 16
        tv.layer.masksToBounds = true
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.backgroundColor = .backgroundDay
        tv.tableFooterView = UIView()
        tv.isScrollEnabled = false // важный момент: высота = контенту, без скролла
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        return tv
    }()
    
    // Констрейнт высоты таблицы
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
        tableView.reloadData()
        updateTableHeight()
    }
    
    // На случай смены шрифтов/ориентации — актуализируем высоту
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableHeightConstraint // вместо bottomAnchor — фиксируем высоту по контенту
        ])
    }
    
    private func updateTableHeight() {
        // Высота одной строки — 75 (как в макете)
        let rowHeight: CGFloat = 75
        let totalHeight = rowHeight * CGFloat(options.count)
        if tableHeightConstraint.constant != totalHeight {
            tableHeightConstraint.constant = totalHeight
            // layoutIfNeeded не обязателен здесь, т.к. метод вызывается и из layoutSubviews
        }
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let (type, title) = options[indexPath.row]
        cell.textLabel?.text = title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.tintColor = .systemBlue
        cell.backgroundColor = .clear // чтобы просвечивал фон таблицы
        
        // Галочка только для активных фильтров (как у вас)
        if let selected = selectedFilter, selected.isActive, selected == type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    // Прячем разделитель только у последней ячейки — оставляем «внутренние» линии
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLast = indexPath.row == options.count - 1
        
        if isLast {
            // Скрыть нижний разделитель у последней ячейки
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            // Оставляем стандартные отступы для внутренних разделителей
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
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
