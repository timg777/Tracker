import UIKit

final class StatisticCell: UIView {
    
    // MARK: - Private Views
    private lazy var titleLabel: UILabel = {
        .init()
    }()
    private lazy var valueLabel: UILabel = {
        .init()
    }()
    
    // MARK: - Private Constants
    private let type: StatisticCellType
    
    // MARK: - Internal Initialization
    init(
        frame: CGRect = .zero,
        type: StatisticCellType
    ) {
        self.type = type
        super.init(frame: frame)
        setupViews()
        StatisticService.shared.didChanged = { [weak self] in
            guard let self else { return }
            configureValueLabel()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    override func layoutSubviews() {
        super.layoutSubviews()
        setupViews()
    }
    
}

// MARK: - Extensions + Internal StatisticCell Views Setting Up
extension StatisticCell {
    func setupViews() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        setupBackground()
        setupTitle()
        setupValueTitle()
        configureTitleLabel()
        configureValueLabel()
    }
    
    func configureTitleLabel() {
        titleLabel.attributedText =
        NSAttributedString(
            string: type.title,
            attributes: [
                .font: UIFont.ypMedium12,
                .foregroundColor: UIColor.ypBlack
            ]
        )
    }
    
    func configureValueLabel() {
        valueLabel.attributedText =
        NSAttributedString(
            string: "\(type.value)",
            attributes: [
                .font: UIFont.ypBold34,
                .foregroundColor: UIColor.ypBlack
            ]
        )
    }
    
    func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -12
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -12
            )
        ])
    }
    
    func setupValueTitle() {
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 12
            ),
            valueLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 12
            ),
            valueLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -12
            )
        ])
    }
    
    func setupBackground() {
        let gradientLayer = CAGradientLayer()
        let shapeLayer = CAShapeLayer()
        
        gradientLayer.colors = [
            UIColor.colorSelection11.cgColor,
            UIColor.colorSelection9.cgColor,
            UIColor.colorSelection3.cgColor
        ]
        
        gradientLayer.frame = bounds
        gradientLayer.type = .axial
        gradientLayer.startPoint = .init(x: 0, y: 0.5)
        gradientLayer.endPoint = .init(x: 1, y: 0.5)
        let path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: 16
        )
        shapeLayer.path = path.cgPath
        
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor =  UIColor.black.cgColor
        shapeLayer.lineCap = .round
        
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
    }
}
