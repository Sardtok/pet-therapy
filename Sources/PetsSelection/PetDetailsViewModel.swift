import Combine
import DependencyInjectionUtils
import NotAGif
import SwiftUI
import Yage

class PetDetailsViewModel: ObservableObject {
    @Inject private var assets: PetsAssetsProvider
    @Inject private var names: SpeciesNamesRepository
    
    private let deletePet = DeletePetButtonCoordinator()
    private let exportPet = ExportPetButtonCoordinator()
    private let renamePet = RenamePetButtonCoordinator()
    
    @Binding var isShown: Bool
    @Published var title: String = ""
    
    private let species: Species
    private var appState: AppState { AppState.global }
    let speciesAbout: String
    var canRemove: Bool { isSelected }
    var canSelect: Bool { !isSelected }
    var isSelected: Bool { appState.isSelected(species.id) }

    var animationFrames: [ImageFrame] {
        assets.images(for: species.id, animation: "front")
    }

    var animationFps: TimeInterval {
        max(3, species.fps)
    }
    
    private var disposables = Set<AnyCancellable>()

    init(isShown: Binding<Bool>, species: Species) {
        self._isShown = isShown
        self.speciesAbout = Lang.Species.about(for: species.id)
        self.species = species
        self.bindTitle()
    }
    
    func close() {
        withAnimation {
            isShown = false
        }
    }

    func selected() {
        appState.select(species.id)
        Tracking.didSelect(species.id)
        close()
    }

    func remove() {
        appState.deselect(species.id)
        Tracking.didRemove(species.id)
        close()
    }
    
    func didAppear() {
        Tracking.didEnterDetails(
            species: species.id,
            name: species.id,
            price: nil,
            purchased: false
        )
    }
    
    func deleteButton() -> some View {
        deletePet.view(for: species) { [weak self] deleted in
            if deleted { self?.close() }
        }
    }

    func exportButton() -> some View {
        exportPet.view(for: species)
    }
    
    func renameButton() -> some View {
        renamePet.view(for: species.id)
    }
    
    private func bindTitle() {
        names.name(forSpecies: species.id)
            .sink { [weak self] name in self?.title = name }
            .store(in: &disposables)
    }
}

extension NSScreen: Identifiable {
    public var id: String { localizedName.lowercased() }
}
