import UIKit

protocol StatisticViewControllerProtocol: AnyObject {
    var presenter: StatisticViewPresenterProtocol? { get set }
}

final class StatisticViewController: UIViewController & StatisticViewControllerProtocol {
    
    // MARK: - Private Views
    private lazy var viewTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText =
        NSAttributedString(
            string: "Статистика",
            attributes: [
                .font: UIFont.ypBold34,
                .foregroundColor: UIColor.ypBlack,
            ]
        )
        label.textAlignment = .center
        return label
    }()
    
    private lazy var noStatisticLabel: UILabel = {
        let label = UILabel()
        label.attributedText =
        NSAttributedString(
            string: "Анализировать пока нечего",
            attributes: [
                .font: UIFont.ypMedium12,
                .foregroundColor: UIColor.ypBlack
            ]
        )
        label.textAlignment = .center
        return label
    }()
    private lazy var noStatisticImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .noStat)
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var statListView: UITableView = {
        .init()
    }()
    
    // MARK: - Internal Properties
    var presenter: StatisticViewPresenterProtocol?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
}

// MARK: - Extensions + Private StatisticViewController Views Configuring
private extension StatisticViewController {
    
    func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func configureStatListView() {
        statListView.addSubview(noStatisticImageView)
        statListView.addSubview(noStatisticLabel)
        view.addSubview(statListView)
    }
    
    func configureViewTitleLabel() {
        view.addSubview(viewTitleLabel)
    }
    
}

// MARK: - Extensions + Private StatisticViewController Views Constraints Activation
private extension StatisticViewController {
    
    func setUpViews() {
        view.backgroundColor = .ypWhite
        
        configureNavigationBar()
        configureStatListView()
        configureViewTitleLabel()
        
        viewTitleLabelConstraintsActivate()
        statListViewConstraintsActivate()
    }
    
    func viewTitleLabelConstraintsActivate() {
        viewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    func statListViewConstraintsActivate() {
        statListView.translatesAutoresizingMaskIntoConstraints = false
        noStatisticLabel.translatesAutoresizingMaskIntoConstraints = false
        noStatisticImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statListView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 0
            ),
            statListView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            statListView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            statListView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: 0
            )
        ])
        
        NSLayoutConstraint.activate([
            noStatisticImageView.centerXAnchor.constraint(
                equalTo: noStatisticImageView.superview?.centerXAnchor ?? view.centerXAnchor
            ),
            noStatisticImageView.centerYAnchor.constraint(
                equalTo: noStatisticImageView.superview?.centerYAnchor ?? view.centerYAnchor
            ),
            noStatisticLabel.topAnchor.constraint(
                equalTo: noStatisticImageView.bottomAnchor,
                constant: 10
            ),
            noStatisticLabel.centerXAnchor.constraint(
                equalTo: noStatisticLabel.superview?.centerXAnchor ?? view.centerXAnchor
            )
        ])
    }
    
}
