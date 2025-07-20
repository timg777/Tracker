import UIKit

final class TrackerDatePicker: UIDatePicker {
    // MARK: - Private Views
    private lazy var dateLabel: UILabel = {
        .init()
    }()
    
    // MARK: - Internal Properties
    var dateWasChanged: ((Date) -> Void)?
    
    // MARK: - Internal Initiailization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions + Private TrackerDatePicker Helpers
private extension TrackerDatePicker {
    func formatDate(
        _ date: Date? = nil
    ) -> (
        date: Date,
        dateString: String
    ) {
        let date = date ?? self.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        
        let formattedDateString = dateFormatter.string(from: date)
        guard
            let formattedDate = dateFormatter.date(from: formattedDateString)
        else {
            return (
                date: date,
                dateString: formattedDateString
            )
        }
        return (
            date: formattedDate,
            dateString: formattedDateString
        )
    }
    
    @objc func datePickerValueDidChanged(_ sender: UIDatePicker) {
        let (date, dateString) = formatDate(sender.date)
        dateWasChanged?(date)
        dateLabel.attributedText =
        NSAttributedString(
            string: dateString,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                .foregroundColor: UIColor.ypBlack
            ]
        )
    }
}

// MARK: - Extensions + Private TrackerDatePicker Setting Up Views
private extension TrackerDatePicker {
    func setupViews() {
        configureDatePicker()
        configureDateLabel()
        
        dateLabelConstraintsActivate()
    }
}

// MARK: - Extensions + Private TrackerDatePicker Views Configuring
private extension TrackerDatePicker {
    func configureDatePicker() {
        backgroundColor = .clear
        datePickerMode = .date
        preferredDatePickerStyle = .compact
        locale = Locale(identifier: "ru_RU")
        addTarget(
            self,
            action: #selector(datePickerValueDidChanged),
            for: .valueChanged
        )
    }
    
    func configureDateLabel() {
        dateLabel.textAlignment = .center
        dateLabel.isUserInteractionEnabled = false
        dateLabel.layer.backgroundColor = #colorLiteral(red: 0.9098036885, green: 0.9098040462, blue: 0.9184128046, alpha: 1)
        dateLabel.layer.cornerRadius = 8
        
        let (_, dateString) = formatDate()
        dateLabel.attributedText =
        NSAttributedString(
            string: dateString,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                .foregroundColor: UIColor.ypBlack
            ]
        )
    }
}

// MARK: - Extensions + Private TrackerDatePicker Constraints Activation
private extension TrackerDatePicker {
    func dateLabelConstraintsActivate() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            dateLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            dateLabel.topAnchor.constraint(
                equalTo: topAnchor
            ),
            dateLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
    }
}
