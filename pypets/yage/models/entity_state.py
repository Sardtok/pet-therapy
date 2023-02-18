from enum import Enum

class EntityState(Enum):
    free_fall = 'free_fall'
    drag = 'drag'
    move = 'move'
    animation = 'animation'
    
    def __repr__(self):
        return self.value