local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local helpers = require("helpers")
local dpi = require('beautiful').xresources.apply_dpi

local keygrabber = require("awful.keygrabber")

-- Appearance
local box_radius = beautiful.dashboard_box_border_radius or dpi(13)
local box_gap = dpi(6)

-- Column widhts
local col1 = 300
local col2 = 240
local col3 = 240
local col4 = 350

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height

-- Create the widget
dashboard = wibox({visible = false, ontop = true, type = "dock", screen = screen.primary})
awful.placement.maximize(dashboard)

dashboard.bg = beautiful.dashboard_bg or beautiful.exit_screen_bg or beautiful.wibar_bg or "#111111"
dashboard.fg = beautiful.dashboard_fg or beautiful.exit_screen_fg or beautiful.wibar_fg or "#FEFEFE"

-- Add dashboard or mask to each screen
awful.screen.connect_for_each_screen(function(s)
    if s == screen.primary then
        s.dashboard = dashboard
    else
        s.dashboard = helpers.screen_mask(s, dashboard.bg)
    end
end)

local function set_visibility(v)
    for s in screen do
        s.dashboard.visible = v
    end
end

dashboard:buttons(gears.table.join(
    -- Middle click - Hide dashboard
    awful.button({ }, 2, function ()
        dashboard_hide()
    end)
))

-- Helper function that puts a widget inside a box with a specified background color
-- Invisible margins are added so that the boxes created with this function are evenly separated
-- The widget_to_be_boxed is vertically and horizontally centered inside the box
local function create_boxed_widget(widget_to_be_boxed, width, height, bg_color)
    local box_container = wibox.container.background()
    box_container.bg = bg_color
    --box_container.bgimage = "/home/fried-milk/.config/neofetch/pixel-frog.png"
    box_container.forced_height = height
    box_container.forced_width = width
    box_container.border_width = beautiful.border_width
    box_container.border_color = beautiful.border_color
    box_container.shape = helpers.rrect(box_radius)
    -- box_container.shape = helpers.prrect(20, true, true, true, true)
    -- box_container.shape = helpers.prrect(30, true, true, false, true)

    local boxed_widget = wibox.widget {
        -- Add margins
        {
            -- Add background color
            {
                -- Center widget_to_be_boxed horizontally
                nil,
                {
                    -- Center widget_to_be_boxed vertically
                    nil,
                    -- The actual widget goes here
                    widget_to_be_boxed,
                    layout = wibox.layout.align.vertical,
                    expand = "none"
                },
                layout = wibox.layout.align.horizontal,
                expand = "none"
            },
            widget = box_container,
        },
        margins = box_gap,
        color = "#FF000000",
        widget = wibox.container.margin
    }

    return boxed_widget
end



-- User widget
local user_picture_container = wibox.container.background()
user_picture_container.shape = gears.shape.circle
user_picture_container.border_width = beautiful.border_width
user_picture_container.boder_color = beautiful.border_color
local user_picture = wibox.widget {
    {
    	image = "/home/fried-milk/.face",
        resize = false,
	    clip_shape = gears.shape.circle,
        valign = "center",
        halign = "center",
	    forced_width = dpi(170),
	    forced_height = dpi(170),
	    widget = wibox.widget.imagebox	
    },
    widget = user_picture_container,
}
local username = os.getenv("USER")
local user_text = wibox.widget.textbox(username:upper())
user_text.font = "Charybdis 30"
user_text.align = "center"
user_text.valign = "center"

local host_text = wibox.widget.textbox()
awful.spawn.easy_async_with_shell("hostname", function(out)
    -- Remove trailing whitespaces
    out = out:gsub('^%s*(.-)%s*$', '%1')
    host_text.markup = helpers.colorize_text("@"..out, beautiful.c4)
end)
-- host_text.markup = "<span foreground='" .. x.color8 .."'>" .. minutes.text .. "</span>"
host_text.font = "VT323 20"
host_text.align = "center"
host_text.valign = "center"
local user_widget = wibox.widget {
    user_picture,
    helpers.vertical_pad(dpi(18)),
    user_text,
    helpers.vertical_pad(dpi(4)),
    host_text,
    layout = wibox.layout.fixed.vertical
}
local user_box = create_boxed_widget(user_widget, col1, dpi(360), beautiful.c3)

