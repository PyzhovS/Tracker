import Foundation
import UIKit

final class TrackersViewController: UIViewController, UISearchBarDelegate {
    
    private let viewModel = TrackersViewModel()
    
    private var isSearching: Bool {
        let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return !text.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyTheme()
        UpdateUI()
        
        // Bindings
        viewModel.onChange = { [weak self] in
            guard let self = self else { return }
            self.filtersButton.isHidden = !self.viewModel.shouldShowFiltersButton
            self.updateCollectionInsets()
            self.updateFilterButtonAppearance()
            self.collectionView.reloadData()
            self.UpdateUI()
        }
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        
        viewModel.load()
        
        // восстановим фильтр на кнопке (если был)
        updateFilterButtonAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionInsets()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // При смене темы обновим оформление
        applyTheme()
    }
    
    private func UpdateUI() {
        let isEmpty = viewModel.sections.isEmpty
        placeholder.isHidden = !isEmpty
        labelSearch.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        
        if isEmpty {
            if viewModel.isFilterActive || isSearching {
                labelSearch.text = NSLocalizedString("empty.nothingFound", comment: "Nothing found")
            } else {
                labelSearch.text = Localizable.Trackers.emptyTitle
            }
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collection.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collection.dataSource = self
        collection.delegate = self
        collection.alwaysBounceVertical = true
        collection.backgroundColor = .clear
        return collection
    }()
    
    private lazy var placeholder: UIImageView = {
        let imageView = UIImageView()
        if let avatarImage = UIImage(named: "error") {
            imageView.image = avatarImage
        }
        return imageView
    }()
    
    private lazy var labelTitle: UILabel = {
        let label = UILabel()
        label.text = Localizable.Trackers.title
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = Localizable.Trackers.searchPlaceholder
        search.backgroundImage = UIImage()
        search.layer.cornerRadius = 10
        search.layer.masksToBounds = true
        search.delegate = self
        search.returnKeyType = .done
        search.enablesReturnKeyAutomatically = false
        return search
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var addTracker: UIButton = {
        let button = UIButton(type: .system)
        if let image = UIImage(named: "AddTracker") {
            button.setImage(image, for: .normal)
        }
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTrackerTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelSearch: UILabel = {
        let label = UILabel()
        label.text = Localizable.Trackers.emptyTitle
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters.button", comment: "Filters"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        return button
    }()
    
    func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(placeholder)
        view.addSubview(labelSearch)
        view.addSubview(searchBar)
        view.addSubview(datePicker)
        view.addSubview(labelTitle)
        view.addSubview(addTracker)
        view.addSubview(filtersButton)
        
        [placeholder,
         labelTitle,
         searchBar,
         addTracker,
         labelSearch,
         datePicker,
         collectionView,
         filtersButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        setupConstraint()
    }
    
    private func applyTheme() {
        // Фон экрана
        view.backgroundColor = .systemBackground
        
        // Поиск
        if #available(iOS 13.0, *) {
            let tf = searchBar.searchTextField
            tf.backgroundColor = .tertiarySystemFill
            tf.textColor = .label
            tf.tintColor = .label
            tf.attributedPlaceholder = NSAttributedString(
                string: Localizable.Trackers.searchPlaceholder,
                attributes: [.foregroundColor: UIColor.secondaryLabel]
            )
            tf.leftView?.tintColor = .secondaryLabel
        }
        
        // Дата: светлую не трогаем; в темной — фон YP Gray Dark и черный текст.
        if traitCollection.userInterfaceStyle == .dark {
            datePicker.backgroundColor = UIColor(named: "YP Gray Dark") ?? .secondarySystemBackground
            datePicker.overrideUserInterfaceStyle = .light   // черный текст в .compact
            datePicker.tintColor = .black                    // акцентные элементы
        } else {
            datePicker.backgroundColor = nil
            datePicker.overrideUserInterfaceStyle = .unspecified
            datePicker.tintColor = view.tintColor
        }
        
        // Кнопка добавления
        addTracker.tintColor = .label
        
        // Текстовые цвета
        labelTitle.textColor = .label
        labelSearch.textColor = .secondaryLabel
        
        // Коллекция
        collectionView.backgroundColor = .clear
        
        // Кнопка фильтров (фон системный — сам адаптируется)
        updateFilterButtonAppearance()
    }
    
    private func updateFilterButtonAppearance() {
        let titleColor: UIColor = viewModel.isFilterActive ? .systemRed : .white
        filtersButton.setTitleColor(titleColor, for: .normal)
    }
    
    private func updateCollectionInsets() {
        let buttonHeight = filtersButton.isHidden ? 0 : (filtersButton.bounds.height)
        let extraSpacing: CGFloat = filtersButton.isHidden ? 0 : 16
        let bottomInset = buttonHeight + extraSpacing
        if collectionView.contentInset.bottom != bottomInset {
            collectionView.contentInset.bottom = bottomInset
            collectionView.scrollIndicatorInsets.bottom = bottomInset
        }
    }
    
    @objc private func addTrackerTapped() {
        let newTrackerVC = NewTrackerViewController()
        newTrackerVC.onTrackerCreated = { [weak self] tracker, category in
            self?.viewModel.addTracker(tracker, in: category)
        }
        present(UINavigationController(rootViewController: newTrackerVC), animated: true)
    }
    
    @objc private func filtersButtonTapped() {
        let vc = FiltersViewController(selectedFilter: viewModel.currentFilter)
        vc.onFilterSelected = { [weak self] filter in
            self?.applySelectedFilter(filter)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func applySelectedFilter(_ filter: FilterType) {
        switch filter {
        case .today:
            // синхронизируем UI datePicker с VM
            let today = Date()
            datePicker.date = today
            viewModel.applyFilterOption(.today)
        case .all:
            viewModel.applyFilterOption(.all)
        case .completed:
            viewModel.applyFilterOption(.completed)
        case .incompleted:
            viewModel.applyFilterOption(.incompleted)
        }
    }
    
    @objc private func dateChanged() {
        viewModel.setDate(datePicker.date)
    }
    
    func setupConstraint() {
        NSLayoutConstraint.activate([
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.widthAnchor.constraint(equalToConstant: 80),
            placeholder.heightAnchor.constraint(equalToConstant: 80),
            
            addTracker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            addTracker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addTracker.widthAnchor.constraint(equalToConstant: 42),
            addTracker.heightAnchor.constraint(equalToConstant: 42),
            
            datePicker.centerYAnchor.constraint(equalTo: addTracker.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21.5),
            
            labelTitle.topAnchor.constraint(equalTo: addTracker.bottomAnchor, constant: 1),
            labelTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -9),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            labelSearch.topAnchor.constraint(equalTo: placeholder.bottomAnchor, constant: 8),
            labelSearch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setSearch(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let item = viewModel.item(at: indexPath)
        
        cell.configure(
            with: item.title,
            emoji: item.emoji,
            color: item.color,
            completedDays: item.completedDays,
            isCompleted: item.isCompleted,
            isActive: item.isActive
        )
        
        cell.completionHandler = { [weak self] in
            self?.viewModel.toggleCompletion(for: item.id)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "Header",
            for: indexPath
        ) as? HeaderView else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = viewModel.sections[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let coloredSectionHeight: CGFloat = 90
        let infoSectionHeight: CGFloat = 58
        let cellHeight = coloredSectionHeight + infoSectionHeight
        let availableWidth = collectionView.bounds.width - 41
        let cellWidth = availableWidth / 2
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemsCount = viewModel.sections[section].items.count
        
        if itemsCount == 1 {
            let cellWidth = (collectionView.bounds.width - 41) / 2
            let extraRightInset = collectionView.bounds.width - 16 - cellWidth - 16
            return UIEdgeInsets(top: 0, left: 16, bottom: 9, right: extraRightInset)
        } else {
            return UIEdgeInsets(top: 0, left: 16, bottom: 9, right: 16)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let item = viewModel.item(at: indexPath)
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return UIMenu() }
            
            let editAction = UIAction(
                title: Localizable.ContextMenu.edit
            ) { [weak self] _ in
                self?.editTracker(item, at: indexPath)
            }
            
            let deleteAction = UIAction(
                title: Localizable.Common.delete,
                attributes: .destructive
            ) { [weak self] _ in
                self?.confirmDeleteTracker(item, at: indexPath)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let nsIndexPath = configuration.identifier as? NSIndexPath else { return nil }
        let indexPath = IndexPath(item: nsIndexPath.item, section: nsIndexPath.section)
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        let topRect = CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: 90)
        parameters.visiblePath = UIBezierPath(roundedRect: topRect, cornerRadius: 12)
        
        return UITargetedPreview(view: cell.contentView, parameters: parameters)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let nsIndexPath = configuration.identifier as? NSIndexPath else { return nil }
        let indexPath = IndexPath(item: nsIndexPath.item, section: nsIndexPath.section)
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        let topRect = CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: 90)
        parameters.visiblePath = UIBezierPath(roundedRect: topRect, cornerRadius: 12)
        
        return UITargetedPreview(view: cell.contentView, parameters: parameters)
    }
    
    private func editTracker(_ item: TrackersViewModel.Item, at indexPath: IndexPath) {
        let editVC = NewTrackerViewController()
        let currentCategoryTitle = viewModel.sections[indexPath.section].title
        
        // Восстанавливаем модель Tracker из item для редактирования, включая schedule
        let tracker = Tracker(id: item.id, title: item.title, emoji: item.emoji, color: item.color, schedule: item.schedule)
        editVC.mode = .edit(tracker, currentCategoryTitle)
        
        editVC.onTrackerUpdated = { [weak self] updatedTracker, categoryTitle in
            self?.viewModel.updateTracker(updatedTracker, in: categoryTitle)
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true)
    }
    
    private func confirmDeleteTracker(_ item: TrackersViewModel.Item, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: Localizable.Alerts.deleteTitle,
            message: Localizable.Alerts.deleteMessage,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: Localizable.Common.delete, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            let tracker = Tracker(id: item.id, title: item.title, emoji: item.emoji, color: item.color, schedule: item.schedule)
            self.viewModel.deleteTracker(tracker)
        })
        
        alert.addAction(UIAlertAction(title: Localizable.Common.cancel, style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: Localizable.Alerts.errorTitle,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Localizable.Common.ok, style: .default))
        present(alert, animated: true)
    }
}
