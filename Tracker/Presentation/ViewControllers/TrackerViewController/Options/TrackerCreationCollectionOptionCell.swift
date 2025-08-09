import UIKit

enum OptionCellType {
    case emoji(Int)
    case color(Int)
}

final class TrackerCreationCollectionOptionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCreationCollectionOptionCell"
    
    static let emojies: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🏅", "🎸", "🏝️", "😪",
    ]
    
    static let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3,
        .colorSelection4, .colorSelection5, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9,
        .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    private lazy var emojiLabel: UILabel = {
        .init()
    }()
    private lazy var colorView: UIView = {
        .init()
    }()
    
    var cellType: OptionCellType? {
        didSet {
            if let cellType {
                switch cellType {
                case .emoji(let index):
                    if let emoji = Self.emojies[safe: index] {
                        configureEmojiView(with: emoji)
                    }
                case .color(let index):
                    if let color = Self.colors[safe: index] {
                        configureColorView(with: color)
                    }
                }
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if let cellType {
                switch cellType {
                case .emoji(_):
                    layer.cornerRadius = 16
                    backgroundColor = isSelected ? .lightGray.withAlphaComponent(0.3) : .clear
                case .color(let int):
                    if let color = Self.colors[safe: int] {
                        layer.cornerRadius = 12
                        layer.borderColor = isSelected ? color.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
                        layer.borderWidth = isSelected ? 3 : 0
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureEmojiView(with emoji: String) {
        emojiLabel.attributedText = NSAttributedString(string: emoji, attributes: [.font: UIFont.ypBold34])
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func configureColorView(with color: UIColor) {
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 8
        
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 6
            ),
            colorView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 6
            ),
            colorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -6
            ),
            colorView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -6
            )
        ])
    }
    
    private func setUpView() {
        backgroundColor = .clear
    }
}
