"""Hermes plugin adapter for OpenCode CLI.

Integration with OpenCode happens via the Hermes ``terminal`` tool plus
the bundled ``opencode`` skill (see skills/autonomous-ai-agents/opencode).
This module only verifies the ``opencode`` binary is available and fails
open so Hermes never breaks when it is missing.
"""

import shutil
import sys


_opencode_available = None
_opencode_missing_warned = False


def register(ctx):
    """Register the plugin (no hooks needed; terminal + skill do the work)."""
    _check_opencode()
    return


def _check_opencode():
    """Return whether the opencode binary is in PATH, warning once when missing."""
    global _opencode_available, _opencode_missing_warned

    if _opencode_available is None:
        _opencode_available = shutil.which("opencode") is not None

    if not _opencode_available and not _opencode_missing_warned:
        print(
            "opencode: hermes plugin warning: opencode binary not found in PATH; "
            "install with `npm i -g opencode-ai@latest`",
            file=sys.stderr,
        )
        _opencode_missing_warned = True

    return _opencode_available
