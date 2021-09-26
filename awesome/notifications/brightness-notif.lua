--INIT
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")

-- SET THEME
local themes_path = os.getenv("HOME") .. "/.config/awesome/themes"
beautiful.init(themes_path .. "/my-first-rice-UWU/theme.lua")

-- VARIABLES
local light_img = themes_path .. "/my-first-rice-UWU/titlebar/close_dark.svg"
local light_val = 0 --so that it doesn't init empty variable in case of error
local offsetx = 15
local offsety = 55

-- COMPONENTS AND FUNCTIONS
local light_icon = wibox.widget {
    image = light_img,
    widget = wibox.widget.imagebox
}

local light_bar = wibox.widget{
    widget = wibox.widget.progressbar,
    shape = helpers.rrect(dpi(50)),
    border_color = beautiful.border_color,
    border_width = beautiful.border_width,
    color = beautiful.c4,
    background_color = beautiful.c3,
    bar_shape = helpers.rrect(dpi(50)),
    max_value = 6818,
    value = light_val,
    forced_height = 10, --DOESTN WORK AAA???
}

local light_notif = wibox({
    screen = awful.screen.focused(),
    x = offsetx,
    y = awful.screen.focused().geometry.height - offsety,
    bg = "#ffffff00",
    width = 300,
    height = 40,
    shape = helpers.rrect(dpi(50)),
    visible = false,
    ontop = true,
})

light_notif : setup {
    {   
        {
    	    {
                {
            	    light_icon,
                    layout = wibox.layout.fixed.horizontal,
	        },
		left = 5,
                widget = wibox.container.margin,
	    },
	    {
                {
		    light_bar,
                    layout = wibox.layout.fixed.horizontal,
	        },
		top = 10,
  		bottom = 10,
	        left = 5,
                right = 13,
                widget = wibox.container.margin,
	    },
	    layout = wibox.layout.fixed.horizontal,
	},
	bg = beautiful.c1,
        shape = helpers.rrect(dpi(50)),
        shape_border_width = beautiful.border_width,
        shape_border_color = beautiful.border_color,
    	widget = wibox.container.background,
    },
    layout = wibox.layout.align.horizontal,
}


-- updates brightness bar percentage
local function set_light_level()
    awful.spawn.easy_async_with_shell(
        "brightnessctl g",
        function(stdout)
            light_val = tonumber(stdout)
            light_bar.value = light_val
	end,
	false
    )
end

-- create a X second timer to hide the notification
-- component whenever the timer is started
local hide_light_notif = gears.timer {
   timeout = 2.5,
   autostart = true,
   callback = function()
      light_notif.visible = false
   end
}

-- show notif and hide it
local function light_change() 
   -- set new volume value
        set_light_level()     

        -- make volume_adjust component visible
        if light_notif.visible then
            hide_light_notif:again()
        else
            light_notif.visible = true
            hide_light_notif:start()
        end
end

-- show light-notif when "brightness_change" signal is emitted
awesome.connect_signal("brightness_change", function() light_change() end)
