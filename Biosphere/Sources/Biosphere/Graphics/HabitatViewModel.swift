//
// Pet Therapy.
//

import Squanch
import SwiftUI

open class HabitatViewModel: ObservableObject {
    
    @Published public var state: Environment
        
    public let id: String
    public let tag: String
    
    private var timer: Timer!    
    private var lastUpdate: TimeInterval
        
    let fps: Double = 15
    
    public init(id: String, bounds: CGRect) {
        self.id = id
        self.tag = "Habitat-\(id)"
        lastUpdate = Date.timeIntervalSinceReferenceDate
        state = Environment(bounds: bounds)
        startRendering()
    }
    
    public func startRendering() {
        printDebug(self.tag, "Starting to render...")
        timer?.invalidate()
        timer = Timer(timeInterval: 1/fps, repeats: true) { [weak self] timer in
            guard timer == self?.timer else { return }
            self?.render()
        }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    public func render() {
        let now = Date.timeIntervalSinceReferenceDate
        self.state.update(after: now - self.lastUpdate)
        self.lastUpdate = now
    }
    
    public func pauseRendering() {
        printDebug(self.tag, "Paused rendering")
        timer?.invalidate()
        timer = nil
    }
    
    open func set(bounds: CGRect) {
        state.set(bounds: bounds)
    }
    
    open func kill(animated: Bool) {
        if animated {
            printDebug(self.tag, "Terminating...")
            state.children
                .forEach { item in
                    item.kill(animated: true) { [weak self] in
                        if item.isDrawable {
                            self?.kill(animated: false)
                        }
                    }
                }
        } else {
            pauseRendering()
            state.children.forEach { $0.kill() }
            state.children.removeAll()
            printDebug(self.tag, "Terminated.")
        }
    }
}

extension HabitatViewModel: Equatable {
    
    public static func == (lhs: HabitatViewModel, rhs: HabitatViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
