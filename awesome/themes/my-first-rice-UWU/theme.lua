----------------------------
--  my first shitty rice  --
--          UWU           --
----------------------------
local gears = require("gears")

--local themes_path = require("gears.filesystem").get_themes_dir()
local themes_path = os.getenv("HOME") .. "/.config/awesome/themes/my-first-rice-UWU"
local dpi = require("beautiful.xresources").apply_dpi

-- {{{ Main
local theme = {}
theme.wallpaper = themes_path .. "/tree_bkg3.jpg"
-- }}}

-- {{{ Styles
theme.font      = "VT323 14"
theme.fancy_font     = "Charybdis 13"

--{{{ Base Colors
theme.c1   = "#ffe5c2" --cream
theme.c2   = "#a9dda4" --light green
theme.c2v2 = "#86cb80" --dark green
theme.c3   = "#3d362d" --light brown
theme.c3v2 = "#29231d" --dark brown
theme.c4   = "#c83bba" --purple

theme.border_color = theme.c3v2
--}}}

--{{{ Universal Colors
theme.fg_normal  = theme.c1
theme.fg_focus   = theme.c4
theme.fg_urgent  = theme.c4
theme.bg_normal  = theme.c3
theme.bg_focus   = theme.c1
theme.bg_urgent  = theme.c3
theme.bg_systray = "#ffe5c200"

-- }}}

-- {{{ Borders
theme.useless_gap   = dpi(6)
theme.border_width  = dpi(3)
theme.border_radius = dpi(13)
theme.border_normal = theme.c3v2
theme.border_focus  = theme.c3v2
theme.border_marked = theme.c1
-- }}}

-- {{{ Titlebars
theme.titlebar_fg_focus  = theme.c3
theme.titlebar_fg_normal = theme.c3
theme.titlebar_bg_focus  = theme.c1
theme.titlebar_bg_normal = theme.c2
-- }}}

-- {{{ Taglist
theme.taglist_fg_focus    = theme.c4
theme.taglist_fg_occupied = theme.c2
theme.taglist_fg_empty    = theme.c1
theme.taglist_bg_focus    = theme.c3v2
theme.taglist_bg_occupied = theme.c3
theme.taglist_bg_empty    = theme.c3
-- }}}

-- {{{ Tasklist
theme.tasklist_bg_focus  = theme.c2
theme.tasklist_bg_normal = theme.c3
-- }}}

-- {{{ Mouse finder ????
theme.mouse_finder_color = theme.c4
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Calendar

-- }}}

-- {{{ Menu
theme.menu_bg_normal = theme.c1
theme.menu_bg_focus = theme.c1
theme.menu_fg_normal = theme.c4
theme.menu_fg_focus = theme.c3
theme.menu_border_color = theme.border_color
theme.menu_boder_width = theme.border_width
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)
-- }}}

-- {{{ Notifications
theme.notification_font = theme.font
theme.notification_bg = theme.c1
theme.notification_fg = theme.c3
theme.notification_border_width = 3
theme.notification_border_color = theme.border_color
theme.notification_margin = 10
theme.notification_spacing = 5
theme.notification_shape = gears.shape.rounded_rect
-- }}}

-- {{{ Dashboard
theme.dashboard_bg = "#29231db3"
theme.dashboard_fg = theme.c1
theme.dashboard_box_border_radius = theme.border_radius
-- }}}

-- {{{ Icons

-- { Taglist
-- theme.taglist_squares_sel   = themes_path .. "/taglist/squarefz.png"
-- theme.taglist_squares_unsel = themes_path .. "/taglist/squarez.png"
-- theme.taglist_squares_resize = "false"
-- }

-- { Misc
theme.awesome_icon      = themes_path .. "/awesome-icon.png"
theme.menu_submenu_icon = themes_path .. "/submenu.png"

theme.pause_icon        = themes_path .. "/misc-icons/pause_icon.svg"
theme.play_icon         = themes_path .. "/misc-icons/play_icon.svg"
theme.prev_icon         = themes_path .. "/misc-icons/prev_icon.svg"
theme.next_icon         = themes_path .. "/misc-icons/next_icon.svg"

theme.volume_icon       = themes_path .. "/titlebar/close_dark.svg"
theme.mute_icon		= themes_path .. "/titlebar/cloase_purple.svg"
-- }

-- { Layout
theme.layout_tile       = themes_path .. "/layouts/tile.png"
theme.layout_tileleft   = themes_path .. "/layouts/tileleft.png"
theme.layout_tilebottom = themes_path .. "/layouts/tilebottom.png"
theme.layout_tiletop    = themes_path .. "/layouts/tiletop.png"
theme.layout_fairv      = themes_path .. "/layouts/fairv.png"
theme.layout_fairh      = themes_path .. "/layouts/fairh.png"
theme.layout_spiral     = themes_path .. "/layouts/spiral.png"
theme.layout_dwindle    = themes_path .. "/layouts/dwindle.png"
theme.layout_max        = themes_path .. "/layouts/max.png"
theme.layout_fullscreen = themes_path .. "/layouts/fullscreen.png"
theme.layout_magnifier  = themes_path .. "/layouts/magnifier.png"
theme.layout_floating   = themes_path .. "/layouts/floating.png"
theme.layout_cornernw   = themes_path .. "/layouts/cornernw.png"
theme.layout_cornerne   = themes_path .. "/layouts/cornerne.png"
theme.layout_cornersw   = themes_path .. "/layouts/cornersw.png"
theme.layout_cornerse   = themes_path .. "/layouts/cornerse.png"
-- }

-- { Titlebar
theme.titlebar_close_button_focus  = themes_path .. "/titlebar/close_purple.svg"
theme.titlebar_close_button_normal = themes_path .. "/titlebar/close_dark.svg"

theme.titlebar_minimize_button_normal = themes_path .. "/titlebar/minimize_dark.svg"
theme.titlebar_minimize_button_focus  = themes_path .. "/titlebar/minimize_purple.svg"

theme.titlebar_ontop_button_focus_active  = themes_path .. "/titlebar/ontop_dark.svg"
theme.titlebar_ontop_button_normal_active = themes_path .. "/titlebar/ontop_purple.svg"
theme.titlebar_ontop_button_focus_inactive  = themes_path .. "/titlebar/ontop_purple.svg"
theme.titlebar_ontop_button_normal_inactive = themes_path .. "/titlebar/ontop_dark.svg"

theme.titlebar_sticky_button_focus_active  = themes_path .. "/titlebar/sticky_dark.svg"
theme.titlebar_sticky_button_normal_active = themes_path .. "/titlebar/sticky_purple.svg"
theme.titlebar_sticky_button_focus_inactive  = themes_path .. "/titlebar/sticky_purple.svg"
theme.titlebar_sticky_button_normal_inactive = themes_path .. "/titlebar/sticky_dark.svg"

theme.titlebar_floating_button_focus_active  = themes_path .. "/titlebar/floating_dark.svg"
theme.titlebar_floating_button_normal_active = themes_path .. "/titlebar/floating_purple.svg"
theme.titlebar_floating_button_focus_inactive  = themes_path .. "/titlebar/floating_purple.svg"
theme.titlebar_floating_button_normal_inactive = themes_path .. "/titlebar/floating_dark.svg"

theme.titlebar_maximized_button_focus_active  = themes_path .. "/titlebar/maximize_dark.svg"
theme.titlebar_maximized_button_normal_active = themes_path .. "/titlebar/maximize_purple.svg"
theme.titlebar_maximized_button_focus_inactive  = themes_path .. "/titlebar/maximize_purple.svg"
theme.titlebar_maximized_button_normal_inactive = themes_path .. "/titlebar/maximize_dark.svg"
-- }

-- }}}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
