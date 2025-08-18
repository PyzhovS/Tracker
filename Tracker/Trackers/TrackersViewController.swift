import Foundation
import UIKit

class TrackersViewController:UIViewController {
   
   
   private var categories: [TrackerCategory] = []
   private var completedTrackers: [TrackerRecord] = []
   private var currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        UpdateUI()
        
    }
    
    private func loadData() {
          // Загрузка тестовых данных (в реальном приложении - из базы данных)
          let sampleTrackers = [
              Tracker(
                  id: UUID(),
                  title: "Поливать растения",
                  emoji: "🌱",
                  color: .systemGreen,
                  schedule: [.monday, .wednesday, .friday]
              ),
              Tracker(
                  id: UUID(),
                  title: "Кошка заслоняла камеру",
                  emoji: "🐱",
                  color: .systemOrange,
                  schedule: nil
              )
          ]
          
          categories = [
              TrackerCategory(title: "Домашний уют", trackers: [sampleTrackers[0]]),
              TrackerCategory(title: "Радостные мелочи", trackers: [sampleTrackers[1]])
          ]
          
        UpdateUI()
      }
    
    private func UpdateUI() {
        let isEmpty = categories.isEmpty
        placeholder.isHidden = !isEmpty
        labelSearch.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collection.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
  //      collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        return collection
        
    }()
    
    private lazy var placeholder: UIImageView = {
        let imageView = UIImageView()
        if let avatarImage = UIImage(named: "error") {
            imageView.image = avatarImage
        }
  //      imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    private lazy var labelTitle: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .black
  //      label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
 
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Поиск"
        search.backgroundImage = UIImage()
        search.layer.cornerRadius = 10
        search.layer.masksToBounds = true
 //       search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
//        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var addTracker: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "addTracker"
        if let addTracker = UIImage(named: "AddTracker") {
            button.setImage(addTracker, for: .normal)
        }
        button.tintColor = .black
 //       button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var labelSearch: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .black
    //    label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    func setupUI() {
        [placeholder, labelTitle, searchBar, addTracker, labelSearch, datePicker, collectionView].forEach {$0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)}
        
        
        
        setupConstraint()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 36) / 2
        let coloredPartHeight: CGFloat = 90
        let whitePartHeight: CGFloat = 58
        return CGSize(width: width, height: coloredPartHeight + whitePartHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
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
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
        collectionView.reloadData()
    }
        
    func setupConstraint() {
        NSLayoutConstraint.activate([
            
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.widthAnchor.constraint(equalToConstant: 80),
            placeholder.heightAnchor.constraint(equalToConstant: 80),
            
            addTracker.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            addTracker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addTracker.widthAnchor.constraint(equalToConstant: 42),
            addTracker.heightAnchor.constraint(equalToConstant: 42),
            
            datePicker.centerYAnchor.constraint(equalTo: addTracker.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21.5),
            
            labelTitle.topAnchor.constraint(equalTo: addTracker.bottomAnchor, constant: 1),
            labelTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
             
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
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
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = categories[indexPath.section].trackers[indexPath.item]
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
        header.titleLabel.text = categories[indexPath.section].title
        return header
    }
}

extension TrackersViewController {
    func didCreateTracker(_ tracker: Tracker, in categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let category = categories[index]
            var trackers = category.trackers
            trackers.append(tracker)
            categories[index] = TrackerCategory(title: category.title, trackers: trackers)
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
        collectionView.reloadData()
    }
}
