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

    # Gruvbox dark colors
    screen.cursor.fg = as_rgb(0x83a598)  # gruvbox blue
    screen.cursor.bg = as_rgb(0x282828)  # gruvbox bg
    screen.draw(f" [{total}] ")
    return screen.cursor.x
