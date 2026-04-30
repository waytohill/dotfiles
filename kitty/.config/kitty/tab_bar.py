from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData

def draw_tab(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_tab_length: int, index: int,
    is_last: bool, extra_data: ExtraData
) -> int:
    if index != 0:
        return 0

    # Draw tab count indicator on the first (active) tab only
    total = extra_data.num_tabs
    if total <= 1:
        return 0

    # Set colors: use the active tab accent color
    screen.cursor.fg = draw_data.active_bg
    screen.cursor.bg = draw_data.default_bg

    label = f" {total} "
    screen.draw(label)
    end = screen.cursor.x

    # Fill rest of the tab bar with background color
    screen.cursor.fg = draw_data.default_bg
    screen.cursor.bg = draw_data.default_bg
    screen.draw(" " * (screen.columns - end))

    return end
