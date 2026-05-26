from pathlib import Path

import torch


def checkpoint_architecture(path):
    """
    Classify a Lightning checkpoint by its state-dict key layout.
    """
    path = Path(path)
    checkpoint = torch.load(path, map_location="cpu", weights_only=False)
    state = checkpoint.get("state_dict", checkpoint)
    keys = set(state.keys())

    if any(k.startswith("edge_model.") for k in keys) and any(k.startswith("node_model.") for k in keys):
        return "mpnn", "current message-passing MPNN architecture"
    if any(k.startswith("input_layer.") for k in keys) or any(k.startswith("mlp_layers.") for k in keys):
        return "legacy_flat", "legacy flat SEMLP/MLP checkpoint"
    return "unknown", "state_dict keys do not match a known model layout"


def assert_checkpoint_architecture(path, expected="mpnn"):
    arch, detail = checkpoint_architecture(path)
    if arch != expected:
        raise RuntimeError(
            f"{path} is a {arch} checkpoint ({detail}), not {expected}. "
            "Delete or archive the stale checkpoint and train a new current-MPNN checkpoint."
        )
    return arch, detail


def load_checkpoint_for_model(model_cls, path, expected="mpnn"):
    """
    Validate a checkpoint layout before delegating to Lightning's loader.
    """
    assert_checkpoint_architecture(path, expected=expected)
    return model_cls.load_from_checkpoint(str(path))
