from typing import Tuple
from config import *
from yage import *
from onscreen import *

def setup(config: Config, resources_path: str) -> Config:
    Config.shared = config
    AssetsProvider.shared = AssetsProvider(resources_path)
    SpeciesProvider.shared = SpeciesProvider()
    CapabilitiesDiscoveryService.shared = MyCapabilities()
    return config

def build_worlds(screens_geometry: List[str]) -> List[World]:
    return [World(*name_and_frame(geo)) for geo in screens_geometry]

def entity_builder(species, world_bounds): 
    return PetEntity(
        species, world_bounds, 
        pet_size = Config.shared.pet_size,
        gravity = Config.shared.gravity_enabled,
    )

def handle_species_selection_changed(species_ids: List[str], worlds: List[World]):
    species = [SpeciesProvider.shared.species_by_id.get(id) for id in species_ids]
    species = [s for s in species if s is not None]    
    for world in worlds:
        world.handle_species_selection_changed(species, entity_builder)

def name_and_frame(geometry: str) -> Tuple[str, Rect]:
    name, geometry = geometry.split('@')
    return name, Rect.from_geometry(geometry)