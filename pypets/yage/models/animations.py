from enum import Enum
from typing import Optional
from yage.utils.geometry import Point, Rect, Size, Vector

class EntityAnimationPosition(Enum):
    from_entity_bottom_left = 'from_entity_bottom_left'
    entity_top_left = 'entity_top_left'
    world_top_left = 'world_top_left'
    world_bottom_left = 'world_bottom_left'
    world_top_right = 'world_top_right'
    world_bottom_right = 'world_bottom_right'

class EntityAnimation:
    def __init__(
        self, 
        id: str, 
        size: Optional[Size] = None, 
        position: 'EntityAnimationPosition' = EntityAnimationPosition.from_entity_bottom_left,
        facing_direction: Optional[Vector] = None,
        required_loops: Optional[int] = None
    ):
        self.id = id
        self.size = size
        self.position = position
        self.facing_direction = facing_direction
        self.required_loops = required_loops

    def frame(self, entity):
        new_size = self._size(entity.frame.size)
        new_position = self._position(entity.frame, new_size, entity.world_bounds)
        return Rect(new_position.x, new_position.y, new_size.width, new_size.height)

    def _size(self, original_size):
        if self.size is None:
            return original_size
        return Size(
            width=self.size.width * original_size.width,
            height=self.size.height * original_size.height
        )

    def _position(self, entity_frame, new_size, world_bounds) -> 'Point':
        e = EntityAnimationPosition
        if e.from_entity_bottom_left == self.position:
            return entity_frame.origin.offset(y=entity_frame.size.height - new_size.height)
        elif e.entity_top_left == self.position:
            return entity_frame.origin
        elif e.world_top_left == self.position:
            return world_bounds.top_left
        elif e.world_bottom_left == self.position:
            return world_bounds.bottom_left.offset(y=-entity_frame.height)
        elif e.world_top_right == self.position:
            return world_bounds.top_right.offset(x=-entity_frame.width)
        elif e.world_bottom_right == self.position:
            return world_bounds.bottom_right.offset(
                x=-entity_frame.size.width,
                y=-entity_frame.size.height
            )
        else: 
            return entity_frame.origin

    def with_loops(self, loops: int) -> 'EntityAnimation':
        return EntityAnimation(
            id=self.id,
            size=self.size,
            position=self.position,
            facing_direction=self.facing_direction,
            required_loops=loops
        )

    def __repr__(self):
        return self.id