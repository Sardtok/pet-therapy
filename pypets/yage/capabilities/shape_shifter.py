"""
import SwiftUI

class ShapeShifter: Capability {
    var animationDuracy: float = 1
    var targetSize: Size = .zero
    var delta: Size = .zero

    def scaleLinearly(to size: Size, duracy: float) {
        guard let subject else { return }
        targetSize = size
        delta = Size(
            width: size.width - subject.frame.width,
            height: size.height - subject.frame.height
        )
        animationDuracy = duracy
        is_enabled = True
    }

    def do_update(self, collisions: List[Collision], time: float) {
        guard is_enabled else { return }
        guard let subject else { return }

        let delta = Size(
            width: time * delta.width / animationDuracy,
            height: time * delta.height / animationDuracy
        )
        let newFrame = Rect(
            x: subject.frame.origin.x - delta.width / 2,
            y: subject.frame.origin.y - delta.height / 2,
            width: subject.frame.width + delta.width,
            height: subject.frame.height + delta.height
        )
        subject.frame = newFrame

        checkCompletion(given: delta)
    }

    def _checkCompletion(given delta: Size) {
        let distance = sqrt(pow(delta.width, 2) + pow(delta.height, 2))
        if distance < 0.01 {
            is_enabled = False
        }
    }
}
"""