import Foundation
import UIKit

final class TrackersViewModel: NSObject {
    
    struct Item {
        let id: UUID
        let title: String
        let emoji: String
        let color: UIColor
        let schedule: [WeekDay]?
        let completedDays: Int
        let isCompleted: Bool
        let isActive: Bool
    }
    
    struct Section {
        let title: String
        let items: [Item]
    }
    
    // MARK: - Outputs
    var onChange: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Public state for View
    private(set) var sections: [Section] = []
    private(set) var shouldShowFiltersButton: Bool = false
    var currentFilter: FilterType? { internalCurrentFilter }
    var isFilterActive: Bool { internalCurrentFilter?.isActive ?? false }
    var currentDate: Date { internalCurrentDate }
    
    // MARK: - Dependencies
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private var filterStorage = FilterStorage()
    
    // MARK: - Internal state
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var internalCurrentDate: Date = Date()
    private var internalCurrentFilter: FilterType? {
        didSet { filterStorage.current = internalCurrentFilter }
    }
    private var searchQuery: String = ""
    
    // MARK: - Init
    init(trackerStore: TrackerStore = TrackerStore(),
         categoryStore: TrackerCategoryStore = TrackerCategoryStore(),
         recordStore: TrackerRecordStore = TrackerRecordStore()) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init()
        
        self.trackerStore.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(categoriesDidChange),
                                               name: .trackerCategoriesDidChange,
                                               object: nil)
        
        self.internalCurrentFilter = filterStorage.current
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .trackerCategoriesDidChange, object: nil)
    }
    
    // MARK: - Public API
    func load() {
        do {
            _ = try categoryStore.fetchAllCategories()
            categories = try categoryStore.fetchCategories()
            completedTrackers = try recordStore.fetchRecords()
            recalc()
        } catch {
            onError?(error.localizedDescription)
        }
    }
    
    func setDate(_ date: Date) {
        internalCurrentDate = date
        recalc()
    }
    
    func setSearch(_ query: String) {
        searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        recalc()
    }
    
    func setFilter(_ filter: FilterType?) {
        internalCurrentFilter = filter
        recalc()
    }
    
    func applyFilterOption(_ option: FilterType) {
        switch option {
        case .all:
            setFilter(nil)
        case .today:
            setDate(Date())
            setFilter(nil)
        case .completed:
            setFilter(.completed)
        case .incompleted:
            setFilter(.incompleted)
        }
    }
    
    func toggleCompletion(for trackerId: UUID) {
        let isCompleted = isTrackerCompletedToday(trackerId: trackerId)
        if isCompleted {
            removeTrackerRecord(trackerId: trackerId)
        } else {
            addTrackerRecord(trackerId: trackerId)
        }
    }
    
    func addTracker(_ tracker: Tracker, in categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker, to: categoryTitle)
            load()
        } catch {
            onError?(Localizable.Errors.failedToSave)
        }
    }
    
    func updateTracker(_ tracker: Tracker, in categoryTitle: String) {
        do {
            try trackerStore.updateTracker(tracker, in: categoryTitle)
            load()
        } catch {
            onError?(Localizable.Errors.failedToUpdate)
        }
    }
    
    func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(tracker)
            load()
        } catch {
            onError?(Localizable.Errors.failedToDelete)
        }
    }
    
    func item(at indexPath: IndexPath) -> Item {
        sections[indexPath.section].items[indexPath.item]
    }
    
    // MARK: - Private helpers
    @objc private func categoriesDidChange() {
        load()
    }
    
    private func recalc() {
        let base = baseCategoriesForSelectedDate()
        shouldShowFiltersButton = !base.isEmpty
        
        let afterStatus = applyCurrentFilter(to: base)
        let afterSearch = applySearchFilter(to: afterStatus)
        
        sections = afterSearch.map { category in
            let items: [Item] = category.trackers.map { tracker in
                let isCompleted = isTrackerCompletedToday(trackerId: tracker.id)
                let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
                return Item(
                    id: tracker.id,
                    title: tracker.title,
                    emoji: tracker.emoji,
                    color: tracker.color,
                    schedule: tracker.schedule,
                    completedDays: completedDays,
                    isCompleted: isCompleted,
                    isActive: canCompleteTracker(for: internalCurrentDate)
                )
            }
            return Section(title: category.title, items: items)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onChange?()
        }
    }
    
    private func baseCategoriesForSelectedDate() -> [TrackerCategory] {
        let calendar = Calendar.current
        let selectedWeekday = calendar.component(.weekday, from: internalCurrentDate)
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
        guard let filter = internalCurrentFilter else { return categories }
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
        let query = searchQuery
        guard !query.isEmpty else { return categories }
        let lowercasedQuery = query.lowercased()
        return categories.compactMap { category in
            let trackers = category.trackers.filter { $0.title.lowercased().contains(lowercasedQuery) }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }
    
    private func addTrackerRecord(trackerId: UUID) {
        let record = TrackerRecord(trackerId: trackerId, date: internalCurrentDate)
        do {
            try recordStore.addRecord(record)
            completedTrackers.append(record)
            recalc()
        } catch {
            onError?(error.localizedDescription)
        }
    }
    
    private func removeTrackerRecord(trackerId: UUID) {
        let recordToRemove = completedTrackers.first {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: internalCurrentDate)
        }
        guard let record = recordToRemove else { return }
        
        do {
            try recordStore.removeRecord(record)
            completedTrackers.removeAll { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: internalCurrentDate) }
            recalc()
        } catch {
            onError?(error.localizedDescription)
        }
    }
    
    private func isTrackerCompletedToday(trackerId: UUID) -> Bool {
        completedTrackers.contains { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: internalCurrentDate) }
    }
    
    private func canCompleteTracker(for date: Date) -> Bool {
        return date <= Date()
    }
}

extension TrackersViewModel: TrackerStoreDelegate {
    func didUpdateTrackers() {
        load()
    }
}
