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
            postCategoriesDidChange()
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
            postCategoriesDidChange()
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
    
    // MARK: - Rename & Delete
    func renameCategory(from oldTitle: String, to newTitle: String) throws {
        // Проверка на дубль нового названия
        if oldTitle != newTitle {
            let dupRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            dupRequest.predicate = NSPredicate(format: "title == %@", newTitle)
            if try !context.fetch(dupRequest).isEmpty {
                throw CategoryError.categoryAlreadyExists
            }
        }
        
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", oldTitle)
        
        guard let category = try context.fetch(request).first else {
            throw CategoryError.failedToUpdate
        }
        
        category.title = newTitle
        
        do {
            try context.save()
            postCategoriesDidChange()
        } catch {
            context.rollback()
            throw CategoryError.failedToUpdate
        }
    }
    
    func deleteCategory(title: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        guard let category = try context.fetch(request).first else {
            throw CategoryError.failedToDelete
        }
        
        context.delete(category)
        
        do {
            try context.save()
            postCategoriesDidChange()
        } catch {
            context.rollback()
            throw CategoryError.failedToDelete
        }
    }
    
    // MARK: - Notifications
    private func postCategoriesDidChange() {
        NotificationCenter.default.post(name: .trackerCategoriesDidChange, object: nil)
    }
}

enum CategoryError: Error, LocalizedError {
    case categoryAlreadyExists
    case failedToSave
    case failedToFetch
    case failedToDelete
    case failedToUpdate
    
    var errorDescription: String? {
        switch self {
        case .categoryAlreadyExists:
            return Localizable.Errors.categoryAlreadyExists
        case .failedToSave:
            return Localizable.Errors.failedToSave
        case .failedToFetch:
            return Localizable.Errors.failedToFetch
        case .failedToDelete:
            return Localizable.Errors.failedToDelete
        case .failedToUpdate:
            return Localizable.Errors.failedToUpdate
        }
    }
}

extension Notification.Name {
    static let trackerCategoriesDidChange = Notification.Name("trackerCategoriesDidChange")
}
