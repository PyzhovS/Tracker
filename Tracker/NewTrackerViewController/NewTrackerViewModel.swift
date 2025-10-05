import UIKit

final class NewTrackerViewModel {
    
    enum Mode {
        case create
        case edit(Tracker, String) // (текущий трекер, его категория)
    }
    
    // MARK: - Outputs
    var onChange: (() -> Void)?
    
    // MARK: - Public read-only state for View
    private(set) var mode: Mode
    private(set) var name: String = ""
    private(set) var selectedCategory: String?
    private(set) var schedule: [WeekDay] = []
    private(set) var selectedEmoji: String?
    private(set) var selectedColor: UIColor?
    
    // Наборы для UI
    let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    // Для режима редактирования — сохраняем id и исходную категорию
    private var originalId: UUID?
    private var originalCategory: String?
    
    // MARK: - Derived
    var selectedEmojiIndex: Int? {
        guard let value = selectedEmoji else { return nil }
        return emojis.firstIndex(of: value)
    }
    var selectedColorIndex: Int? {
        guard let value = selectedColor else { return nil }
        return colors.firstIndex(where: { $0.isEqual(value) })
    }
    var scheduleIsEmpty: Bool { schedule.isEmpty }
    var selectedCategoryTitle: String? { selectedCategory }
    
    var selectedDaysText: String? {
        guard !schedule.isEmpty else { return nil }
        if schedule.count == WeekDay.allCases.count {
            return Localizable.NewTracker.everyDay
        }
        let sorted = schedule.sorted { $0.rawValue < $1.rawValue }
        return sorted.map { $0.shortName }.joined(separator: ", ")
    }
    
    var isCreateEnabled: Bool {
        let maxLen = 38
        let isNameOK = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && name.count <= maxLen
        let hasSchedule = !schedule.isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        
        let requiresCategory: Bool = {
            switch mode {
            case .create: return true
            case .edit: return false
            }
        }()
        let isCategoryOK = requiresCategory ? (selectedCategory != nil) : true
        
        return isNameOK && hasSchedule && hasEmoji && hasColor && isCategoryOK
    }
    
    // MARK: - Init
    init(mode: Mode = .create) {
        self.mode = mode
        if case .edit(let tracker, let category) = mode {
            self.originalId = tracker.id
            self.originalCategory = category
            self.name = tracker.title
            self.selectedEmoji = tracker.emoji
            self.selectedColor = tracker.color
            self.schedule = tracker.schedule ?? []
            self.selectedCategory = category
        }
    }
    
    // MARK: - Inputs
    func setName(_ text: String) {
        name = text
        onChange?()
    }
    
    func selectCategory(_ title: String?) {
        selectedCategory = title
        onChange?()
    }
    
    func setSchedule(_ days: [WeekDay]) {
        schedule = days
        onChange?()
    }
    
    func selectEmoji(at index: Int) {
        guard emojis.indices.contains(index) else { return }
        selectedEmoji = emojis[index]
        onChange?()
    }
    
    func selectColor(at index: Int) {
        guard colors.indices.contains(index) else { return }
        selectedColor = colors[index]
        onChange?()
    }
    
    // MARK: - Result builder
    func makeResult() -> (tracker: Tracker, category: String)? {
        guard isCreateEnabled,
              let emoji = selectedEmoji,
              let color = selectedColor else { return nil }
        
        let id: UUID
        switch mode {
        case .create:
            id = UUID()
        case .edit:
            id = originalId ?? UUID()
        }
        
        let tracker = Tracker(
            id: id,
            title: name,
            emoji: emoji,
            color: color,
            schedule: schedule
        )
        
        // Категория: для .edit — используем выбранную, иначе — исходную
        let categoryToUse: String = {
            switch mode {
            case .create:
                return selectedCategory ?? ""
            case .edit:
                return selectedCategory ?? (originalCategory ?? "")
            }
        }()
        
        return (tracker, categoryToUse)
    }
}
