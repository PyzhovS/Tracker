import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let category = try context.fetch(request).first {
            return category
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        CoreDataManager.shared.saveContext()
        
        return newCategory
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categoriesCoreData = try context.fetch(request)
        
        return categoriesCoreData.compactMap { categoryCoreData in
            guard let title = categoryCoreData.title,
                  let trackersSet = categoryCoreData.trackers as? Set<TrackerCoreData> else {
                return nil
            }
            
            let trackers = trackersSet.compactMap { trackerCoreData -> Tracker? in
                let trackerStore = TrackerStore()
                return trackerStore.convertToTracker(from: trackerCoreData)
            }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
}
