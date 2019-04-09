import base64

from traitlets import Unicode, List, Dict

from ipywidgets.widgets import register, Button
from ipywidgets.widgets.trait_types import bytes_serialization

UNSELECTED = 0
SELECTED = 1
MIXED = 2
EMPTY = 3

def state_diff(old_states, new_states):
    result = []
    for key in old_states.keys():
        if old_states[key] != new_states[key]:
            for i in range(len(old_states[key])):
                if old_states[key][i] != new_states[key][i]:
                    result.append({key: {"icon": i, "new":new_states[key][i]}})
    return result
    
@register
class TreeView(Button):
    """An example widget."""
    _view_name = Unicode('TreeView').tag(sync=True)
    _model_name = Unicode('TreeModel').tag(sync=True)
    _view_module = Unicode('jupyter_cadquery').tag(sync=True)
    _model_module = Unicode('jupyter_cadquery').tag(sync=True)
    _view_module_version = Unicode('^0.1.0').tag(sync=True)
    _model_module_version = Unicode('^0.1.0').tag(sync=True)
    image_paths = List(Dict(None, allow_none=True))
    icons = List(Dict(None, allow_none=True)).tag(sync=True)
    tree = Dict(None, allow_none=True).tag(sync=True)
    state = Dict(None, allow_none=True).tag(sync=True)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        icons = []
        for image_set in self.image_paths:
            icons.append({k:self._load_image(v) for k,v in image_set.items()})
        self.icons = icons

    def _load_image(self, image_path):
        if image_path == "":
            return b""
        else:
            return base64.b64encode(open(image_path, 'rb').read()).decode()
