local library = {
    flags = {},
    connections = {},
    open = true,
    notifications = {},
    current_element = nil,
    config_ignores = {},
    directory = "obelus_ui",
    keybinds = {},
    components = {},
    theme = {
        Accent = Color3.fromRGB(180,105,125),
        WindowOutline = Color3.fromRGB(39, 39, 47),
        WindowInline = Color3.fromRGB(23, 23, 30),
        WindowHolder = Color3.fromRGB(32, 32, 38),
        PageUnselected = Color3.fromRGB(32, 32, 38),
        PageSelected = Color3.fromRGB(55, 55, 64),
        SectionBg = Color3.fromRGB(27, 27, 34),
        SectionInnerBorder = Color3.fromRGB(50, 50, 58),
        SectionOuterBorder = Color3.fromRGB(19, 19, 27),
        WindowBorder = Color3.fromRGB(58, 58, 67),
        Text = Color3.fromRGB(245, 245, 245),
        RiskyText = Color3.fromRGB(245, 239, 120),
        ObjectBg = Color3.fromRGB(41, 41, 50),
        StrokeColor = Color3.fromRGB(50, 50, 58)
    },
    accent_instances = {},
    font = nil,
    services = {
        Players = game:GetService("Players"),
        UserInputService = game:GetService("UserInputService"),
        TweenService = game:GetService("TweenService"),
        HttpService = game:GetService("HttpService"),
        RunService = game:GetService("RunService"),
        CoreGui = game:GetService("CoreGui")
    },
    config = {},
    config_callbacks = {},
    current_element_open = nil
}

local total_flags = 0

function library:registerAccent(instance, property)
    if not instance then return end
    table.insert(self.accent_instances, {
        instance = instance,
        property = property or "BackgroundColor3"
    })
end

function library:updateAccent(color)
    self.theme.Accent = color
    for _, data in pairs(self.accent_instances) do
        if data.instance and data.instance.Parent then
            pcall(function()
                data.instance[data.property] = color
            end)
        end
    end
end

function library:applyTheme(instance, property)
    self:registerAccent(instance, property)
end

if not isfolder(library.directory) then
    makefolder(library.directory)
    makefolder(library.directory .. "/configs")
    makefolder(library.directory .. "/fonts")
end

if not isfile(library.directory .. "/fonts/ProggyTiny.ttf") then
    writefile(library.directory .. "/fonts/ProggyTiny.ttf", game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyTiny.ttf"))
end

local font_data = {
    name = "ProggyTiny",
    faces = {{
        name = "Regular",
        weight = 400,
        style = "normal",
        assetId = getcustomasset(library.directory .. "/fonts/ProggyTiny.ttf")
    }}
}

writefile(library.directory .. "/fonts/font_encode.json", library.services.HttpService:JSONEncode(font_data))
library.font = Font.new(getcustomasset(library.directory .. "/fonts/font_encode.json"), Enum.FontWeight.Regular)

function library.next_flag()
    total_flags = total_flags + 1
    return tostring(total_flags)
end

function library.rgb_to_hsv(rgb)
    local r, g, b = rgb.R, rgb.G, rgb.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v = 0, 0, max
    local delta = max - min
    if max ~= 0 then
        s = delta / max
    end
    if delta ~= 0 then
        if r == max then
            h = (g - b) / delta
        elseif g == max then
            h = 2 + (b - r) / delta
        else
            h = 4 + (r - g) / delta
        end
        h = h / 6
        if h < 0 then h = h + 1 end
    end
    return h, s, v
end

function library.hsv_to_rgb(h, s, v)
    if s == 0 then
        return Color3.new(v, v, v)
    end
    local h6 = h * 6
    local i = math.floor(h6)
    local f = h6 - i
    local p = v * (1 - s)
    local q = v * (1 - s * f)
    local t = v * (1 - s * (1 - f))
    if i == 0 then
        return Color3.new(v, t, p)
    elseif i == 1 then
        return Color3.new(q, v, p)
    elseif i == 2 then
        return Color3.new(p, v, t)
    elseif i == 3 then
        return Color3.new(p, q, v)
    elseif i == 4 then
        return Color3.new(t, p, v)
    else
        return Color3.new(v, p, q)
    end
end

function library.create(class, props)
    local obj = Instance.new(class)
    for prop, val in pairs(props or {}) do
        obj[prop] = val
    end
    return obj
end

function library.add_gradient(obj, rotation)
    local gradient = library.create("UIGradient", {
        Parent = obj,
        Rotation = rotation or 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,200))
        },
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0.3)
        }
    })
    return gradient
end

