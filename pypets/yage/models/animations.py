from enum import Enum
from typing import Optional
from yage.utils.geometry import Point, Rect, Size, Vector

class EntityAnimationAnchorPoint(Enum):
    bottom = 'bottom'
    top = 'top'

class EntityAnimation:
    def __init__(
        self, 
        id: str, 
        size: Optional[Size] = None, 
        anchor_point: 'EntityAnimationAnchorPoint' = EntityAnimationAnchorPoint.bottom,
        facing_direction: Optional[Vector] = None,
        required_loops: Optional[int] = None
    ):
        self.id = id
        self.size = size
        self.anchor_point = anchor_point
        self.facing_direction = facing_direction
        self.required_loops = required_loops

    def frame(self, entity):
        new_size = self._size(entity.frame.size)
        new_position = self._position(entity.frame, new_size)
        return Rect(new_position.x, new_position.y, new_size.width, new_size.height)

    def _size(self, original_size):
        if self.size is None: return original_size
        return Size(
            width=self.size.width * original_size.width,
            height=self.size.height * original_size.height
        )

    def _position(self, entity_frame, new_size) -> 'Point':
        if self.anchor_point == EntityAnimationAnchorPoint.bottom:
            return entity_frame.origin.offset(y=entity_frame.size.height - new_size.height)        
        elif self.anchor_point == EntityAnimationAnchorPoint.top:
            return entity_frame.origin

    def with_loops(self, loops: int) -> 'EntityAnimation':
        return EntityAnimation(
            id=self.id,
            size=self.size,
            anchor_point=self.anchor_point,
            facing_direction=self.facing_direction,
            required_loops=loops
        )

    def __repr__(self):
        return self.id