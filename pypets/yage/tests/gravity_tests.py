import pdb
import unittest
from yage.capabilities import BounceOnLateralCollisions, Gravity, LinearMovement
from yage.models.entity import Entity, EntityState
from yage.utils.geometry import Point, Rect, Size, Vector
from yage.models.species import SPECIES_AGENT
from yage.models.world import World

class GravityTests(unittest.TestCase):
    def setUp(self):
        self.env = World(name="test", bounds=Rect(x=0, y=0, width=1000, height=1000))
        self.player = Entity(
            species=SPECIES_AGENT,
            id="player",
            frame=Rect(x=0, y=0, width=50, height=50),
            world_bounds=self.env.bounds
        )
        self.player.speed = 1
        self.player.direction = Vector(1, 0)
        self.player.state = EntityState.move
        self.player.install(LinearMovement)
        self.player.install(Gravity)
        self.env.children.append(self.player)

    def test_non_static_entities_are_not_used_as_ground(self):
        ground1 = Entity(
            species=SPECIES_AGENT,
            id="ground1",
            frame=Rect(x=0, y=100, width=200, height=50),
            world_bounds=self.env.bounds
        )
        self.env.children.append(ground1)

        go_right = Vector(1, 0)
        self.player.speed = 1
        self.player.frame.origin = Point(x=50, y=0)
        self.player.direction = go_right
        self.player.state = EntityState.move

        self.env.update(after=0.1)
        self.assertEqual(self.player.state, EntityState.free_fall)
        self.assertEqual(self.player.direction, Gravity.fall_direction)

        for _ in range(70): self.env.update(after=0.1)
        self.assertEqual(self.player.state, EntityState.free_fall)
        self.assertEqual(self.player.direction, Gravity.fall_direction)

    def test_entities_can_fall_to_ground(self):
        ground1 = Entity(
            species=SPECIES_AGENT,
            id="ground1",
            frame=Rect(x=0, y=100, width=200, height=50),
            world_bounds=self.env.bounds
        )
        ground1.is_static = True
        self.env.children.append(ground1)

        go_right = Vector(1, 0)
        self.player.speed = 1
        self.player.frame.origin = Point(x=50, y=0)
        self.player.direction = go_right
        self.player.state = EntityState.move

        self.env.update(after=0.1)
        self.assertEqual(self.player.state, EntityState.free_fall)
        self.assertEqual(self.player.direction, Gravity.fall_direction)

        for i in range(80): 
            self.env.update(after=0.1)
            print(i, self.player.frame, self.player.speed)
        self.assertEqual(self.player.state, EntityState.move)
        self.assertEqual(self.player.frame.min_y, ground1.frame.min_y - self.player.frame.height)
        self.assertEqual(self.player.direction, go_right)

    def test_entities_raise_above_ground(self):
        ground1 = Entity(
            species=SPECIES_AGENT,
            id="ground1",
            frame=Rect(x=0, y=100, width=200, height=50),
            world_bounds=self.env.bounds
        )
        ground1.is_static = True
        self.env.children.append(ground1)

        self.player.install(BounceOnLateralCollisions)
        self.player.speed = 1
        self.player.frame.origin = Point(x=50, y=60)
        self.player.direction = Vector(1, 0)
        self.player.state = EntityState.move

        self.env.update(after=0.1)
        self.assertEqual(self.player.state, EntityState.move)
        self.assertEqual(self.player.frame.min_y, ground1.frame.min_y - self.player.frame.height)
    
    def test_ladder(self):
        ground1 = Entity(
            species=SPECIES_AGENT,
            id="ground1",
            frame=Rect(x=369, y=354, width=250, height=48),
            world_bounds=self.env.bounds
        )
        ground1.is_static = True
        self.env.children.append(ground1)

        ground2 = Entity(
            species=SPECIES_AGENT,
            id="ground2",
            frame=Rect(x=396, y=402, width=687, height=70),
            world_bounds=self.env.bounds
        )
        ground2.is_static = True
        self.env.children.append(ground2)

        self.player.install(BounceOnLateralCollisions)
        self.player.speed = 1
        self.player.frame.size = Size(width=70, height=70)
        self.player.frame.origin = Point(
            x=ground1.frame.max_x - 40,
            y=ground1.frame.min_y - self.player.frame.height
        )
        self.player.direction = Vector(1, 0)
        self.player.state = EntityState.move

        for _ in range(0, 20): self.env.update(after=0.1)
        self.assertEqual(self.player.state,EntityState.move)
        
        for _ in range(20, 51): self.env.update(after=0.1)
        self.assertEqual(self.player.state, EntityState.free_fall)
        
        for _ in range(51, 112): self.env.update(after=0.1)
        self.assertEqual(self.player.state,EntityState.move)

        for _ in range(112, 200): self.env.update(after=0.1)
        self.assertEqual(self.player.state,EntityState.move)