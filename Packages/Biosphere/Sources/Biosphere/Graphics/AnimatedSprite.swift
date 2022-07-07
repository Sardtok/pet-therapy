//
// Pet Therapy.
//

import AppKit
import Combine
import Schwifty
import Squanch

open class AnimatedSprite: Capability, ObservableObject {
    
    public let id: String
    
    @Published public private(set) var animation: ImageAnimator = .none
    
    private var lastFrameBeforeAnimations: CGRect
    private var lastState: EntityState = .drag
    private var stateCanc: AnyCancellable!
    
    public required init(with subject: Entity) {
        self.id = "\(subject.id)-Sprite"
        self.lastFrameBeforeAnimations = subject.frame
        super.init(with: subject)
        
        stateCanc = subject.$state.sink { newState in
            Task { @MainActor in
                self.lastState = newState
                self.updateSprite()
            }
        }
    }
    
    @MainActor
    private func updateSprite() {
        guard let path = subject?.animationPath(for: lastState) else { return }
        guard path != animation.baseName else { return }
        printDebug(id, "Loading", path)
        animation.invalidate()
        animation = buildAnimator(baseName: path, state: lastState)
    }
    
    open func buildAnimator(baseName: String, state: EntityState) -> ImageAnimator {
        guard let subject = subject else { return .none }
        let frames = frames(for: baseName)
        
        if case .animation(let anim, let requiredLoops) = state {
            let requiredFrame = anim.frame(for: subject)
            
            return ImageAnimator(
                baseName: baseName,
                frames: frames,
                onFirstFrameLoaded: { completedLoops in
                    guard completedLoops == 0 else { return }
                    self.handleAnimationStarted(setFrame: requiredFrame)
                },
                onLoopCompleted: { completedLoops in
                    guard requiredLoops == completedLoops else { return }
                    self.handleAnimationCompleted()
                }
            )
        } else {
            return ImageAnimator(baseName: baseName, frames: frames)
        }
    }
    
    open func frames(for name: String) -> [NSImage] {
        AnimatedSprite.frames(for: name, in: .main)
    }
    
    public func handleAnimationStarted(setFrame requiredFrame: CGRect) {
        printDebug(id, "Animation started")
        subject?.movement?.isEnabled = false
        subject?.set(frame: requiredFrame)
    }
    
    public func handleAnimationCompleted() {
        printDebug(id, "Animation completed")
        subject?.movement?.isEnabled = true
        subject?.set(state: .move)
        subject?.set(frame: self.lastFrameBeforeAnimations)
    }
    
    open override func update(with collisions: Collisions, after time: TimeInterval) {
        guard isEnabled, let subject = subject else { return }
        
        if let next = animation.nextFrame(after: time) {
            subject.sprite = next
        }
        if !subject.state.isAnimation {
            lastFrameBeforeAnimations = subject.frame
        }
    }
    
    open override func uninstall() {
        subject?.sprite = nil
        super.uninstall()
        animation = .none
        stateCanc?.cancel()
        stateCanc = nil
    }
}

// MARK: - Entity Utils

extension Entity {
    
    public var animation: AnimatedSprite? { capability(for: AnimatedSprite.self) }
    
    public var isDrawable: Bool { animation != nil }
}

// MARK: - Frames from Bundle

extension AnimatedSprite {

    static func frames(for name: String, in bundle: Bundle) -> [NSImage] {
        var frames: [NSImage] = []
        var frameIndex = 0
        
        while true {
            if let path = bundle.path(forResource: "\(name)-\(frameIndex)", ofType: "png"),
               let image = NSImage(contentsOfFile: path) {
                frames.append(image)
            } else {
                if frameIndex != 0 { break }
            }
            frameIndex += 1
        }
        return frames
    }
}

// MARK: - Animation State

private extension EntityState {
    
    var isAnimation: Bool {
        if case .animation = self {
            return true
        } else {
            return false
        }
    }
}
