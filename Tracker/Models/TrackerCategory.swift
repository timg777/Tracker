struct TrackerCategory: Hashable {
    let title: String
    let trackers: [TrackerModel]
}

// MARK: - Extensions + Internal TrackerCategory from entity Initialization
extension TrackerCategory {
    init?(entity: TrackerCategoryEntity) {
        guard
            let title = entity.name,
            let trackers = entity.trackers?.compactMap({
                if let entity = $0 as? TrackerEntity {
                    TrackerModel(entity: entity)
                } else {
                    nil
                }
            })
        else { return nil }
        
        self.init(title: title, trackers: trackers)
    }
}
