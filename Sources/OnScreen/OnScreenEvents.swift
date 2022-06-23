//
// Pet Therapy.
// 

import Foundation
import Pets
import UfoAbduction

extension OnScreenViewModel {
    
    func scheduleEvents() {
        scheduleUfoAbduction()
    }
    
    // MARK: - Ufo Abduction
    
    private func scheduleUfoAbduction() {
        state.schedule(every: .timeOfDay(hour: 11, minute: 56)) { [weak self] _ in
            guard let env = self, let pet = env.anyPet else { return }
            animateUfoAbduction(of: pet, in: env.state) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    OnScreen.show()
                }
            }
            env.spawnWindows()
        }
    }
    
    // MARK: - Utils
    
    private var anyPet: PetEntity? {
        state.children.compactMap { $0 as? PetEntity }.first
    }
}
