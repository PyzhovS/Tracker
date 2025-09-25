import Foundation

final class CategoryViewModel {
    
    // MARK: - Properties
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [String] = []
    private(set) var selectedCategory: String?
    
    // MARK: - Bindings
    var onCategoriesUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - Initialization
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore(), selectedCategory: String? = nil) {
        self.categoryStore = categoryStore
        self.selectedCategory = selectedCategory
    }
    
    // MARK: - Public Methods
    
    func loadCategories() {
        do {
            categories = try categoryStore.fetchAllCategories()
            onCategoriesUpdate?()
        } catch {
            handleError(error)
        }
    }
    
    func addNewCategory(title: String) {
        do {
            try categoryStore.addNewCategory(title: title)
            categories.append(title)
            onCategoriesUpdate?()
        } catch {
            handleError(error)
        }
    }
    
    func selectCategory(at index: Int) {
        guard index >= 0 && index < categories.count else { return }
        selectedCategory = categories[index]
        onCategorySelected?(selectedCategory!)
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
        onCategorySelected?(category)
    }
    
    func getCategoriesCount() -> Int {
        return categories.count
    }
    
    func getCategoryTitle(at index: Int) -> String {
        guard index >= 0 && index < categories.count else { return "" }
        return categories[index]
    }
    
    func hasCategories() -> Bool {
        return !categories.isEmpty
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        guard index >= 0 && index < categories.count else { return false }
        return categories[index] == selectedCategory
    }
    
    // MARK: - Private Methods
    private func handleError(_ error: Error) {
        if let categoryError = error as? CategoryError {
            onError?(categoryError.errorDescription ?? "Произошла ошибка")
        } else {
            onError?(error.localizedDescription)
        }
    }
}
