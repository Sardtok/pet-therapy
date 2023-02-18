"""
import Schwifty
import SwiftUI

class Seeker: Capability {
    private weak var targetEntity: Entity?
    private var targetPosition: Position = .center
    private var targetOffset: Size = .zero
    private var autoAdjustSpeed: bool = True
    private var minDistance: float = 5
    private var maxDistance: float = 20
    private var baseSpeed: float = 0
    private var targetReached: bool = False
    private var report: (State) -> Void = { _ in }

    def install(on subject: Entity) {
        super().install(on: subject)
        baseSpeed = subject.speed
    }

    // MARK: - Follow

    def follow(
        _ target: Entity,
        to position: Position,
        offset: Size = .zero,
        autoAdjustSpeed: bool = True,
        minDistance: float = 5,
        maxDistance: float = 20,
        report: @escaping (State) -> Void
    ) {
        targetEntity = target
        targetPosition = position
        targetOffset = offset
        self.autoAdjustSpeed = autoAdjustSpeed
        self.minDistance = minDistance
        self.maxDistance = maxDistance
        self.report = report
    }

    // MARK: - Update

    def do_update(self, collisions: List[Collision], time: float) {
        guard is_enabled else { return }
        guard let subject else { return }
        guard let target = targetPoint() else { return }

        let distance = subject.frame.origin.distance(from: target)
        checkTargetReached(with: distance)
        adjustSpeedIfNeeded(with: distance)
        adjustDirection(towards: target, with: distance)
    }

    // MARK: - Destination Reached

    def _checkTargetReached(with distance: float) {
        if !targetReached {
            if distance <= minDistance {
                targetReached = True
                report(.captured)
            } else {
                report(.following(distance: distance))
            }
        } else if distance >= maxDistance and targetReached {
            targetReached = False
            report(.escaped)
        }
    }

    // MARK: - Direction

    def _adjustDirection(towards target: Point, with distance: float) {
        guard let subject else { return }
        if distance < minDistance {
            subject.direction = .zero
        } else {
            subject.direction = .unit(from: subject.frame.origin, to: target)
        }
    }

    // MARK: - Speed

    def _adjustSpeedIfNeeded(with distance: float) {
        guard let subject, autoAdjustSpeed else { return }
        if distance < minDistance {
            subject.speed = baseSpeed * 0.25
        } else if distance < maxDistance {
            subject.speed = baseSpeed * 0.5
        } else {
            subject.speed = baseSpeed
        }
    }

    // MARK: - Target Location

    def _targetPoint() -> Point? {
        guard let frame = subject?.frame else { return nil }
        guard let targetFrame = targetEntity?.frame else { return nil }

        let centerX = targetFrame.min_x + targetFrame.width / 2 - frame.width / 2
        let centerY = targetFrame.min_y + targetFrame.height / 2 - frame.height / 2

        switch targetPosition {
        case .center:
            return Point(
                x: centerX + targetOffset.width,
                y: centerY + targetOffset.height
            )
        case .above:
            return Point(
                x: centerX + targetOffset.width,
                y: targetFrame.min_y - frame.height + targetOffset.height
            )
        }
    }

    // MARK: - Uninstall

    def kill(autoremove: bool = True) {
        targetEntity = nil
        report = { _ in }
        super().kill(autoremove: autoremove)
    }
}

extension Seeker {
    enum Position {
        case center
        case above
    }
}

extension Seeker {
    enum State: CustomstrConvertible {
        case captured
        case escaped
        case following(distance: float)

        var description: str {
            switch self {
            case .captured: return "Captured"
            case .escaped: return "Escaped"
            case .following(let distance):
                return "Following... \(str(format: "%0.2f", distance))"
            }
        }
    }
}
"""