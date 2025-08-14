import UIKit

final class TrackerTableView: UITableView {
    
    // MARK: - Internal Initialization
    override init(frame: CGRect = .zero, style: UITableView.Style = .plain) {
        super.init(frame: frame, style: style)
        
        backgroundColor = .clear
        separatorStyle = .none
        tableFooterView = nil
        tableHeaderView = nil
        layer.cornerRadius = 16
        clipsToBounds = true
        isScrollEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions + Internal TrackerTableView Helpers
extension TrackerTableView {
    func constraintsActivate(using view: UIView, objectsCount: Int) {
        translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            heightAnchor.constraint(
                equalToConstant: ViewsHeightConstant.tableViewCellHeight.rawValue * CGFloat(objectsCount)
            )
        ])
    }
}
