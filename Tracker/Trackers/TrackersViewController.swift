import Foundation
import UIKit

final class TrackersViewController: UIViewController, UISearchBarDelegate {
    
    private var visibleCategories: [TrackerCategory] = []
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private var currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        UpdateUI()
        filterTrackersBySelectedDate()
    }
    
    private func UpdateUI() {
        let isEmpty = visibleCategories.isEmpty
        placeholder.isHidden = !isEmpty
        labelSearch.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collection.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collection.dataSource = self
        collection.delegate = self
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
        label.text = "Трекеры"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Поиск"
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
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTrackerTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var labelSearch: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(placeholder)
        view.addSubview(labelSearch)
        view.addSubview(searchBar)
        view.addSubview(datePicker)
        view.addSubview(labelTitle)
        view.addSubview(addTracker)
        
        [placeholder,
         labelTitle,
         searchBar,
         addTracker,
         labelSearch,
         datePicker,
         collectionView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        setupConstraint()
    }
    
    @objc private func addTrackerTapped() {
        let newTrackerVC = NewTrackerViewController()
        newTrackerVC.onTrackerCreated = { [weak self] tracker, category in
            self?.didCreateTracker(tracker, in: category)
        }
        present(UINavigationController(rootViewController: newTrackerVC), animated: true)
    }
    
    private func addTrackerRecord(trackerId: UUID) {
        let record = TrackerRecord(trackerId: trackerId, date: currentDate)
        completedTrackers.append(record)
        collectionView.reloadData()
    }
    
    private func removeTrackerRecord(trackerId: UUID) {
        completedTrackers.removeAll { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
        collectionView.reloadData()
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
    
    private func filterTrackersBySelectedDate() {
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: currentDate)
        visibleCategories = categories.compactMap { category in
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
            
            searchBar.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -9),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            labelSearch.topAnchor.constraint(equalTo: placeholder.bottomAnchor, constant: 8),
            labelSearch.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
            if isCompleted {
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
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = visibleCategories[indexPath.section]
        let itemsCount = section.trackers.count
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
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let existingCategory = categories[index]
            let updatedCategory = TrackerCategory(
                title: existingCategory.title,
                trackers: existingCategory.trackers + [tracker]
            )
            categories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
        filterTrackersBySelectedDate()
    }
}
