import UIKit

final class DebouncedUISearchController: UISearchController {
    
    // MARK: - Internal Properties
    var debounce: TimeInterval?
    
    weak var debounceDelegate: DebouncedSearchControllerDelegate?
    
    // MARK: - Internal Initialization
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        
        searchResultsUpdater = self
        searchBar.placeholder = "Поиск"
        hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions + DebouncedUISearchController -> UISearchResultsUpdating Conformance
extension DebouncedUISearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        Timer.scheduledTimer(withTimeInterval: debounce ?? 0, repeats: false) { [weak self] _ in
            guard let self else { return }
            debounceDelegate?.debouncedSearchController(
                didChangeSearchText: searchController.searchBar.text ?? ""
            )
        }
    }
}
