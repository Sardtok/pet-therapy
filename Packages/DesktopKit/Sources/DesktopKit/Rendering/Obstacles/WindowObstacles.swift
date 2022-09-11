import Combine
import Squanch
import SwiftUI
import WindowsDetector
import Yage

open class WindowObstaclesService: ObservableObject {
        
    private let world: LiveWorld
    private let windowsDetector = WindowsDetector().started(pollInterval: 1)
    private var windowsCanc: AnyCancellable!
    
    public init(world: LiveWorld) {
        self.world = world
    }
    
    public func start() {
        windowsCanc = windowsDetector.$userWindows.sink { [weak self] in
            self?.onWindows($0)
        }
    }
    
    func onWindows(_ windowInfos: [WindowInfo]) {
        let windows = windowInfos.map { SomeWindow(from: $0) }
        let obstacles = obstacles(from: windows)
        world.update(withObstacles: obstacles)
    }
    
    func obstacles(from windows: [SomeWindow]) -> [Entity] {
        return windows
            .reversed()
            .filter { isValidWindow(owner: $0.owner, frame: $0.frame) }
            .map { $0.frame }
            .reduce([]) { obstacles, rect in
                let visibleObstacles = obstacles.flatMap { $0.parts(bySubtracting: rect) }
                let newObstacles = self.obstacles(fromWindowFrame: rect)
                return visibleObstacles + newObstacles
            }
            .filter { isValidObstacle(frame: $0) }
            .map { WindowObstacle(of: $0, in: world) }
    }
    
    open func obstacles(fromWindowFrame frame: CGRect) -> [CGRect] {
        [frame]
    }
    
    open func isValidWindow(owner: String, frame: CGRect) -> Bool {
        guard !frame.isNull && !frame.isEmpty && !frame.isInfinite else { return false }
        guard !frame.contains(world.state.bounds) else { return false }
        return true
    }
    
    open func isValidObstacle(frame: CGRect) -> Bool {
        true
    }
    
    public func stop() {
        windowsDetector.stop()
        windowsCanc?.cancel()
    }
}

struct SomeWindow: Codable {
    let owner: String
    let frame: CGRect
    
    init(from info: WindowInfo) {
        owner = info.processName?.lowercased() ?? ""
        frame = info.frame
    }
}

class WindowObstacle: Entity {
    
    init(of frame: CGRect, in world: LiveWorld) {
        super.init(id: WindowObstacle.nextId(), frame: frame, in: world.state.bounds)
        self.isStatic = true
    }
    
    static func nextId() -> String {
        id += 1
        return "window-\(id)"
    }
    
    static var id: Int = 0
}

extension Entity {
    var isWindowObstacle: Bool { self is WindowObstacle }
}

extension LiveWorld {
    
    func update(withObstacles obstacles: [Entity]) {
        let incomingRects = obstacles.map { $0.frame }
        let existingRects = state.children
            .filter { $0.isWindowObstacle }
            .map { $0.frame }
        
        state.children.removeAll { child in
            guard child.isWindowObstacle else { return false }
            if incomingRects.contains(child.frame) {
                return false
            } else {
                child.kill()
                return true
            }
        }
        obstacles
            .filter { !existingRects.contains($0.frame) }
            .forEach { state.children.append($0) }
    }
}
