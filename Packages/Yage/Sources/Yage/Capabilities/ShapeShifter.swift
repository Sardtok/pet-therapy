import SwiftUI

public class ShapeShifter: Capability {
    var animationDuracy: TimeInterval = 1
    var targetSize: CGSize = .zero
    var delta: CGSize = .zero
    var remainingTime: TimeInterval = 0

    public func scaleLinearly(to size: CGSize, duracy: TimeInterval) {
        guard let subject else { return }
        targetSize = size
        delta = CGSize(
            width: size.width - subject.frame.width,
            height: size.height - subject.frame.height
        )
        animationDuracy = duracy
        remainingTime = duracy
        isEnabled = true
    }

    override public func doUpdate(with collisions: Collisions, after time: TimeInterval) {
        subject?.frame = updatedFrame(after: time)
        checkCompletion(after: time)
    }
    
    private func updatedFrame(after time: TimeInterval) -> CGRect {
        guard let subject else { return .zero }
        let delta = CGSize(
            width: time * delta.width / animationDuracy,
            height: time * delta.height / animationDuracy
        )
        return CGRect(
            x: subject.frame.origin.x - delta.width / 2,
            y: subject.frame.origin.y - delta.height / 2,
            width: subject.frame.width + delta.width,
            height: subject.frame.height + delta.height
        )
    }
    
    private func checkCompletion(after time: TimeInterval) {
        remainingTime -= time
        if remainingTime <= 0.0001 {
            isEnabled = false
        }
    }
}
