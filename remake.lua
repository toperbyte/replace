local library = {
    flags = {},
    connections = {},
    open = true,
    notifications = {},
    current_element = nil,
    config_ignores = {},
    directory = "obelus_ui",
    keybinds = {},
    watermark_gui = nil,
    theme = {
        Accent = Color3.fromRGB(180, 95, 125),
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
        ObjectBg = Color3.fromRGB(41, 41, 50)
    },
    font = nil,
    services = {
        Players = game:GetService("Players"),
        UserInputService = game:GetService("UserInputService"),
        TweenService = game:GetService("TweenService"),
        HttpService = game:GetService("HttpService"),
        RunService = game:GetService("RunService"),
        CoreGui = game:GetService("CoreGui")
    }
}

local total_flags = 0
local cp_count = 0

local key_names = {
    [Enum.KeyCode.LeftControl] = "LCtrl", [Enum.KeyCode.RightControl] = "RCtrl",
    [Enum.KeyCode.LeftShift] = "LShift", [Enum.KeyCode.RightShift] = "RShift",
    [Enum.KeyCode.LeftAlt] = "LAlt", [Enum.KeyCode.RightAlt] = "RAlt",
    [Enum.KeyCode.CapsLock] = "Caps", [Enum.KeyCode.Tab] = "Tab",
    [Enum.KeyCode.Space] = "Space", [Enum.KeyCode.Return] = "Enter",
    [Enum.KeyCode.Backspace] = "Bksp", [Enum.KeyCode.Delete] = "Del",
    [Enum.KeyCode.Insert] = "Ins", [Enum.KeyCode.Home] = "Home",
    [Enum.KeyCode.End] = "End", [Enum.KeyCode.PageUp] = "PgUp",
    [Enum.KeyCode.PageDown] = "PgDn", [Enum.KeyCode.Up] = "Up",
    [Enum.KeyCode.Down] = "Dn", [Enum.KeyCode.Left] = "Lt",
    [Enum.KeyCode.Right] = "Rt", [Enum.KeyCode.One] = "1",
    [Enum.KeyCode.Two] = "2", [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5",
    [Enum.KeyCode.Six] = "6", [Enum.KeyCode.Seven] = "7",
    [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0", [Enum.KeyCode.A] = "A",
    [Enum.KeyCode.B] = "B", [Enum.KeyCode.C] = "C",
    [Enum.KeyCode.D] = "D", [Enum.KeyCode.E] = "E",
    [Enum.KeyCode.F] = "F", [Enum.KeyCode.G] = "G",
    [Enum.KeyCode.H] = "H", [Enum.KeyCode.I] = "I",
    [Enum.KeyCode.J] = "J", [Enum.KeyCode.K] = "K",
    [Enum.KeyCode.L] = "L", [Enum.KeyCode.M] = "M",
    [Enum.KeyCode.N] = "N", [Enum.KeyCode.O] = "O",
    [Enum.KeyCode.P] = "P", [Enum.KeyCode.Q] = "Q",
    [Enum.KeyCode.R] = "R", [Enum.KeyCode.S] = "S",
    [Enum.KeyCode.T] = "T", [Enum.KeyCode.U] = "U",
    [Enum.KeyCode.V] = "V", [Enum.KeyCode.W] = "W",
    [Enum.KeyCode.X] = "X", [Enum.KeyCode.Y] = "Y",
    [Enum.KeyCode.Z] = "Z"
}

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

function library.round(num, decimal)
    local mult = 10 ^ (decimal or 1)
    return math.floor(num * mult + 0.5) / mult
end

function library.create(class, props)
    local obj = Instance.new(class)
    for prop, val in pairs(props or {}) do
        obj[prop] = val
    end
    return obj
end

function library.outline(obj, color, thickness)
    local border = library.create("UIStroke", {
        Parent = obj,
        Color = color,
        Thickness = thickness or 1
    })
    return border
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

function library.connect(signal, cb)
    local conn = signal:Connect(cb)
    table.insert(library.connections, conn)
    return conn
end

function library.unload()
    for _, conn in pairs(library.connections) do
        conn:Disconnect()
    end
    if library.gui then
        library.gui:Destroy()
    end
    if library.watermark_gui then
        library.watermark_gui:Destroy()
    end
    library.flags = {}
    library.connections = {}
    library.keybinds = {}
end

function library.draggify(frame)
    local drag_data = { dragging = false, start_pos = nil, start_mouse = nil }
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag_data.dragging = true
            drag_data.start_mouse = Vector2.new(input.Position.X, input.Position.Y)
            drag_data.start_pos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag_data.dragging = false
        end
    end)
    library.connect(library.services.UserInputService.InputChanged, function(input)
        if drag_data.dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = Vector2.new(input.Position.X, input.Position.Y) - drag_data.start_mouse
                frame.Position = UDim2.new(0, drag_data.start_pos.X.Offset + delta.X, 0, drag_data.start_pos.Y.Offset + delta.Y)
            end
        end
    end)
end

function library.hsv_to_rgb(h, s, v)
    return Color3.fromHSV(h, s, v)
end

function library.rgb_to_hsv(color)
    return color:ToHSV()
end

function library.color_to_hex(color)
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    return string.format("#%02x%02x%02x", r, g, b)
end

function library.watermark(cfg)
    if library.watermark_gui then library.watermark_gui:Destroy() end
    
    local watermark_gui = library.create("ScreenGui", { Parent = library.services.CoreGui, Name = "Watermark" })
    library.watermark_gui = watermark_gui
    
    local frame = library.create("Frame", {
        Parent = watermark_gui,
        Size = UDim2.new(0, cfg.size_x or 200, 0, cfg.size_y or 22),
        Position = cfg.position or UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = library.theme.WindowHolder,
        BackgroundTransparency = 0,
        BorderSizePixel = 1,
        BorderColor3 = library.theme.WindowOutline
    })
    
    local top_accent = library.create("Frame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = library.theme.Accent,
        BorderSizePixel = 0
    })
    
    local text = library.create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 2),
        BackgroundTransparency = 1,
        Text = cfg.text or "Obelus UI",
        FontFace = library.font,
        TextSize = 11,
        TextColor3 = library.theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    
    if cfg.update then
        library.connect(library.services.RunService.RenderStepped, function()
            text.Text = cfg.update()
        end)
    end
    
    return frame
