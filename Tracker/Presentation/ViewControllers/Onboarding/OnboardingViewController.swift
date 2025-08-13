import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Private Views
    lazy var pages: [UIViewController] = {
        [
            OnboardingPageViewController(currentPage: .aboutTracker),
            OnboardingPageViewController(currentPage: .aboutWaterAndYoga)
        ]
    }()
    
    lazy var skipButton: TrackerButton = {
        .init()
    }()
    
    lazy var pageControl: UIPageControl = {
        .init()
    }()
    
    // MARK: - Private Properties
    private var isTransitionInProgress = false
    
    // MARK: - Internal Properties
    var didTapOnboardingSkipButton: (() -> Void)?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: - Private Initialization
    private override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil
    ) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions + Private OnboardingViewController skipButton Action Handler
private extension OnboardingViewController {
    @objc func skipButtonTapped() {
        didTapOnboardingSkipButton?()
    }
}

// MARK: - Extensions + Private OnboardingViewController Views Configuring
private extension OnboardingViewController {
    func configurePageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count
        pageControl.pageIndicatorTintColor = .background
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.backgroundStyle = .minimal
    }
    
    func configureSkipButton() {
        skipButton.title = "Вот это технологии!"
        skipButton.titleColor = .ypWhite
        skipButton.addTarget(
            self,
            action: #selector(skipButtonTapped),
            for: .touchUpInside
        )
    }
}

// MARK: - Extensions + Private OnboardingViewController Views Constraints Activation
private extension OnboardingViewController {
    func pageControlConstraintsActivate() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            pageControl.bottomAnchor.constraint(
                equalTo: skipButton.topAnchor,
                constant: -24
            )
        ])
    }

    func skipButtonConstraintsActivate() {
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(skipButton)
        
        skipButton.activateConstraints(
            view: view,
            position: .bottom,
            constant: -50
        )
    }
}

// MARK: - Extensions + Private OnboardingViewController Setting Up Views
private extension OnboardingViewController {
    func setupView() {
        delegate = self
        dataSource = self
        
        configurePageControl()
        configureSkipButton()
        
        skipButtonConstraintsActivate()
        pageControlConstraintsActivate()
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
    }
}

// MARK: - Extensions + Internal OnboardingViewController -> UIPageViewControllerDataSource Conformance
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        getViewController(by: viewController, next: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        getViewController(by: viewController, next: true)
    }
    
    private func getViewController(by vc: UIViewController, next: Bool) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: vc) else { return nil }
        
        let index = viewControllerIndex + (next ? 1 : -1)
        
        guard
            let previousViewController = pages[safe: index]
        else {
            return nil
        }
        
        return previousViewController
    }
}

// MARK: - Extensions + Internal OnboardingViewController -> UIPageViewControllerDelegate Conformance
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        isTransitionInProgress = true
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        isTransitionInProgress = false
        guard
            let currentViewController = pageViewController.viewControllers?.first,
            let currentPage = pages.firstIndex(of: currentViewController)
        else { return }
        pageControl.currentPage = currentPage
    }
    
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        .portrait
    }
    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        .portrait
    }
}
