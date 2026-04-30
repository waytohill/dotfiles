from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData

def draw_tab(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_tab_length: int, index: int,
    is_last: bool, extra_data: ExtraData
) -> int:
    if index == 0:
        total = extra_data.num_tabs
        if tab.is_active:
            screen.cursor.fg = draw_data.active_bg
        else:
            screen.cursor.fg = draw_data.inactive_bg
        screen.cursor.bg = draw_data.default_bg
        screen.draw(f"  {total} ")
    return 0
