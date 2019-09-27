-- Provides:
-- evil::weather
--      temperature (integer)
--      description (string)
--      icon_code (string)
local awful = require("awful")

-- Configuration
local key = user.forecastio_key
local latlon = user.forecastio_latlon
local units = user.weather_units
-- Don't update too often, because your requests might get blocked for 24 hours
local update_interval = 1200

local weather_details_script = [[
    bash -c '
    KEY="]]..key..[["
    LOC="]]..latlon..[["
    UNITS="]]..units..[["
  
    weather=$(cat /home/bradley/work/bcicen/notebooks/forecast/weather.json)
    #weather=$(curl -sf "https://api.darksky.net/forecast/$KEY/$LOC?units=$UNITS")
  
    if [ ! -z "$weather" ]; then
        weather_temp=$(echo "$weather" | jq -r ".currently.temperature" | cut -d "." -f1)
        weather_icon=$(echo "$weather" | jq -r ".currently.icon")
        weather_description=$(echo "$weather" | jq -r ".currently.summary")
  
        echo "$weather_icon"@"${weather_description,,}"@"$weather_temp"
    else
        echo "..."
    fi
  ']]

-- Periodically get weather info
awful.widget.watch(weather_details_script, update_interval, function(widget, stdout)
    local idx = 0
    local icon_code = "..."
    local description
    local temperature

    for token in string.gmatch(stdout, "([^@]+)") do
      if idx == 0 then
        icon_code = token
      elseif idx == 1 then
        description = token
      elseif idx == 2 then
        temperature = token
      end
      idx = idx + 1
    end

    if icon_code == "..." then
        awesome.emit_signal("evil::weather", 999, "Weather unavailable", "")
    else
        -- Replace "-0" with "0" degrees
        temperature = string.gsub(temperature, '%-0', '0')
        -- Capitalize first letter of the description
        --weather_details = weather_details:sub(1,1):upper()..weather_details:sub(2)
        awesome.emit_signal("evil::weather", tonumber(temperature), description, icon_code)
    end
end)
