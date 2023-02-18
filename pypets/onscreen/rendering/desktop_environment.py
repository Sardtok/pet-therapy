from typing import List
from yage.models import *

class DesktopEnvironment:
    def __init__(self, displays: List['Display']):
        self._load_worlds(displays)
    
    def _load_worlds(self, displays: List['Display']):
        self.worlds = [World(name=display.name, bounds=display.bounds) for display in displays]
    
    def remove(self, species: Species):
        for child in self.worlds.children:
            if child.species == species: 
                child.kill()
                self.worlds.children.remove(child)    
    
    def kill(self):
        for world in self.worlds: 
            world.kill()

class Display:
    def __init__(self, name: str, bounds: Rect):
        self.name = name
        self.bounds = bounds