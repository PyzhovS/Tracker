// StatisticsViewModel.swift
import Foundation
import UIKit

struct StatisticItem: Codable {
    let title: String
    let value: Int
}

final class StatisticsViewModel {
    
    enum State {
        case empty
        case data([StatisticItem])
    }
    
    // MARK: - Outputs
    var onStateChange: ((State) -> Void)?
    
    // MARK: - Deps
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    
    // MARK: - Cache (UserDefaults)
    private let defaults = UserDefaults.standard
    private let cacheKey = "Statistics.Cache.Items"
    
    // MARK: - Lifecycle
    func load() {
        if let cached = loadCache() {
            if cached.isEmpty {
                onStateChange?(.empty)
            } else {
                onStateChange?(.data(cached))
            }
        } else {
            onStateChange?(.empty)
        }
        recalcAndPublish()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidSave),
                                               name: .NSManagedObjectContextDidSave,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func contextDidSave() {
        recalcAndPublish()
    }
    
    private func recalcAndPublish() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let trackers = try self.trackerStore.fetchTrackers()
                let records = try self.recordStore.fetchRecords()
                let items = self.computeStatistics(trackers: trackers, records: records)
                
                DispatchQueue.main.async {
                    if items.isEmpty {
                        self.onStateChange?(.empty)
                    } else {
                        self.onStateChange?(.data(items))
                    }
                    self.saveCache(items: items)
                }
            } catch {
                DispatchQueue.main.async {
                    self.onStateChange?(.empty)
                }
            }
        }
    }
    
    private func computeStatistics(trackers: [Tracker], records: [TrackerRecord]) -> [StatisticItem] {
        guard !records.isEmpty else { return [] }
        
        let calendar = Calendar.current
        func startOfDay(_ date: Date) -> Date { calendar.startOfDay(for: date) }
        
        let grouped = Dictionary(grouping: records, by: { startOfDay($0.date) })
        let days = grouped.keys.sorted()
        
        var bestStreak = 0
        var currentStreak = 0
        var previousDay: Date?
        for day in days {
            if let prev = previousDay,
               calendar.dateComponents([.day], from: prev, to: day).day == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            bestStreak = max(bestStreak, currentStreak)
            previousDay = day
        }
        
        func scheduledTrackersIDs(on date: Date) -> [UUID] {
            let weekday = calendar.component(.weekday, from: date)
            return trackers.compactMap { tracker in
                if let schedule = tracker.schedule {
                    return schedule.contains(where: { $0.rawValue == weekday }) ? tracker.id : nil
                } else {
                    return tracker.id
                }
            }
        }
        var idealDays = 0
        for day in days {
            let scheduled = scheduledTrackersIDs(on: day)
            guard !scheduled.isEmpty else { continue }
            let completedIDs = Set(grouped[day, default: []].map { $0.trackerId })
            if Set(scheduled).isSubset(of: completedIDs) {
                idealDays += 1
            }
        }
        
        let totalCompletions = records.count
        let average = Int((Double(totalCompletions) / Double(days.count)).rounded())
        
        return [
            StatisticItem(title: Localizable.Statistics.bestPeriod, value: bestStreak),
            StatisticItem(title: Localizable.Statistics.idealDays, value: idealDays),
            StatisticItem(title: Localizable.Statistics.completedCount, value: totalCompletions),
            StatisticItem(title: Localizable.Statistics.averageValue, value: average)
        ]
    }
    
    private func loadCache() -> [StatisticItem]? {
        guard let data = defaults.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode([StatisticItem].self, from: data)
    }
    
    private func saveCache(items: [StatisticItem]) {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: cacheKey)
        } else {
            defaults.removeObject(forKey: cacheKey)
        }
    }
}
