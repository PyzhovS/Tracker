import UIKit

// MARK: - NewTrackerViewController
final class NewTrackerViewController: UIViewController {
    
    // MARK: - Mode
    enum Mode {
        case create
        case edit(Tracker, String, Int)
    }
    
    // MARK: - Callbacks
    var mode: Mode = .create
    var onTrackerUpdated: ((Tracker, String) -> Void)?
    var onTrackerCreated: ((Tracker, String) -> Void)?
    
    // MARK: - ViewModel
    private var viewModel: NewTrackerViewModel!
    
    // MARK: - Data
    private let menuItems = [Localizable.NewTracker.category, Localizable.NewTracker.schedule]
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.NewTracker.title
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.isHidden = true
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = Localizable.NewTracker.namePlaceholder
        field.layer.cornerRadius = 16
        field.layer.masksToBounds = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.font = UIFont.systemFont(ofSize: 17)
        field.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
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
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        return table
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.NewTracker.emojiTitle
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textAlignment = .left
        label.textColor = .label
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
        collectionView.allowsMultipleSelection = false
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        return collectionView
    }()
    
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.NewTracker.colorTitle
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textAlignment = .left
        label.textColor = .label
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
        collectionView.allowsMultipleSelection = false
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localizable.Common.cancel, for: .normal)
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
        button.setTitle(Localizable.NewTracker.create, for: .normal)
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
    
    // MARK: - Constraints
    private var tableViewHeightConstraint: NSLayoutConstraint!
    private var nameTopToTitleConstraint: NSLayoutConstraint!
    private var nameTopToDaysConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NewTrackerViewModel(mode: convertMode(mode))
        bindViewModel()
        setupUI()
        setupConstraints()
        setupGestureRecognizer()
        applyTheme()
        applyModeUI()
        nameTextField.text = viewModel.name
        tableView.reloadData()
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
        updateCreateButtonAppearance()
        updateTableHeight()
    }
    
    // MARK: - Helpers
    private func convertMode(_ m: Mode) -> NewTrackerViewModel.Mode {
        switch m {
        case .create: return .create
        case .edit(let t, let c, let days): return .edit(t, c, days)
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onChange = { [weak self] in
            guard let self else { return }
            self.updateCreateButtonAppearance()
            self.tableView.reloadData()
            self.updateTableHeight()
        }
    }
    
    // MARK: - Trait Changes
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
        updateCreateButtonAppearance()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(scrollView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(daysCountLabel)
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
        [titleLabel, daysCountLabel, nameTextField, tableView, emojiLabel, emojiCollectionView,
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
    
    // MARK: - Actions
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Layout
    private func setupConstraints() {
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 150)
        nameTopToTitleConstraint = nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24)
        nameTopToDaysConstraint = nameTextField.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 40)
        
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -14),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            daysCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            daysCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            nameTopToTitleConstraint,
            
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
    
    // MARK: - Theming
    private func applyTheme() {
        view.backgroundColor = .systemBackground
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        if traitCollection.userInterfaceStyle == .dark {
            nameTextField.backgroundColor = .tertiarySystemFill
            nameTextField.keyboardAppearance = .dark
        } else {
            nameTextField.backgroundColor = .backgroundDay
            nameTextField.keyboardAppearance = .light
        }
        nameTextField.textColor = .label
        nameTextField.tintColor = .label
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: Localizable.NewTracker.namePlaceholder,
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
        
        tableView.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? .secondarySystemBackground : .backgroundDay
        emojiLabel.textColor = .label
        colorLabel.textColor = .label
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
    }
    
    private func applyModeUI() {
        switch mode {
        case .create:
            titleLabel.text = Localizable.NewTracker.title
            createButton.setTitle(Localizable.NewTracker.create, for: .normal)
            daysCountLabel.isHidden = true
            nameTopToDaysConstraint.isActive = false
            nameTopToTitleConstraint.isActive = true
        case .edit:
            titleLabel.text = Localizable.EditTracker.title
            createButton.setTitle(Localizable.EditTracker.save, for: .normal)
            daysCountLabel.text = viewModel.daysCountText
            daysCountLabel.isHidden = false
            nameTopToTitleConstraint.isActive = false
            nameTopToDaysConstraint.isActive = true
        }
        view.layoutIfNeeded()
    }
    
    // MARK: - UI State
    private func updateCreateButtonAppearance() {
        let enabled = viewModel.isCreateEnabled
        createButton.isEnabled = enabled
        
        if enabled {
            if traitCollection.userInterfaceStyle == .dark {
                createButton.backgroundColor = .white
                createButton.setTitleColor(.black, for: .normal)
            } else {
                createButton.backgroundColor = .black
                createButton.setTitleColor(.white, for: .normal)
            }
        } else {
            createButton.backgroundColor = .ypGray
            createButton.setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: - Actions (Inputs)
    @objc private func nameChanged() {
        viewModel.setName(nameTextField.text ?? "")
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let result = viewModel.makeResult() else { return }
        
        switch mode {
        case .create:
            onTrackerCreated?(result.tracker, result.category)
        case .edit:
            onTrackerUpdated?(result.tracker, result.category)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func categoryButtonTapped() {
        hideKeyboard()
        
        let viewModelCategory = CategoryViewModel(selectedCategory: viewModel.selectedCategoryTitle)
        let categoryVC = CategoryListViewController(selectedCategory: viewModel.selectedCategoryTitle, viewModel: viewModelCategory)
        
        viewModelCategory.onCategorySelected = { [weak self] selectedCategory in
            self?.viewModel.selectCategory(selectedCategory)
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CustomTableViewCell {
                cell.configure(title: Localizable.NewTracker.category, subtitle: selectedCategory)
            }
            self?.dismiss(animated: true)
        }
        
        let navController = UINavigationController(rootViewController: categoryVC)
        present(navController, animated: true)
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleSelectionViewController()
        scheduleVC.selectedDays = viewModel.schedule
        scheduleVC.onScheduleSelected = { [weak self] selectedDays in
            self?.viewModel.setSchedule(selectedDays)
            self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            self?.updateTableHeight()
        }
        
        let navVC = UINavigationController(rootViewController: scheduleVC)
        present(navVC, animated: true)
    }
    
    // MARK: - Layout Updates
    private func updateTableHeight() {
        tableViewHeightConstraint.constant = viewModel.scheduleIsEmpty ? 150 : 165
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
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
        
        if indexPath.row == 0 {
            subtitle = viewModel.selectedCategoryTitle
        } else if indexPath.row == 1 {
            subtitle = viewModel.selectedDaysText
        }
        
        let isLastCell = indexPath.row == menuItems.count - 1
        cell.configure(title: title, subtitle: subtitle, isLastCell: isLastCell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 && !viewModel.scheduleIsEmpty {
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

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension NewTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return viewModel.emojis.count
        } else {
            return viewModel.colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            let emoji = viewModel.emojis[indexPath.item]
            let isSelected = (indexPath.item == viewModel.selectedEmojiIndex)
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            let color = viewModel.colors[indexPath.item]
            let isSelected = (indexPath.item == viewModel.selectedColorIndex)
            cell.configure(with: color, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let previous = viewModel.selectedEmojiIndex
            viewModel.selectEmoji(at: indexPath.item)
            var toReload: [IndexPath] = []
            if let previous = previous {
                toReload.append(IndexPath(item: previous, section: 0))
            }
            toReload.append(IndexPath(item: indexPath.item, section: 0))
            UIView.performWithoutAnimation {
                emojiCollectionView.reloadItems(at: toReload)
            }
            updateCreateButtonAppearance()
        } else {
            let previous = viewModel.selectedColorIndex
            viewModel.selectColor(at: indexPath.item)
            var toReload: [IndexPath] = []
            if let previous = previous {
                toReload.append(IndexPath(item: previous, section: 0))
            }
            toReload.append(IndexPath(item: indexPath.item, section: 0))
            UIView.performWithoutAnimation {
                colorCollectionView.reloadItems(at: toReload)
            }
            updateCreateButtonAppearance()
        }
    }
}

// MARK: - WeekDay+ShortName
extension WeekDay {
    var shortName: String {
        switch self {
        case .monday: return Localizable.WeekdayShort.monday
        case .tuesday: return Localizable.WeekdayShort.tuesday
        case .wednesday: return Localizable.WeekdayShort.wednesday
        case .thursday: return Localizable.WeekdayShort.thursday
        case .friday: return Localizable.WeekdayShort.friday
        case .saturday: return Localizable.WeekdayShort.saturday
        case .sunday: return Localizable.WeekdayShort.sunday
        }
    }
}