-- Power menu
local smol_botton = col1/3-1.75*box_gap
local function create_powerm_button(iconz, width, bg_color, hover_color, cmd_nr)
    local button_container = wibox.widget {
	bg = bg_color,
	forced_height = smol_botton,
   	forced_width = width,
	shape = helpers.rrect(box_radius),
	widget = wibox.container.background(),
    }

    local button = wibox.widget {
	{
        {
	        {
	    	    image = iconz,
	    	    --resize = false,
	        	valign = "center",
	        	halign = "center",
		        widget = wibox.widget.imagebox,
	        },
            halign = "center",
            valign = "center",
            widget = wibox.container.place,
        },
	    margins = dpi(1),
	    widget = wibox.container.margin,
	},	
	widget = button_container,
    }

    button:buttons(
        gears.table.join(
            awful.button({ }, 1, function ()
                if(cmd_nr == 1) then
		            awful.spawn.with_shell("poweroff")
		        elseif(cmd_nr == 2) then
		            awful.spawn.with_shell("reboot")
		        elseif(cmd_nr == 3) then
   		            awful.spawn.with_shell("env XSECURELOCK_SAVER=saver_xscreensaver XSECURRELOCK_PASSWORD_PROMPT=emoticon XSECURELOCK_SHOW_DATETIME=1 XSECURELOCK_SHOW__USERNAME=1 XSECURELOCK_BLANK_TIMEOUT=10 XSECURELOCK_AUTH_BACKGROUND_COLOR=#3d362d XSECURELOCK_AUTH_FOREGROUND_COLOR=#ffe5c2 XSECURELOCK_AUTH_WARNING_COLOR=#c83bba XSECURELOCK_FONT=VT323 xsecurelock") 
		        elseif (cmd_nr == 4) then
		            awesome.quit()
		        end
                    dashboard_hide()
            end)
    ))

    button:connect_signal("mouse::enter", function ()
        button_container.bg = hover_color
    end)
    button:connect_signal("mouse::leave", function ()
        button_container.bg = bg_color
    end)

    return button
end

-- Create the buttons
local shutdown = create_powerm_button("/home/fried-milk/.config/awesome/themes/my-first-rice-UWU/titlebar/close_dark.svg", smol_botton, beautiful.c2, beautiful.c1, 1)
local reboot   = create_powerm_button("/home/fried-milk/.config/awesome/themes/my-first-rice-UWU/titlebar/close_dark.svg", smol_botton, beautiful.c2, beautiful.c1, 2)
local lock     = create_powerm_button("/home/fried-milk/.config/awesome/themes/my-first-rice-UWU/titlebar/close_dark.svg", col1, beautiful.c2, beautiful.c1, 3)
local quit     = create_powerm_button("/home/fried-milk/.config/awesome/themes/my-first-rice-UWU/titlebar/close_dark.svg", smol_botton, beautiful.c2, beautiful.c1, 4)

-- Add clickable effects on hover
helpers.add_hover_cursor(shutdown, "hand1")
helpers.add_hover_cursor(reboot, "hand1")
helpers.add_hover_cursor(lock, "hand1")
helpers.add_hover_cursor(quit, "hand1")

local power_menu = wibox.widget {
    {
        shutdown,
        reboot,
        quit,
        forced_num_cols = 3,
        spacing = box_gap * 2.5,
        layout = wibox.layout.grid
    },
    {
        {
            lock,
            layout = wibox.layout.flex.horizontal,
        },
        top = box_gap * 2.5,
        widget = wibox.container.margin,
    },
    layout = wibox.layout.align.vertical
}

local power_menu_box = create_boxed_widget(power_menu, col1, dpi(200), "#00000000")

