--INIT
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")

-- SET THEME
--local themes_path = os.getenv("HOME") .. "/.config/awesome/themes"
--beautiful.init(themes_path .. "/my-first-rice-UWU/theme.lua")

-- VARIABLES
local sound_icon = beautiful.volume_icon
local mute_icon   = beautiful.mute_icon
local volume_percent = 0 --so that it doesn't init empty variable in case of error
local offsetx = 15
local offsety = 55
local is_muted = false

-- COMPONENTS AND FUNCTIONS
local volume_icon = wibox.widget {
    image = mute_icon,
    widget = wibox.widget.imagebox
}

local volume_bar = wibox.widget{
    widget = wibox.widget.progressbar,
    shape = helpers.rrect(dpi(50)),
    border_color = beautiful.border_color,
    border_width = beautiful.border_width,
    color = beautiful.c4,
    background_color = beautiful.c3,
    bar_shape = helpers.rrect(dpi(50)),
    max_value = 100,
    value = volume_percent,
    forced_height = 10, --DOESTN WORK AAA???
}

local volume_notif = wibox({
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

volume_notif : setup {
    {   
        {
    	    {
                {
            	    volume_icon,
                    forced_height = 10,
                    layout = wibox.layout.fixed.horizontal,
	        },
		left = 5,
		--margins = 3,
                widget = wibox.container.margin,
	    },
	    {
                {
		    volume_bar,
                    forced_height = 10,
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
	bg = beautiful.c2,
        shape = helpers.rrect(dpi(50)),
        shape_border_width = beautiful.border_width,
        shape_border_color = beautiful.border_color,
    	widget = wibox.container.background,
    },
    layout = wibox.layout.align.horizontal,
}


-- updates volume percentage and icon
local function set_volume_level()
    awful.spawn.easy_async_with_shell(
        "amixer get Master | awk '$0~/%/{print $4}' | tr -d '[]%'",
        function(stdout)
            volume_percent = tonumber(stdout)
            volume_bar.value = volume_percent
	    if (volume_percent == 0 or is_muted) then
	        volume_icon.image = mute_icon
	    else
	        volume_icon.image = sound_icon
	    end
	end,
	false
    )
end

-- create a X second timer to hide the volume adjust
-- component whenever the timer is started
local hide_volume_notif = gears.timer {
   timeout = 2.5,
   autostart = true,
   callback = function()
      volume_notif.visible = false
   end
}

-- show volume notif and hide it
local function volume_change() 
   -- set new volume value
        set_volume_level()     

        -- make volume_adjust component visible
        if volume_notif.visible then
            hide_volume_notif:again()
        else
            volume_notif.visible = true
            hide_volume_notif:start()
        end
end

-- show volume-notif when "volume_change" signal is emitted
awesome.connect_signal("volume_change", function() volume_change() end)

-- show notif and change to mute icon
awesome.connect_signal("volume_mute",
    function()
        is_muted = not is_muted
        volume_change()     
    end
)

-- notification version attempt, but i cant put a progressbar or any other widget in it
--[[ 
    naughty.destroy(notification)
    notification = naughty.notify {
	text = tostring(volume_percent),
	--title = "Volume",
	icon = volume_icon,
	icon_size = 30,
	timeout = 5,
	hover_timeout = 15,
	screen = mouse.screen,
	position = "bottom_left",
	ontop = true,
	height = 35,
	width = 100,
 	fg = beautiful.border_color,
	bg = beautiful.c2,
	border_width = beautiful.border_width,
	border_color = beautiful.border_color,
	--margin = 15,
	shape = helpers.rrect(beautiful.border_radius),
    }

]]
