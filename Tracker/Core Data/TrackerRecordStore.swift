import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.trackerId = record.trackerId
        recordCoreData.date = record.date
        
        CoreDataManager.shared.saveContext()
    }
    
    func removeRecord(_ record: TrackerRecord) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            record.date as CVarArg
        )
        
        if let recordToDelete = try context.fetch(request).first {
            context.delete(recordToDelete)
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