-- Weather widget with text icons
local weather_widget = require("weather-widget.weather-content")
local weather_widget_icon = weather_widget:get_all_children()[1]
weather_widget_icon.font = "icomoon 40"
weather_widget_icon.align = "center"
weather_widget_icon.valign = "center"
-- So that content does not get cropped
-- weather_widget_icon.forced_width = dpi(50)
local weather_widget_description = weather_widget:get_all_children()[2]
weather_widget_description.font = "VT323 30"
local weather_widget_temperature = weather_widget:get_all_children()[3]
weather_widget_temperature.font = "Charybdis 40"

local weather = wibox.widget{
    {
        nil,
        {
            weather_widget_icon,
            weather_widget_temperature,
            spacing = dpi(5),
            layout = wibox.layout.align.horizontal
        },
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    {
        nil,
        weather_widget_description,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical
}

local weather_box = create_boxed_widget(weather, col2, 560-col2-smol_botton-2.65*box_gap, beautiful.c3)
  
-- CPU widget
local cpu_widget = require("widgets.cpu-widget")
local cpu_widget_caption = cpu_widget:get_all_children()[1]
cpu_widget_caption.font = "VT323 25"
local cpu_widget_temp = cpu_widget:get_all_children()[2]
cpu_widget_temp.font = "VT323 20"
local cpu_widget_usage = cpu_widget:get_all_children()[3]
cpu_widget_usage.font = "VT323 20"

local cpu = wibox.widget{
    cpu_widget_caption,
    {
        cpu_widget_temp,
        cpu_widget_usage,
        layout = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.fixed.horizontal,
}

local cpu_box = create_boxed_widget(cpu, col2, col1/3-1.5*box_gap, beautiful.c3)

-- Disk Widget
local disk_arc = wibox.widget {
    start_angle = 3 * math.pi / 2,
    min_value = 0,
    max_value = 100,
    value = 50,
    border_width = 0,
    border_color = beautiful.border_color,
    thickness = dpi(25),
    forced_width = dpi(50),
    forced_height = dpi(50),
    rounded_edge = true,
    bg = beautiful.c3.."bf",
    colors = { beautiful.c4 },
    widget = wibox.container.arcchart
}

local disk_hover_text_value = wibox.widget {
    align = "center",
    valign = "center",
    font = "Charybdis 25",
    widget = wibox.widget.textbox()
}
local disk_hover_text = wibox.widget {
    disk_hover_text_value,
    {
        align = "center",
        valign = "center",
        font = "VT323 25",
        markup = helpers.colorize_text("free", beautiful.c3),
        widget = wibox.widget.textbox,
    },
    spacing = dpi(2),
    visible = false,
    layout = wibox.layout.fixed.vertical
}

awesome.connect_signal("evil::disk", function(used, total)
    disk_arc.value = -used * 100 / total
    disk_hover_text_value.markup = helpers.colorize_text(tostring(helpers.round(total - used, 1)).."G", beautiful.c3)
end)

local disk_icon = wibox. widget {
    align = "center",
    valign = "center",
    font = "icomoon 40",
    markup = helpers.colorize_text("", beautiful.c3),
    widget = wibox.widget.textbox()
}

local disk = wibox.widget {
    {
        {
            {
                nil,
                disk_hover_text,
                expand = "none",
                layout = wibox.layout.align.vertical
            },
            disk_icon,
            disk_arc,
            top_only = false,
            layout = wibox.layout.stack
        },
        margins = 20,
        widget = wibox.container.margin,
    },
    bg = beautiful.c2,
    shape = gears.shape.circle,
    border_width = beautiful.border_width,
    border_color = beautiful.border_color,
    forced_height = col2,
    forced_width = col2,
    widget = wibox.container.background
}

local disk_box = create_boxed_widget(disk, col2, col2, beautiful.c3.."00")

disk_box:connect_signal("mouse::enter", function ()
    disk_icon.visible = false
    disk_hover_text.visible = true
end)
disk_box:connect_signal("mouse::leave", function ()
    disk_icon.visible = true
    disk_hover_text.visible = false
end)

-- Shortcut list
-- Create list element
local function create_shortcut_li(cmd, appname, fg_color, hover_color, is_left, icon)
    local icon_size = dpi(35)

    local appnamew = wibox.widget.textbox()
    appnamew.font = "Charybdis 25"
    appnamew.markup = helpers.colorize_text(appname, fg_color)

    local iconw = wibox.widget.imagebox()
    iconw.image = icon
    iconw.resize = true
    iconw.forced_height = icon_size
    iconw.forced_width  = icon_size 

    local marginw = wibox.container.margin()
    marginw.forced_width = dpi(200)
    marginw.left = 10
    marginw.right = 10
    marginw.top = 5
    marginw.bottom = 5

    local li    
    if is_left then    
	li = wibox.widget {
        {
	        {
	    	    {
	    	    	halign = "left",
			        valign = "left",
		    	    widget = iconw,
	    	    },	
	    	    halign = "left",
		        widget = wibox.container.place,
	    	},
	    	{
	    	    align = "right",
		        widget = appnamew,
	        },	
	        layout = wibox.layout.align.horizontal
	    },
	    widget = marginw,
    }
    else
	li = wibox.widget {
	    {
 		    {
	    	    align = "left",	
	    	    widget = appnamew,
	    	},	
	    	{
	    	    {
	    	        halign = "right",
			        valign = "right",
		            widget = iconw,
	    	    },	
		        halign = "right",
	    	    widget = wibox.container.place,
	    	},
	        layout = wibox.layout.align.horizontal
    	},
	    widget = marginw,
	}
    end

    li:buttons(
        gears.table.join(
            awful.button({ }, 1, function ()
                awful.spawn.with_shell(cmd)
                dashboard_hide()
            end)
    ))

    li:connect_signal("mouse::enter", function ()
        appnamew.markup = helpers.colorize_text(appname, hover_color)
    end)
    li:connect_signal("mouse::leave", function ()
        appnamew.markup = helpers.colorize_text(appname, fg_color)
    end)

    return li
end

-- Creat shortcut elements
local firefox = create_shortcut_li("firefox", "FIREFOX", beautiful.c1, beautiful.c4, true, "/home/fried-milk/.config/neofetch/pixel-frog.png")
-- the command for tor is stupid
local tor     = create_shortcut_li("cd / &&  ./opt/tor-browser_en-US/Browser/start-tor-browser", "ONION", beautiful.c1, beautiful.c4, false, "/home/fried-milk/.config/neofetch/pixel-frog.png")
local spotify = create_shortcut_li("spotify", "SPOTIFY", beautiful.c1, beautiful.c4, true, "/home/fried-milk/.config/neofetch/pixel-frog.png")
local element = create_shortcut_li("element-desktop", "ELEMENT", beautiful.c1, beautiful.c4, false, "/home/fried-milk/.config/neofetch/pixel-frog.png")
local discord = create_shortcut_li("discord", "DISCORD", beautiful.c1, beautiful.c4, true, "/home/fried-milk/.config/neofetch/pixel-frog.png")
--TODO
local files = create_shortcut_li("discord", "DISCORD", beautiful.c1, beautiful.c4, false, "/home/fried-milk/.config/neofetch/pixel-frog.png")

-- Create shortcut list
local shortcut_list = wibox.widget{
    firefox,
    tor,
    spotify,
    element,
    discord, 
    files,
    layout = wibox.layout.fixed.vertical
} 

local shortcut_list_box = create_boxed_widget(shortcut_list, col3, 320-0.5*box_gap, beautiful.c3)

-- Clock
local textclock = wibox.widget.textclock()
textclock.format = '%H:%M:%S'
textclock.refresh = 100
textclock.font = 'Charybdis 29'
textclock.valign = 'center'
textclock.align = 'center'

local clock_arc = wibox.widget{
    start_angle = 1.5*math.pi,
    min_value = 0,
    max_value = 60,
    value = 30,
    border_width = 0,
    border_color = beautiful.border_color,
    thickness = dpi(25),
    forced_width = dpi(200),
    forced_height = dpi(200),
    rounded_edge = true,
    bg = beautiful.c3.."bf",
    colors = { beautiful.c4 },
    widget = wibox.container.arcchart
}

local clock = wibox.widget{
    {
        {
            textclock,
            clock_arc,  
            top_only = false,
            layout = wibox.layout.stack
        },    
        valign = "center",
        halign = "center",
        widget = wibox.container.place
    },
    bg = beautiful.c2,
    border_width = beautiful.border_width,
    border_color = beautiful.border_color,
    forced_height = col3,
    forced_width = col3,
    shape = gears.shape.circle,
    widget = wibox.container.background
}

local clock_timer
clock_timer = gears.timer {
    timeout = 1,
    autostart = false,
    call_now = false,
    single_shot = false,
    callback = function()
        textclock.markup = helpers.colorize_text(os.date('%H:%M:%S'), beautiful.c3)
        clock_arc.value = tonumber(os.date('%S'))
    end
}

local clock_box = create_boxed_widget(clock, col3, col3, "#00000000")

-- Uptime
local uptime_text = wibox.widget.textbox()
awful.widget.watch("uptime -p | sed 's/^...//'", 60, function(_, stdout)
    -- Remove trailing whitespaces
    local out = stdout:gsub('^%s*(.-)%s*$', '%1')
    uptime_text.markup = helpers.colorize_text(out, beautiful.c3)
end)
local uptime = wibox.widget {
    {
        align = "center",
        valign = "center",
        font = "VT323 40",
        forced_width = col4/2-70,
        markup = helpers.colorize_text("", beautiful.c4),
        widget = wibox.widget.textbox()
    },
    {
        align = "center",
        valign = "center",
        font = "VT323 25",
        wrap = "word",
        forced_width =col4/2,
        align = "right",
        widget = uptime_text
    },
    --spacing = dpi(10),
    layout = wibox.layout.fixed.horizontal
}

local uptime_box = create_boxed_widget(uptime, col4, 160-0.55*box_gap, beautiful.c2)

uptime_box:buttons(gears.table.join(
    awful.button({ }, 1, function ()
        exit_screen_show()
        gears.timer.delayed_call(function()
            dashboard_hide()
        end)
    end)
))
helpers.add_hover_cursor(uptime_box, "hand1")

-- Calendar
local calendar = require("calendar-widget.calendar")
-- Update calendar whenever dashboard is shown
dashboard:connect_signal("property::visible", function ()
    if dashboard.visible then
        calendar.date = os.date('*t')
    end
end)

local calendar_box = create_boxed_widget(calendar, col4, dpi(400), beautiful.c3)
-- local calendar_box = create_boxed_widget(calendar, 380, 540, x.color0)


-- Item placement
dashboard:setup {
    -- Center boxes vertically
    nil,
    {
        -- Center boxes horizontally
        nil,
        {
            -- Column container
            {
                -- Column 1
                user_box,
                power_menu_box,
                layout = wibox.layout.fixed.vertical
            },
            {
                -- Column 2
                weather_box,
                disk_box,
                cpu_box,
                layout = wibox.layout.fixed.vertical
            },
   	        {
                -- Column 3
                clock_box,
                shortcut_list_box,
                layout = wibox.layout.fixed.vertical
            },
	        {
		        -- Column 4
		        calendar_box,
		        uptime_box,
		        layout = wibox.layout.fixed.vertical
	        },
            layout = wibox.layout.fixed.horizontal
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.horizontal

    },  
    nil,
    expand = "none",
    layout = wibox.layout.align.vertical
}

local dashboard_grabber
function dashboard_hide()
    --textclock.refresh=600
    clock_timer:stop()
    awful.keygrabber.stop(dashboard_grabber)
    set_visibility(false)
end


local original_cursor = "left_ptr"
function dashboard_show()
    -- Fix cursor sometimes turning into "hand1" right after showing the dashboard
    -- Sigh... This fix does not always work
    local w = mouse.current_wibox
    if w then
        w.cursor = original_cursor
    end
    -- naughty.notify({text = "starting the keygrabber"})
    dashboard_grabber = awful.keygrabber.run(function(_, key, event)
        if event == "release" then return end
        -- Press Escape or q or F1 to hide it
        if key == 'Escape' or key == 'q' or key == 'F1' then
            dashboard_hide()
        end
    end)
    
    --textclock.refresh=1
    clock_timer:start()
    set_visibility(true)
end
