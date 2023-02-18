from typing import Optional
from yage.capabilities import *
from yage.models import *
from .sprites import MySpritesProvider

class MyCapabilities(CapabilitiesDiscoveryService):
    def __init__(self):
        self.capabilities = {
            "AnimatedSprite": AnimatedSprite,
            "AnimationsProvider": AnimationsProvider,
            "AnimationsScheduler": AnimationsScheduler,
            "AutoRespawn": AutoRespawn,
            "BounceOnLateralCollisions": BounceOnLateralCollisions,
            "FlipHorizontallyWhenGoingLeft": FlipHorizontallyWhenGoingLeft,
            "Gravity": Gravity,
            "LinearMovement": LinearMovement,
            "Rotating": Rotating,
            "PetsSpritesProvider": MySpritesProvider,
        }

    def capability(self, id: str) -> Optional[Capability]:
        return self.capabilities.get(id)