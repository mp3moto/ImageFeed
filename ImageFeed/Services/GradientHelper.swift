import UIKit

final class GradientForView {
    let width, height :CGFloat
    let radius: CGFloat?
    
    init(width: CGFloat, height: CGFloat, radius: CGFloat) {
        self.width = width
        self.height = height
        self.radius = radius
    }
    
    init(width: CGFloat, height: CGFloat) {
        self.radius = nil
        self.width = width
        self.height = height
    }
    
    func getAnimatedLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()

        gradient.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.masksToBounds = true

        if let radius = radius {
            gradient.cornerRadius = radius
        } else {
            gradient.cornerRadius = height / 2
        }

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]

        gradient.add(gradientChangeAnimation, forKey: "locationsChange")

        return gradient
    }
}
