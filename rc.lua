-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- !!SMART BORDERS
--require('smart_borders'){ show_button_tooltips = true }

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- SET THEME
local themes_path = os.getenv("HOME") .. "/.config/awesome/themes"
beautiful.init(themes_path .. "/my-first-rice-UWU/theme.lua")

-- EXTRA MODULES STOLEN FROM THE INTERNET	
local keys = require("keys")
local helpers = require("helpers")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local battery_widget = require("battery-widget.battery")
local keyboard_layout = require("keyboard_layout")
local spotify_widget = require("spotify-widget.spotify")
local net_widgets = require("net_widgets")
require("notifications.volume-notif")
require("notifications.brightness-notif")
require("dashboard.config")
require("weather-widget.weather-evil")

-- DEFAULT APPS
terminal = "kitty"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- COMMANDS TO RUN WHEN (RE)START AWESOME
awful.spawn.with_shell("picom --experimental-backends --config ~/.config/picom.conf")

-- LAYOUTS, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ WIBAR
-- Date preview widget
date_widget = wibox.widget{
    {    
	image = themes_path .. "/my-first-rice-UWU/taglist/taglist_fill.svg",
	resize = true,
        widget = wibox.widget.imagebox,
    },
    {    	
    	format = '%d/%m/%Y  ',
    	font = beautiful.fancy_font, 
    	fg = beautiful.chocolate_brown,
    	widget = wibox.widget.textclock,
    },
    layout = wibox.layout.align.horizontal,
}

-- Textclock widget
time_widget = wibox.widget{
    {
	image = themes_path .. "/my-first-rice-UWU/taglist/taglist_fill.svg",
	resize = true,
	widget = wibox.widget.imagebox,
    },
    {
        format = '%H:%M  ',
    	font = beautiful.fancy_font,
    	widget = wibox.widget.textclock
    },
    layout = wibox.layout.align.horizontal,
}

-- Bluetooth shortcut hopefully
bluetooth_shortcut = wibox.widget{
    {
        {
	    image = themes_path .. "/my-first-rice-UWU/taglist/taglist_fill.svg",
	    resize = true,
	    widget = wibox.widget.imagebox,
	},
        margins = 3,
        widget = wibox.container.margin,
    },
    id = "background",
    bg = beautiful.tasklist_bg_focus,
    shape_border_width = beautiful.border_width,
    shape_border_color = beautiful.border_color,
    shape = helpers.rrect(beautiful.border_radius),
    widget = wibox.container.background,
}
--TODO change to only left click :))
bluetooth_shortcut:connect_signal("button::press", function() awful.spawn.with_shell("blueman-manager") end)

-- Keyboard layout widget
local kbdcfg = keyboard_layout.kbdcfg({type = "tui", cmd = "setxkbmap", remember_layout = false})
kbdcfg.add_primary_layout("English", "US", "us")
kbdcfg.add_primary_layout("Rumenski", "RO", "ro std")
kbdcfg.bind()

-- Mouse bindings for keyboard widget
kbdcfg.widget:buttons(
 awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch_next() end),
                       awful.button({ }, 3, function () kbdcfg.menu:toggle() end))
)

keyblayout_widget = wibox.widget{
    {
        {
	    kbdcfg.widget,
	    --widget = wibox.widget.textbox,
	    layout = wibox.layout.fixed.horizontal
	},
        margins = 0,
        widget = wibox.container.margin,
    },
    id = "background",
    bg = beautiful.tasklist_bg_focus,
    shape_border_width = beautiful.border_width,
    shape_border_color = beautiful.border_color,
    shape = helpers.rrect(beautiful.border_radius),
    forced_width = 35,
    widget = wibox.container.background,
}

