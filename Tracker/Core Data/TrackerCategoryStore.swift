import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // Получение всех категорий из Core Data (только названия)
    func fetchAllCategories() throws -> [String] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categoriesCoreData = try context.fetch(request)
        
        return categoriesCoreData.compactMap { $0.title }
    }
    
    func addNewCategory(title: String) throws {
        // Проверяем, что категория с таким названием не существует
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
    
    // Получение или создание категории (для привязки трекеров)
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
    
    // Метод для совместимости со старым кодом
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
            return "Категория с таким названием уже существует"
        case .failedToSave:
            return "Не удалось сохранить категорию"
        case .failedToFetch:
            return "Не удалось загрузить категории"
        }
    }
}
