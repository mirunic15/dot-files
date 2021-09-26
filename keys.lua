-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local wibox = require("wibox")
require("awful.hotkeys_popup.keys")
-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")
local helpers = require("helpers")
---------------------------------------------------------------------------------
local keys = {}

--Variables aa??
local is_muted = false

-- supers
super = "Mod4"
alt = "Mod1"
ctrl = "Control"
shift = "Shift"

-- {{{ Mouse bindings
keys.desktopbuttons = gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
   -- awful.button({ }, 4, awful.tag.viewnext),
   -- awful.button({ }, 5, awful.tag.viewprev)
)
-- }}}

-- {{{ Key bindings
keys.globalkeys = gears.table.join(
    awful.key({ super,           }, "d",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ super,           }, "q",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ super,           }, "w",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ super,           }, "Tab", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ alt,           }, "w",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ alt,     }, "q",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ super,           }, "e", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ alt, shift   }, "w", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ alt, shift   }, "q", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ alt, shift }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ alt, shift }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ alt,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ alt,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Resize focused client or layout factor
    awful.key({ super, ctrl }, "Down", function (c)
        helpers.resize_dwim(client.focus, "down")
    end),
    awful.key({ super, ctrl }, "Up", function (c)
        helpers.resize_dwim(client.focus, "up")
    end),
    awful.key({ super, ctrl }, "Left", function (c)
        helpers.resize_dwim(client.focus, "left")
    end),
    awful.key({ super, ctrl }, "Right", function (c)
        helpers.resize_dwim(client.focus, "right")
    end),
    awful.key({ super, ctrl }, "j", function (c)
        helpers.resize_dwim(client.focus, "down")
    end),
    awful.key({ super, ctrl }, "k", function (c)
        helpers.resize_dwim(client.focus, "up")
    end),
    awful.key({ super, ctrl }, "h", function (c)
        helpers.resize_dwim(client.focus, "left")
    end),
    awful.key({ super, ctrl }, "l", function (c)
        helpers.resize_dwim(client.focus, "right")
    end),

    -- Standard program
    awful.key({ super,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ super, ctrl }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ super, shift   }, "Escape", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ super,           }, "s",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ super,           }, "a",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ super, shift   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ super, shift   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ super, ctrl }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ super, ctrl }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ super,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ super, shift   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ super, ctrl }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ super },            "t",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "awesome"}),

    
    awful.key({ super },            "r",     function () awful.spawn.with_shell("rofi -modi 'drun,window,run' -show drun") end,
              {description = "run prompt", group = "awesome"}),

    awful.key({ super }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ super }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    --Brightness
    awful.key({}, "XF86MonBrightnessDown", 
	function() 
	    awful.spawn.with_shell("brightnessctl -d 'intel_backlight' set 3%-")
	    awesome.emit_signal("brightness_change") 
	end,
	{description = "sudo lower brighness", group = "screen light"}),

    awful.key({}, "XF86MonBrightnessUp", 
	function() 
	    awful.spawn.with_shell("brightnessctl -d 'intel_backlight' set 3%+")
            awesome.emit_signal("brightness_change") 
	end,
	{description = "sudo raise brightness", group = "screen light"}),

    -- Volume
    awful.key({}, "XF86AudioMute", 
         function()
	     if(not is_muted) then
                 awful.spawn.with_shell("amixer sset Master mute")
		 awful.spawn.with_shell("amixer sser Speaker mute")
		 is_muted = true
                 --awesome.emit_signal("volume_change")
                 awesome.emit_signal("volume_mute")
	     else
	         awful.spawn.with_shell("amixer sset Master unmute")
		 awful.spawn.with_shell("amixer sset Speaker unmute")
		 is_muted = false
		 --awesome.emit_signal("volume_change")
                 awesome.emit_signal("volume_mute")
	     end
	 end,
	{description = "(un)mute Master", group = "volume"}),

    awful.key({}, "XF86AudioLowerVolume",
	function() 
	    awful.spawn.with_shell("amixer sset Master 1%-") 
	    awesome.emit_signal("volume_change")	
	end,
	{description = "raise volume", group = "volume"}),

    awful.key({}, "XF86AudioRaiseVolume", 
	function() 
	    awful.spawn.with_shell("amixer sset Master 1%+") 
            awesome.emit_signal("volume_change")
	end,
	{description = "lower volume", group = "volume"}),

    --Misc
    awful.key({}, "Print", function() awful.spawn.with_shell("flameshot gui") end, 
	{description = "screenshot", group = "misc"}),

    --Lock Screen
    awful.key({ super, shift }, "Tab", 
	function() 
	    awful.spawn.with_shell("env XSECURELOCK_SAVER=saver_xscreensaver XSECURELOCK_PASSWORD_PROMPT=emoticon XSECURELOCK_SHOW_DATETIME=1 XSECURELOCK_SHOW_USERNAME=1 XSECURELOCK_BLANK_TIMEOUT=10 XSECURELOCK_AUTH_BACKGROUND_COLOR=#3d362d XSECURELOCK_AUTH_FOREGROUND_COLOR=#ffe5c2 XSECURELOCK_AUTH_WARNING_COLOR=#c83bba XSECURELOCK_FONT=VT323 xsecurelock") 
	end,
	{description = "enable lock screen", group = "awesome"}),

-- Dashboard
    awful.key({ super }, "z", function()
        if dashboard_show then
            dashboard_show()
        end
        -- rofi_show()
    end, {description = "dashboard", group = "custom"})
)

keys.clientkeys = gears.table.join(
-- Move to edge or swap by direction
    awful.key({ shift, ctrl }, "Down", function (c)
        helpers.move_client_dwim(c, "down")
    end),
    awful.key({ shift, ctrl }, "Up", function (c)
        helpers.move_client_dwim(c, "up")
    end),
    awful.key({ shift, ctrl }, "Left", function (c)
        helpers.move_client_dwim(c, "left")
    end),
    awful.key({ shift, ctrl }, "Right", function (c)
        helpers.move_client_dwim(c, "right")
    end),


    awful.key({ super,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ super, shift   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ super, ctrl }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ super, ctrl }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ super,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ super,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ super,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ super,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ super, ctrl }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ super, shift   }, "n",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    keys.globalkeys = gears.table.join(keys.globalkeys,
        -- View tag only.
        awful.key({ super }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ super, shift }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ alt, shift }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ super, ctrl, shift }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

keys.clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ super }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ super }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)
-- }}}

return keys

