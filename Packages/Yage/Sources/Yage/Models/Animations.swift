import Schwifty
import SwiftUI

public struct EntityAnimation: Codable {
    public let id: String
    public let facingDirection: CGVector?
    public let requiredLoops: Int?

    let size: CGSize?
    let anchor: AnchorPoint

    public init(
        id: String,
        size: CGSize? = nil,
        anchor: AnchorPoint = .bottom,
        facingDirection: CGVector? = nil,
        requiredLoops: Int? = nil
    ) {
        self.id = id
        self.size = size
        self.anchor = anchor
        self.facingDirection = facingDirection
        self.requiredLoops = requiredLoops
    }

    public func frame(for entity: Entity) -> CGRect {
        let newSize = size(for: entity.frame.size)
        let newPosition = position(
            originalFrame: entity.frame,
            newSize: newSize,
            in: entity.worldBounds
        )
        return CGRect(origin: newPosition, size: newSize)
    }

    private func size(for originalSize: CGSize) -> CGSize {
        guard let customSize = size else { return originalSize }
        return CGSize(
            width: customSize.width * originalSize.width,
            height: customSize.height * originalSize.height
        )
    }

    private func position(
        originalFrame entityFrame: CGRect,
        newSize: CGSize,
        in worldBounds: CGRect
    ) -> CGPoint {
        switch anchor {
        case .bottom: return entityFrame.origin.offset(y: entityFrame.size.height - newSize.height)
        case .top: return entityFrame.origin
        }
    }
}

extension EntityAnimation: CustomStringConvertible {
    public var description: String { id }
}

public extension EntityAnimation {
    enum AnchorPoint: String, Codable {
        case top
        case bottom
    }
}

public extension EntityAnimation {
    func with(loops: Int) -> EntityAnimation {
        EntityAnimation(
            id: id,
            size: size,
            anchor: anchor,
            facingDirection: facingDirection,
            requiredLoops: loops
        )
    }
}
