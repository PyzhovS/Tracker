import UIKit

class NewTrackerViewController: UIViewController {
    
    // MARK: - Properties
    private let menuItems = ["Категория", "Расписание"]
    var onTrackerCreated: ((Tracker, String) -> Void)?
    private var currentSchedule: [WeekDay] = []
    
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.backgroundColor = .backgroundDay
        field.layer.cornerRadius = 16
        field.layer.masksToBounds = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.font = UIFont.systemFont(ofSize: 17)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isScrollEnabled = false
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.backgroundColor = .backgroundDay
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(tableView)
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(createButton)
        view.addSubview(buttonsStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -14),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 78),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupActions() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    @objc private func textFieldDidChange() {
        let maxTex = 38
        var isNameEntered = !(nameTextField.text?.isEmpty ?? true)
        if nameTextField.text?.count ?? 0 > maxTex {
            isNameEntered = false
        }
        createButton.isEnabled = isNameEntered
        createButton.backgroundColor = isNameEntered ? .black : .gray
    }
    
    @objc private func cancelButtonTapped() {
        
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
           
           let newTracker = Tracker(
               id: UUID(),
               title: name,
               emoji: "🟢",
               color: .systemBlue,
               schedule: currentSchedule// Будет заполнено в ScheduleSelectionViewController
           )
           
           onTrackerCreated?(newTracker, "Разное")
           dismiss(animated: true)
    }
    
    @objc private func categoryButtonTapped() {
        
        print("Категория tapped")
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleSelectionViewController()
           
           scheduleVC.onScheduleSelected = { [weak self] selectedDays in
               // НЕ сохраняем в currentSchedule, сразу обновляем интерфейс
               let scheduleText = selectedDays.isEmpty ? "Расписание" :
                   selectedDays.map { $0.displayName }.joined(separator: ", ")
               
               // Обновляем ячейку таблицы
               if let cell = self?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) {
                   cell.detailTextLabel?.text = scheduleText
                   cell.detailTextLabel?.textColor = .gray
                   cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
               }
               
               // Сохраняем выбранные дни только при создании трекера
               self?.currentSchedule = selectedDays // Если нужно для создания
           }
           
           let navVC = UINavigationController(rootViewController: scheduleVC)
           present(navVC, animated: true)
        print("Расписание tapped")
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = menuItems[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        
        // Для ячейки расписания показываем выбранные дни
        if indexPath.row == 1 && !currentSchedule.isEmpty {
            let selectedDaysText = currentSchedule.map { $0.displayName }.joined(separator: ", ")
            cell.detailTextLabel?.text = selectedDaysText
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        } else {
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            categoryButtonTapped()
        case 1:
            scheduleButtonTapped()
        default:
            break
        }
    }
}
