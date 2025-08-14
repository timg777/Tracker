import UIKit

final class ScheduleOptionsCell: TrackerTableViewCell {
    
    // MARK: - Private Views
    private lazy var titleLabel: UILabel = {
        .init()
    }()
    private lazy var switchView: UISwitch = {
        .init()
    }()
    
    // MARK: - Internal Static Constants
    static let reuseIdentifier = "NewHabitCreationScheduleOptionsCell"
    
    // MARK: - Internal Properties
    var weekday: Weekday? {
        didSet {
            titleLabel.text = weekday?.fullName
            switchView.isOn = isOn ?? false
        }
    }
    var isOn: Bool?
    var didSelectWeekday: ((Weekday?) -> Void)?
    var didDeselectWeekday: ((Weekday?) -> Void)?
    
    // MARK: - View Life Cycles
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        setUpViews()
    }
}

// MARK: - Extensions + Private ScheduleOptionsCell Actions Handlers
private extension ScheduleOptionsCell {
    @objc func switchValueDidChange() {
        if let isOn, isOn {
            didDeselectWeekday?(weekday)
        } else {
            didSelectWeekday?(weekday)
        }
    }
}

// MARK: - Extensions + Private ScheduleOptionsCell Setting Up Views
private extension ScheduleOptionsCell {
    func setUpViews() {
        backgroundColor = .background
        selectionStyle = .none
        
        configureTitleLabel()
        configureSwitchView()
        
        titleLabelConstraintsActivate()
        switchViewConstraintsActivate()
    }
}

// MARK: - Extensions + Private ScheduleOptionsCell Views Configuring
private extension ScheduleOptionsCell {
    func configureTitleLabel() {
        titleLabel.attributedText =
        NSAttributedString(
            string: "",
            attributes: [
                .font: UIFont.ypRegular17,
                .foregroundColor: UIColor.ypBlack
            ]
        )
    }
    
    func configureSwitchView() {
        switchView.onTintColor = .ypBlue
    }
}

// MARK: - Extensions + Private ScheduleOptionsCell View Constraints Activation
private extension ScheduleOptionsCell {
    func titleLabelConstraintsActivate() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            )
        ])
    }
    
    func switchViewConstraintsActivate() {
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        
        contentView.addSubview(switchView)
        
        NSLayoutConstraint.activate([
            switchView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            switchView.centerYAnchor.constraint(
                equalTo: centerYAnchor
            )
        ])
    }
}
