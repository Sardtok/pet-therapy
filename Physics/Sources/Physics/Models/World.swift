//
// Pet Therapy.
//

import SwiftUI

public struct World {
    
    public let bounds: CGRect
    public var children: [PhysicsEntity] = []
    
    public init(bounds rect: CGRect) {
        bounds = rect
        children = []
        children.append(contentsOf: hotspots())
    }
    
    public mutating func update(after time: TimeInterval) {
        children
            .filter { !$0.isStatic }
            .forEach { child in
                let collisions = child.collisions(with: children)
                child.update(with: collisions, after: time)
            }
    }
}
