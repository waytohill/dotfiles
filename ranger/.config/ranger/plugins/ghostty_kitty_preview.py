# -*- coding: utf-8 -*-
"""Workaround for Ghostty + ranger Kitty image previews.

Ghostty supports the Kitty graphics protocol but does not reply to the
filesystem-sharing query (`a=q`) that ranger's KittyImageDisplayer sends during
initialization. This plugin replaces the initialization so the query is skipped
and the (faster) temporary-file transfer mode is used directly.
"""
from __future__ import absolute_import, division, print_function

import fcntl
import struct
import sys
import termios

from ranger.ext.img_display import ImageDisplayError, KittyImageDisplayer


def _late_init(self):
    """Initialize the Kitty image displayer without the Ghostty query."""
    try:
        import PIL.Image  # noqa: F401
        self.backend = PIL.Image
    except ImportError:
        raise ImageDisplayError("Image previews in kitty require PIL (pillow)")

    # Cell size in pixels, required for fitting the image to the preview pane.
    ret = fcntl.ioctl(
        sys.stdout, termios.TIOCGWINSZ, struct.pack("HHHH", 0, 0, 0, 0)
    )
    n_cols, n_rows, x_px_tot, y_px_tot = struct.unpack("HHHH", ret)
    self.pix_row = max(1, x_px_tot // max(1, n_rows))
    self.pix_col = max(1, y_px_tot // max(1, n_cols))

    # Ghostty rejects the temporary-file transfer with
    # "temporary file not named correctly", so stream raw pixels directly.
    self.stream = True
    self.needs_late_init = False


KittyImageDisplayer._late_init = _late_init