function library.outline(obj, color, thickness)
    local border = library.create("UIStroke", {
        Parent = obj,
        Color = color,
        Thickness = thickness or 1,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    return border
end

function library.connect(signal, cb)
    local conn = signal:Connect(cb)
    table.insert(library.connections, conn)
    return conn
end

function library.draggify(frame)
    local drag_data = { dragging = false, start_pos = nil, start_mouse = nil }
    
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag_data.dragging = true
            drag_data.start_mouse = Vector2.new(input.Position.X, input.Position.Y)
            drag_data.start_pos = frame.Position
        end
    end
    
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag_data.dragging = false
        end
    end
    
    frame.InputBegan:Connect(onInputBegan)
    frame.InputEnded:Connect(onInputEnded)
    
    library.connect(library.services.UserInputService.InputChanged, function(input)
        if drag_data.dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = Vector2.new(input.Position.X, input.Position.Y) - drag_data.start_mouse
                frame.Position = UDim2.new(0, drag_data.start_pos.X.Offset + delta.X, 0, drag_data.start_pos.Y.Offset + delta.Y)
            end
        end
    end)
end

local keys = {
    [Enum.KeyCode.LeftShift] = "LS",
    [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC",
    [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS",
    [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent",
    [Enum.KeyCode.LeftAlt] = "LA",
    [Enum.KeyCode.RightAlt] = "RA",
    [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.One] = "1",
    [Enum.KeyCode.Two] = "2",
    [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4",
    [Enum.KeyCode.Five] = "5",
    [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7",
    [Enum.KeyCode.Eight] = "8",
    [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.KeypadOne] = "Num1",
    [Enum.KeyCode.KeypadTwo] = "Num2",
    [Enum.KeyCode.KeypadThree] = "Num3",
    [Enum.KeyCode.KeypadFour] = "Num4",
    [Enum.KeyCode.KeypadFive] = "Num5",
    [Enum.KeyCode.KeypadSix] = "Num6",
    [Enum.KeyCode.KeypadSeven] = "Num7",
    [Enum.KeyCode.KeypadEight] = "Num8",
    [Enum.KeyCode.KeypadNine] = "Num9",
    [Enum.KeyCode.KeypadZero] = "Num0",
    [Enum.KeyCode.Minus] = "-",
    [Enum.KeyCode.Equals] = "=",
    [Enum.KeyCode.Tilde] = "~",
    [Enum.KeyCode.LeftBracket] = "[",
    [Enum.KeyCode.RightBracket] = "]",
    [Enum.KeyCode.Semicolon] = ",",
    [Enum.KeyCode.Quote] = "'",
    [Enum.KeyCode.BackSlash] = "\\",
    [Enum.KeyCode.Comma] = ",",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Slash] = "/",
    [Enum.KeyCode.Asterisk] = "*",
    [Enum.KeyCode.Plus] = "+",
    [Enum.KeyCode.Backquote] = "`",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
    [Enum.KeyCode.Escape] = "ESC",
    [Enum.KeyCode.Space] = "SPC",
}

function library:createColorPicker(options, parent)
    local cp_cfg = options or {}
    local cp_flag = cp_cfg.flag or library.next_flag()
    local cp_current = cp_cfg.color or Color3.fromRGB(255, 255, 255)
    local h, s, v = library.rgb_to_hsv(cp_current)
    local opened = false
    
    local cp_preview = library.create("TextButton", {
        Parent = parent,
        BackgroundColor3 = cp_current,
        Size = UDim2.new(0, 18, 0, 9),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    library.outline(cp_preview, Color3.new(0, 0, 0), 1)
    library.add_gradient(cp_preview, 90)
    
    local cp_outline = library.create("Frame", {
        Parent = library.gui,
        Visible = false,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 150, 0, 170),
        BackgroundColor3 = library.theme.SectionBg,
        BorderSizePixel = 1,
        BorderColor3 = library.theme.WindowBorder,
        ZIndex = 2000
    })
    library.outline(cp_outline, Color3.new(0, 0, 0), 2)
    
    local sat_val_bg = library.create("Frame", {
        Parent = cp_outline,
        Size = UDim2.new(0, 130, 0, 130),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = library.hsv_to_rgb(h, 1, 1),
        ZIndex = 2001
    })
    
    local w_grad = library.create("Frame", {
        Parent = sat_val_bg,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 2002
    })
    local g1 = library.create("UIGradient", { Parent = w_grad })
    g1.Color = ColorSequence.new(Color3.new(1, 1, 1))
    g1.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    
    local b_grad = library.create("Frame", {
        Parent = sat_val_bg,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 2003
    })
    local g2 = library.create("UIGradient", { Parent = b_grad })
    g2.Color = ColorSequence.new(Color3.new(0, 0, 0))
    g2.Rotation = 90
    g2.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    
    local cursor = library.create("Frame", {
        Parent = sat_val_bg,
        Size = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 2005,
        Position = UDim2.new(s, -2, 1 - v, -2)
    })
    library.outline(cursor, Color3.new(0, 0, 0), 1)
    
    local hue_bar = library.create("Frame", {
        Parent = cp_outline,
        Size = UDim2.new(0, 130, 0, 12),
        Position = UDim2.new(0, 10, 1, -22),
        ZIndex = 2001
    })
    
    local h_grad = library.create("UIGradient", { Parent = hue_bar })
    h_grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
    })
    
    local hue_cursor = library.create("Frame", {
        Parent = hue_bar,
        Size = UDim2.new(0, 3, 0, 14),
        Position = UDim2.new(h, -1, 0, -1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 2005,
        BorderSizePixel = 0
    })
    library.outline(hue_cursor, Color3.new(0, 0, 0), 1)
    
    local function update_cp()
        local color = library.hsv_to_rgb(h, s, v)
        cp_preview.BackgroundColor3 = color
        sat_val_bg.BackgroundColor3 = library.hsv_to_rgb(h, 1, 1)
        cursor.Position = UDim2.new(s, -2, 1 - v, -2)
        hue_cursor.Position = UDim2.new(h, -1, 0, -1)
        library.flags[cp_flag] = color
        if cp_cfg.callback then cp_cfg.callback(color, cp_cfg.alpha or 1) end
    end
    
    local function handle_input(input, frame, is_hue)
        local pos = input.Position
        local size = frame.AbsoluteSize
        local fpos = frame.AbsolutePosition
        local rel_x = math.clamp((pos.X - fpos.X) / size.X, 0, 1)
        local rel_y = math.clamp((pos.Y - fpos.Y) / size.Y, 0, 1)
        if is_hue then
            h = rel_x
        else
            s = rel_x
            v = 1 - rel_y
        end
        update_cp()
    end
    
    local dragging_sv = false
    local dragging_h = false
    
    sat_val_bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging_sv = true
            handle_input(i, sat_val_bg, false)
        end
    end)
    
    hue_bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging_h = true
            handle_input(i, hue_bar, true)
        end
    end)
    
    library.connect(library.services.UserInputService.InputChanged, function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            if dragging_sv then
                handle_input(i, sat_val_bg, false)
            elseif dragging_h then
                handle_input(i, hue_bar, true)
            end
        end
    end)
    
    library.connect(library.services.UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging_sv = false
            dragging_h = false
        end
    end)
    
    cp_preview.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if library.current_element_open and library.current_element_open ~= cp_outline then
                library.current_element_open.Visible = false
                library.current_element_open = nil
            end
            
            opened = not opened
            cp_outline.Visible = opened
            if opened then
                library.current_element_open = cp_outline
                local pos = cp_preview.AbsolutePosition
                local size = cp_outline.AbsoluteSize
                local viewport = library.services.UserInputService:GetMouseLocation()
                local x = math.clamp(pos.X - 155, 0, viewport.X - size.X)
                local y = math.clamp(pos.Y, 0, viewport.Y - size.Y)
                cp_outline.Position = UDim2.new(0, x, 0, y)
            else
                if library.current_element_open == cp_outline then
                    library.current_element_open = nil
                end
            end
        end
    end)
    
    update_cp()
    
    local picker = {
        set = function(c)
            cp_current = c
            h, s, v = library.rgb_to_hsv(c)
            update_cp()
        end,
        get = function()
            return cp_current
        end
    }
    
    if cp_flag then
        library.components[cp_flag] = picker
    end
    
    return picker
end

function library:createKeyBind(options, parent, section)
    local cfg = {
        flag = options.flag or tostring(total_flags + 1),
        callback = options.callback or function() end,
        key = options.key or Enum.KeyCode.None,
        mode = options.mode or "toggle",
        active = options.default or false,
        open = false,
        binding = nil,
        in_keybindlist = options.in_keybindlist or true,
        keybindlist_ref = options.keybindlist_ref or nil
    }
    total_flags = total_flags + 1
    
    local outline = library.create("TextButton", {
        Parent = parent,
        Text = "",
        AutoButtonColor = false,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        SelectionOrder = -1,
        Size = UDim2.new(0, 0, 0, 9),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    })
    
    local text_label = library.create("TextLabel", {
        Parent = outline,
        FontFace = library.font,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Text = "[ ... ]",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, -1),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        TextSize = 12,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    })
    
    local function updateText()
        local text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
        local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))
        text_label.Text = "[" .. string.lower(__text or "...") .. "]"
        if cfg.in_keybindlist and cfg.keybindlist_ref then
            cfg.keybindlist_ref:Refresh()
        end
    end
    
    function cfg:SetVisible(bool)
        cfg.open = bool
        if bool then
            if section and section.closeCurrentElement then
                section:closeCurrentElement()
            end
            library.current_element_open = cfg
            text_label.Text = "[ ... ]"
        end
    end
    
    function cfg:Set(value)
        if type(value) == "boolean" then
            cfg.active = value
            cfg.callback(value)
        elseif tostring(value):find("Enum") then
            cfg.key = value
            updateText()
            cfg.callback(cfg.active)
        elseif type(value) == "table" then
            if value.key then
                cfg.key = value.key
            end
            if value.mode then
                cfg.mode = value.mode
            end
            if value.active ~= nil then
                cfg.active = value.active
            end
            updateText()
            cfg.callback(cfg.active)
        end
    end
    
    function cfg:Get()
        return {
            active = cfg.active,
            mode = cfg.mode,
            key = cfg.key
        }
    end
    
    local function onKeyBindClick(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            cfg.open = not cfg.open
            if cfg.open then
                if section and section.closeCurrentElement then
                    section:closeCurrentElement()
                end
                library.current_element_open = cfg
                text_label.Text = "[ ... ]"
                cfg.binding = library.connect(library.services.UserInputService.InputBegan, function(keycode, game_event)
                    if not game_event then
                        cfg.key = keycode.KeyCode or keycode.UserInputType
                        updateText()
                        if cfg.binding then
                            cfg.binding:Disconnect()
                            cfg.binding = nil
                        end
                        cfg.open = false
                        cfg.callback(cfg.active)
                    end
                end)
            else
                if cfg.binding then
                    cfg.binding:Disconnect()
                    cfg.binding = nil
                end
            end
        end
    end
    
    outline.InputBegan:Connect(onKeyBindClick)
    
    library.connect(library.services.UserInputService.InputBegan, function(input, game_event)
        if not game_event and not cfg.open then
            if input.KeyCode == cfg.key or input.UserInputType == cfg.key then
                if cfg.mode == "toggle" then
                    cfg.active = not cfg.active
                    cfg.callback(cfg.active)
                elseif cfg.mode == "hold" then
                    cfg.active = true
                    cfg.callback(cfg.active)
                end
            end
        end
    end)
    
    library.connect(library.services.UserInputService.InputEnded, function(input, game_event)
        if not game_event and not cfg.open then
            if input.KeyCode == cfg.key or input.UserInputType == cfg.key then
                if cfg.mode == "hold" then
                    cfg.active = false
                    cfg.callback(cfg.active)
                end
            end
        end
    end)
    
    cfg:Set({key = cfg.key, mode = cfg.mode, active = cfg.active})
    
    if cfg.flag then
        library.components[cfg.flag] = cfg
    end
    
    return cfg
end

function library:createLabel(info, parent)
    local info = info or {}
    local label = {}
    
    local contentHolder = library.create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 14)
    })
    
    local labelTitle = library.create("TextLabel", {
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = contentHolder,
        Size = UDim2.new(1, -(info.Offset or 36), 1, 0),
        Position = UDim2.new(0, info.Offset or 36, 0, 0),
        FontFace = library.font,
        RichText = true,
        Text = info.Name or info.name or info.Text or info.text or "new label",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextStrokeTransparency = 0.5,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local rightComponents = library.create("Frame", {
        Parent = contentHolder,
        Position = UDim2.new(1, 0, 0, -1),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0
    })
    
    library.create("UIListLayout", {
        Parent = rightComponents,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    label.rightComponents = rightComponents
    label.contentHolder = contentHolder
    
    function label:Set(text)
        labelTitle.Text = text or "new label"
    end
    
    function label:ColorPicker(options)
        return library:createColorPicker(options, rightComponents)
    end
    
    function label:KeyBind(options)
        return library:createKeyBind(options, rightComponents)
    end
    
    function label:Remove()
        contentHolder:Destroy()
        label = nil
    end
    
    return label
end

function library:createToggle(info, parent)
    local info = info or {}
    local toggle = {
        state = (info.Default or info.default or info.Def or info.def or false),
        callback = (info.Callback or info.callback or function() end),
        flag = info.flag or library.next_flag()
    }
    
    local contentHolder = library.create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 14)
    })
    
    local toggleButton = library.create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = contentHolder,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    
    local toggleTitle = library.create("TextLabel", {
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = contentHolder,
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        FontFace = library.font,
        RichText = true,
        Text = info.Name or info.name or info.Text or info.text or "new toggle",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextStrokeTransparency = 0.5,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleFrame = library.create("Frame", {
        BackgroundColor3 = Color3.fromRGB(1, 1, 1),
        BorderSizePixel = 0,
        Parent = contentHolder,
        Position = UDim2.new(0, 16, 0, 2),
        Size = UDim2.new(0, 10, 0, 10)
    })
    library.outline(toggleFrame, library.theme.StrokeColor, 1)
    
    local toggleInlineGradient = library.create("Frame", {
        BackgroundColor3 = toggle.state and library.theme.Accent or Color3.fromRGB(63, 63, 63),
        BorderSizePixel = 0,
        Parent = toggleFrame,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2)
    })
    library:applyTheme(toggleInlineGradient, "BackgroundColor3")
    library.add_gradient(toggleInlineGradient, 90)
    
    local rightComponents = library.create("Frame", {
        Parent = contentHolder,
        Position = UDim2.new(1, 0, 0, -1),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0
    })
    
    library.create("UIListLayout", {
        Parent = rightComponents,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    toggle.rightComponents = rightComponents
    toggle.contentHolder = contentHolder
    
    local function onToggle(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggle.state = not toggle.state
            toggleInlineGradient.BackgroundColor3 = toggle.state and library.theme.Accent or Color3.fromRGB(63, 63, 63)
            toggle.callback(toggle.state)
        end
    end
    
    toggleButton.InputBegan:Connect(onToggle)
    
    function toggle:ColorPicker(options)
        return library:createColorPicker(options, rightComponents)
    end
    
    function toggle:KeyBind(options)
        return library:createKeyBind(options, rightComponents)
    end
    
    function toggle:Remove()
        contentHolder:Destroy()
        toggle = nil
    end
    
    function toggle:Get()
        return toggle.state
    end
    
    function toggle:Set(value)
        if typeof(value) == "boolean" then
            toggle.state = value
            toggleInlineGradient.BackgroundColor3 = toggle.state and library.theme.Accent or Color3.fromRGB(63, 63, 63)
            toggle.callback(value)
        end
    end
    
    if toggle.flag then
        library.components[toggle.flag] = toggle
    end
    
    return toggle
end

function library:createButton(info, parent)
    local info = info or {}
    local button = {
        callback = (info.Callback or info.callback or function() end)
    }
    
    local contentHolder = library.create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 20)
    })
    
    local buttonButton = library.create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = contentHolder,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    
    local buttonFrame = library.create("Frame", {
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BorderColor3 = Color3.fromRGB(1, 1, 1),
        BorderMode = Enum.BorderMode.Inset,
        BorderSizePixel = 1,
        Parent = contentHolder,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(1, -32, 1, 0)
    })
    library.outline(buttonFrame, library.theme.StrokeColor, 1)
    
    local buttonInline = library.create("Frame", {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Parent = buttonFrame,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2)
    })
    library.add_gradient(buttonInline, 90)
    
    local buttonTitle = library.create("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = contentHolder,
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        FontFace = library.font,
        RichText = true,
        Text = info.Name or info.name or info.Text or info.text or "new button",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextStrokeTransparency = 0.5,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    
    local function onButton(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            button.callback()
        end
    end
    
    buttonButton.InputBegan:Connect(onButton)
    
    function button:Remove()
        contentHolder:Destroy()
        button = nil
    end
    
    return button
end

function library:createSlider(info, parent)
    local info = info or {}
    local slider = {
        state = (info.Default or info.default or info.Def or info.def or 0),
        min = (info.Minimum or info.minimum or info.Min or info.min or 0),
        max = (info.Maximum or info.maximum or info.Max or info.max or 10),
        decimals = (1 / (info.Decimals or info.decimals or info.Tick or info.tick or 0.25)),
        suffix = (info.Suffix or info.suffix or info.Ending or info.ending or ""),
        callback = (info.Callback or info.callback or function() end),
        holding = false,
        flag = info.flag or library.next_flag()
    }
    
    local contentHolder = library.create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, (info.Name or info.name or info.Text or info.text) and 20 or 10)
    })
    
    local sliderButton = library.create("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = contentHolder,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    
    if (info.Name or info.name or info.Text or info.text) then
        local sliderTitle = library.create("TextLabel", {
            AnchorPoint = Vector2.new(0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = contentHolder,
            Size = UDim2.new(1, -16, 0, 14),
            Position = UDim2.new(0, 16, 0, 0),
            FontFace = library.font,
            RichText = true,
            Text = (info.Name or info.name or info.Text or info.text),
            TextColor3 = Color3.fromRGB(180, 180, 180),
            TextStrokeTransparency = 0.5,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end
    
    local sliderFrame = library.create("Frame", {
        BackgroundColor3 = Color3.fromRGB(1, 1, 1),
        BorderSizePixel = 0,
        Parent = contentHolder,
        Position = UDim2.new(0, 16, 0, (info.Name or info.name or info.Text or info.text) and 14 or 0),
        Size = UDim2.new(1, -32, 0, 6)
    })
    library.outline(sliderFrame, library.theme.StrokeColor, 1)
    
    local sliderInlineGradient = library.create("Frame", {
        BackgroundColor3 = Color3.fromRGB(63, 63, 63),
        BorderSizePixel = 0,
        Parent = sliderFrame,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2)
    })
    library.add_gradient(sliderInlineGradient, 90)
    
    local sliderSlideHolder = library.create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = sliderFrame,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2)
    })
    
    local sliderSlide = library.create("Frame", {
        BackgroundColor3 = library.theme.Accent,
        BorderSizePixel = 0,
        Parent = sliderSlideHolder,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0)
    })
    library:applyTheme(sliderSlide, "BackgroundColor3")
    library.add_gradient(sliderSlide, 90)
    
    local sliderValue = library.create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.25),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = sliderSlide,
        Size = UDim2.new(0, 10, 0, 14),
        Position = UDim2.new(1, 0, 0.5, 0),
        FontFace = library.font,
        RichText = true,
        Text = tostring(slider.state) .. tostring(slider.suffix),
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextStrokeTransparency = 0.5,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local uis = library.services.UserInputService
    
    local function onSliderDown(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            slider.holding = true
            slider:Refresh(input.Position)
        end
    end
    
    sliderButton.InputBegan:Connect(onSliderDown)
    
    library.connect(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            slider.holding = false
        end
    end)
    
    library.connect(uis.InputChanged, function(input)
        if slider.holding then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                slider:Refresh(input.Position)
            end
        end
    end)
    
    function slider:Remove()
        contentHolder:Destroy()
        slider = nil
    end
    
    function slider:Get()
        return slider.state
    end
    
    function slider:Set(value)
        slider.state = math.clamp(math.round(value * slider.decimals) / slider.decimals, slider.min, slider.max)
        sliderSlide.Size = UDim2.new(1 - ((slider.max - slider.state) / (slider.max - slider.min)), 0, 1, 0)
        sliderValue.Text = tostring(slider.state) .. tostring(slider.suffix)
        pcall(slider.callback, slider.state)
    end
    
    function slider:Refresh(position)
        if slider.holding then
            local mouseLocation = position or uis:GetMouseLocation()
            local percent = math.clamp((mouseLocation.X - sliderSlideHolder.AbsolutePosition.X) / sliderSlideHolder.AbsoluteSize.X, 0, 1)
            local value = slider.min + (slider.max - slider.min) * percent
            slider:Set(value)
        end
    end
    
    if slider.flag then
        library.components[slider.flag] = slider
    end
    
    slider:Set(slider.state)
    return slider
end

function library:createTextBox(info, parent)
    local info = info or {}
    local textbox = {
        text = info.Default or info.default or "",
        placeholder = info.Placeholder or info.placeholder or "type here...",
        flag = info.flag or library.next_flag(),
        callback = info.Callback or info.callback or function() end
    }
    
    local contentHolder = library.create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    local textboxTitle = library.create("TextLabel", {
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = contentHolder,
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 16, 0, 0),
        FontFace = library.font,
        RichText = true,
        Text = info.Name or info.name or info.Text or info.text or "textbox",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextStrokeTransparency = 0.5,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local textboxFrame = library.create("Frame", {
        BackgroundColor3 = Color3.fromRGB(1, 1, 1),
        BorderSizePixel = 0,
        Parent = contentHolder,
        Position = UDim2.new(0, 16, 0, 17.5),
        Size = UDim2.new(1, -32, 0, 24)
    })
    library.outline(textboxFrame, library.theme.StrokeColor, 1)
    
    local textboxInline = library.create("Frame", {
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BorderSizePixel = 0,
        Parent = textboxFrame,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2)
    })
    
    local textboxBg = library.create("Frame", {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Parent = textboxInline,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2)
    })
    library.add_gradient(textboxBg, 90)
    
    local textboxInput = library.create("TextBox", {
        Parent = textboxBg,
        FontFace = library.font,
        TextSize = 12,
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        Text = textbox.text,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        PlaceholderText = textbox.placeholder,
        PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
        ClearTextOnFocus = false
    })
    
    function textbox:Get()
        return textbox.text
    end
    
    function textbox:Set(value)
        textbox.text = value
        textboxInput.Text = value
        textbox.callback(value)
    end
    
    textboxInput:GetPropertyChangedSignal("Text"):Connect(function()
        textbox.text = textboxInput.Text
        textbox.callback(textbox.text)
    end)
    
    if textbox.flag then
        library.components[textbox.flag] = textbox
    end
    
    return textbox
