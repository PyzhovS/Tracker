import UIKit

final class NewTrackerViewController: UIViewController {
    
    // MARK: - Properties
    private let menuItems = ["Категория", "Расписание"]
    var onTrackerCreated: ((Tracker, String) -> Void)?
    private var currentSchedule: [WeekDay] = []
    private var selectedCategory: String?
    private var selectedEmoji: String? = nil
    private var selectedColor: UIColor? = nil
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection51, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10,.colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
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
        field.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return field
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        table.isScrollEnabled = false
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.separatorStyle = .none
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.backgroundColor = .backgroundDay
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        return table
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestureRecognizer()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        contentView.addSubview(titleLabel)
        scrollView.addSubview(contentView)
        contentView.addSubview(nameTextField)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(createButton)
        view.addSubview(buttonsStack)
        
        [titleLabel, nameTextField, tableView, emojiLabel, emojiCollectionView,
         colorLabel, colorCollectionView, cancelButton, createButton, buttonsStack,
         scrollView, contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func setupConstraints() {
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 150)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: -14),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableViewHeightConstraint,
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 200),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func textFieldDidChange() {
        let maxText = 38
        let text = nameTextField.text ?? ""
        let isNameEntered = !text.isEmpty && text.count <= maxText
        let currentScheduleIsEmpty = !currentSchedule.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isEnable = currentScheduleIsEmpty && isNameEntered && isEmojiSelected && isColorSelected
        
        createButton.isEnabled = isEnable
        createButton.backgroundColor = isEnable ? .black : .ypGray
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let emoji = selectedEmoji,
              let category = selectedCategory,
              let color = selectedColor else { return }
        
        
        let newTracker = Tracker(
            id: UUID(),
            title: name,
            emoji: emoji,
            color: color,
            schedule: currentSchedule
        )
        
        onTrackerCreated?(newTracker, category)
       
        dismiss(animated: true)
    }
    
    @objc private func categoryButtonTapped() {
        selectedCategory = "Важное"
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CustomTableViewCell {
                cell.configure(title: "Категория", subtitle: selectedCategory)
            }
        textFieldDidChange()
        viewHeightConstraint()
        
        print("Категория tapped")
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleSelectionViewController()
        scheduleVC.selectedDays = currentSchedule
        scheduleVC.onScheduleSelected = { [weak self] selectedDays in
            self?.currentSchedule = selectedDays
            self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            self?.textFieldDidChange()
            self?.viewHeightConstraint()
        }
        
        let navVC = UINavigationController(rootViewController: scheduleVC)
        present(navVC, animated: true)
    }
    
    private func viewHeightConstraint() {
        let totalHeight: CGFloat = 165
        for i in 0..<menuItems.count {
            if i == 1 && !currentSchedule.isEmpty {
                tableViewHeightConstraint.constant = totalHeight
            } else {
                tableViewHeightConstraint.constant = 150
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func formatSelectedDays(_ days: [WeekDay]) -> String {
        if days.count == WeekDay.allCases.count {
            return "Каждый день"
        }
        let sortedDays = days.sorted { $0.rawValue < $1.rawValue }
        return sortedDays.map { $0.shortName }.joined(separator: ", ")
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        let title = menuItems[indexPath.row]
        var subtitle: String? = nil
        
        if indexPath.row == 1 {
            subtitle = currentSchedule.isEmpty ? nil : formatSelectedDays(currentSchedule)
        }
        let isLastCell = indexPath.row == menuItems.count - 1
        cell.configure(title: title, subtitle: subtitle, isLastCell: isLastCell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 && !currentSchedule.isEmpty {
            return 90
        }
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        hideKeyboard()
        
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

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension NewTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji, isSelected: emoji == selectedEmoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            let color = colors[indexPath.item]
            cell.configure(with: color, isSelected: color == selectedColor)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
        } else {
            selectedColor = colors[indexPath.item]
        }
        collectionView.reloadData()
        textFieldDidChange()
    }
}

extension WeekDay {
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