-- Spotify widget
local sp_widget = spotify_widget({
    font = beautiful.font,
    play_icon = beautiful.play_icon,
    pause_icon = beautiful.pause_icon,
    prev_icon = beautiful.prev_icon,
    next_icon = beautiful.next_icon,
    dim_when_paused = false,
    max_length = 100,
    show_tooltip = false,
    max_width = 180,
    separator_text = " ~ ",
    text_color = beautiful.c3,
    separator_color = beautiful.c4,
    margin_lr = 10,
    bg = beautiful.taglist_fg_occupied,
    border_width = beautiful.border_width,
    border_color = beautiful.border_color,
    shape = helpers.rrect(beautiful.border_radius),
    border_radius = beautiful.border_radius,
    tl = false,
    tr = false, 
    tooltip_bg = beautiful.c1,
    tooltip_fg = beautiful.c3,
    tooltip_width = 500
})

--Wifi widget?
local wifi_widget = net_widgets.wireless({
    interface = "wlp58s0", 
    font = beautiful.fancy_font, 
    popup_signal = false,
    popup_metrics = true,
    popup_position = "top_right",
    onclick = terminal .. "nmtui" --TODO??
})

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
	layout  = {
	    spacing = 10,
	    spacing_widget = {
		{
 	        color = beautiful.c4,
		forced_height = 3,
	        shape = gears.shape.circle,
                widget = wibox.widget.separator,	
		},
		left = 3,
                right = 3,
                widget = wibox.container.margin,           
	    },
	    layout = wibox.layout.fixed.horizontal,
	},
	style = {
	    shape = helpers.rrect(dpi(7)),
	    font = beautiful.fancy_font,
	    bg_focus    = beautiful.taglist_bg_focus,
	    bg_occupied = beautiful.taglist_bg_occupied,
	    bg_empty    = beautiful.taglist_bg_empty,
	    fg_focus    = beautiful.taglist_fg_focus,
	    fg_empty    = beautiful.taglist_fg_empty,
	    fg_occupied = beautiful.taglist_fg_occupied,
 	},
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
 	screen   = s,
    	filter   = awful.widget.tasklist.filter.currenttags,
    	buttons  = tasklist_buttons,
    	layout   = {
            spacing = 7,
            layout  = wibox.layout.fixed.horizontal
	},
	style = {
	   font = beautiful.fancy_font,
	   bg_focus = beautiful.tasklist_bg_focus,
	   bg_normal = beautiful.tasklist_bg_normal,
	   shape = helpers.rrect(beautiful.border_radius),
	   shape_border_width = beautiful.border_width,
	   shape_border_color = beautiful.border_color
	},
	widget_template = {
           {
               {
                   id     = 'icon_role',
                   widget = wibox.widget.imagebox,
               },
               margins = 7,
               widget  = wibox.container.margin,
           },
	   id = 'background_role',
           widget = wibox.container.background,
        },
    }
    
    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top",  screen = s, height = 35, bg = "#ff000000" })

    -- Add widgets to the wibox
    s.mywibox:setup {
       -- {    
            { -- LEFT WIDGETS
                {
		    {
                        --mylauncher,
			sp_widget,
                        s.mytasklist,
                        s.mypromptbox,
		        layout = wibox.layout.fixed.horizontal,
		    },
		    left = 15,
		    widget = wibox.container.margin,
		},
                forced_width = 800,
                layout = wibox.layout.fixed.horizontal,
            },
	    { -- MIDDLE WIDGETS    
	        {
                    {
		        {
			    {
		                {
			            {	
    	                                s.mytaglist,
	                                layout = wibox.layout.fixed.horizontal,
		                    },
		                    margins = 3,
	                            widget = wibox.container.margin,
	                        },
		                bg = beautiful.taglist_bg_empty,
		                shape = helpers.rrect(beautiful.border_radius),
		                shape_border_width = beautiful.border_width,
	 	                shape_border_color = beautiful.border_color,
	                        widget = wibox.container.background,
	                     },	
			     right = 10,
			     widget = wibox.container.margin,	
			},
		        {
		            {
			        {	
                		    s.mylayoutbox,
				    layout = wibox.layout.fixed.horizontal,
		                },
		                margins = 10,
	                        widget = wibox.container.margin,
	                    },
		            bg = beautiful.tasklist_bg_focus,
		            shape = helpers.rrect(beautiful.border_radius),
		            shape_border_width = beautiful.border_width,
	 	            shape_border_color = beautiful.border_color,
	                    widget = wibox.container.background,
	                },
			layout = wibox.layout.fixed.horizontal,
		    },
                    left = 45,
                    widget = wibox.container.margin,	
	        },
		layout = wibox.layout.fixed.horizontal,
	
            },
            { -- RIGHT WIDGETS
	       	{
		    {	
                        bluetooth_shortcut,
 			{
			    {
                        	keyblayout_widget,
				layout = wibox.layout.fixed.horizontal,
			    },
                            left = 6,
                            right = 6,
                            widget = wibox.container.margin,
			},
                        {
		            {   
			        {	
    	                            --mykeyboardlayout,
                		    --wibox.widget.systray(),
				    battery_widget(),
				    { 
				        {
				    	    wifi_widget, 
					    layout = wibox.layout.fixed.horizontal,
					},
					right = 15,
                                        widget = wibox.container.margin,
				    },  			    
           			    date_widget,
                                    time_widget,
              	                    layout = wibox.layout.fixed.horizontal,
		                },
		                margins = 3,
	                        widget = wibox.container.margin,
	                    },
		            bg = beautiful.taglist_bg_empty,
		            shape = helpers.rrect(beautiful.border_radius),
		            shape_border_width = beautiful.border_width,
	 	            shape_border_color = beautiful.border_color,
	                    widget = wibox.container.background,
	                },
                        layout = wibox.layout.fixed.horizontal,
		    },
                    right = 15,
                    widget = wibox.container.margin,	
	        },
		layout = wibox.layout.fixed.horizontal,
            },
        layout = wibox.layout.align.horizontal,
    }
    -- Place bar at the top and add margins
    awful.placement.top(s.mywibox, {margins = 5})
    -- Also add some screen padding so that clients do not stick to the bar
    s.padding = { top = 0}

end)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_color,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = keys.clientkeys,
                     buttons = keys.clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- (heavily improvised) maximized clients dont go into semi-fullscreen
