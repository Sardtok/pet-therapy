import Foundation
import Yage

// MARK: - Schedule Event

extension ScreenEnvironment {
    func scheduleUfoAbduction() {
        scheduleRandomly(withinHours: 0..<5) { [weak self] in
            self?.startUfoAbductionOfRandomVictim()
        }
    }

    public func startUfoAbductionOfRandomVictim() {
        guard let victim = victim else { return }
        animateUfoAbduction(of: victim)
    }
}

// MARK: - Play Event

private extension ScreenEnvironment {
    var victim: PetEntity? {
        children
            .compactMap { $0 as? PetEntity }
            .randomElement()
    }

    func animateUfoAbduction(of target: PetEntity) {
        let ufo = UfoEntity(in: self)
        ufo.frame.origin = bounds.topLeft.offset(x: -100, y: -100)
        children.append(ufo)
        ufo.abduct(target) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                ufo.kill()
                self?.children.removeAll { $0 == ufo }
                target.kill()
                self?.children.removeAll { $0 == target }
                self?.add(pet: target.species)
            }
        }
    }
}

// MARK: - Entity

private class UfoEntity: PetEntity {
    init(in world: World) {
        super.init(of: .ufo, in: world.bounds)
        setBounceOnLateralCollisions(enabled: false)
    }

    func abduct(_ target: Entity, onCompletion: @escaping () -> Void) {
        let abduction = UfoAbduction()
        install(abduction)
        abduction.abduct(target, onCompletion)
    }
}

// MARK: - Animation

private extension EntityAnimation {
    static let abduction = EntityAnimation(
        id: "abduction",
        size: CGSize(width: 1, height: 3),
        position: .entityTopLeft
    )
}

// MARK: - Abduction

private class UfoAbduction: Capability {
    weak var target: Entity?

    private var subjectOriginalSize: CGSize!

    private var onCompletion: () -> Void = {}

    func abduct(_ target: Entity, _ onCompletion: @escaping () -> Void) {
        guard let subject else { return }
        subjectOriginalSize = subject.frame.size
        self.target = target
        self.onCompletion = onCompletion

        let seeker = Seeker()
        subject.install(seeker)
        let distance = CGSize(width: 0, height: -50)

        seeker.follow(target, to: .above, offset: distance) { [weak self] captureState in
            guard let self else {
                seeker.kill()
                onCompletion()
                return
            }
            guard case .captured = captureState else { return }
            seeker.isEnabled = false
            self.paralizeTarget()
            self.captureRayAnimation()
        }
    }

    private func paralizeTarget() {
        guard let target = target else { return }
        target.setGravity(enabled: false)
        target.direction = CGVector(dx: 0, dy: -1)
        target.speed = PetEntity.speedMultiplier(for: target.frame.size.width)
    }

    private func captureRayAnimation() {
        guard let subject = subject, let target = target else { return }
        subject.direction = .zero
        subject.set(state: .action(action: EntityAnimation.abduction, loops: 1))
        subject.capability(for: Seeker.self)?.kill()

        let shape = ShapeShifter()
        target.install(shape)
        shape.scaleLinearly(to: CGSize(width: 5, height: 5), duracy: 1.1)
        scheduleAnimationCompletion(in: 1.25)
    }

    private func scheduleAnimationCompletion(in delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            self.target?.capability(for: AnimatedSprite.self)?.kill()
            self.resumeMovement()
            self.onCompletion()
        }
    }

    private func resumeMovement() {
        subject?.set(state: .move)
        subject?.frame.size = subjectOriginalSize
        subject?.direction = CGVector(dx: 1, dy: 0)
        kill()
    }

    override func kill(autoremove: Bool = true) {
        super.kill(autoremove: autoremove)
        target = nil
    }
}

private extension Species {
    static let ufo = Species(
        id: "ufo",
        capabilities: [
            "AnimatedSprite",
            "AnimationsProvider",
            "AutoRespawn",
            "BounceOnLateralCollisions",
            "LinearMovement",
            "PetsSpritesProvider"
        ],
        dragPath: "front",
        movementPath: "front",
        speed: 2
    )
}