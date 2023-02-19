import random
from onscreen.interactions import *
from yage.capabilities import Gravity
from yage.models import *
from yage.utils.geometry import *

class PetEntity(Entity):
    def __init__(self, species, world, **kwargs):
        pet_size = kwargs.get('pet_size', 75)
        super().__init__(
            species, 
            PetEntity.next_id(species), 
            Rect(0, 0, pet_size, pet_size),
            world
        )
        self.install(Gravity)
        self.reset_speed()
        self._set_initial_position()
        self._set_initial_direction()
        self.set_gravity_enabled(kwargs.get('gravity', True))
        self._install_additional_capabilities()

    def _install_additional_capabilities(self):
        self.install(ShowsMenuOnRightClick)
        self.install(MouseDraggable)
        self.install(ShowsHomeOnDoubleClick)
    
    def reset_speed(self):
        self.speed = 30.0 * self.species.speed * self.frame.size.width / 75.0

    def _set_initial_position(self):
        random_x = random.uniform(0.1, 0.75) * self.world_bounds.width
        self.frame.origin = Point(random_x, self.world_bounds.height+5)

    def _set_initial_direction(self):
        self.direction = Vector(1, 0)

    def set_gravity_enabled(self, enabled: bool):
        gravity = self.capability(Gravity)
        if not gravity: 
            self.install(Gravity)
            return self.set_gravity_enabled(enabled)

        gravity.is_enabled = enabled
        if not enabled:
            self.direction = Vector(1, 0)
            self.state = EntityState.move

    @classmethod
    def next_id(cls, species):
        if not hasattr(cls, 'incremental_id'): cls.incremental_id = 0
        cls.incremental_id += 1
        return f'{species.id}-{cls.incremental_id}'