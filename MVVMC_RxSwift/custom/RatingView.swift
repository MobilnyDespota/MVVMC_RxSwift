import UIKit
import RxSwift
import RxCocoa

class RatingView: UIView {
    private var circleLayer = CAShapeLayer()
    private var ratingLayer = CAShapeLayer()
    
    private var startPoint = CGFloat(-Double.pi / 2)
    private var endPoint = CGFloat(3 * Double.pi / 2)
    
    let percantegeLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.white, .tiny, .bold)
        label.text = "%"
        return label
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.white, .standard, .bold)
        return label
    }()
    
    var rating: CGFloat = 0.0 {
        didSet {
            ratingLabel.text = String(Int(round(rating * 100)))
            if rating >= 0.5 {
                circleLayer.strokeColor = UIColor.green.withAlphaComponent(0.3).cgColor
                ratingLayer.strokeColor = UIColor.green.cgColor
            } else {
                circleLayer.strokeColor = UIColor.yellow.withAlphaComponent(0.3).cgColor
                ratingLayer.strokeColor = UIColor.yellow.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        initSubviews()
    }
    
    func initSubviews() {
        self.backgroundColor = UIColor.black
        self.layer.cornerRadius = frame.size.width / 2.0
        
        addSubview(ratingLabel)
        ratingLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        ratingLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 11)
        
        addSubview(percantegeLabel)
        percantegeLabel.autoPinEdge(.left, to: .right, of: ratingLabel)
        percantegeLabel.autoPinEdge(.top, to: .top, of: ratingLabel)
        
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
                                        radius: (frame.size.height / 2.0) - 4,
                                        startAngle: startPoint,
                                        endAngle: endPoint,
                                        clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 3.0
        circleLayer.strokeEnd = 1.0
        layer.addSublayer(circleLayer)

        ratingLayer.path = circularPath.cgPath
        ratingLayer.fillColor = UIColor.clear.cgColor
        ratingLayer.lineCap = .round
        ratingLayer.lineWidth = 3.0
        ratingLayer.strokeEnd = 0.0
        layer.addSublayer(ratingLayer)
    }
    
    func progressAnimation(duration: TimeInterval) {
            let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
            circularProgressAnimation.duration = duration
            circularProgressAnimation.toValue = rating
            circularProgressAnimation.fillMode = .forwards
            circularProgressAnimation.isRemovedOnCompletion = false
            ratingLayer.add(circularProgressAnimation, forKey: "progressAnim")
        }
}

extension Reactive where Base: RatingView {
    var rating: Binder<CGFloat> {
        return Binder(self.base) { ratingView, rating in
            ratingView.rating = rating
            ratingView.progressAnimation(duration: 0.5)
        }
    }
}
