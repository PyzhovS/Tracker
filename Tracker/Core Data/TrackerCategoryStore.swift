import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    
    func fetchAllCategories() throws -> [String] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categoriesCoreData = try context.fetch(request)
        
        return categoriesCoreData.compactMap { $0.title }
    }
    
    func addNewCategory(title: String) throws {
        
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        let existingCategories = try context.fetch(request)
        
        guard existingCategories.isEmpty else {
            throw CategoryError.categoryAlreadyExists
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw CategoryError.failedToSave
        }
    }
    
    func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let category = try context.fetch(request).first {
            return category
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        
        do {
            try context.save()
            return newCategory
        } catch {
            context.rollback()
            throw CategoryError.failedToSave
        }
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categoriesCoreData = try context.fetch(request)
        
        return categoriesCoreData.compactMap { categoryCoreData in
            guard let title = categoryCoreData.title else { return nil }
            
            let trackerStore = TrackerStore()
            let trackers: [Tracker] = (categoryCoreData.trackers as? Set<TrackerCoreData>)?.compactMap { trackerCoreData in
                return trackerStore.convertToTracker(from: trackerCoreData)
            } ?? []
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
}

enum CategoryError: Error, LocalizedError {
    case categoryAlreadyExists
    case failedToSave
    case failedToFetch
    
    var errorDescription: String? {
        switch self {
        case .categoryAlreadyExists:
            return Localizable.Errors.categoryAlreadyExists
        case .failedToSave:
            return Localizable.Errors.failedToSave
        case .failedToFetch:
            return Localizable.Errors.failedToFetch
        }
    }
}

