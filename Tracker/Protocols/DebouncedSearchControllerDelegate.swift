protocol DebouncedSearchControllerDelegate: AnyObject {
    func debouncedSearchController(didChangeSearchText text: String)
}
