import UIKit

final class TrackerCollectionCell: UICollectionViewCell {
    
    // MARK: - Static Constants
    static let reuseIdentifier = "TrackerCell"
    
    // MARK: - Private Views
    private lazy var emojiLabel: UILabel = {
        .init()
    }()
    private lazy var emojiView: UIView = {
        .init()
    }()
    private lazy var titleLabel: UILabel = {
        .init()
    }()
    private lazy var daysLabel: UILabel = {
        .init()
    }()
    private lazy var plusButton: UIButton = {
        .init()
    }()
    private lazy var coloredRectangeContainerView: UIView = {
        .init()
    }()
    
    // MARK: - Private Properties
    private var titleTopConstraint: NSLayoutConstraint?
    
    weak var delegate: TrackerCollectionCellDelegate? {
        didSet {
            guard
                let _ = delegate,
                let _ = tracker
            else { return }
            updateData()

            configureEmojiLabel()
            configureEmojiView()
            configureTitleLabel()
            configureColoredRectangeContainerView()
        }
    }
    private var daysCheckedCount: Int? {
        didSet {
            configureDaysLabel()
        }
    }
    private var isDayChecked: Bool? {
        didSet {
            configurePlusButton()
        }
    }
    private var isPinned: Bool? {
        guard let tracker else { return nil }
        return delegate?.isTrackerPinned(uuid: tracker.id)
    }
    
    // MARK: - Private Constants
    private let reportManager = YMMYYandexMetricaReportManager.shared
    
    // MARK: - Internal Properties
    var indexPath: IndexPath?
    var tracker: TrackerModel?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        addContextMenuInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func localizedTitle(for uiElement: LocalizationManager.UIElement.TrackerCollectionCell) -> String {
        LocalizationManager.shared.localizedString(using: uiElement.rawValue)
    }
    private func localizedTitle(for shared: LocalizationManager.UIElement.Shared) -> String {
        LocalizationManager.shared.localizedString(using: shared.rawValue)
    }
}

// MARK: - Extensions + Inernal TrackerCollectionCell -> UIContextMenuInteractionDelegate Conformance
extension TrackerCollectionCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        reportManager.sendActionReport(
            reportTitle: "User initiated context menu",
            event: .click,
            screenName: "Main",
            item: .context
        )
        
        guard let isPinned else { return nil }
        
        let pinTitle = localizedTitle(for: isPinned ? .unpin : .pin)
        let editTitle = localizedTitle(for: .edit)
        let deleteTitle = localizedTitle(for: .remove)
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(children: [
                UIAction(title: pinTitle) { [weak self] _ in
                    guard let self else { return }
                    if isPinned {
                        delegate?.unpinTracker(at: indexPath)
                    } else {
                        delegate?.pinTracker(at: indexPath)
                    }
                    
                    reportManager.sendActionReport(
                        reportTitle: "User \(isPinned ? "unpinned" : "pinned") tracker",
                        event: .click,
                        screenName: "Main",
                        item: .context
                    )
                },
                UIAction(title: editTitle) { [weak self] _ in
                    guard let self else { return }
                    delegate?.editTracker(at: indexPath)
                    
                    reportManager.sendActionReport(
                        reportTitle: "User initiated editing tracker",
                        event: .click,
                        screenName: "Main",
                        item: .edit
                    )
                },
                UIAction(title: deleteTitle, attributes: [.destructive]) { [weak self] _ in
                    guard let self else { return }
                    delegate?.tryDeleteTracker(at: indexPath)
                    
                    reportManager.sendActionReport(
                        reportTitle: "User initiated deleting tracker",
                        event: .click,
                        screenName: "Main",
                        item: .delete
                    )
                },
            ])
        }
        
        return configuration
    }
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        let params = UIPreviewParameters()
        params.backgroundColor = .clear
        
        return UITargetedPreview(view: coloredRectangeContainerView, parameters: params)
    }
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        let params = UIPreviewParameters()
        params.backgroundColor = .clear
        
        return UITargetedPreview(view: coloredRectangeContainerView, parameters: params)
    }
}

// MARK: - Extensions + Private TrackerCollectionCell Helpers
private extension TrackerCollectionCell {
    func addContextMenuInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
    }
}

// MARK: - Extensions + Private TrackerCollectionCell Buttons Handlers
private extension TrackerCollectionCell {
    @objc func didTapPlusButton() {
        guard
            let tracker,
            let delegate,
            let indexPath,
            delegate.dateIsLessThanTodayDate()
        else { return }
        
        delegate.toggleTrackerRecord(
            for: tracker.id,
            updateWith: indexPath
        )
        updateData()
        
        reportManager.sendActionReport(
            reportTitle: "User \((isDayChecked ?? false) ? "unchecked" : "checked")",
            event: .click,
            screenName: "Main",
            item: .tracker
        )
    }
    
    func updateData() {
        guard
            let tracker,
            let delegate
        else { return }
        
        isDayChecked = delegate.isTrackerCompletedToday(uuid: tracker.id)
        daysCheckedCount = delegate.trackerRecordsCount(for: tracker.id)
    }
}

