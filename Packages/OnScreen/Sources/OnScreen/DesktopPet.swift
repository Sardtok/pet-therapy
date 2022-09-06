import AppState
import DesktopKit
import Combine
import Pets
import Schwifty
import SwiftUI

class DesktopPet: PetEntity {
    
    private var sizeCanc: AnyCancellable!
    private var gravityCanc: AnyCancellable!
    
    init(of species: Pet, in habitatBounds: CGRect) {
        super.init(of: species, size: AppState.global.petSize, in: habitatBounds)
        fps = species.fps
        setupAutoRespawn()
        setupMenu()
        setInitialPosition()
        setInitialDirection()
        bindSizeToSettings()
        bindGravityToSettings()
    }
    
    private func setInitialPosition() {
        let randomX = CGFloat.random(in: 0.1..<0.75) * habitatBounds.width
        let randomY: CGFloat
        
        if capability(for: WallCrawler.self) != nil {
            randomY = habitatBounds.height - frame.height
        } else {
            randomY = CGFloat.random(in: 0.1..<0.5) * habitatBounds.height
        }
        set(origin: CGPoint(x: randomX, y: randomY))
    }
    
    private func setupAutoRespawn() {
        guard AutoRespawn.isCompatible(with: self) else { return }
        install(AutoRespawn.self)
    }
    
    private func setupMenu() {
        install(ShowsMenuOnRightClick.self)
    }
    
    private func setInitialDirection() {
        set(direction: .init(dx: 1, dy: 0))
    }
    
    private func bindSizeToSettings() {
        sizeCanc = AppState.global.$petSize.sink { size in
            self.set(size: CGSize(square: size))
        }
    }
    
    override func kill(animated: Bool, onCompletion: @escaping () -> Void = {}) {
        sizeCanc?.cancel()
        gravityCanc?.cancel()
        super.kill(animated: animated, onCompletion: onCompletion)
    }
}

private extension DesktopPet {
    
    var supportsGravity: Bool {
        capability(for: WallCrawler.self) == nil
    }
    
    func bindGravityToSettings() {
        guard supportsGravity else { return }
        gravityCanc = AppState.global.$gravityEnabled.sink { gravityEnabled in
            if !gravityEnabled {
                self.disableGravity()
            } else {
                self.enableGravity()
            }
        }
    }
    
    func disableGravity() {
        uninstall(Gravity.self)
        if direction.dy > 0 {
            set(direction: .init(dx: 1, dy: 0))
        }
        set(state: .move)
    }
    
    func enableGravity() {
        guard capability(for: Gravity.self) == nil else { return }
        install(Gravity.self)
    }
}
