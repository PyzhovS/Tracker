import Foundation
import UIKit

final class TrackersViewController: UIViewController, UISearchResultsUpdating {
    
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var filterStorage = FilterStorage()
    
    private var visibleCategories: [TrackerCategory] = []
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private var currentDate = Date()
    
    private var currentFilter: FilterType? {
        didSet {
            filterStorage.current = currentFilter
            updateFilterButtonAppearance()
            filterTrackersBySelectedDate()
        }
    }
    
    private var isSearching: Bool {
        let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return !text.isEmpty
    }
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = Localizable.Trackers.searchPlaceholder
        sc.searchBar.returnKeyType = .done
        sc.searchBar.enablesReturnKeyAutomatically = false
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        UpdateUI()
        currentFilter = filterStorage.current // если не выбирали — nil (все трекеры)
        filterTrackersBySelectedDate()
        trackerStore.delegate = self
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionInsets()
    }
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func loadData() {
        do {
            _ = try trackerCategoryStore.fetchAllCategories()
            categories = try trackerCategoryStore.fetchCategories()
            completedTrackers = try trackerRecordStore.fetchRecords()
            filterTrackersBySelectedDate()
        } catch {
            print("Ошибка загрузки данных: \(error)")
        }
    }
    
    private func UpdateUI() {
        let isEmpty = visibleCategories.isEmpty
        placeholder.isHidden = !isEmpty
        labelSearch.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        
        if isEmpty {
            if isFilterActive || isSearching {
                labelSearch.text = NSLocalizedString("empty.nothingFound", comment: "Nothing found")
            } else {
                labelSearch.text = Localizable.Trackers.emptyTitle
            }
        }
    }
    
    private var isFilterActive: Bool {
        switch currentFilter {
        case .completed, .incompleted:
            return true
        default:
            return false
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
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
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
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTrackerTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelSearch: UILabel = {
        let label = UILabel()
        label.text = Localizable.Trackers.emptyTitle
        label.textColor = .black
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
        view.addSubview(datePicker)
        view.addSubview(labelTitle)
        view.addSubview(addTracker)
        view.addSubview(filtersButton)
        
        [placeholder,
         labelTitle,
         addTracker,
         labelSearch,
         datePicker,
         collectionView,
         filtersButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        setupConstraint()
    }
    
    private func updateFilterButtonAppearance() {
        let titleColor: UIColor = isFilterActive ? .red : .white
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
            self?.didCreateTracker(tracker, in: category)
        }
        present(UINavigationController(rootViewController: newTrackerVC), animated: true)
    }
    
    @objc private func filtersButtonTapped() {
        let vc = FiltersViewController(selectedFilter: currentFilter)
        vc.onFilterSelected = { [weak self] filter in
            self?.applySelectedFilter(filter)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func applySelectedFilter(_ filter: FilterType) {
        switch filter {
        case .all:
            currentFilter = nil
        case .today:
            datePicker.date = Date()
            currentDate = datePicker.date
            currentFilter = nil
        case .completed:
            currentFilter = .completed
        case .incompleted:
            currentFilter = .incompleted
        }
    }
    
    private func addTrackerRecord(trackerId: UUID) {
        let record = TrackerRecord(trackerId: trackerId, date: currentDate)
        do {
            try trackerRecordStore.addRecord(record)
            completedTrackers.append(record)
            filterTrackersBySelectedDate()
        } catch {
            print("Error adding record: \(error)")
        }
    }
    
    private func removeTrackerRecord(trackerId: UUID) {
        let recordToRemove = completedTrackers.first {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        
        if let record = recordToRemove {
            do {
                try trackerRecordStore.removeRecord(record)
                completedTrackers.removeAll { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                filterTrackersBySelectedDate()
            } catch {
                print("Error removing record: \(error)")
            }
        }
    }
    
    private func isTrackerCompletedToday(trackerId: UUID) -> Bool {
        completedTrackers.contains { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
    }
    
    private func canCompleteTracker(for date: Date) -> Bool {
        return date <= Date()
    }
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
        filterTrackersBySelectedDate()
    }
    
    private func baseCategoriesForSelectedDate() -> [TrackerCategory] {
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: currentDate)
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                if let schedule = tracker.schedule {
                    return schedule.contains { $0.rawValue == selectedWeekday }
                } else {
                    return true
                }
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                title: category.title,
                trackers: filteredTrackers
            )
        }
    }
    
    private func applyCurrentFilter(to categories: [TrackerCategory]) -> [TrackerCategory] {
        guard let filter = currentFilter else { return categories }
        switch filter {
        case .completed:
            return categories.compactMap { category in
                let trackers = category.trackers.filter { isTrackerCompletedToday(trackerId: $0.id) }
                return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
            }
        case .incompleted:
            return categories.compactMap { category in
                let trackers = category.trackers.filter { !isTrackerCompletedToday(trackerId: $0.id) }
                return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
            }
        case .all, .today:
            return categories
        }
    }
    
    private func applySearchFilter(to categories: [TrackerCategory]) -> [TrackerCategory] {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !query.isEmpty else { return categories }
        let lowercasedQuery = query.lowercased()
        return categories.compactMap { category in
            let trackers = category.trackers.filter { $0.title.lowercased().contains(lowercasedQuery) }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }
    
    private func filterTrackersBySelectedDate() {
        let base = baseCategoriesForSelectedDate()
        
        filtersButton.isHidden = base.isEmpty
        updateCollectionInsets()
        
        let afterStatus = applyCurrentFilter(to: base)
        let afterSearch = applySearchFilter(to: afterStatus)
        visibleCategories = afterSearch
        
        collectionView.reloadData()
        UpdateUI()
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
            
            collectionView.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 24),
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
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        filterTrackersBySelectedDate()
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = isTrackerCompletedToday(trackerId: tracker.id)
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        cell.configure(
            with: tracker.title,
            emoji: tracker.emoji,
            color: tracker.color,
            completedDays: completedDays,
            isCompleted: isCompleted,
            isActive: canCompleteTracker(for: currentDate)
        )
        
        cell.completionHandler = { [weak self] in
            guard let self = self else { return }
            let currentlyCompleted = self.isTrackerCompletedToday(trackerId: tracker.id)
            if currentlyCompleted {
                self.removeTrackerRecord(trackerId: tracker.id)
            } else {
                self.addTrackerRecord(trackerId: tracker.id)
            }
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
        header.titleLabel.text = visibleCategories[indexPath.section].title
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
        let itemsCount = visibleCategories[section].trackers.count
        
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

extension TrackersViewController {
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker, to: categoryTitle)
            loadData()
        } catch {
            print("Error saving tracker: \(error)")
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        loadData()
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return UIMenu() }
            
            let editAction = UIAction(
                title: Localizable.ContextMenu.edit,
                image: UIImage(systemName: "square.and.pencil")
            ) { [weak self] _ in
                self?.editTracker(tracker, at: indexPath)
            }
            
            let deleteAction = UIAction(
                title: Localizable.Common.delete,
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.deleteTracker(tracker, at: indexPath)
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
    
    private func editTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        let editVC = NewTrackerViewController()
        let currentCategoryTitle = visibleCategories[indexPath.section].title
        editVC.mode = .edit(tracker, currentCategoryTitle)
        editVC.onTrackerUpdated = { [weak self] updatedTracker, categoryTitle in
            self?.updateTracker(updatedTracker, categoryTitle: categoryTitle, at: indexPath)
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: Localizable.Alerts.deleteTitle,
            message: Localizable.Alerts.deleteMessage,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: Localizable.Common.delete, style: .destructive) { [weak self] _ in
            self?.confirmDeleteTracker(tracker, at: indexPath)
        })
        
        alert.addAction(UIAlertAction(title: Localizable.Common.cancel, style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func confirmDeleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        do {
            try trackerStore.deleteTracker(tracker)
            
            if let categoryIndex = categories.firstIndex(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) {
                var category = categories[categoryIndex]
                var trackers = category.trackers
                trackers.removeAll { $0.id == tracker.id }
                
                if trackers.isEmpty {
                    categories.remove(at: categoryIndex)
                } else {
                    categories[categoryIndex] = TrackerCategory(title: category.title, trackers: trackers)
                }
            }
            
            filterTrackersBySelectedDate()
            
        } catch {
            print("Error deleting tracker: \(error)")
            showError(Localizable.Errors.failedToDelete)
        }
    }
    
    private func updateTracker(_ tracker: Tracker, categoryTitle: String, at indexPath: IndexPath) {
        do {
            try trackerStore.updateTracker(tracker, in: categoryTitle)
            loadData()
        } catch {
            print("Error updating tracker: \(error)")
            showError(Localizable.Errors.failedToUpdate)
        }
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

