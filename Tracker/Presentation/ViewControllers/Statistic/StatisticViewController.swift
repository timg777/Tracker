import UIKit

final class StatisticViewController: UIViewController {
    
    // MARK: - Private Views
    private lazy var viewTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText =
        NSAttributedString(
            string: LocalizationManager.shared.localizedString(for: .stats(.navigationTitle)),
            attributes: [
                .font: UIFont.ypBold34,
                .foregroundColor: UIColor.ypBlack,
            ]
        )
        label.textAlignment = .center
        return label
    }()
    
    private lazy var noContentPlaceholderView: NoContentPlaceHolderView = {
        .init()
    }()
    private lazy var bestPeriodView: StatisticCell = {
        .init(type: .bestPeriod)
    }()
    private lazy var idealDaysView: StatisticCell = {
        .init(type: .idealDays)
    }()
    private lazy var completedTrackersView: StatisticCell = {
        .init(type: .completedTrackers)
    }()
    private lazy var averageDaysView: StatisticCell = {
        .init(type: .averageDays)
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
//            bestPeriodView,
//            idealDaysView,
            completedTrackersView,
//            averageDaysView,
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        reloadNoContentPlaceholderView()
    }
}

// MARK: - Extensions + Private StatisticViewController Views Configuring
private extension StatisticViewController {
    
    func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func reloadNoContentPlaceholderView() {
        let dataIsEmpty = !StatisticService.shared.oneAtLeastExists
        noContentPlaceholderView.verticalStackView.isHidden = !dataIsEmpty
    }
}

// MARK: - Extensions + Private StatisticViewController Views Constraints Activation
private extension StatisticViewController {
    
    func setUpViews() {
        view.backgroundColor = .ypWhite
    
        configureNavigationBar()
        
        viewTitleLabelConstraintsActivate()
        stackViewConstraintsActivate()
        noContentPlaceholderViewConstraintsActivate()
        
        bestPeriodViewContraintsActivate()
        idealDaysViewContraintsActivate()
        completedTrackersViewContraintsActivate()
        averageDaysViewContraintsActivate()
    }
    
    func bestPeriodViewContraintsActivate() {
        bestPeriodView.translatesAutoresizingMaskIntoConstraints = false
        
        bestPeriodView.heightAnchor.constraint(
            equalToConstant: ViewsHeightConstant.statisticsCellHeight.rawValue
        ).isActive = true
    }
    func idealDaysViewContraintsActivate() {
        idealDaysView.translatesAutoresizingMaskIntoConstraints = false
        
        idealDaysView.heightAnchor.constraint(
            equalToConstant: ViewsHeightConstant.statisticsCellHeight.rawValue
        ).isActive = true
    }
    func completedTrackersViewContraintsActivate() {
        completedTrackersView.translatesAutoresizingMaskIntoConstraints = false
        
        completedTrackersView.heightAnchor.constraint(
            equalToConstant: ViewsHeightConstant.statisticsCellHeight.rawValue
        ).isActive = true
    }
    func averageDaysViewContraintsActivate() {
        averageDaysView.translatesAutoresizingMaskIntoConstraints = false
        
        averageDaysView.heightAnchor.constraint(
            equalToConstant: ViewsHeightConstant.statisticsCellHeight.rawValue
        ).isActive = true
    }
    
    func viewTitleLabelConstraintsActivate() {
        viewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(viewTitleLabel)
        
        NSLayoutConstraint.activate([
            viewTitleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 44
            ),
            viewTitleLabel.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
        ])
    }
    
    func stackViewConstraintsActivate() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            stackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }
    
    func noContentPlaceholderViewConstraintsActivate() {
        noContentPlaceholderView.type = .noStat
        let placeholderView = noContentPlaceholderView.verticalStackView
        placeholderView.isHidden = true
        view.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            placeholderView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            placeholderView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
    }
}
