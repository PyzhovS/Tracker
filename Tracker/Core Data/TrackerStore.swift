import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    private var isCoreDataReady = false
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(coreDataDidInitialize),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
        
        checkCoreDataReadiness()
    }
    
    private func checkCoreDataReadiness() {
        if context.persistentStoreCoordinator != nil {
            isCoreDataReady = true
            setupFetchedResultsController()
        }
    }
    
    @objc private func coreDataDidInitialize(notification: NSNotification) {
        if !isCoreDataReady {
            checkCoreDataReadiness()
        }
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }
    
    func convertToTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        guard
            let id = trackerCoreData.id,
            let title = trackerCoreData.title,
            let emoji = trackerCoreData.emoji,
            let colorHex = trackerCoreData.color
        else {
            return nil
        }
        
        let color = UIColor(hex: colorHex) ?? .systemBlue
        
        let schedule: [WeekDay]?
        if let scheduleData = trackerCoreData.schedule {
            schedule = try? JSONDecoder().decode([WeekDay].self, from: scheduleData)
        } else {
            schedule = nil
        }
        
        return Tracker(
            id: id,
            title: title,
            emoji: emoji,
            color: color,
            schedule: schedule
        )
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.toHex()
        
        if let schedule = tracker.schedule {
            trackerCoreData.schedule = try? JSONEncoder().encode(schedule)
        }
        
        let categoryStore = TrackerCategoryStore()
        let category = try categoryStore.fetchOrCreateCategory(with: categoryTitle)
        trackerCoreData.category = category
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
            throw error
        }
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let trackersCoreData = try context.fetch(request)
        return trackersCoreData.compactMap { convertToTracker(from: $0) }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        var r, g, b, a: CGFloat
        let length = hexSanitized.count
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    func toHex() -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let a = Float(components.count >= 4 ? components[3] : 1.0)
        
        return String(format: "#%02lX%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255),
                      lroundf(a * 255))
    }
}
