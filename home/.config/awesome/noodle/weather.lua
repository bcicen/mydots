local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")

local weather_temperature_symbol = "°C"
local weatherf_temperature_symbol = "°F"

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
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local weather_icon = wibox.widget{
    text = whatever_icon,
    --align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local weather_temperature = wibox.widget{
    text = "  ",
    align  = 'center',
    valign = 'bottom',
    widget = wibox.widget.textbox
}

local weather_temperaturef = wibox.widget{
    text = "  ",
    align  = 'right',
    valign = 'center',
    widget = wibox.widget.textbox
}

local weather = wibox.widget{
    nil,
    {
        weather_icon,
        {
          weather_temperature,
          weather_temperaturef,
          layout = wibox.layout.fixed.vertical
        },
        spacing = dpi(18),
        layout = wibox.layout.fixed.horizontal
    },
    weather_description,
    layout = wibox.layout.fixed.vertical
}

awesome.connect_signal("evil::weather", function(temperature, description, icon_code)
    local icon
    local color
    print(icon_code)
    -- Set icon and color depending on icon_code
    if icon_code == "clear-day" then
        icon = sun_icon
        color = beautiful.xcolor3
    elseif icon_code == "clear-night" then
        icon = moon_icon
        color = beautiful.xcolor4
    elseif icon_code == "partly-cloudy-day" then
        icon = dcloud_icon
        color = beautiful.xcolor3
    elseif icon_code == "partly-cloudy-night" then
        icon = ncloud_icon
        color = beautiful.xcolor4
    elseif icon_code == "cloudy" then
        icon = cloud_icon
        color = beautiful.xcolor1
    elseif icon_code == "rain" then
        icon = rain_icon
        color = beautiful.xcolor4
    elseif icon_code == "thunderstorm" or icon_code == "tornado" or icon_code == "hail" then
        icon = storm_icon
        color = beautiful.xcolor1
    elseif icon_code == "snow" then
        icon = snow_icon
        color = beautiful.xcolor6
    elseif icon_code == "fog" or icon_code == "wind" then
        icon = mist_icon
        color = beautiful.xcolor5
    else
        icon = whatever_icon
        color = beautiful.xcolor2
    end

    weather_icon.markup = helpers.colorize_text(icon, color)
    weather_description.markup = description
    weather_temperature.markup = tostring(temperature)..weather_temperature_symbol
    weather_temperaturef.markup = helpers.colorize_text(tostring((temperature*9) / 5 + 32)..weatherf_temperature_symbol, '#878996')

    --weather_temperature.markup = helpers.colorize_text(tostring(temperature)..weather_temperature_symbol, color)
end)

return weather
