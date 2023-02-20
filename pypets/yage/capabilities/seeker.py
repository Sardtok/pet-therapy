from math import isclose
from enum import Enum
from typing import List, Optional, Tuple
from yage.models.capability import Capability
from yage.models.collisions import Collision
from yage.models.entity import Entity
from yage.utils.geometry import Point, Vector

class SeekerTargetPosition(Enum):
    CENTER = 'center'
    ABOVE = 'above'

class SeekerState(Enum):
    CAPTURED = 'captured'
    ESCAPED = 'escaped'
    FOLLOWING = 'following'

    def __repr__(self):
        if self == SeekerState.CAPTURE: return "Captured"
        elif self == SeekerState.ESCAPED: return "Escaped"
        else: return f"Following... {self.distance:.2f}"

class Seeker(Capability):
    def __init__(self, subject):
        super().__init__(subject)
        self.target_entity: Optional[Entity] = None
        self.target_position: SeekerTargetPosition = SeekerTargetPosition.CENTER
        self.target_offset = Point(0, 0)
        self.auto_adjust_speed = True
        self.min_distance = 5
        self.max_distance = 20
        self.base_speed = subject.speed
        self.target_reached = False
        self.report = lambda state, distance: None

    def follow(
        self,
        target: Entity,
        position: SeekerTargetPosition,
        offset: Point = Point(0, 0),
        auto_adjust_speed: bool = True,
        min_distance: float = 5,
        max_distance: float = 20,
        report = lambda state, distance: None
    ):
        self.target_entity = target
        self.target_position = position
        self.target_offset = offset
        self.auto_adjust_speed = auto_adjust_speed
        self.min_distance = min_distance
        self.max_distance = max_distance
        self.report = report

    def do_update(self, collisions: List[Collision], time: float):
        subject = self.subject
        target = self._target_point()
        if target is None:
            return

        distance = subject.frame.origin.distance(target)
        self._check_target_reached(distance)
        self._adjust_speed(distance)
        self._adjust_direction(target, distance)

    def _check_target_reached(self, distance: float):
        if not self.target_reached:
            if isclose(distance, self.min_distance, rel_tol=1e-5):
                self.target_reached = True
                self.report(SeekerState.CAPTURE, None)
            else:
                self.report(SeekerState.FOLLOWING, distance)
        elif isclose(distance, self.max_distance, rel_tol=1e-5) and self.target_reached:
            self.target_reached = False
            self.report(SeekerState.ESCAPED, None)

    def _adjust_direction(self, target: Tuple[float, float], distance: float):
        subject = self.subject
        if distance < self.min_distance:
            subject.direction = Vector(0, 0)
        else:
            subject.direction = Vector(
                (target.x - subject.frame.origin.x) / distance,
                (target.y - subject.frame.origin.y) / distance
            )

    def _adjust_speed(self, distance: float):
        subject = self.subject
        if not self.auto_adjust_speed:
            return
        if distance < self.min_distance:
            subject.speed = self.base_speed * 0.25
        elif distance < self.max_distance:
            subject.speed = self.base_speed * 0.5
        else:
            subject.speed = self.base_speed

    def _target_point(self) -> Optional[Point]:
        subject = self.subject
        if subject is None: return None
        target = self.target_entity
        if target is None: return None

        frame = subject.frame
        target_frame = target.frame
        if target_frame is None: return None

        center_x = target_frame.min_x + target_frame.width / 2 - frame.width / 2
        center_y = target_frame.min_y + target_frame.height / 2 - frame.height / 2

        if self.target_position == SeekerTargetPosition.CENTER:
            x = center_x + self.target_offset.x
            y = center_y + self.target_offset.y
        elif self.target_position == SeekerTargetPosition.ABOVE:
            x = center_x + self.target_offset.x
            y = target_frame.min_y - frame.height + self.target_offset.y

        return Point(x, y)