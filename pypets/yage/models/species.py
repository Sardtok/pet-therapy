from typing import List
from yage.models.animations import EntityAnimation

class Species:
    def __init__(
        self, 
        id: str,
        animations: List[EntityAnimation] = [],
        capabilities: List[str] = [],
        drag_path: str = 'drag',
        fps: float = 10,
        movement_path: str = 'walk',
        speed: float = 1,
        tags: List[str] = [],
        z_index: float = 0
    ):
        self.id = id
        self.animations = animations
        self.capabilities = capabilities
        self.drag_path = drag_path
        self.fps = fps
        self.movement_path = movement_path
        self.speed = speed
        self.tags = tags
        self.z_index = z_index        

    def __eq__(self, other: 'Species'):
        if other is None: return False
        return self.id == other.id

    def __repr__(self):
        return self.id

SPECIES_AGENT = Species("agent")
SPECIES_HOTSPOT = Species("hotspot")