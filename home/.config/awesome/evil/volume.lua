-- Provides:
-- evil::volume
--      volume percentage (integer)
--      muted (boolean)
-- evil::microphone
--      muted (boolean)
local awful = require("awful")

local function emit_volume_info()
    -- Get volume info
    awful.spawn.easy_async("pamixer --get-mute --get-volume",
        function(stdout)
            local idx = 0
            local volume = 0
            local muted = false

            for token in string.gmatch(stdout, "([^%s]+)") do
              if idx == 0 then
                if token == "true" then
                  muted = true
                end
              elseif idx == 1 then
                volume = token
              end
              idx = idx + 1
            end

            awesome.emit_signal("evil::volume", tonumber(volume), muted)
        end
    )
end

local function emit_microphone_info()
    -- Use tail to grab the last line of the output (which refers to the microphone)
    awful.spawn.easy_async_with_shell("pacmd list-sources | grep muted | tail -1 | awk '{print $2}'",
        function(stdout)
            -- Remove trailing whitespace
            muted = stdout:gsub('^%s*(.-)%s*$', '%1')
            if muted == "yes" then
                awesome.emit_signal("evil::microphone", true)
            else
                awesome.emit_signal("evil::microphone", false)
            end
        end
    )
end


-- Run once to initialize widgets
emit_volume_info()
emit_microphone_info()

-- Sleeps until pactl detects an event (volume up/down/toggle mute)
local volume_script = [[
    bash -c '
    pactl subscribe 2> /dev/null | grep --line-buffered "sink"
    ']]


-- Sleeps until pactl detects an event (microphone volume up / down / (un)mute)
local microphone_script = [[
  bash -c '
  pactl subscribe 2> /dev/null | grep --line-buffered "source"
  ']]

-- Kill old pactl subscribe processes
awful.spawn.easy_async_with_shell("ps x | grep \"pactl subscribe\" | grep -v grep | awk '{print $1}' | xargs kill", function ()
    -- Run emit_volume_info() with each line printed
    awful.spawn.with_line_callback(volume_script, {
        stdout = function(line)
            emit_volume_info()
        end
    })
    -- Run emit_microphone_info() with each line printed
    awful.spawn.with_line_callback(microphone_script, {
        stdout = function(line)
            emit_microphone_info()
        end
    })

end)


