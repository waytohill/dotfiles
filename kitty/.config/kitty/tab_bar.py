from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

def draw_tab(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_tab_length: int, index: int,
    is_last: bool, extra_data: ExtraData
) -> int:
    # Only draw indicator on first tab
    if index != 0:
        return 0

    total = extra_data.num_tabs
    if total <= 1:
        return 0

    # Draw a colored marker with tab count
    # Use the active tab's background as foreground for visibility
    screen.cursor.fg = as_rgb(0x7aa2f7)  # bright blue - always visible
    screen.cursor.bg = as_rgb(0x1a1b26)  # dark background
    screen.draw(f" [{total}] ")
    return screen.cursor.x