end

function library.update_watermark(text)
    if library.watermark_gui and library.watermark_gui:FindFirstChildWhichIsA("Frame") then
        local frame = library.watermark_gui:FindFirstChildWhichIsA("Frame")
        if frame and frame:FindFirstChildWhichIsA("TextLabel") then
            frame:FindFirstChildWhichIsA("TextLabel").Text = text
        end
    end
end

function library.keybind_list(cfg)
    local frame = library.create("Frame", {
        Parent = cfg.parent,
        Size = UDim2.new(1, 0, 0, cfg.size or 120),
        BackgroundTransparency = 1
    })
    
    if cfg.title then
        local title = library.create("TextLabel", {
            Parent = frame,
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = cfg.title,
            FontFace = library.font,
            TextSize = 12,
            TextColor3 = library.theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end
    
    local scroll = library.create("ScrollingFrame", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, cfg.title and 18 or 0),
        Size = UDim2.new(1, 0, 1, -(cfg.title and 18 or 0)),
        BackgroundColor3 = library.theme.ObjectBg,
        BorderSizePixel = 1,
        BorderColor3 = library.theme.SectionOuterBorder,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    library.add_gradient(scroll, 90)
    
    local layout = library.create("UIListLayout", {
        Parent = scroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1)
    })
    
    local function refresh()
        for _, v in pairs(scroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        
        for i, kb in pairs(library.keybinds) do
            local row = library.create("Frame", { Parent = scroll, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1 })
            
            local name_label = library.create("TextLabel", {
                Parent = row,
                Text = kb.name,
                FontFace = library.font,
                TextSize = 11,
                TextColor3 = library.theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.6, -5, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local key_label = library.create("TextLabel", {
                Parent = row,
                Text = kb.text,
                FontFace = library.font,
                TextSize = 11,
                TextColor3 = library.theme.Accent,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(0.6, 5, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Right
            })
        end
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end)
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, #library.keybinds * 21 + 10)
    end
    
    refresh()
    
    library.connect(library.services.RunService.RenderStepped, refresh)
    
    return { refresh = refresh }
end

function library.key_picker(cfg)
    local flag = cfg.flag or library.next_flag()
    local current_key = cfg.default or Enum.KeyCode.LeftAlt
    local listening = false
    local text_key = key_names[current_key] or key_names[Enum.KeyCode.LeftAlt]
    
    local frame = library.create("Frame", {
        Parent = cfg.parent,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1
    })
    
    local title = library.create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = cfg.name or "Keybind",
        FontFace = library.font,
        TextSize = 12,
        TextColor3 = library.theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local button = library.create("TextButton", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 16),
        Size = UDim2.new(0.6, 0, 0, 18),
        BackgroundColor3 = library.theme.ObjectBg,
        BorderSizePixel = 1,
        BorderColor3 = library.theme.SectionOuterBorder,
        Text = text_key,
        FontFace = library.font,
        TextSize = 11,
        TextColor3 = library.theme.Text,
        AutoButtonColor = false
    })
    library.add_gradient(button, 90)
    
    local clear_btn = library.create("TextButton", {
        Parent = frame,
        Position = UDim2.new(0.62, 5, 0, 16),
        Size = UDim2.new(0.38, -5, 0, 18),
        BackgroundColor3 = library.theme.ObjectBg,
        BorderSizePixel = 1,
        BorderColor3 = library.theme.SectionOuterBorder,
        Text = "Clear",
        FontFace = library.font,
        TextSize = 11,
        TextColor3 = library.theme.RiskyText,
        AutoButtonColor = false
    })
    library.add_gradient(clear_btn, 90)
    
    local function set_key(key)
        current_key = key
        text_key = key_names[key] or "???"
        button.Text = text_key
        library.flags[flag] = key
        
        local found = false
        for i, kb in pairs(library.keybinds) do
            if kb.flag == flag then
                kb.key = key
                kb.text = text_key
                found = true
                break
            end
        end
        if not found then
            table.insert(library.keybinds, {
                flag = flag,
                name = cfg.name or "Keybind",
                key = key,
                text = text_key
            })
        end
        
        if cfg.callback then cfg.callback(key) end
    end
    
    button.MouseButton1Click:Connect(function()
        listening = true
        button.Text = "..."
        button.BackgroundColor3 = library.theme.Accent
        
        local conn
        conn = library.services.UserInputService.InputBegan:Connect(function(input, game_processed)
            if listening and not game_processed then
                local key = input.KeyCode
                if key ~= Enum.KeyCode.Unknown then
                    set_key(key)
                    listening = false
                    button.Text = text_key
                    button.BackgroundColor3 = library.theme.ObjectBg
                    conn:Disconnect()
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    set_key(Enum.KeyCode.LeftAlt)
                    listening = false
                    button.Text = text_key
                    button.BackgroundColor3 = library.theme.ObjectBg
                    conn:Disconnect()
                end
            end
        end)
        
        task.wait(5)
        if listening then
            listening = false
            button.Text = text_key
            button.BackgroundColor3 = library.theme.ObjectBg
            if conn then conn:Disconnect() end
        end
    end)
    
    clear_btn.MouseButton1Click:Connect(function()
        set_key(Enum.KeyCode.LeftAlt)
    end)
    
    set_key(current_key)
    
    return { set = set_key, get = function() return current_key end }
end
local element
function library.window(cfg)
    local window = {
        pages = {},
        page_buttons = {},
        page_accents = {},
        gui = nil,
        holder = nil
    }
    
    local size_x = cfg.size and cfg.size.X or 550
    local size_y = cfg.size and cfg.size.Y or 450
    
    window.gui = library.create("ScreenGui", { Parent = library.services.CoreGui, Name = "ObelusUI" })
    library.gui = window.gui
    
    local window_outline = library.create("Frame", {
        Parent = window.gui,
        Size = UDim2.new(0, size_x, 0, size_y),
        Position = UDim2.new(0.5, -size_x/2, 0.5, -size_y/2),
        BackgroundColor3 = library.theme.WindowOutline,
        BorderSizePixel = 0
    })
    
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
    library.add_gradient(window_accent, 90)
    
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
    
    local pages_list = library.create("UIListLayout", {
        Parent = pages_holder,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Padding = UDim.new(0, 1)
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
            right_scroll = nil
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
            local section = { holder = nil, content = nil, elements = {} }
            local section_name = section_cfg.name or "Section"
            local side = section_cfg.side == "right" and right or left
            
            local section_bg = library.create("Frame", {
                Parent = side,
                Size = UDim2.new(1, 0, 0, section_cfg.size or 180),
                BackgroundColor3 = library.theme.SectionBg,
                BorderSizePixel = 0
            })
            library.add_gradient(section_bg, 90)
            
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
            
            local title_text = library.create("TextLabel", {
                Parent = section_bg,
                Text = section_name,
                FontFace = library.font,
                TextSize = 12,
                TextColor3 = library.theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, -8),
                Size = UDim2.new(0, #section_name * 7, 0, 14)
            })
            
            local content_frame = library.create("Frame", {
                Parent = outer_border,
                Size = UDim2.new(1, -32, 1, -20),
                Position = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1
            })
            
            local content_layout = library.create("UIListLayout", {
                Parent = content_frame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            section.holder = section_bg
            section.content = content_frame
            
            local function update_section_height()
                local total_height = 0
                for _, child in pairs(content_frame:GetChildren()) do
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

            function section:new_toggle(toggle_cfg)
                local flag = toggle_cfg.flag or library.next_flag()
                local value = toggle_cfg.default or false
                local cp_attachments = {}
                
                local holder = library.create("TextButton", { 
                    Parent = content_frame, 
                    Size = UDim2.new(1, 0, 0, 14), 
                    BackgroundTransparency = 1, 
                    Text = "",
                    AutoButtonColor = false
                })
                
                local toggle_frame = library.create("Frame", { 
                    Parent = holder, 
                    Size = UDim2.new(0, 10, 0, 10), 
                    BackgroundColor3 = library.theme.ObjectBg, 
                    BorderSizePixel = 0 
                })
                library.add_gradient(toggle_frame, 90)
                
                local outer = library.create("Frame", { 
                    Parent = toggle_frame, 
                    Size = UDim2.new(1, -2, 1, -2), 
                    Position = UDim2.new(0, 1, 0, 1), 
                    BackgroundColor3 = library.theme.SectionOuterBorder, 
                    BorderSizePixel = 0 
                })
                
                local accent = library.create("Frame", { 
                    Parent = outer, 
                    Size = UDim2.new(1, 0, 1, 0), 
                    BackgroundColor3 = library.theme.Accent, 
                    Visible = value, 
                    BorderSizePixel = 0 
                })
                library.add_gradient(accent, 90)
                
                local text = library.create("TextLabel", { 
                    Parent = holder, 
                    Text = toggle_cfg.name or "Toggle", 
                    FontFace = library.font, 
                    TextSize = 12, 
                    TextColor3 = toggle_cfg.risky and library.theme.RiskyText or library.theme.Text, 
                    BackgroundTransparency = 1, 
                    Position = UDim2.new(0, 16, 0, 0), 
                    Size = UDim2.new(1, -20, 1, 0), 
                    TextXAlignment = Enum.TextXAlignment.Left 
                })
                
                local function set_value(val)
                    value = val
                    accent.Visible = val
                    library.flags[flag] = val
                    if toggle_cfg.callback then toggle_cfg.callback(val) end
                end
                
                holder.MouseButton1Click:Connect(function()
                    set_value(not value)
                end)
                
                set_value(value)
                local element = {}
element.set = set_value
element._cp_count = 0

element.add_colorpicker = function(cp_cfg)
    element._cp_count = element._cp_count + 1
    local cp_index = element._cp_count
    
    local cp_flag = cp_cfg.flag or library.next_flag()
    local cp_current = cp_cfg.default or Color3.fromRGB(255, 255, 255)
    local h, s, v = library.rgb_to_hsv(cp_current)
    local opened = false
    
    local cp_preview = library.create("TextButton", {
        Parent = holder,
        BackgroundColor3 = cp_current,
        Size = UDim2.new(0, 20, 0, 10),
        Position = UDim2.new(1, -(cp_index * 25), 0.5, -5),
        Text = "",
        ZIndex = 17,
        AutoButtonColor = false
    })
    library.outline(cp_preview, Color3.new(0, 0, 0), 1)
    
    local icon_gradient = library.create("UIGradient", { Parent = cp_preview, Rotation = 90 })
    
    local picker_gui = library.create("Frame", {
        Parent = window.gui,
        BackgroundColor3 = library.theme.SectionBg,
        Size = UDim2.new(0, 150, 0, 170),
        Visible = false,
        ZIndex = 2000,
        BorderSizePixel = 1,
        BorderColor3 = library.theme.WindowBorder
    })
    library.outline(picker_gui, Color3.new(0, 0, 0), 2)
    
    local sat_val_bg = library.create("Frame", {
        Parent = picker_gui,
        Size = UDim2.new(0, 130, 0, 130),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = library.hsv_to_rgb(h, 1, 1),
        ZIndex = 2001
    })
    
    local w_grad = library.create("Frame", { Parent = sat_val_bg, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2002 })
    local g1 = library.create("UIGradient", { Parent = w_grad })
    g1.Color = ColorSequence.new(Color3.new(1, 1, 1))
    g1.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
    
    local b_grad = library.create("Frame", { Parent = sat_val_bg, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2003 })
    local g2 = library.create("UIGradient", { Parent = b_grad })
    g2.Color = ColorSequence.new(Color3.new(0, 0, 0))
    g2.Rotation = 90
    g2.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
    
    local cursor = library.create("Frame", {
        Parent = sat_val_bg,
        Size = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 2005,
        Position = UDim2.new(s, -2, 1 - v, -2)
    })
    library.outline(cursor, Color3.new(0, 0, 0), 1)
    
    local hue_bar = library.create("Frame", {
        Parent = picker_gui,
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
    
    local function update_cp()
        local color = library.hsv_to_rgb(h, s, v)
        icon_gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(1, Color3.new(color.R * 0.7, color.G * 0.7, color.B * 0.7))
        })
        cp_preview.BackgroundColor3 = color
        sat_val_bg.BackgroundColor3 = library.hsv_to_rgb(h, 1, 1)
        cursor.Position = UDim2.new(s, -2, 1 - v, -2)
        library.flags[cp_flag] = color
        if cp_cfg.callback then cp_cfg.callback(color) end
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
    
    library.services.UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            if dragging_sv then
                handle_input(i, sat_val_bg, false)
            elseif dragging_h then
                handle_input(i, hue_bar, true)
            end
        end
    end)
    
    library.services.UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging_sv = false
            dragging_h = false
        end
    end)
    
    cp_preview.MouseButton1Click:Connect(function()
        opened = not opened
        if opened then
            picker_gui.Position = UDim2.new(0, cp_preview.AbsolutePosition.X - 155, 0, cp_preview.AbsolutePosition.Y)
            picker_gui.Visible = true
        else
            picker_gui.Visible = false
        end
    end)
    
    update_cp()
    
    return element
end

table.insert(section.elements, element)
update_section_height()
return element
            end

            function section:new_slider(slider_cfg)
    local flag = slider_cfg.flag or library.next_flag()
    local min = slider_cfg.min or 0
    local max = slider_cfg.max or 100
    local def = slider_cfg.default or min
    local decimals = slider_cfg.float or 0
    
    local holder = library.create("Frame", { 
        Parent = content_frame, 
        Size = UDim2.new(1, 0, 0, 38), 
        BackgroundTransparency = 1 
    })
    
    local text = library.create("TextLabel", { 
        Parent = holder, 
        Text = slider_cfg.name, 
        FontFace = library.font, 
        TextSize = 12, 
        TextColor3 = library.theme.Text, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 0, 14), 
        TextXAlignment = Enum.TextXAlignment.Left 
    })
    
    local bg = library.create("TextButton", { 
        Parent = holder, 
        Position = UDim2.new(0, 0, 0, 16), 
        Size = UDim2.new(1, 0, 0, 8), 
        BackgroundColor3 = library.theme.ObjectBg, 
        BorderSizePixel = 0, 
        Text = "",
        AutoButtonColor = false
    })
    library.add_gradient(bg, 90)
    
    local bar = library.create("Frame", { 
        Parent = bg, 
        Size = UDim2.new((def - min) / (max - min), 0, 1, 0), 
        BackgroundColor3 = library.theme.Accent, 
        BorderSizePixel = 0 
    })
    library.add_gradient(bar, 90)
    
    local function format_value(v)
        if decimals > 0 then
            local mult = 10 ^ decimals
            local rounded = math.floor(v * mult + 0.5) / mult
            return tostring(rounded)
        else
            return tostring(math.floor(v + 0.5))
        end
    end
    
    local value_display = library.create("TextLabel", { 
        Parent = holder, 
        Text = format_value(def), 
        FontFace = library.font, 
        TextSize = 10, 
        TextColor3 = library.theme.Text, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(0, 40, 0, 12), 
        Position = UDim2.new((def - min) / (max - min), -20, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Center
    })
    
    local function set(v)
        if decimals > 0 then
            local mult = 10 ^ decimals
            v = math.floor(math.clamp(v, min, max) * mult + 0.5) / mult
        else
            v = math.floor(math.clamp(v, min, max) + 0.5)
        end
        library.flags[flag] = v
        value_display.Text = format_value(v)
        local percent = (v - min) / (max - min)
        bar.Size = UDim2.new(percent, 0, 1, 0)
        value_display.Position = UDim2.new(percent, -20, 0, 24)
        if slider_cfg.callback then slider_cfg.callback(v) end
    end
    
    local dragging = false
    
    bg.MouseButton1Down:Connect(function()
        dragging = true
        local mouse_pos = library.services.UserInputService:GetMouseLocation()
        local new_val = min + ((mouse_pos.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X) * (max - min)
        set(new_val)
    end)
    
    library.services.UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouse_pos = library.services.UserInputService:GetMouseLocation()
            local new_val = min + ((mouse_pos.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X) * (max - min)
            set(new_val)
        end
    end)
    
    library.services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    set(def)
    
    local element = { set = set }
    table.insert(section.elements, element)
    update_section_height()
    return element
            end

            function section:new_dropdown(drop_cfg)
                local flag = drop_cfg.flag or library.next_flag()
                local options = {}
                for _, opt in pairs(drop_cfg.options or {}) do
                    table.insert(options, opt)
                end
                local selected = drop_cfg.default or (options[1] or "None")
                local open = false
                
                local holder = library.create("Frame", { 
                    Parent = content_frame, 
                    Size = UDim2.new(1, 0, 0, 38), 
                    BackgroundTransparency = 1 
                })
                
                local text = library.create("TextLabel", { 
                    Parent = holder, 
                    Text = drop_cfg.name, 
                    FontFace = library.font, 
                    TextSize = 12, 
                    TextColor3 = library.theme.Text, 
                    BackgroundTransparency = 1, 
                    Size = UDim2.new(1, 0, 0, 14), 
                    TextXAlignment = Enum.TextXAlignment.Left 
                })
                
                local button = library.create("TextButton", { 
                    Parent = holder, 
                    Position = UDim2.new(0, 0, 0, 16), 
                    Size = UDim2.new(1, 0, 0, 20), 
                    BackgroundColor3 = library.theme.ObjectBg, 
                    BorderSizePixel = 0, 
                    Text = "  " .. selected, 
                    FontFace = library.font, 
                    TextSize = 12, 
                    TextColor3 = library.theme.Text, 
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                library.add_gradient(button, 90)
               
                local arrow = library.create("ImageLabel", { 
                    Parent = button, 
                    Image = "rbxassetid://116204929609664", 
                    Position = UDim2.new(1, -15, 0, 7), 
                    Size = UDim2.new(0, 8, 0, 5), 
                    BackgroundTransparency = 1, 
                    ImageColor3 = library.theme.Text 
                })
                
                local dropdown_frame = library.create("Frame", { 
                    Parent = button, 
                    Position = UDim2.new(0, 0, 1, 2), 
                    Size = UDim2.new(1, 0, 0, 0), 
                    BackgroundColor3 = library.theme.ObjectBg, 
                    BorderSizePixel = 1, 
                    BorderColor3 = library.theme.SectionOuterBorder, 
                    Visible = false, 
                    ZIndex = 10,
                    ClipsDescendants = true
                })
                
                local scroll = library.create("ScrollingFrame", {
                    Parent = dropdown_frame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 4,
                    CanvasSize = UDim2.new(0, 0, 0, 0)
                })
                
                local layout = library.create("UIListLayout", {
                    Parent = scroll,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 1)
                })
                
                local function update_dropdown()
                    for _, v in pairs(scroll:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    
                    for _, opt in pairs(options) do
                        local opt_btn = library.create("TextButton", {
                            Parent = scroll,
                            Size = UDim2.new(1, 0, 0, 20),
                            BackgroundColor3 = library.theme.ObjectBg,
                            BorderSizePixel = 0,
                            Text = "  " .. opt,
                            FontFace = library.font,
                            TextSize = 12,
                            TextColor3 = library.theme.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                            ZIndex = 11
                        })
                        library.add_gradient(opt_btn, 90)
                        
                        if opt == selected then
                            local highlight = library.create("Frame", {
                                Parent = opt_btn,
                                Size = UDim2.new(0, 3, 1, 0),
                                BackgroundColor3 = library.theme.Accent,
                                BorderSizePixel = 0
                            })
                        end
                        
                        opt_btn.MouseButton1Click:Connect(function()
                            selected = opt
                            button.Text = "  " .. selected
                            dropdown_frame.Visible = false
                            open = false
                            library.flags[flag] = selected
                            if drop_cfg.callback then drop_cfg.callback(selected) end
                            update_dropdown()
                        end)
                    end
                    
                    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
                    end)
                    
                    local height = math.min(#options * 21, 120)
                    dropdown_frame.Size = UDim2.new(1, 0, 0, height)
                    scroll.CanvasSize = UDim2.new(0, 0, 0, #options * 21)
                end
                
                button.MouseButton1Click:Connect(function()
                    open = not open
                    dropdown_frame.Visible = open
                    if open then
                        update_dropdown()
                    end
                end)
                
                update_dropdown()
                library.flags[flag] = selected
                
                local element = { 
                    set = function(v) 
                        selected = v
                        button.Text = "  " .. selected
                        library.flags[flag] = selected
                        update_dropdown()
                    end,
                    refresh = function(new_opts)
                        options = {}
                        for _, opt in pairs(new_opts or {}) do
                            table.insert(options, opt)
                        end
                        selected = options[1] or "None"
                        button.Text = "  " .. selected
                        library.flags[flag] = selected
                        update_dropdown()
                    end
                }
                table.insert(section.elements, element)
                update_section_height()
                return element
            end

            function section:new_textbox(box_cfg)
                local flag = box_cfg.flag or library.next_flag()
                
                local holder = library.create("Frame", { 
                    Parent = content_frame, 
                    Size = UDim2.new(1, 0, 0, 38), 
                    BackgroundTransparency = 1 
                })
                
                local text = library.create("TextLabel", { 
                    Parent = holder, 
                    Text = box_cfg.name, 
                    FontFace = library.font, 
                    TextSize = 12, 
                    TextColor3 = library.theme.Text, 
                    BackgroundTransparency = 1, 
                    Size = UDim2.new(1, 0, 0, 14), 
                    TextXAlignment = Enum.TextXAlignment.Left 
                })
                
                local box = library.create("TextBox", { 
                    Parent = holder, 
                    Position = UDim2.new(0, 0, 0, 16), 
                    Size = UDim2.new(1, 0, 0, 20), 
                    BackgroundColor3 = library.theme.ObjectBg, 
                    BorderSizePixel = 0, 
                    Text = box_cfg.default or "", 
                    PlaceholderText = box_cfg.placeholder or "...", 
                    FontFace = library.font, 
                    TextSize = 12, 
                    TextColor3 = library.theme.Text, 
                    ClearTextOnFocus = false 
                })
                library.add_gradient(box, 90)
                
                box.FocusLost:Connect(function()
                    library.flags[flag] = box.Text
                    if box_cfg.callback then box_cfg.callback(box.Text) end
                end)
                
                local element = { 
                    set = function(v) 
                        box.Text = v 
                        library.flags[flag] = v
                    end 
                }
                table.insert(section.elements, element)
                update_section_height()
                return element
            end

        function section:new_listbox(lb_cfg)
    local items = {}
    if lb_cfg.options then
        for _, v in pairs(lb_cfg.options) do
            table.insert(items, v)
        end
    end
    local selected_item = nil
    
    local holder = library.create("Frame", { 
        Parent = content_frame, 
        Size = UDim2.new(1, 0, 0, lb_cfg.size or 100), 
        BackgroundTransparency = 1 
    })
    
    local text = library.create("TextLabel", { 
        Parent = holder, 
        Text = lb_cfg.name, 
        FontFace = library.font, 
        TextSize = 12, 
        TextColor3 = library.theme.Text, 
        BackgroundTransparency = 1, 
        Size = UDim2.new(1, 0, 0, 14), 
        TextXAlignment = Enum.TextXAlignment.Left 
    })
    
    local scroll = library.create("ScrollingFrame", { 
        Parent = holder, 
        Position = UDim2.new(0, 0, 0, 16), 
        Size = UDim2.new(1, 0, 1, -18), 
        BackgroundColor3 = library.theme.ObjectBg, 
        BorderSizePixel = 0, 
        ScrollBarThickness = 4, 
        CanvasSize = UDim2.new(0, 0, 0, 0) 
    })
    library.add_gradient(scroll, 90)
    
    local layout = library.create("UIListLayout", { 
        Parent = scroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1)
    })
    
    local function refresh_list()
        for _, v in pairs(scroll:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        
        for _, item in pairs(items) do
            local btn = library.create("TextButton", { 
                Parent = scroll, 
                Size = UDim2.new(1, 0, 0, 20), 
                BackgroundTransparency = 1, 
                Text = "  " .. tostring(item), 
                FontFace = library.font, 
                TextSize = 12, 
                TextColor3 = library.theme.Text, 
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            })
            
            if item == selected_item then
                local highlight = library.create("Frame", {
                    Parent = btn,
                    Size = UDim2.new(0, 3, 1, 0),
                    BackgroundColor3 = library.theme.Accent,
                    BorderSizePixel = 0
                })
            end
            
            btn.MouseButton1Click:Connect(function()
                selected_item = item
                if lb_cfg.callback then lb_cfg.callback(item) end
                refresh_list()
            end)
        end
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, #items * 21 + 4)
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    end)
    
    refresh_list()
    
    local element = { 
        add = function(v) 
            table.insert(items, tostring(v)) 
            refresh_list() 
            update_section_height()
        end, 
        remove = function(v) 
            v = tostring(v)
            for i, x in pairs(items) do 
                if x == v then 
                    table.remove(items, i) 
                    break 
                end 
            end 
            refresh_list() 
            update_section_height()
        end, 
        refresh = function(new_items) 
            items = {}
            if new_items then
                for _, v in pairs(new_items) do
                    table.insert(items, tostring(v))
                end
            end
            selected_item = nil
            refresh_list() 
            update_section_height()
        end,
        clear = function()
            items = {}
            selected_item = nil
            refresh_list()
            update_section_height()
        end
    }
    table.insert(section.elements, element)
    update_section_height()
    return element
            end

            function section:new_button(btn_cfg)
                local holder = library.create("Frame", { 
                    Parent = content_frame, 
                    Size = UDim2.new(1, 0, 0, 24), 
                    BackgroundTransparency = 1 
                })
                
                local outer = library.create("Frame", { 
                    Parent = holder, 
                    Size = UDim2.new(1, -2, 1, -2), 
                    Position = UDim2.new(0, 1, 0, 1), 
                    BackgroundColor3 = library.theme.SectionOuterBorder, 
                    BorderSizePixel = 0 
                })
                
                local button = library.create("TextButton", { 
                    Parent = outer, 
                    Text = btn_cfg.name or "Button", 
                    FontFace = library.font, 
                    TextSize = 12, 
                    TextColor3 = library.theme.Text, 
                    BackgroundColor3 = library.theme.ObjectBg, 
                    Size = UDim2.new(1, 0, 1, 0), 
                    BorderSizePixel = 0,
                    AutoButtonColor = false
                })
                library.add_gradient(button, 90)
                
                button.MouseButton1Click:Connect(function()
                    if btn_cfg.callback then btn_cfg.callback() end
                end)
                update_section_height()
            end
            
            function section:new_label(label_cfg)
    if not label_cfg then
        label_cfg = {}
    end
    
    local label_holder = library.create("Frame", {
        Parent = content_frame,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1
    })
    
    local label = library.create("TextLabel", {
        Parent = label_holder,
        Size = UDim2.new(1, -30, 1, 0),
        Text = label_cfg.name or "Label",
        FontFace = library.font,
        TextSize = 12,
        TextColor3 = label_cfg.risky and library.theme.RiskyText or library.theme.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local label_element = {
        set_text = function(text)
            label.Text = text
        end,
        get_text = function()
            return label.Text
        end,
        add_colorpicker = nil
    }
    
    if not label_element._cp_count then
        label_element._cp_count = 0
    end
    
    label_element.add_colorpicker = function(cp_cfg)
        label_element._cp_count = label_element._cp_count + 1
        local cp_index = label_element._cp_count
        
        local cp_flag = cp_cfg.flag or library.next_flag()
        local cp_current = cp_cfg.default or Color3.fromRGB(255, 255, 255)
        local h, s, v = library.rgb_to_hsv(cp_current)
        local opened = false
        
        local cp_preview = library.create("TextButton", {
            Parent = label_holder,
            BackgroundColor3 = cp_current,
            Size = UDim2.new(0, 20, 0, 10),
            Position = UDim2.new(1, -(cp_index * 25), 0.5, -5),
            Text = "",
            ZIndex = 17,
            AutoButtonColor = false
        })
        library.outline(cp_preview, Color3.new(0, 0, 0), 1)
        
        local icon_gradient = library.create("UIGradient", { Parent = cp_preview, Rotation = 90 })
        
        local picker_gui = library.create("Frame", {
            Parent = window.gui,
            BackgroundColor3 = library.theme.SectionBg,
            Size = UDim2.new(0, 150, 0, 170),
            Visible = false,
            ZIndex = 2000,
            BorderSizePixel = 1,
            BorderColor3 = library.theme.WindowBorder
        })
        library.outline(picker_gui, Color3.new(0, 0, 0), 2)
        
        local sat_val_bg = library.create("Frame", {
            Parent = picker_gui,
            Size = UDim2.new(0, 130, 0, 130),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = library.hsv_to_rgb(h, 1, 1),
            ZIndex = 2001
        })
        
        local w_grad = library.create("Frame", { Parent = sat_val_bg, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2002 })
        local g1 = library.create("UIGradient", { Parent = w_grad })
        g1.Color = ColorSequence.new(Color3.new(1, 1, 1))
        g1.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
        
        local b_grad = library.create("Frame", { Parent = sat_val_bg, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2003 })
        local g2 = library.create("UIGradient", { Parent = b_grad })
        g2.Color = ColorSequence.new(Color3.new(0, 0, 0))
        g2.Rotation = 90
        g2.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        
        local cursor = library.create("Frame", {
            Parent = sat_val_bg,
            Size = UDim2.new(0, 4, 0, 4),
            BackgroundColor3 = Color3.new(1, 1, 1),
            ZIndex = 2005,
            Position = UDim2.new(s, -2, 1 - v, -2)
        })
        library.outline(cursor, Color3.new(0, 0, 0), 1)
        
        local hue_bar = library.create("Frame", {
            Parent = picker_gui,
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
        
        local function update_cp()
            local color = library.hsv_to_rgb(h, s, v)
            icon_gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color),
                ColorSequenceKeypoint.new(1, Color3.new(color.R * 0.7, color.G * 0.7, color.B * 0.7))
            })
            cp_preview.BackgroundColor3 = color
            sat_val_bg.BackgroundColor3 = library.hsv_to_rgb(h, 1, 1)
            cursor.Position = UDim2.new(s, -2, 1 - v, -2)
            library.flags[cp_flag] = color
            if cp_cfg.callback then cp_cfg.callback(color) end
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
        
        library.services.UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                if dragging_sv then
                    handle_input(i, sat_val_bg, false)
                elseif dragging_h then
                    handle_input(i, hue_bar, true)
                end
            end
        end)
        
        library.services.UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging_sv = false
                dragging_h = false
            end
        end)
        
        cp_preview.MouseButton1Click:Connect(function()
            opened = not opened
            if opened then
                picker_gui.Position = UDim2.new(0, cp_preview.AbsolutePosition.X - 155, 0, cp_preview.AbsolutePosition.Y)
                picker_gui.Visible = true
            else
                picker_gui.Visible = false
            end
        end)
        
        update_cp()
        
        return label_element
    end
    
    update_section_height()
    return label_element
end
            function section:new_keypicker(key_cfg)
                local picker = library.key_picker({
                    parent = content_frame,
                    name = key_cfg.name,
                    flag = key_cfg.flag,
                    default = key_cfg.default,
                    callback = key_cfg.callback
                })
                update_section_height()
                return picker
            end

            function section:new_keybind_list(list_cfg)
                local list = library.keybind_list({
                    parent = content_frame,
                    title = list_cfg.title,
                    size = list_cfg.size
                })
                update_section_height()
                return list
            end

            return section
        end
        return page
    end
    
    return window
end

function library.save_config(name)
    local config_data = {}
    for flag, value in pairs(library.flags) do
        if typeof(value) == "EnumItem" then
            config_data[flag] = value.Name
        elseif typeof(value) == "Color3" then
            config_data[flag] = { value.R, value.G, value.B }
        else
            config_data[flag] = value
        end
    end
    writefile(library.directory .. "/configs/" .. name .. ".json", library.services.HttpService:JSONEncode(config_data))
end

function library.load_config(name)
    local path = library.directory .. "/configs/" .. name .. ".json"
    if not isfile(path) then return false end
    local config_data = library.services.HttpService:JSONDecode(readfile(path))
    for flag, value in pairs(config_data) do
        if library.flags[flag] ~= nil then
            if type(value) == "string" and Enum.KeyCode[value] then
                library.flags[flag] = Enum.KeyCode[value]
            elseif type(value) == "table" and #value == 3 then
                library.flags[flag] = Color3.new(value[1], value[2], value[3])
            else
                library.flags[flag] = value
            end
        end
    end
    return true
end

function library.get_configs()
    local configs = {}
    if isfolder(library.directory .. "/configs") then
        for _, file in pairs(listfiles(library.directory .. "/configs")) do
            local name = file:match("([^/]+)%.json$")
            if name then
                table.insert(configs, name)
            end
        end
    end
    return configs
end
--local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/obelus.lua"))()
return library
