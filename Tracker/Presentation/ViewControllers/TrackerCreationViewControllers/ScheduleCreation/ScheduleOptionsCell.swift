import UIKit

final class ScheduleOptionsCell: UITableViewCell {
    
    // MARK: - Private Views
    private lazy var titleLabel: UILabel = {
        .init()
    }()
    private lazy var switchView: UISwitch = {
        .init()
    }()
    private lazy var separator: UIView = {
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
    var isLastItem: Bool? {
        didSet {
            separator.isHidden = isLastItem ?? true
        }
    }
    
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
        configureSeparator()
        
        titleLabelConstraintsActivate()
        switchViewConstraintsActivate()
        separatorConstraintsActivate()
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
    
    func configureSeparator() {
        separator.backgroundColor = .ypGray.withAlphaComponent(0.5)
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
    
    func separatorConstraintsActivate() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            separator.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            separator.heightAnchor.constraint(
                equalToConstant: 1
            ),
            separator.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
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
