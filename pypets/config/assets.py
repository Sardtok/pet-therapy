import os
from typing import List, Optional

class _Asset:    
    def __init__(self, path: str):
        self.path = path
        self.sprite = _sprite_name_from_path(path)        
        tokens = self.sprite.split('-')
        self.resources_path = ''
        self.key = tokens[0] if len(tokens) > 0 else ''
        self.frame = int(tokens[-1]) if len(tokens) > 1 else 0
    
def _key(species: str, animation: str) -> str:
    return f'{species}_{animation}'
    
def _key_from_sprite(sprite: str) -> str:
    return sprite.split("-")[0]

def _sprite_name_from_path(path: str) -> str:
    return os.path.split(path)[-1].split('.')[0]

class AssetsProvider:
    def __init__(self, assets_path):
        self.assets_path = assets_path
        self._all_assets_paths = []
        self._sorted_assets_by_key = {}
        self.reload_assets()
    
    def frames(self, species: str, animation: str) -> List[str]:
        key = _key(species, animation)
        assets = self._sorted_assets_by_key.get(key) or []
        return [asset.sprite for asset in assets]
    
    def path(self, sprite: str) -> Optional[str]:
        try:
            key = _key_from_sprite(sprite) 
            return next(asset for asset in self._sorted_assets_by_key[key] if asset.sprite == sprite).path
        except KeyError or AttributeError: 
            return None
    
    def reload_assets(self):
        self._all_assets_paths = self._build_assets_paths()        
        assets = [_Asset(path) for path in self._all_assets_paths]
        assets = sorted(assets, key=lambda asset: asset.frame)
        by_key = {}
        for asset in assets: 
            by_key[asset.key] = (by_key.get(asset.key) or []) + [asset]
        self._sorted_assets_by_key = by_key
    
    def _all_assets(self, species: str) -> List[str]:
        return [path for path in self._all_assets_paths if species in path]
        
    def _build_assets_paths(self) -> List[str]:
        images = [path for path in os.listdir(self.assets_path) if path.endswith('.png')]
        return [os.path.join(self.assets_path, path) for path in images]