end

function library:createDropdown(info, parent)
    local info = info or {}
    local dropdown = {
        items = info.Items or info.items or {"Option 1", "Option 2", "Option 3"},
        multi = info.Multi or info.multi or false,
        flag = info.flag or library.next_flag(),
        callback = info.Callback or info.callback or function() end,
        open = false,
        selected = {},
        option_instances = {}
    }
    dropdown.default = info.Default or info.default or (dropdown.multi and {dropdown.items}) or dropdown.items
    
    local contentHolder = library.create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 45)
    })
    
    local dropdownTitle = library.create("TextLabel", {
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = contentHolder,
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 16, 0, 0),
        FontFace = library.font,
        RichText = true,
        Text = info.Name or info.name or info.Text or info.text or "dropdown",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextStrokeTransparency = 0.5,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local dropdownButton = library.create("TextButton", {
        Parent = contentHolder,
        Position = UDim2.new(0, 16, 0, 16),
        Size = UDim2.new(1, -32, 0, 25),
        BackgroundColor3 = Color3.fromRGB(1, 1, 1),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    })
    library.outline(dropdownButton, library.theme.StrokeColor, 1)
    library.add_gradient(dropdownButton, 90)
    
    local dropdownInline = library.create("Frame", {
        Parent = dropdownButton,
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2)
    })
    
    local dropdownBg = library.create("Frame", {
        Parent = dropdownInline,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2)
    })
    library.add_gradient(dropdownBg, 90)
    
    local dropdownText = library.create("TextLabel", {
        Parent = dropdownBg,
        FontFace = library.font,
        TextSize = 12,
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        Text = "",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
    
    local dropdownArrow = library.create("ImageLabel", {
        Parent = dropdownBg,
        Image = "rbxassetid://116204929609664",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0, 8, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    local dropdownHolder = library.create("Frame", {
        Parent = library.gui,
        Visible = false,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 999
    })
    library.outline(dropdownHolder, library.theme.StrokeColor, 1)
    library.add_gradient(dropdownHolder, 90)
    
    local dropdownHolderInline = library.create("Frame", {
        Parent = dropdownHolder,
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0,
        ZIndex = 999
    })
    
    local dropdownHolderBg = library.create("Frame", {
        Parent = dropdownHolderInline,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0,
        ZIndex = 999
    })
    
    local dropdownScroll = library.create("ScrollingFrame", {
        Parent = dropdownHolderBg,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 1000,
        Active = true
    })
    
    local dropdownList = library.create("UIListLayout", {
        Parent = dropdownScroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    local dropdownPadding = library.create("UIPadding", {
        Parent = dropdownScroll,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4)
    })
    
    dropdownList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, dropdownList.AbsoluteContentSize.Y + 8)
    end)
    
    function dropdown:RenderOptions()
        for _, inst in pairs(dropdown.option_instances) do
            inst:Destroy()
        end
        dropdown.option_instances = {}
        
        for _, item in pairs(dropdown.items) do
            local option = library.create("TextButton", {
                Parent = dropdownScroll,
                FontFace = library.font,
                TextSize = 12,
                Text = item,
                TextColor3 = Color3.fromRGB(180, 180, 180),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                BorderSizePixel = 0,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 1001,
                TextTruncate = Enum.TextTruncate.AtEnd
            })
            
            option.MouseButton1Click:Connect(function()
                if dropdown.multi then
                    local found = false
                    for i, v in pairs(dropdown.selected) do
                        if v == item then
                            table.remove(dropdown.selected, i)
                            found = true
                            break
                        end
                    end
                    if not found then
                        table.insert(dropdown.selected, item)
                    end
                    dropdown:Set(dropdown.selected)
                else
                    dropdown:Set(item)
                    dropdown:SetVisible(false)
                end
            end)
            
            table.insert(dropdown.option_instances, option)
        end
        
        dropdown:UpdateDisplay()
    end
    
    function dropdown:UpdateDisplay()
        local text = ""
        if dropdown.multi then
            text = table.concat(dropdown.selected, ", ")
        else
            text = dropdown.selected[1] or ""
        end
        dropdownText.Text = text
        
        for _, inst in pairs(dropdown.option_instances) do
            local isSelected = false
            for _, v in pairs(dropdown.selected) do
                if v == inst.Text then
                    isSelected = true
                    break
                end
            end
            inst.TextColor3 = isSelected and (library.theme.Accent or Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(180, 180, 180)
        end
    end
    
    function dropdown:SetVisible(bool)
        dropdown.open = bool
        dropdownHolder.Visible = bool
        dropdownArrow.Rotation = bool and 180 or 0
        if bool then
            if library.current_element_open then
                library.current_element_open.Visible = false
                library.current_element_open = nil
            end
            library.current_element_open = dropdown
        end
    end
    
    function dropdown:Get()
        return dropdown.multi and dropdown.selected or (dropdown.selected[1] or nil)
    end
    
    function dropdown:Set(value)
        if type(value) == "table" then
            dropdown.selected = value
        else
            dropdown.selected = {value}
        end
        dropdown:UpdateDisplay()
        dropdown.callback(dropdown:Get())
    end
    
    function dropdown:RefreshItems(newItems)
        dropdown.items = newItems or {}
        dropdown:RenderOptions()
        dropdown:Set(dropdown.default)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdown.open = not dropdown.open
        dropdown:SetVisible(dropdown.open)
    end)
    
    local function updateDropdownPosition()
        local pos = dropdownButton.AbsolutePosition
        local size = dropdownButton.AbsoluteSize
        local inset = game:GetService("GuiService"):GetGuiInset()
        dropdownHolder.Position = UDim2.new(0, pos.X, 0, pos.Y + size.Y - inset.Y + 55)
        dropdownHolder.Size = UDim2.new(0, size.X, 0, math.min(120, dropdownList.AbsoluteContentSize.Y + 10))
    end
    
    dropdownButton:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateDropdownPosition)
    dropdownList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateDropdownPosition)
    
    dropdown:RenderOptions()
    dropdown:Set(dropdown.default)
    
    if dropdown.flag then
        library.components[dropdown.flag] = dropdown
    end
    
    return dropdown
end

function library:createList(info, parent)
    local info = info or {}
    local list = {
        items = info.Items or info.items or {"Item 1", "Item 2", "Item 3"},
        flag = info.flag or library.next_flag(),
        callback = info.Callback or info.callback or function() end,
        selected = nil,
        option_instances = {}
    }
    
    local contentHolder = library.create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
        Size = UDim2.new(1, 0, 0, info.Size or 120)
    })
    
    local listTitle = library.create("TextLabel", {
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = contentHolder,
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 16, 0, 0),
        FontFace = library.font,
        RichText = true,
        Text = info.Name or info.name or info.Text or info.text or "list",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextStrokeTransparency = 0.5,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local listFrame = library.create("Frame", {
        Parent = contentHolder,
        Position = UDim2.new(0, 16, 0, 16),
        Size = UDim2.new(1, -32, 1, -16),
        BackgroundColor3 = Color3.fromRGB(1, 1, 1),
        BorderSizePixel = 0
    })
    library.outline(listFrame, library.theme.StrokeColor, 1)
    library.add_gradient(listFrame, 90)
    
    local listInline = library.create("Frame", {
        Parent = listFrame,
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0
    })
    
    local listBg = library.create("Frame", {
        Parent = listInline,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BorderSizePixel = 0
    })
    
    local listScroll = library.create("ScrollingFrame", {
        Parent = listBg,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 10,
        Active = true
    })
    
    local listLayout = library.create("UIListLayout", {
        Parent = listScroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    local listPadding = library.create("UIPadding", {
        Parent = listScroll,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4)
    })
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
    end)
    
    function list:RenderItems()
        for _, inst in pairs(list.option_instances) do
            inst:Destroy()
        end
        list.option_instances = {}
        
        for _, item in pairs(list.items) do
            local option = library.create("TextButton", {
                Parent = listScroll,
                FontFace = library.font,
                TextSize = 12,
                Text = item,
                TextColor3 = Color3.fromRGB(180, 180, 180),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                BorderSizePixel = 0,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 11,
                TextTruncate = Enum.TextTruncate.AtEnd
            })
            
            option.MouseButton1Click:Connect(function()
                list:Set(item)
            end)
            
            table.insert(list.option_instances, option)
        end
        
        list:UpdateDisplay()
    end
    
    function list:UpdateDisplay()
        for _, inst in pairs(list.option_instances) do
            inst.TextColor3 = (inst.Text == list.selected) and (library.theme.Accent or Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(180, 180, 180)
        end
    end
    
    function list:Get()
        return list.selected
    end
    
    function list:Set(value)
        list.selected = value
        list:UpdateDisplay()
        list.callback(value)
    end
    
    function list:AddItem(item)
        table.insert(list.items, item)
        list:RenderItems()
    end
    
    function list:RemoveItem(item)
        for i, v in pairs(list.items) do
            if v == item then
                table.remove(list.items, i)
                break
            end
        end
        if list.selected == item then
            list:Set(nil)
        end
        list:RenderItems()
    end
    
    function list:RefreshItems(newItems)
        list.items = newItems or {}
        list:RenderItems()
        if not table.find(list.items, list.selected) then
            list:Set(nil)
        end
    end
    
    list:RenderItems()
    
    if info.Default or info.default then
        list:Set(info.Default or info.default)
    end
    
    if list.flag then
        library.components[list.flag] = list
    end
    
    return list
end

function library:createMultiSection(page, section_cfg)
    local multi = {
        sections = {},
        parent = page,
        holder = nil,
        content = nil,
        total_sections = 0
    }
    
    local section_name = section_cfg.name or "Multi Section"
    local side = section_cfg.side == "right" and page.right or page.left
    local section_names = section_cfg.sections or {"Page 1", "Page 2", "Page 3"}
    local section_height = section_cfg.size or section_cfg.height or 400
    local fill_mode = section_cfg.Fill or section_cfg.fill or false
    
    local section_bg = library.create("Frame", {
        Parent = side,
        Size = UDim2.new(1, 0, 0, section_height),
        BackgroundColor3 = library.theme.SectionBg,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    library.add_gradient(section_bg, 90)
    library.outline(section_bg, library.theme.StrokeColor, 1.5)
    
    local inner_border = library.create("Frame", {
        Parent = section_bg,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.SectionInnerBorder,
        BorderSizePixel = 0
    })
    
    local outer_border = library.create("Frame", {
        Parent = inner_border,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.SectionOuterBorder,
        BorderSizePixel = 0
    })
    
    local title_bg = library.create("Frame", {
        Parent = section_bg,
        Size = UDim2.new(0, #section_name * 7 + 10, 0, 6),
        Position = UDim2.new(0, 12, 0, -4),
        BackgroundColor3 = library.theme.WindowHolder,
        BorderSizePixel = 0
    })
    library.outline(title_bg, library.theme.StrokeColor, 1)
    
    library.create("TextLabel", {
        Parent = section_bg,
        Text = section_name,
        FontFace = library.font,
        TextSize = 12,
        TextColor3 = library.theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, -5),
        Size = UDim2.new(0, #section_name * 7, 0, 14)
    })
    
    local button_holder = library.create("Frame", {
        Parent = outer_border,
        Size = UDim2.new(1, -4, 0, 22),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = library.theme.SectionBg,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    local button_scroll = library.create("ScrollingFrame", {
        Parent = button_holder,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    local button_layout = library.create("UIListLayout", {
        Parent = button_scroll,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local multiContentHolder = library.create("Frame", {
        Parent = outer_border,
        Size = UDim2.new(1, -8, 1, -32),
        Position = UDim2.new(0, 4, 0, 28),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })
    
    local content_scroll = library.create("ScrollingFrame", {
        Parent = multiContentHolder,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    library.create("UIPadding", {
        Parent = content_scroll,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4)
    })
    
    multi.holder = section_bg
    multi.content = content_scroll
    multi.button_holder = button_scroll
    multi.button_layout = button_layout
    
    local section_objects = {}
    local count = #section_names
    
    for i, name in ipairs(section_names) do
        local width = 1 / count
        local btn = library.create("TextButton", {
            Parent = button_scroll,
            Text = name,
            FontFace = library.font,
            TextSize = 11,
            TextColor3 = library.theme.Text,
            BackgroundColor3 = library.theme.PageUnselected,
            Size = UDim2.new(width, -(i < count and 2 or 0), 1, -2),
            Position = UDim2.new(0, 0, 0, 1),
            BorderSizePixel = 0,
            AutoButtonColor = false
        })
        library.add_gradient(btn, 90)
        library.outline(btn, library.theme.StrokeColor, 1)
        
        local btn_accent = library.create("Frame", {
            Parent = btn,
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = library.theme.Accent,
            Visible = false,
            BorderSizePixel = 0
        })
        library:applyTheme(btn_accent, "BackgroundColor3")
        
        local content = library.create("Frame", {
            Parent = content_scroll,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        local content_layout = library.create("UIListLayout", {
            Parent = content,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })
        
        content_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if fill_mode then
                local total_height = content_layout.AbsoluteContentSize.Y + 12
                content.Size = UDim2.new(1, 0, 0, total_height)
                content_scroll.CanvasSize = UDim2.new(0, 0, 0, total_height + 8)
            end
        end)
        
        task.wait(0.05)
        if fill_mode then
            local total_height = content_layout.AbsoluteContentSize.Y + 12
            content.Size = UDim2.new(1, 0, 0, total_height)
            content_scroll.CanvasSize = UDim2.new(0, 0, 0, total_height + 8)
        else
            content.Size = UDim2.new(1, 0, 0, 0)
            content_scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        end
        
        local section_obj = {
            holder = content,
            name = name,
            button = btn,
            accent = btn_accent,
            layout = content_layout,
            elements = {},
            parent_multi = multi,
            colorpicker_connections = {},
            fill_mode = fill_mode
        }
        
        function section_obj:closeCurrentElement()
            if library.current_element_open then
                library.current_element_open.Visible = false
                library.current_element_open = nil
            end
        end
        
        function section_obj:updateContentSize()
            if self.fill_mode then
                local total_height = self.layout.AbsoluteContentSize.Y + 12
                self.holder.Size = UDim2.new(1, 0, 0, total_height)
                content_scroll.CanvasSize = UDim2.new(0, 0, 0, total_height + 8)
            end
        end
        
        function section_obj:Label(info) return library:createLabel(info, content) end
        function section_obj:Toggle(info) return library:createToggle(info, content) end
        function section_obj:Button(info) return library:createButton(info, content) end
        function section_obj:Slider(info) return library:createSlider(info, content) end
        function section_obj:TextBox(info) return library:createTextBox(info, content) end
        function section_obj:Dropdown(info) return library:createDropdown(info, content) end
        function section_obj:List(info) return library:createList(info, content) end
        
        table.insert(multi.sections, section_obj)
        multi.total_sections = #multi.sections
        
        if i == 1 then
            btn.BackgroundColor3 = library.theme.PageSelected
            btn_accent.Visible = true
            content.Visible = true
        end
        
        btn.MouseButton1Click:Connect(function()
            for _, sec in pairs(multi.sections) do
                sec.button.BackgroundColor3 = library.theme.PageUnselected
                sec.accent.Visible = false
                sec.holder.Visible = false
            end
            btn.BackgroundColor3 = library.theme.PageSelected
            btn_accent.Visible = true
            content.Visible = true
        end)
        
        btn.TouchTap:Connect(function()
            for _, sec in pairs(multi.sections) do
                sec.button.BackgroundColor3 = library.theme.PageUnselected
                sec.accent.Visible = false
                sec.holder.Visible = false
            end
            btn.BackgroundColor3 = library.theme.PageSelected
            btn_accent.Visible = true
            content.Visible = true
        end)
    end
    
    function multi:updateSize()
        local total_height = 0
        for _, section in pairs(multi.sections) do
            local height = 0
            for _, child in pairs(section.holder:GetChildren()) do
                if child:IsA("Frame") then
                    height = height + child.AbsoluteSize.Y + 6
                end
            end
            if height > 0 then
                total_height = math.max(total_height, height + 20)
            end
        end
        if total_height > 0 then
            multi.holder.Size = UDim2.new(1, 0, 0, total_height + 50)
        end
    end
    
    return multi
end

function library:window(cfg)
    local window = {
        pages = {},
        page_buttons = {},
        page_accents = {},
        gui = nil,
        holder = nil,
        elements = {},
        section_content_holder = nil,
        current_section = nil,
        colorpicker_connections = {}
    }
    
    local size_x = cfg.size and cfg.size.X or 550
    local size_y = cfg.size and cfg.size.Y or 450
    
    window.gui = library.create("ScreenGui", { Parent = library.services.CoreGui, Name = "ObelusUI" })
    library.gui = window.gui
    
    local camera = workspace.CurrentCamera
    local viewport = camera.ViewportSize
    local start_x = (viewport.X - size_x) / 2
    local start_y = (viewport.Y - size_y) / 2
    
    local window_outline = library.create("Frame", {
        Parent = window.gui,
        Size = UDim2.new(0, size_x, 0, size_y),
        Position = UDim2.new(0, start_x, 0, start_y),
        BackgroundColor3 = library.theme.WindowOutline,
        BorderSizePixel = 0
    })
    library.outline(window_outline, Color3.new(0,0,0), 1)
    
    library.draggify(window_outline)
    window.holder = window_outline
    
    local window_inline = library.create("Frame", {
        Parent = window_outline,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = library.theme.WindowInline,
        BorderSizePixel = 0
    })
    library.add_gradient(window_inline, 90)
    
    local window_accent = library.create("Frame", {
        Parent = window_inline,
        Size = UDim2.new(1, -2, 0, 2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.Accent,
        BorderSizePixel = 0
    })
    library:applyTheme(window_accent, "BackgroundColor3")
    library.outline(window_accent, Color3.new(0,0,0))
    
    local window_holder = library.create("Frame", {
        Parent = window_inline,
        Size = UDim2.new(1, -30, 1, -35),
        Position = UDim2.new(0, 15, 0, 15),
        BackgroundColor3 = library.theme.WindowHolder,
        BorderSizePixel = 0
    })
    library.add_gradient(window_holder, 90)
    
    local pages_holder = library.create("Frame", {
        Parent = window_holder,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = library.theme.WindowHolder,
        BorderSizePixel = 0
    })
    
    local content_holder = library.create("Frame", {
        Parent = window_holder,
        Size = UDim2.new(1, -40, 1, -35),
        Position = UDim2.new(0, 20, 0, 40),
        BackgroundTransparency = 1
    })
    
    function window:new_page(page_cfg)
        local page = {
            sections = {},
            button = nil,
            accent = nil,
            content = nil,
            left = nil,
            right = nil,
            left_scroll = nil,
            right_scroll = nil,
            elements = {},
            section_content_holder = nil
        }
        
        local page_name = page_cfg.name or "Page"
        
        local page_button = library.create("TextButton", {
            Parent = pages_holder,
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = library.theme.PageUnselected,
            BorderSizePixel = 0
        })
        library.add_gradient(page_button, 90)
        
        local button_inline = library.create("Frame", {
            Parent = page_button,
            Size = UDim2.new(1, -2, 1, -2),
            Position = UDim2.new(0, 1, 0, 1),
            BackgroundColor3 = library.theme.PageUnselected,
            BorderSizePixel = 0
        })
        library.add_gradient(button_inline, 90)
        
        local button_text = library.create("TextLabel", {
            Parent = button_inline,
            Text = page_name,
            FontFace = library.font,
            TextSize = 12,
            TextColor3 = library.theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0)
        })
        
        local button_accent = library.create("Frame", {
            Parent = page_button,
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = library.theme.Accent,
            Visible = false,
            BorderSizePixel = 0
        })
        library:applyTheme(button_accent, "BackgroundColor3")
        library.add_gradient(button_accent, 90)
        
        page.button = page_button
        page.accent = button_accent
        
        local page_content = library.create("Frame", {
            Parent = content_holder,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false
        })
        
        local left_scroll = library.create("ScrollingFrame", {
            Parent = page_content,
            Size = UDim2.new(0.5, -10, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0,0,0,0),
            BorderSizePixel = 0
        })
        
        local left_padding = library.create("UIPadding", {
            Parent = left_scroll,
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4)
        })
        
        local left = library.create("Frame", {
            Parent = left_scroll,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        local right_scroll = library.create("ScrollingFrame", {
            Parent = page_content,
            Size = UDim2.new(0.5, -10, 1, 0),
            Position = UDim2.new(0.5, 10, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0,0,0,0),
            BorderSizePixel = 0
        })
        
        local right_padding = library.create("UIPadding", {
            Parent = right_scroll,
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4)
        })
        
        local right = library.create("Frame", {
            Parent = right_scroll,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        local left_layout = library.create("UIListLayout", {
            Parent = left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        
        local right_layout = library.create("UIListLayout", {
            Parent = right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        
        left_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            left_scroll.CanvasSize = UDim2.new(0, 0, 0, left_layout.AbsoluteContentSize.Y + 30)
        end)
        
        right_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            right_scroll.CanvasSize = UDim2.new(0, 0, 0, right_layout.AbsoluteContentSize.Y + 30)
        end)
        
        page.content = page_content
        page.left = left
        page.right = right
        page.left_scroll = left_scroll
        page.right_scroll = right_scroll
        
        table.insert(window.pages, page_content)
        table.insert(window.page_buttons, page_button)
        table.insert(window.page_accents, button_accent)
        
        page_button.MouseButton1Click:Connect(function()
            for i, btn in pairs(window.page_buttons) do
                btn.BackgroundColor3 = library.theme.PageUnselected
                local inline = btn:FindFirstChildWhichIsA("Frame")
                if inline then inline.BackgroundColor3 = library.theme.PageUnselected end
            end
            for i, acc in pairs(window.page_accents) do acc.Visible = false end
            for i, cont in pairs(window.pages) do cont.Visible = false end
            page_button.BackgroundColor3 = library.theme.PageSelected
            button_inline.BackgroundColor3 = library.theme.PageSelected
            button_accent.Visible = true
            page_content.Visible = true
        end)
        
        page_button.TouchTap:Connect(function()
            for i, btn in pairs(window.page_buttons) do
                btn.BackgroundColor3 = library.theme.PageUnselected
                local inline = btn:FindFirstChildWhichIsA("Frame")
                if inline then inline.BackgroundColor3 = library.theme.PageUnselected end
            end
            for i, acc in pairs(window.page_accents) do acc.Visible = false end
            for i, cont in pairs(window.pages) do cont.Visible = false end
            page_button.BackgroundColor3 = library.theme.PageSelected
            button_inline.BackgroundColor3 = library.theme.PageSelected
            button_accent.Visible = true
            page_content.Visible = true
        end)
        
        for i, btn in pairs(window.page_buttons) do
            local width = 1 / #window.page_buttons
            btn.Size = UDim2.new(width, i == 1 and 1 or i == #window.page_buttons and -2 or -1, 1, 0)
            btn.Position = UDim2.new(width * (i - 1), i == 1 and 0 or 2, 0, 0)
        end
        
        if #window.pages == 1 then
            page_button.BackgroundColor3 = library.theme.PageSelected
            button_inline.BackgroundColor3 = library.theme.PageSelected
            button_accent.Visible = true
            page_content.Visible = true
        end
        
        function page:new_section(section_cfg)
            local section = { 
                holder = nil, 
                content = nil, 
                elements = {},
                side = section_cfg.side == "right" and "right" or "left",
                sectionContentHolder = nil,
                colorpicker_connections = {}
            }
            local section_name = section_cfg.name or "Section"
            local side = section.side == "right" and right or left
            
            local section_bg = library.create("Frame", {
                Parent = side,
                Size = UDim2.new(1, 0, 0, section_cfg.size or 180),
                BackgroundColor3 = library.theme.SectionBg,
                BorderSizePixel = 0
            })
            library.add_gradient(section_bg, 90)
            library.outline(section_bg, library.theme.StrokeColor, 1.5)
            
            local inner_border = library.create("Frame", {
                Parent = section_bg,
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = library.theme.SectionInnerBorder,
                BorderSizePixel = 0
            })
            
            local outer_border = library.create("Frame", {
                Parent = inner_border,
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = library.theme.SectionOuterBorder,
                BorderSizePixel = 0
            })
            
            local title_bg = library.create("Frame", {
                Parent = section_bg,
                Size = UDim2.new(0, #section_name * 7 + 10, 0, 6),
                Position = UDim2.new(0, 12, 0, -4),
                BackgroundColor3 = library.theme.WindowHolder,
                BorderSizePixel = 0
            })
            library.outline(title_bg, library.theme.StrokeColor, 1)
            
            local title_text = library.create("TextLabel", {
                Parent = section_bg,
                Text = section_name,
                FontFace = library.font,
                TextSize = 12,
                TextColor3 = library.theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, -5),
                Size = UDim2.new(0, #section_name * 7, 0, 14)
            })
            
            local sectionContentHolder = library.create("Frame", {
                Parent = outer_border,
                Size = UDim2.new(1, -32, 1, -20),
                Position = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1
            })
            
            local content_layout = library.create("UIListLayout", {
                Parent = sectionContentHolder,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            section.holder = section_bg
            section.content = sectionContentHolder
            section.sectionContentHolder = sectionContentHolder
            
            local function update_section_height()
                local total_height = 0
                for _, child in pairs(sectionContentHolder:GetChildren()) do
                    if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                        total_height = total_height + child.AbsoluteSize.Y + 8
                    end
                end
                if total_height > 0 then
                    section_bg.Size = UDim2.new(1, 0, 0, total_height + 35)
                end
            end
            
            content_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_section_height)
            task.wait(0.1)
            update_section_height()
            
            function section:Update()
                update_section_height()
            end
            
            function section:closeCurrentElement()
                if library.current_element_open then
                    library.current_element_open.Visible = false
                    library.current_element_open = nil
                end
            end
            
            function section:Label(info) return library:createLabel(info, sectionContentHolder) end
            function section:Toggle(info) return library:createToggle(info, sectionContentHolder) end
            function section:Button(info) return library:createButton(info, sectionContentHolder) end
            function section:Slider(info) return library:createSlider(info, sectionContentHolder) end
            function section:TextBox(info) return library:createTextBox(info, sectionContentHolder) end
            function section:Dropdown(info) return library:createDropdown(info, sectionContentHolder) end
            function section:List(info) return library:createList(info, sectionContentHolder) end
            
            return section
        end
        
        function page:multisection(section_cfg)
            return library:createMultiSection(page, section_cfg)
        end
        
        return page
    end
    
    return window
end

function library:watermark(cfg)
    local watermark = {
        gui = nil,
        outline = nil,
        inner = nil,
        accent = nil,
        text_label = nil,
        connections = {},
        visible = true,
        show_fps = cfg.show_fps or false,
        show_ping = cfg.show_ping or false,
        fps_update_rate = cfg.fps_update_rate or 0.5
    }
    
    local text = cfg.text or "Obelus UI"
    local font_size = cfg.font_size or 12
    local initial_position = cfg.position or Vector2.new(50, 50)
    
    watermark.gui = library.create("ScreenGui", { 
        Parent = library.services.CoreGui, 
        Name = "ObelusWatermark",
        IgnoreGuiInset = true
    })
    
    local function getPing()
        return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    end
    
    local function updateText()
        local final_text = text
        if watermark.show_fps and watermark.current_fps then
            final_text = final_text .. " | " .. watermark.current_fps .. " fps"
        end
        if watermark.show_ping and watermark.current_ping then
            final_text = final_text .. " | " .. watermark.current_ping .. " ms"
        end
        watermark.text_label.Text = final_text
    end
    
    watermark.outline = library.create("Frame", {
        Parent = watermark.gui,
        Size = UDim2.new(0, 150, 0, 28),
        Position = UDim2.new(0, initial_position.X, 0, initial_position.Y),
        BackgroundColor3 = library.theme.WindowOutline,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true
    })
    library.outline(watermark.outline, Color3.new(0, 0, 0), 1)
    
    watermark.inner = library.create("Frame", {
        Parent = watermark.outline,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = library.theme.WindowInline,
        BorderSizePixel = 0
    })
    library.add_gradient(watermark.inner, 90)
    
    watermark.accent = library.create("Frame", {
        Parent = watermark.inner,
        Size = UDim2.new(1, -2, 0, 2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.Accent,
        BorderSizePixel = 0
    })
    library:applyTheme(watermark.accent, "BackgroundColor3")
    library.outline(watermark.accent, Color3.new(0, 0, 0))
    
    watermark.text_label = library.create("TextLabel", {
        Parent = watermark.inner,
        BackgroundTransparency = 1,
        FontFace = library.font,
        TextSize = font_size,
        TextColor3 = library.theme.Text,
        Text = text,
        Size = UDim2.new(1, -8, 1, -4),
        Position = UDim2.new(0, 4, 0, 3),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    local function updateSize()
        watermark.outline.Size = UDim2.new(0, watermark.text_label.TextBounds.X + 25, 0, 28)
    end
    
    if watermark.show_fps or watermark.show_ping then
        local frame_count = 0
        local last_update = tick()
        
        local update_conn = library.services.RunService.RenderStepped:Connect(function(dt)
            frame_count = frame_count + 1
            local now = tick()
            if now - last_update >= watermark.fps_update_rate then
                if watermark.show_fps then
                    watermark.current_fps = math.round(frame_count / (now - last_update))
                end
                if watermark.show_ping then
                    watermark.current_ping = getPing()
                end
                updateText()
                updateSize()
                frame_count = 0
                last_update = now
            end
        end)
        table.insert(watermark.connections, update_conn)
    end
    
    function watermark:SetText(newText)
        text = newText or "Obelus UI"
        updateText()
        updateSize()
    end
    
    function watermark:SetVisible(bool)
        watermark.visible = bool
        watermark.outline.Visible = bool
    end
    
    function watermark:Toggle()
        watermark:SetVisible(not watermark.visible)
    end
    
    function watermark:GetPosition()
        local pos = watermark.outline.Position
        return Vector2.new(pos.X.Offset, pos.Y.Offset)
    end
    
    function watermark:SetPosition(pos)
        local viewport = workspace.CurrentCamera.ViewportSize
        local size = watermark.outline.AbsoluteSize
        local x = math.clamp(pos.X, 0, viewport.X - size.X)
        local y = math.clamp(pos.Y, 0, viewport.Y - size.Y)
        watermark.outline.Position = UDim2.new(0, x, 0, y)
    end
    
    function watermark:Destroy()
        for _, conn in pairs(watermark.connections) do
            conn:Disconnect()
        end
        if watermark.gui then
            watermark.gui:Destroy()
        end
    end
    
    updateSize()
    return watermark
end

function library:keybindlist(cfg)
    local list = {
        gui = nil,
        outline = nil,
        inner = nil,
        accent = nil,
        title_label = nil,
        items = {},
        connections = {},
        visible = true
    }
    
    local title = cfg.title or "Keybinds"
    local font_size = cfg.font_size or 10
    local initial_position = cfg.position or Vector2.new(50, 50)
    local height = cfg.height or 150
    
    list.gui = library.create("ScreenGui", { 
        Parent = library.services.CoreGui, 
        Name = "ObelusKeybindList",
        IgnoreGuiInset = true
    })
    
    list.outline = library.create("Frame", {
        Parent = list.gui,
        Size = UDim2.new(0, 200, 0, height),
        Position = UDim2.new(0, initial_position.X, 0, initial_position.Y),
        BackgroundColor3 = library.theme.WindowOutline,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true
    })
    library.outline(list.outline, Color3.new(0, 0, 0), 1)
    
    list.inner = library.create("Frame", {
        Parent = list.outline,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = library.theme.WindowInline,
        BorderSizePixel = 0
    })
    library.add_gradient(list.inner, 90)
    
    list.accent = library.create("Frame", {
        Parent = list.inner,
        Size = UDim2.new(1, -2, 0, 2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.Accent,
        BorderSizePixel = 0
    })
    library:applyTheme(list.accent, "BackgroundColor3")
    library.outline(list.accent, Color3.new(0, 0, 0))
    
    list.title_label = library.create("TextLabel", {
        Parent = list.inner,
        BackgroundTransparency = 1,
        FontFace = library.font,
        TextSize = font_size,
        TextColor3 = library.theme.Text,
        Text = title,
        Size = UDim2.new(1, -8, 0, 16),
        Position = UDim2.new(0, 4, 0, 4),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    local scroll = library.create("ScrollingFrame", {
        Parent = list.inner,
        Size = UDim2.new(1, -8, 1, -24),
        Position = UDim2.new(0, 4, 0, 22),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    local scroll_layout = library.create("UIListLayout", {
        Parent = scroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })
    
    scroll_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, scroll_layout.AbsoluteContentSize.Y + 8)
    end)
    
    function list:Add(key, text)
        local entry = {
            key = key,
            text = text or "Keybind"
        }
        
        local item = library.create("Frame", {
            Parent = scroll,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1
        })
        
        local name_label = library.create("TextLabel", {
            Parent = item,
            BackgroundTransparency = 1,
            FontFace = library.font,
            TextSize = font_size - 1,
            TextColor3 = library.theme.Text,
            Text = entry.text,
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })
        
        local key_label = library.create("TextLabel", {
            Parent = item,
            BackgroundTransparency = 1,
            FontFace = library.font,
            TextSize = font_size - 1,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            Text = keys[key] or tostring(key):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", ""),
            Size = UDim2.new(0.4, 0, 1, 0),
            Position = UDim2.new(0.6, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Center
        })
        
        entry.item = item
        entry.name_label = name_label
        entry.key_label = key_label
        
        table.insert(list.items, entry)
        
        return {
            SetKey = function(new_key)
                entry.key = new_key
                list:Refresh()
            end,
            SetText = function(new_text)
                entry.text = new_text
                entry.name_label.Text = new_text
            end
        }
    end
    
    function list:Refresh()
        for _, entry in pairs(list.items) do
            entry.key_label.Text = keys[entry.key] or tostring(entry.key):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
        end
    end
    
    function list:SetVisible(bool)
        list.visible = bool
        list.outline.Visible = bool
    end
    
    function list:Toggle()
        list:SetVisible(not list.visible)
    end
    
    function list:Destroy()
        for _, conn in pairs(list.connections) do
            conn:Disconnect()
        end
        if list.gui then
            list.gui:Destroy()
        end
    end
    
    return list
end

function library:configuration()
    local config = {}
    
    function config:Save(name)
        if not name then return false, "no config name provided" end
        if not isfolder(library.directory .. "/configs") then
            makefolder(library.directory .. "/configs")
        end
        
        local data = {}
        for flag, component in pairs(library.components) do
            if component and component.Get then
                local value = component:Get()
                if type(value) == "table" and value.Color3 ~= nil then
                    local color = value.Color3
                    data[flag] = {
                        r = color.R,
                        g = color.G,
                        b = color.B,
                        a = value.Alpha or 1
                    }
                else
                    data[flag] = value
                end
            end
        end
        
        local json = library.services.HttpService:JSONEncode(data)
        writefile(library.directory .. "/configs/" .. name .. ".json", json)
        return true
    end
    
    function config:Load(name)
        if not name then return false, "no config name provided" end
        local path = library.directory .. "/configs/" .. name .. ".json"
        if not isfile(path) then return false, "config not found" end
        
        local data = library.services.HttpService:JSONDecode(readfile(path))
        for flag, value in pairs(data) do
            local component = library.components[flag]
            if component and component.Set then
                if type(value) == "table" and value.r ~= nil then
                    local color = Color3.new(value.r, value.g, value.b)
                    component:Set(color)
                else
                    component:Set(value)
                end
            end
        end
        return true
    end
    
    function config:Delete(name)
        if not name then return false, "no config name provided" end
        local path = library.directory .. "/configs/" .. name .. ".json"
        if not isfile(path) then return false, "config not found" end
        delfile(path)
        return true
    end
    
    function config:List()
        local list = {}
        if not isfolder(library.directory .. "/configs") then
            makefolder(library.directory .. "/configs")
            return list
        end
        for _, file in pairs(listfiles(library.directory .. "/configs")) do
            local name = file:match("([^/]+)%.json$")
            if name then table.insert(list, name) end
        end
        return list
    end
    
    return config
end

function library.unload()
    for _, conn in pairs(library.connections) do
        conn:Disconnect()
    end
    if library.gui then
        library.gui:Destroy()
    end
    library.flags = {}
    library.connections = {}
    library.keybinds = {}
    library.components = {}
end

return library