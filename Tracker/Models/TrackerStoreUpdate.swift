import Foundation

struct TrackerStoreUpdate {
    let insertedIndices: IndexSet
    let deletedIndices: IndexSet
    let updatedIndices: IndexSet
    let movedIndices: [Move]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
    
    struct Move {
        let oldSection: Int
        let oldIndex: Int
        let newSection: Int
        let newIndex: Int
    }
}
