local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")

local cpu_caption = wibox.widget{
    text = "CPU: ",
    valign = 'center',
    widget = wibox.widget.textbox,
}

local cpu_temp = wibox.widget{
    text = "???°C",
    valign = 'center',
    widget = wibox.widget.textbox,
}

local cpu_usage = wibox.widget{
    text = "???%",
    valign = 'center',
    widget = wibox.widget.textbox,
}

local cpu = wibox.widget{
    cpu_caption,
    cpu_temp,
    cpu_usage,
    --spacing = 8,
    layout = wibox.layout.fixed.horizontal,
}

awesome.connect_signal("daemon::cpu", function(temperature, usage)
    --local color 
    cpu_temp.markup = temperature
    cpu_usage.markup = usage
end)

return cpu
