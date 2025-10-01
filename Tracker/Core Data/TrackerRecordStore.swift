import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // Проверка существования записи для трекера в конкретный день
    private func recordExists(trackerId: UUID, on date: Date) throws -> Bool {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return false
        }
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND (date >= %@) AND (date < %@)",
            trackerId as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg
        )
        let count = try context.count(for: request)
        return count > 0
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        // Предотвращаем дублирование записи в один и тот же день
        if try recordExists(trackerId: record.trackerId, on: record.date) {
            return
        }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.trackerId = record.trackerId
        recordCoreData.date = record.date
        
        CoreDataManager.shared.saveContext()
    }
    
    func removeRecord(_ record: TrackerRecord) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: record.date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND (date >= %@) AND (date < %@)",
            record.trackerId as CVarArg,
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )
        
        let recordsToDelete = try context.fetch(request)
        for item in recordsToDelete {
            context.delete(item)
        }
        if !recordsToDelete.isEmpty {
            CoreDataManager.shared.saveContext()
        }
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let recordsCoreData = try context.fetch(request)
        
        return recordsCoreData.compactMap { recordCoreData in
            guard let trackerId = recordCoreData.trackerId,
                  let date = recordCoreData.date else {
                return nil
            }
            
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
}