// MARK: - Extensions + Private TrackerCollectionCell Setting Up Views
private extension TrackerCollectionCell {
    func setupViews() {
        backgroundColor = .clear
        
        coloredRectangeContainerViewConstraintsActivate()
        emojiViewConstraintsActivate()
        emojiLabelConstraintsActivate()
        titleLabelConstraintsActivate()
        plusButtonConstraintsActivate()
        daysLabelConstraintsActivate()
    }
}

// MARK: - Extensions + Private TrackerCollectionCell Views Configuring
private extension TrackerCollectionCell {
    func configureEmojiLabel() {
        emojiLabel.attributedText =
        NSAttributedString(
            string: tracker?.emoji ?? "",
            attributes: [
                .font: UIFont.ypMedium13
            ]
        )
        emojiLabel.contentMode = .center
    }
    
    func configureEmojiView() {
        emojiView.layer.cornerRadius = 12
        emojiView.backgroundColor = .white.withAlphaComponent(0.2)
        emojiView.layer.shadowRadius = 10
        emojiView.layer.shadowOpacity = 0.3
    }
    
    func configureTitleLabel() {
        let paragraphStyle: NSMutableParagraphStyle = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.minimumLineHeight = 18
            paragraphStyle.maximumLineHeight = 18
            return paragraphStyle
        }()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ypMedium13,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        titleLabel.attributedText =
        NSAttributedString(
            string: tracker?.title ?? "No title",
            attributes: attributes
        )
        
        titleLabel.numberOfLines = 2
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.3
        titleLabel.layer.shadowRadius = 2
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func configureDaysLabel() {
        
        let title = String.localizedStringWithFormat(
            localizedTitle(for: .daysCheckedCount),
            daysCheckedCount ?? 0
        )
        
        daysLabel.attributedText =
        NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.ypMedium12,
                .foregroundColor: UIColor.ypBlack
            ]
        )
    }
    
    func configurePlusButton() {
        plusButton.setTitle(
            nil,
            for: .normal
        )
        plusButton.addTarget(
            self,
            action: #selector(didTapPlusButton),
            for: .touchUpInside
        )
        plusButton.imageView?.contentMode = .scaleAspectFit
        plusButton.imageView?.tintColor = .mainViewBackground
        plusButton.layer.cornerRadius = 17
        plusButton.backgroundColor = tracker?.color
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            let image = UIImage(systemName: (isDayChecked ?? false) ? "checkmark" : "plus")
            image?.withRenderingMode(.alwaysTemplate)
            plusButton.setImage(
                image,
                for: .normal
            )
            plusButton.layer.opacity = (isDayChecked ?? false) ? 0.5 : 1
        }
    }
    
    func configureColoredRectangeContainerView() {
        coloredRectangeContainerView.backgroundColor = tracker?.color
        coloredRectangeContainerView.layer.cornerRadius = 12
    }
}

// MARK: - Extensions + Private TrackerCollectionCell Constraints Activation
private extension TrackerCollectionCell {
    func daysLabelConstraintsActivate() {
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
            daysLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            daysLabel.trailingAnchor.constraint(
                equalTo: plusButton.leadingAnchor,
                constant: -8
            ),
            daysLabel.centerYAnchor.constraint(
                equalTo: plusButton.centerYAnchor
            )
        ])
    }
    
    func plusButtonConstraintsActivate() {
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            plusButton.topAnchor.constraint(
                equalTo: coloredRectangeContainerView.bottomAnchor,
                constant: 8
            ),
            plusButton.widthAnchor.constraint(
                equalToConstant: 34
            ),
            plusButton.heightAnchor.constraint(
                equalTo: plusButton.widthAnchor
            )
        ])
    }
    
    func coloredRectangeContainerViewConstraintsActivate() {
        coloredRectangeContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(coloredRectangeContainerView)
        
        NSLayoutConstraint.activate([
            coloredRectangeContainerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            coloredRectangeContainerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            coloredRectangeContainerView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            coloredRectangeContainerView.heightAnchor.constraint(
                equalToConstant: contentView.bounds.height * 0.6
            )
        ])
    }
    
    func emojiViewConstraintsActivate() {
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        
        coloredRectangeContainerView.addSubview(emojiView)
        
        NSLayoutConstraint.activate([
            emojiView.leadingAnchor.constraint(
                equalTo: coloredRectangeContainerView.leadingAnchor,
                constant: 12
            ),
            emojiView.topAnchor.constraint(
                equalTo: coloredRectangeContainerView.topAnchor,
                constant: 12
            ),
            emojiView.widthAnchor.constraint(
                equalToConstant: 24
            ),
            emojiView.heightAnchor.constraint(
                equalTo: emojiView.widthAnchor
            )
        ])
    }
    
    func emojiLabelConstraintsActivate() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emojiView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(
                equalTo: emojiView.centerXAnchor
            ),
            emojiLabel.centerYAnchor.constraint(
                equalTo: emojiView.centerYAnchor
            )
        ])
    }
    
    func titleLabelConstraintsActivate() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        coloredRectangeContainerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: coloredRectangeContainerView.leadingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: coloredRectangeContainerView.trailingAnchor,
                constant: -12
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: coloredRectangeContainerView.bottomAnchor,
                constant: -12
            )
        ])
    }
}
