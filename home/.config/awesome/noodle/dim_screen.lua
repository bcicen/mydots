local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
-- local naughty = require("naughty")

local helpers = require("helpers")
local pad = helpers.pad

-- Appearance
-- icomoon symbols
local icon_font = "icomoon bold 45"
local icon_font_big = "icomoon bold 145"
local moon_icon = ""
local light_icon = ""
local exit_icon = ""

local button_bg = beautiful.xcolor0
local button_size = dpi(120)

local mk_light_command = function(n)
  return function()
    print('light ' .. n)
  end
end

-- Commands
local dim_command = function()
    awful.spawn.with_shell("~/.config/awesome/bin/xbrightness.sh 0.2")
end
local undim_command = function()
    awful.spawn.with_shell("~/.config/awesome/bin/xbrightness.sh 1.0")
end

-- Helper function that generates the clickable buttons
local create_button = function(symbol, hover_color, text, command)
    local icon = wibox.widget {
        forced_height = button_size,
        forced_width = button_size,
        align = "center",
        valign = "center",
        font = icon_font,
        --text = symbol,
        markup = helpers.colorize_text(symbol, hover_color .. "AA"),
        widget = wibox.widget.textbox()
    }

    local button = wibox.widget {
        {
            nil,
            icon,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        forced_height = button_size,
        forced_width = button_size,
        border_width = dpi(8),
        border_color = button_bg,
        shape = helpers.rrect(dpi(20)),
        bg = button_bg,
        widget = wibox.container.background
    }

    -- Bind left click to run the command
    button:buttons(gears.table.join(
        awful.button({ }, 1, function ()
            command()
        end)
    ))

    -- Change color on hover
    button:connect_signal("mouse::enter", function ()
        icon.markup = helpers.colorize_text(icon.text, hover_color)
        button.border_color = hover_color
    end)
    button:connect_signal("mouse::leave", function ()
        icon.markup = helpers.colorize_text(icon.text, hover_color .. "AA")
        button.border_color = button_bg
    end)

    -- Use helper function to change the cursor on hover
    helpers.add_hover_cursor(button, "hand1")

    return button
end

-- Create the exit screen wibox
dim_screen = wibox({visible = false, ontop = true, type = "dock"})
awful.placement.maximize(dim_screen)

dim_screen.bg = beautiful.dim_screen_bg or beautiful.wibar_bg or "#111111"
dim_screen.fg = beautiful.dim_screen_fg or beautiful.wibar_fg or "#FEFEFE"

local dim_screen_grabber
function dim_screen_hide()
    awful.keygrabber.stop(dim_screen_grabber)
    dim_screen.visible = false
    sidebar.visible = true
    undim_command()
end
function dim_screen_show()
    dim_command()
    dim_screen_grabber = awful.keygrabber.run(function(_, key, event)
        -- Ignore case
        key = key:lower()

        if event == "release" then return end

        sidebar.visible = true
        dim_screen_hide()
    end)
    dim_screen.visible = true
end

-- buttons
local moon = wibox.widget {
    align = "center",
    valign = "center",
    font = icon_font_big,
    --text = moon_icon,
    markup = helpers.colorize_text(moon_icon, "#FFFFFF66"),
    widget = wibox.widget.textbox()
}

local light1 = create_button(light_icon, beautiful.xcolor1, "light1", mk_light_command(1))
local light2 = create_button(light_icon, beautiful.xcolor2, "light2", mk_light_command(2))
local light3 = create_button(light_icon, beautiful.xcolor3, "light3", mk_light_command(3))
local light4 = create_button(light_icon, beautiful.xcolor5, "light4", mk_light_command(4))
local exit = create_button(exit_icon, beautiful.xcolor4, "exit", dim_screen_hide)

-- Item placement
dim_screen:setup {
    {
      moon,
      left = dpi(20),
      right = dpi(20),
      top = dpi(200),
      widget = wibox.container.margin
    },
    {
        nil,
        {
            light1,
            light2,
            light3,
            light4,
            exit,
            spacing = dpi(50),
            layout = wibox.layout.fixed.horizontal
        },
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    expand = "none",
    layout = wibox.layout.align.vertical
}
