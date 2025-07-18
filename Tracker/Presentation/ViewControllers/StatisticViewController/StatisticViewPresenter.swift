import UIKit

protocol StatisticViewPresenterProtocol: AnyObject {
    var view: StatisticViewControllerProtocol? { get set }
}

final class StatisticViewPresenter: StatisticViewPresenterProtocol {
    weak var view: StatisticViewControllerProtocol?
}
