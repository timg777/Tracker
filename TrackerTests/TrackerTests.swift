import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTrackerViewControllerLightAppearance() throws {
        try testAppearance(theme: .light)
    }
    
    func testTrackerViewControllerDarkAppearance() throws {
        try testAppearance(theme: .dark)
    }

    private func testAppearance(theme: UIUserInterfaceStyle) throws {
        let vc = TrackersViewController()
        
        try testViewControllerAppearance(
            for: .iPhoneSe,
            theme: .init(userInterfaceStyle: theme),
            vc: vc
        )
        try testViewControllerAppearance(
            for: .iPhone13Mini,
            theme: .init(userInterfaceStyle: theme),
            vc: vc
        )
        try testViewControllerAppearance(
            for: .iPhoneX,
            theme: .init(userInterfaceStyle: theme),
            vc: vc
        )
        try testViewControllerAppearance(
            for: .iPhone8Plus,
            theme: .init(userInterfaceStyle: theme),
            vc: vc
        )
        try testViewControllerAppearance(
            for: .iPhone13Pro,
            theme: .init(userInterfaceStyle: theme),
            vc: vc
        )
        try testViewControllerAppearance(
            for: .iPhone13ProMax,
            theme: .init(userInterfaceStyle: theme),
            vc: vc
        )
        
        try testViewControllerAppearance(
            for: .iPadMini,
            theme: .init(userInterfaceStyle: theme),
            vc: vc
        )
        try testViewControllerAppearance(
            for: .iPadPro12_9,
            theme: .init(userInterfaceStyle: theme),
            vc: vc
        )
        try testViewControllerAppearance(
            for: .iPadPro10_5,
            theme: .init(userInterfaceStyle: theme),
            vc: vc
        )
    }
    
    private func testViewControllerAppearance(
        for device: SnapshotTesting.ViewImageConfig,
        theme: UITraitCollection,
        vc: UIViewController
    ) throws {
        assertSnapshots(
            of: vc,
            as: [.image(on: device)],
            record: false
        )
    }

}