client.connect_signal("property::maximized", function(c)
    if (c.maximized==true) then
	c.height = dpi(1015) 
	c.width = dpi(1890)
	c.y = 47
	c.x = 12
        c.floating = false
    end
end)


-- Changing spotify notifications.
naughty.config.presets.spotify = { 
    -- if you want to disable Spotify notifications completely, return false
    callback = function(args)
        return false
    end,

    -- Adjust the size of the notification
    height = 100,
    width  = 400,
    -- Guessing the value, find a way to fit it to the proper size later
    icon_size = 90
}
table.insert(naughty.dbus.config.mapping, {{appname = "Spotify"}, naughty.config.presets.spotify})


--TITLEBAR
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    
    --[[awful.titlebar(c,{
        --properties??
        size = 5,
	position = "right",
	bg_normal = beautiful.border_color,
	bg_focus = beautiful.border_color,
    })

    awful.titlebar(c,{
        --properties??
        size = 5,
	position = "bottom",
	bg_normal = beautiful.border_color,
	bg_focus = beautiful.border_color,
    })]]

    awful.titlebar(c,
	           {--properties??
                    size = 28,
		    position = "top",
                   }
    ) : setup {
        { -- Left
	    {
                {
                    widget = awful.titlebar.widget.iconwidget(c),
                },
                left = 5,
                right = 5,
                top = 2,
                bottom = 2,
                widget = wibox.container.margin,
            },
	    { -- TITLE
              align = "left",
	      font = "VT323 15",
              widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
	    awful.titlebar.widget.minimizebutton (c),
            awful.titlebar.widget.closebutton    (c),
	    --[[{
		color = beautiful.border_color,
	        shape = helpers.rrect(0),
		forced_width = 5,
		widget = wibox.widget.separator,
	    },]]
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }

end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
