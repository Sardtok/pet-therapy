import Combine
import Schwifty
import SwiftUI
import WindowsDetector
import Yage

class DesktopObstaclesService: ObservableObject {
    let world: World
    private static let windowsDetector = WindowsDetector().started(pollInterval: 1)
    private var disposables = Set<AnyCancellable>()

    init(world: World) {
        self.world = world
    }

    func start() {
        guard NSScreen.screens.count == 1 else {
            Logger.log("DesktopObstaclesService", "Refusing to start: Multiple screen are not yet supported.")
            return
        }
        DesktopObstaclesService.windowsDetector.$userWindows
            .sink { [weak self] in self?.onWindows($0) }
            .store(in: &disposables)
    }

    func stop() {
        disposables.removeAll()
    }

    private func onWindows(_ windows: [WindowInfo]) {
        let obstacles = obstacles(from: windows)
        world.update(withObstacles: obstacles)
    }

    private func obstacles(from windows: [WindowInfo]) -> [Entity] {
        windows
            .reversed()
            .filter { $0.isValidObstacle(within: world.bounds) }
            .map { $0.frame }
            .reduce([]) { obstacles, rect in
                let visibleObstacles = obstacles.flatMap { $0.parts(bySubtracting: rect) }
                let newObstacles = self.obstacles(fromWindowFrame: rect)
                return visibleObstacles + newObstacles
            }
            .filter { isValidObstacle(frame: $0) }
            .map { WindowObstacle(of: $0, in: world) }
    }

    private func obstacles(fromWindowFrame frame: CGRect) -> [CGRect] {
        obstacles(from: frame, borderThickness: 10)
    }

    func obstacles(from frame: CGRect, borderThickness: CGFloat) -> [CGRect] {
        [CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: borderThickness)]
    }

    private func isValidObstacle(frame: CGRect) -> Bool {
        frame.minY > 100
    }
}

class WindowObstacle: Entity {
    init(of frame: CGRect, in world: World) {
        let id = WindowObstacle.nextId()
        super.init(
            species: .window,
            id: id,
            frame: frame,
            in: world.bounds
        )
        isStatic = true
    }

    static func nextId() -> String {
        id += 1
        return "window-\(id)"
    }

    static var id: Int = 0
}

private extension Species {
    static let window = Species(id: "window")
}

extension Entity {
    var isWindowObstacle: Bool { species == .window }
}

extension World {
    func update(withObstacles obstacles: [Entity]) {
        let incomingRects = obstacles.map { $0.frame }
        let existingRects = children
            .filter { $0.isWindowObstacle }
            .map { $0.frame }

        children.removeAll { child in
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
            .forEach { children.append($0) }
    }
}

private extension WindowInfo {
    var owner: String { processName?.lowercased() ?? "" }

    func isValidObstacle(within worldBounds: CGRect) -> Bool {
        guard !frame.isNull && !frame.isEmpty && !frame.isInfinite else { return false }
        guard frame != worldBounds else { return false }
        guard !frame.contains(worldBounds) else { return false }
        guard !ignoreList.contains(owner) else { return false }

        if owner.contains("desktop pets") {
            return frame.width >= 450 && frame.height >= 450
        }
        return true
    }
}

private let ignoreList: [String] = [
    "parallels desktop",
    "shades",
    "tiles"
]