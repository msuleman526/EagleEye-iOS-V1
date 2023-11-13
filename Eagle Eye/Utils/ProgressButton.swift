import UIKit

class ProgressButton: UIButton {
    private var progressLayer = CAShapeLayer()
    private var timer: Timer?
    private var progress: CGFloat = 0
    var actionCompletion: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(handleTouchUpOutside), for: .touchUpOutside)
        addTarget(self, action: #selector(handleTouchCancel), for: .touchCancel)
        configureProgressLayer()
    }

    private func configureProgressLayer() {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2),
            radius: (bounds.size.width - 10) / 2,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )

        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = tintColor.cgColor
        progressLayer.lineWidth = 5
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        layer.addSublayer(progressLayer)
    }

    @objc private func handleTouchDown() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progress += 0.015
            self.progressLayer.strokeEnd = min(self.progress, 1.0)
            if self.progress >= 1.0 {
                self.timer?.invalidate()
                self.performAutoTap()
            }
        }
    }

    @objc private func handleTouchUpInside() {
        timer?.invalidate()
        progressLayer.strokeEnd = 0
        progress = 0
    }

    @objc private func handleTouchUpOutside() {
        timer?.invalidate()
        progressLayer.strokeEnd = 0
        progress = 0
    }

    @objc private func handleTouchCancel() {
        timer?.invalidate()
        progressLayer.strokeEnd = 0
        progress = 0
    }

    private func performAutoTap() {
        if progress >= 1.0 {
            DispatchQueue.main.async {
                self.sendActions(for: .touchUpInside)
                self.actionCompletion?()
            }
        }
    }
}
