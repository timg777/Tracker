import UIKit

final class KeyboardDismissGestureHub: NSObject {
    // MARK: - Private Properties
    private weak var targetView: UIView?
    
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    
    private var keyboardHeight: CGFloat = 0
    
    // MARK: - Internal Properties
    var keyboardHeightDidChange: ((CGFloat) -> Void)?
    
    // MARK: - Internal Initiailization
    init(view: UIView) {
        super.init()
        
        self.targetView = view
        setupGestures()
        registerKeyboardNotification()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Extensions + Private KeyboardDismissGestureHub Setting Up Gestures
private extension KeyboardDismissGestureHub {
    func setupGestures() {
        setupTapGesture()
        setupPanGesture()
    }
    
    func setupTapGesture() {
        guard let view = targetView else { return }
        
        tapGestureRecognizer =
        UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapGesture)
        )
        tapGestureRecognizer?.cancelsTouchesInView = false
        
        guard let tapGestureRecognizer else { return }
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupPanGesture() {
        guard let view = targetView else { return }
        
        panGestureRecognizer =
        UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture)
        )
        panGestureRecognizer?.cancelsTouchesInView = false
        
        guard let panGestureRecognizer else { return }
        view.addGestureRecognizer(panGestureRecognizer)
    }
}

// MARK: - Extensions + Private KeyboardDismissGestureHub Gestures Handling
private extension KeyboardDismissGestureHub {
    @objc func handleTapGesture() {
        targetView?.endEditing(true)
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = targetView else { return }
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            fallthrough // TODO: - future UIInputViewController custon keyboard implementation
        case .ended, .cancelled:
            if translation.y > 0 {
                view.endEditing(true)
            }
        default:
            break
        }
    }
}

// MARK: - Extensions + Private KeyboardDismissGestureHub Keyboard Notification Registration
private extension KeyboardDismissGestureHub {
    func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

// MARK: - Extensions + Private KeyboardDismissGestureHub Notification Handler
private extension KeyboardDismissGestureHub {
    @objc func keyboardWillChangeFrame(notification: Notification) {
        if let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrameValue.cgRectValue.height
        }
    }
    @objc func keyboardWillShow(notification: Notification) {
        keyboardHeightDidChange?(keyboardHeight)
    }
    @objc func keyboardWillHide(notification: Notification) {
        keyboardHeightDidChange?(0)
    }
}
