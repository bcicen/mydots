local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Set colors
local active_color = beautiful.temperature_bar_active_color or "#5AA3CC"
local background_color = beautiful.temperature_bar_background_color or "#222222"

local temperature_bar = wibox.widget{
  max_value     = 100,
  value         = 50,
  forced_height = dpi(10),
  margins       = {
    top = dpi(8),
    bottom = dpi(8),
  },
  forced_width  = dpi(180),
  shape         = gears.shape.rounded_bar,
  bar_shape     = gears.shape.rounded_bar,
  color         = active_color,
  background_color = background_color,
  border_width  = 0,
  border_color  = beautiful.border_color,
  widget        = wibox.widget.progressbar,
}


local temperature_bar_text = wibox.widget{
  forced_height = dpi(10),
  forced_width  = dpi(20),
  align = "left",
  valign = "center",
  font = "Product Sans 10",
  text = "0°C",
  -- markup = helpers.colorize_text(symbol, color),
  widget = wibox.widget.textbox()
}

awesome.connect_signal("evil::temperature", function(value)
    temperature_bar.value = value
    temperature_bar_text.text = tostring(value) .. "°C"
end)

return function() return temperature_bar, temperature_bar_text end
