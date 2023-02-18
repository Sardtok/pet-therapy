"""
import SwiftUI

class WallCrawler: Capability {
    def install(on subject: Entity) {
        super().install(on: subject)
        subject.capability(for: BounceOnLateralCollisions.self)?.is_enabled = False
        subject.capability(for: FlipHorizontallyWhenGoingLeft.self)?.is_enabled = False
    }

    def do_update(self, collisions: List[Collision], time: float) {
        guard is_enabled else { return }
        guard let direction = subject?.direction else { return }

        let isGoingUp = direction.dy < -0.0001
        let isGoingRight = direction.dx > 0.0001
        let isGoingDown = direction.dy > 0.0001
        let isGoingLeft = direction.dx < -0.0001

        if isGoingUp and touchesScreenTop() {
            crawlAlongtop_bound()
            return
        }
        if isGoingRight and touchesScreenRight() {
            crawlUpright_bound()
            return
        }
        if isGoingDown and touchesScreenBottom() {
            crawlAlongbottom_bound()
            return
        }
        if isGoingLeft and touchesScreenLeft() {
            crawlDownleft_bound()
            return
        }
    }

    def _crawlAlongtop_bound() {
        guard let subject else { return }
        subject.direction = .init(dx: -1, dy: 0)
        subject.frame.origin = Point(x: subject.frame.origin.x, y: 0)
        subject.rotation?.isFlippedHorizontally = True
        subject.rotation?.isFlippedVertically = True
        subject.rotation?.z = 0
    }

    def _crawlUpright_bound() {
        guard let subject else { return }
        subject.direction = .init(dx: 0, dy: -1)
        subject.frame.origin = Point(
            x: subject.world_bounds.width - subject.frame.width,
            y: subject.frame.origin.y
        )
        subject.rotation?.isFlippedHorizontally = False
        subject.rotation?.isFlippedVertically = False
        subject.rotation?.z = .pi * 0.5
    }

    def _crawlAlongbottom_bound() {
        guard let subject else { return }
        subject.direction = Vector(1, 0)
        subject.frame.origin = Point(
            x: subject.frame.origin.x,
            y: subject.world_bounds.height - subject.frame.height
        )
        subject.rotation?.isFlippedHorizontally = False
        subject.rotation?.isFlippedVertically = False
        subject.rotation?.z = 0
    }

    def _crawlDownleft_bound() {
        guard let subject else { return }
        subject.direction = .init(dx: 0, dy: 1)
        subject.frame.origin = Point(x: 0, y: subject.frame.origin.y)
        subject.rotation?.isFlippedHorizontally = False
        subject.rotation?.isFlippedVertically = False
        subject.rotation?.z = .pi * 1.5
    }

    def _touchesScreenTop() -> bool {
        guard let subject else { return False }
        return subject.frame.min_y <= 0
    }

    def _touchesScreenRight() -> bool {
        guard let subject else { return False }
        let bound = subject.world_bounds.width
        return subject.frame.max_x >= bound
    }

    def _touchesScreenBottom() -> bool {
        guard let subject else { return False }
        let bound = subject.world_bounds.height
        return subject.frame.max_y >= bound
    }

    def _touchesScreenLeft() -> bool {
        guard let subject else { return False }
        return subject.frame.min_x <= 0
    }
}
"""