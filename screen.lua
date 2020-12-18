--[[
    Criação da wibar
]]


local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local layout_margin = 3

-- Widget de relógio
local text_clock = wibox.widget.textclock("%R")

local clock_icon = wibox.widget{
    markup = "<span color='#cf6dd6'>  </span>",
    font = "Ionicons 11",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local clock = wibox.container.margin(wibox.widget({
    clock_icon, 
    text_clock,
    layout = wibox.layout.fixed.horizontal,
}),10, 10)

-- Widget de Bat

local bat_text =  wibox.widget.textbox("12%")

local bat_icon = wibox.widget{
    markup = "<span color='#7dafff'>  </span>",
    font = "Ionicons 11",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local bat = wibox.container.margin(wibox.widget(
    {
        bat_icon,
        bat_text,
        layout = wibox.layout.fixed.horizontal,
    }
),10, 10)

awesome.connect_signal("widgets::battery", function(vol, charging)
    if charging then
        bat_text.text = "A/C"
        bat_icon.markup = "<span color='#7dafff'>  </span>"
    else 
        bat_text.text = vol .. "%"
        if vol > 20 then
            bat_icon.markup = "<span color='#7dafff'>  </span>"
        else 
            bat_icon.markup = "<span color='#7dafff'>  </span>"
        end
    end
end)

-- Widget de CPU

local cpu_text =  wibox.widget.textbox("12%")

local cpu_icon = wibox.widget{
    markup = '<span color="#6dd676">  </span>',
    font = "Ionicons 11",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local cpu = wibox.container.margin(wibox.widget({
    cpu_icon,
    cpu_text,
    layout = wibox.layout.fixed.horizontal,
}),10, 10)

-- Sinal do uso de cpu usado 
awesome.connect_signal("widgets::cpu", function(usage)
    cpu_text.text = tostring( usage ) .. "%"
end)

-- Função para criação do wallpaper para uma tela
local function set_wallpaper(s)
    local wallpaper = beautiful.wallpaper
    if wallpaper then 
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, false)
    end
end

function round_this_shit(widget, color) 
    local shape = function(cr,w,h)
        gears.shape.rounded_rect(cr,w,h,10)
    end
    return wibox.container.margin(wibox.container.background(widget, color, shape),0,10,5,0)
end

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then c.minimized = true else
            c:emit_signal(
                "request::activate",
                "tasklist",
                {raise = true}
            )
        end
    end),
    awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () wful.client.focus.byidx(-1) end))

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    -- Tags para cada workspace
    awful.tag({ "1", "2", "3", "4", "5"}, s, awful.layout.layouts[1])

    -- Prompt para chamar os aplicativos
    s.mypromptbox = awful.widget.prompt()

    -- Inicio da wibar
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 30 })

    s.mytasklist = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = tasklist_buttons,
        style    = {
            bg_normal = "#111",
            bg_focus = "#111",
            bg_minimize = "#111",
            shape  = function(cr,w,h)
                wibox.container.margin(
                gears.shape.rounded_rect(cr,w,h,10),10,10,10,10)
            end,
        },
        layout   = {
            spacing = 10,
            spacing_widget = {
                forced_width = 5,
                valign = 'center',
                halign = 'center',
                widget = wibox.container.place,
            },
            layout  = wibox.layout.flex.horizontal
        },
        -- Notice that there is *NO* wibox.wibox prefix, it is a template,
        -- not a widget instance.
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        right = 5,
                        left = 3,
                        widget  = wibox.container.margin,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                margins = 5,
                widget = wibox.container.margin
            },
            id     = 'background_role',
            bg = "#F00",
            widget = wibox.container.background,
        }
    }


    -- Setup da wibar
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            layout = wibox.layout.fixed.horizontal,
            s.mypromptbox,
        },
        {
            s.mytasklist,
            top = 5,
            widget = wibox.container.margin
        },
        { 
            layout = wibox.layout.fixed.horizontal,
            round_this_shit(bat,"#111"),
            round_this_shit(cpu,"#111"),
            round_this_shit(clock,"#111")
        },
    }

end)