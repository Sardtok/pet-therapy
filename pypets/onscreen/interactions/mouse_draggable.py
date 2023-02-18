from typing import Optional
from yage.models import Capability
from yage.models.entity_state import EntityState
from yage.utils.geometry import Point, Rect, Size
from yage.utils.logger import Logger

class MouseDraggable(Capability):
    def __init__(self, subject):
        super().__init__(subject)
        self.subject.mouse_drag = self

    def mouse_dragged(self, current_delta: Size) -> None:
        if not self.drag_enabled or self.subject is None:
            return
        if not self.is_being_dragged:
            self._mouse_drag_started()
        new_frame = self.subject.frame.offset(size=current_delta)
        self.subject.frame.origin = self._nearest_position(new_frame, self.subject.world_bounds)

    def mouse_up(self, total_delta: Size) -> Optional[Point]:
        if not self.drag_enabled or not self.is_being_dragged: return None
        return self._mouse_drag_ended()

    @property
    def drag_enabled(self):
        return self.is_enabled and self.subject.is_static == False

    @property
    def is_being_dragged(self):
        return self.subject.state == EntityState.drag

    def _mouse_drag_started(self) -> None:
        self.subject.state = EntityState.drag
        self.subject.movement.is_enabled = False

    def _mouse_drag_ended(self) -> Point:
        final_position = self._nearest_position(self.subject.frame, self.subject.world_bounds)
        self.subject.frame.origin = final_position
        self.subject.state = EntityState.move
        self.subject.movement.is_enabled = True
        return final_position

    def _nearest_position(self, rect: Rect, bounds: Rect) -> Point:
        return Point(
            min(max(rect.min_x, bounds.min_x), bounds.max_x - rect.width),
            min(max(rect.min_y, bounds.min_y), bounds.max_y - rect.height)
        )