local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")

--local weather_temperature_symbol
--if user.weather_units == "metric" then
    weather_temperature_symbol = "°C"
--elseif user.weather_units == "imperial" then
--    weather_temperature_symbol = "°F"
--end

-- Text icons
-- 'Typicons' font
-- local sun_icon = ""
-- local moon_icon = ""
-- local dcloud_icon = ""
-- local ncloud_icon = ""
-- local cloud_icon = ""
-- local rain_icon = ""
-- local storm_icon = ""
-- local snow_icon = ""
-- local mist_icon = ""
-- local whatever_icon = ""

-- 'Icomoon' font (filled variant)
local sun_icon = ""
local moon_icon = ""
local dcloud_icon = ""
local ncloud_icon = ""
local cloud_icon = ""
local rain_icon = ""
local storm_icon = ""
local snow_icon = ""
local mist_icon = ""
local whatever_icon = ""

local weather_description = wibox.widget{
    -- text = "Weather unavailable",
    text = "Loading weather...",
    -- align  = 'center',
    valign = 'center',
    -- font = "sans 14",
    widget = wibox.widget.textbox
}

local weather_icon = wibox.widget{
    text = whatever_icon,
    -- align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local weather_temperature = wibox.widget{
    text = "  ",
    -- align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local weather = wibox.widget{
    weather_icon,
    weather_description,
    weather_temperature,
    spacing = 8,
    layout = wibox.layout.fixed.horizontal
}

local weather_icons = {
    ["01d"] = { icon = sun_icon, color = beautiful.c1 },
    ["01n"] = { icon = moon_icon, color = beautiful.c1 },
    ["02d"] = { icon = dcloud_icon, color = beautiful.c2 },
    ["02n"] = { icon = ncloud_icon, color = beautiful.c2v2 },
    ["03d"] = { icon = cloud_icon, color = beautiful.c2 },
    ["03n"] = { icon = cloud_icon, color = beautiful.c2 },
    ["04d"] = { icon = cloud_icon, color = beautiful.c2 },
    ["04n"] = { icon = cloud_icon, color = beautiful.c2 },
    ["09d"] = { icon = rain_icon, color = beautiful.c2v2 },
    ["09n"] = { icon = rain_icon, color = beautiful.c2v2 },
    ["10d"] = { icon = rain_icon, color = beautiful.c2v2 },
    ["10n"] = { icon = rain_icon, color = beautiful.c2v2 },
    ["11d"] = { icon = storm_icon, color = beautiful.c4 },
    ["11n"] = { icon = storm_icon, color = beautiful.c4 },
    ["13d"] = { icon = snow_icon, color = beautiful.c1 },
    ["13n"] = { icon = snow_icon, color = beautiful.c1 },
    ["40d"] = { icon = mist_icon, color = beautiful.c4 },
    ["40n"] = { icon = mist_icon, color = beautiful.c4 },
    ["50d"] = { icon = mist_icon, color = beautiful.c4 },
    ["50n"] = { icon = mist_icon, color = beautiful.c4 },
    ["_"] = { icon = whatever_icon, color = beautiful.c1 },
}

awesome.connect_signal("evil::weather", function(temperature, description, icon_code)
    local icon
    local color
    if weather_icons[icon_code] then
        icon = weather_icons[icon_code].icon
        color = weather_icons[icon_code].color
    else
        icon = weather_icons['_'].icon
        color = weather_icons['_'].color
    end

    weather_icon.markup = helpers.colorize_text(icon, color)
    weather_description.markup = description
    --weather_temperature.markup = temperature
    weather_temperature.markup = helpers.colorize_text(" "..tostring(temperature)..weather_temperature_symbol, beautiful.c2)
end)

return weather
