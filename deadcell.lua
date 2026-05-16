local library = {
    flags = {},
    connections = {},
    open = true,
    notifications = {},
    current_element = nil,
    config_ignores = {},
    directory = "obelus_ui",
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
        Thickness = thickness or 1,
        LineJoinMode = Enum.LineJoinMode.Miter
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
    library.flags = {}
    library.connections = {}
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
    local watermark = {
        text = cfg.text or "Obelus UI",
        active = cfg.active ~= false,
        draggable = cfg.draggable ~= false,
        position = cfg.position or UDim2.new(0, 10, 0, 10),
        gui = nil,
        holder = nil,
        text_label = nil,
        dragging = false,
        drag_start = nil,
        drag_start_pos = nil
    }
    
    if not watermark.active then
        return {
            set_text = function() end,
            set_active = function() end,
            set_draggable = function() end,
            set_position = function() end,
            remove = function() end
        }
    end
    
    --  holder
    watermark.holder = library.create("Frame", {
        Parent = library.gui or library.services.CoreGui,
        Size = UDim2.new(0, 0, 0, 0),
        Position = watermark.position,
        BackgroundTransparency = 1,
        ZIndex = 999,
        Name = "WatermarkHolder"
    })
    
    
    local container = library.create("Frame", {
        Parent = watermark.holder,
        Size = UDim2.new(0, 180, 0, 28),
        BackgroundColor3 = library.theme.ObjectBg,
        BorderSizePixel = 1,
        BorderColor3 = library.theme.SectionOuterBorder,
        ZIndex = 1000
    })
    library.add_gradient(container, 90)
    

    library.outline(container, Color3.fromRGB(0, 0, 0), 1)
    
    local top_accent = library.create("Frame", {
        Parent = container,
        Size = UDim2.new(1, -2, 0, 2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 1001
    })
    library.add_gradient(top_accent, 90)
    

    local inner = library.create("Frame", {
        Parent = container,
        Position = UDim2.new(0, 1, 0, 4),
        Size = UDim2.new(1, -2, 1, -5),
        BackgroundColor3 = library.theme.SectionInnerBorder,
        BorderSizePixel = 0,
        ZIndex = 1001
    })
    

    watermark.text_label = library.create("TextLabel", {
        Parent = inner,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = watermark.text,
        FontFace = library.font,
        TextSize = 11,
        TextColor3 = library.theme.Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1002
    })
    

    if watermark.draggable then
        local drag_frame = library.create("Frame", {
            Parent = container,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ZIndex = 1003
        })
        
        drag_frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                watermark.dragging = true
                watermark.drag_start = Vector2.new(input.Position.X, input.Position.Y)
                watermark.drag_start_pos = watermark.holder.Position
            end
        end)
        
        drag_frame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                watermark.dragging = false
            end
        end)
        
        library.connect(library.services.UserInputService.InputChanged, function(input)
            if watermark.dragging then
                if input.UserInputType == Enum.UserInputType.MouseMovement or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    local delta = Vector2.new(input.Position.X, input.Position.Y) - watermark.drag_start
                    
                    local new_x = watermark.drag_start_pos.X.Offset + delta.X
                    local new_y = watermark.drag_start_pos.Y.Offset + delta.Y
                    
                    watermark.holder.Position = UDim2.new(0, new_x, 0, new_y)
                end
            end
        end)
    end
    
    
    local methods = {}
    
    function methods:set_text(new_text)
        watermark.text = new_text
        watermark.text_label.Text = new_text
    end
    
    function methods:set_active(active)
        watermark.active = active
        watermark.holder.Visible = active
    end
    
    function methods:set_draggable(draggable)
        watermark.draggable = draggable
    end
    
    function methods:set_position(pos)
        watermark.position = pos
        watermark.holder.Position = pos
    end
    
    function methods:get_position()
        return watermark.holder.Position
    end
    
    function methods:get_text()
        return watermark.text
    end
    
    function methods:is_active()
        return watermark.active
    end
    
    function methods:remove()
        if watermark.holder then
            watermark.holder:Destroy()
        end
    end
    
    return methods
end

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

            function section:new_label(label_cfg)
                local info = label_cfg or {}
                local label = {}
                local colorpickers = {}
                local keybinds = {}
                
                local content_holder = library.create("Frame", {
                    Parent = content_frame,
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1
                })
                
                local right_components = library.create("Frame", {
                    Parent = content_holder,
                    Position = UDim2.new(1, 0, 0, -1),
                    Size = UDim2.new(0, 0, 0, 12),
                    BackgroundTransparency = 1
                })
                
                local right_layout = library.create("UIListLayout", {
                    Parent = right_components,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Padding = UDim.new(0, 4)
                })
                
                local label_title = library.create("TextLabel", {
                    Parent = content_holder,
                    Size = UDim2.new(1, -(info.offset or 36), 1, 0),
                    Position = UDim2.new(0, info.offset or 36, 0, 0),
                    BackgroundTransparency = 1,
                    Text = info.name or info.text or "new label",
                    FontFace = library.font,
                    TextSize = 12,
                    TextColor3 = info.risky and library.theme.RiskyText or library.theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                function label:add_colorpicker(cp_cfg)
                    local cp_flag = cp_cfg.flag or library.next_flag()
                    local cp_current = cp_cfg.default or Color3.fromRGB(255, 255, 255)
                    local h, s, v = library.rgb_to_hsv(cp_current)
                    local opened = false
                    
                    local cp_outline = library.create("Frame", {
                        Parent = window.gui,
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
                    
                    local cp_preview = library.create("TextButton", {
                        Parent = right_components,
                        BackgroundColor3 = cp_current,
                        Size = UDim2.new(0, 18, 0, 9),
                        Text = "",
                        AutoButtonColor = false
                    })
                    library.outline(cp_preview, Color3.new(0, 0, 0), 1)
                    
                    local function update_cp()
                        local color = library.hsv_to_rgb(h, s, v)
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
                    
                    library.connect(library.services.UserInputService.InputChanged, function(i)
                        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                            if dragging_sv then handle_input(i, sat_val_bg, false)
                            elseif dragging_h then handle_input(i, hue_bar, true) end
                        end
                    end)
                    
                    library.connect(library.services.UserInputService.InputEnded, function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            dragging_sv = false
                            dragging_h = false
                        end
                    end)
                    
                    cp_preview.MouseButton1Click:Connect(function()
                        opened = not opened
                        if opened then
                            cp_outline.Position = UDim2.new(0, cp_preview.AbsolutePosition.X - 155, 0, cp_preview.AbsolutePosition.Y)
                            cp_outline.Visible = true
                        else
                            cp_outline.Visible = false
                        end
                    end)
                    
                    update_cp()
                    return { set = function(c) cp_current = c; h,s,v = library.rgb_to_hsv(c); update_cp() end, get = function() return cp_current end }
                end
                
                function label:add_keypicker(kb_cfg)
                    local kb_flag = kb_cfg.flag or library.next_flag()
                    local current_key = kb_cfg.default or Enum.KeyCode.LeftAlt
                    local listening = false
                    local text_key = key_names[current_key] or key_names[Enum.KeyCode.LeftAlt]
                    
                    local button = library.create("TextButton", {
                        Parent = right_components,
                        Size = UDim2.new(0, 40, 0, 12),
                        BackgroundColor3 = library.theme.ObjectBg,
                        BorderSizePixel = 1,
                        BorderColor3 = library.theme.SectionOuterBorder,
                        Text = text_key,
                        FontFace = library.font,
                        TextSize = 10,
                        TextColor3 = library.theme.Text,
                        AutoButtonColor = false
                    })
                    library.add_gradient(button, 90)
                    
                    local function set_key(key)
                        current_key = key
                        text_key = key_names[key] or "???"
                        button.Text = text_key
                        library.flags[kb_flag] = key
                        if kb_cfg.callback then kb_cfg.callback(key) end
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
                                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
                    
                    set_key(current_key)
                    return { set = set_key, get = function() return current_key end }
                end
                
                function label:set_text(text)
                    label_title.Text = text
                end
                
                function label:get_text()
                    return label_title.Text
                end
                
                function label:remove()
                    content_holder:Destroy()
                    update_section_height()
                end
                
                update_section_height()
                return label
            end

            function section:new_toggle(toggle_cfg)
                local info = toggle_cfg or {}
                local flag = info.flag or library.next_flag()
                local toggle = {
                    state = info.default or false,
                    callback = info.callback or function() end
                }
                local colorpickers = {}
                local keybinds = {}
                
                local content_holder = library.create("Frame", {
                    Parent = content_frame,
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1
                })
                
                local right_components = library.create("Frame", {
                    Parent = content_holder,
                    Position = UDim2.new(1, 0, 0, -1),
                    Size = UDim2.new(0, 0, 0, 12),
                    BackgroundTransparency = 1
                })
                
                local right_layout = library.create("UIListLayout", {
                    Parent = right_components,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Padding = UDim.new(0, 4)
                })
                
                local toggle_button = library.create("TextButton", {
                    Parent = content_holder,
                    Size = UDim2.new(0.5, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                })
                
                local toggle_title = library.create("TextLabel", {
                    Parent = content_holder,
                    Size = UDim2.new(1, -36, 1, 0),
                    Position = UDim2.new(0, 36, 0, 0),
                    BackgroundTransparency = 1,
                    Text = info.name or info.text or "new toggle",
                    FontFace = library.font,
                    TextSize = 12,
                    TextColor3 = info.risky and library.theme.RiskyText or library.theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local toggle_frame = library.create("Frame", {
                    Parent = content_holder,
                    Position = UDim2.new(0, 16, 0, 2),
                    Size = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = library.theme.ObjectBg,
                    BorderSizePixel = 0
                })
                library.add_gradient(toggle_frame, 90)
                
                local toggle_inner = library.create("Frame", {
                    Parent = toggle_frame,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    BackgroundColor3 = toggle.state and library.theme.Accent or library.theme.SectionOuterBorder,
                    BorderSizePixel = 0
                })
                library.add_gradient(toggle_inner, 90)
                
                local function set_value(val)
                    toggle.state = val
                    toggle_inner.BackgroundColor3 = val and library.theme.Accent or library.theme.SectionOuterBorder
                    library.flags[flag] = val
                    toggle.callback(val)
                end
                
                toggle_button.MouseButton1Click:Connect(function()
                    set_value(not toggle.state)
                end)
                
                set_value(toggle.state)
                
                local element = {
                    set = set_value,
                    get = function() return toggle.state end,
                    remove = function()
                        content_holder:Destroy()
                        update_section_height()
                    end
                }
                
                function element:add_colorpicker(cp_cfg)
                    local cp_flag = cp_cfg.flag or library.next_flag()
                    local cp_current = cp_cfg.default or Color3.fromRGB(255, 255, 255)
                    local h, s, v = library.rgb_to_hsv(cp_current)
                    local opened = false
                    
                    local cp_outline = library.create("Frame", {
                        Parent = window.gui,
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
                    
                    local cp_preview = library.create("TextButton", {
                        Parent = right_components,
                        BackgroundColor3 = cp_current,
                        Size = UDim2.new(0, 18, 0, 9),
                        Text = "",
                        AutoButtonColor = false
                    })
                    library.outline(cp_preview, Color3.new(0, 0, 0), 1)
                    
                    local function update_cp()
                        local color = library.hsv_to_rgb(h, s, v)
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
                    
                    library.connect(library.services.UserInputService.InputChanged, function(i)
                        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                            if dragging_sv then handle_input(i, sat_val_bg, false)
                            elseif dragging_h then handle_input(i, hue_bar, true) end
                        end
                    end)
                    
                    library.connect(library.services.UserInputService.InputEnded, function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            dragging_sv = false
                            dragging_h = false
                        end
                    end)
                    
                    cp_preview.MouseButton1Click:Connect(function()
                        opened = not opened
                        if opened then
                            cp_outline.Position = UDim2.new(0, cp_preview.AbsolutePosition.X - 155, 0, cp_preview.AbsolutePosition.Y)
                            cp_outline.Visible = true
                        else
                            cp_outline.Visible = false
                        end
                    end)
                    
                    update_cp()
                    return { set = function(c) cp_current = c; h,s,v = library.rgb_to_hsv(c); update_cp() end, get = function() return cp_current end }
                end
                
                function element:add_keypicker(kb_cfg)
                    local kb_flag = kb_cfg.flag or library.next_flag()
                    local current_key = kb_cfg.default or Enum.KeyCode.LeftAlt
                    local listening = false
                    local text_key = key_names[current_key] or key_names[Enum.KeyCode.LeftAlt]
                    
                    local button = library.create("TextButton", {
                        Parent = right_components,
                        Size = UDim2.new(0, 40, 0, 12),
                        BackgroundColor3 = library.theme.ObjectBg,
                        BorderSizePixel = 1,
                        BorderColor3 = library.theme.SectionOuterBorder,
                        Text = text_key,
                        FontFace = library.font,
                        TextSize = 10,
                        TextColor3 = library.theme.Text,
                        AutoButtonColor = false
                    })
                    library.add_gradient(button, 90)
                    
                    local function set_key(key)
                        current_key = key
                        text_key = key_names[key] or "???"
                        button.Text = text_key
                        library.flags[kb_flag] = key
                        if kb_cfg.callback then kb_cfg.callback(key) end
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
                                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
                    
                    set_key(current_key)
                    return { set = set_key, get = function() return current_key end }
                end
                
                table.insert(section.elements, element)
                update_section_height()
                return element
            end

            function section:new_button(btn_cfg)
                local info = btn_cfg or {}
                local button = {
                    callback = info.callback or function() end
                }
                
                local content_holder = library.create("Frame", {
                    Parent = content_frame,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1
                })
                
                local button_button = library.create("TextButton", {
                    Parent = content_holder,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                })
                
                local button_frame = library.create("Frame", {
                    Parent = content_holder,
                    Position = UDim2.new(0, 16, 0, 0),
                    Size = UDim2.new(1, -32, 1, 0),
                    BackgroundColor3 = library.theme.ObjectBg,
                    BorderSizePixel = 1,
                    BorderColor3 = library.theme.SectionOuterBorder
                })
                library.add_gradient(button_frame, 90)
                
                local button_inner = library.create("Frame", {
                    Parent = button_frame,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    BackgroundColor3 = library.theme.SectionInnerBorder,
                    BorderSizePixel = 0
                })
                
                local button_title = library.create("TextLabel", {
                    Parent = content_holder,
                    Size = UDim2.new(1, -32, 1, 0),
                    Position = UDim2.new(0, 16, 0, 0),
                    BackgroundTransparency = 1,
                    Text = info.name or info.text or "new button",
                    FontFace = library.font,
                    TextSize = 12,
                    TextColor3 = library.theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Center
                })
                
                button_button.MouseButton1Click:Connect(function()
                    button.callback()
                end)
                
                local element = {
                    remove = function()
                        content_holder:Destroy()
                        update_section_height()
                    end
                }
                
                table.insert(section.elements, element)
                update_section_height()
                return element
            end

            function section:new_slider(slider_cfg)
                local info = slider_cfg or {}
                local flag = info.flag or library.next_flag()
                local min_val = info.min or 0
                local max_val = info.max or 100
                local default_val = info.default or min_val
                local decimals = info.decimals or 1
                local suffix = info.suffix or ""
                
                local slider = {
                    state = default_val,
                    min = min_val,
                    max = max_val,
                    decimals = decimals,
                    suffix = suffix,
                    callback = info.callback or function() end,
                    holding = false
                }
                
                local content_holder = library.create("Frame", {
                    Parent = content_frame,
                    Size = UDim2.new(1, 0, 0, (info.name or info.text) and 32 or 18),
                    BackgroundTransparency = 1
                })
                
                local slider_button = library.create("TextButton", {
                    Parent = content_holder,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                })
                
                if info.name or info.text then
                    local slider_title = library.create("TextLabel", {
                        Parent = content_holder,
                        Size = UDim2.new(1, -16, 0, 14),
                        Position = UDim2.new(0, 16, 0, 0),
                        BackgroundTransparency = 1,
                        Text = info.name or info.text,
                        FontFace = library.font,
                        TextSize = 12,
                        TextColor3 = library.theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end
                
                local slider_frame = library.create("Frame", {
                    Parent = content_holder,
                    Position = UDim2.new(0, 16, 0, (info.name or info.text) and 16 or 0),
                    Size = UDim2.new(1, -32, 0, 10),
                    BackgroundColor3 = library.theme.ObjectBg,
                    BorderSizePixel = 0
                })
                library.add_gradient(slider_frame, 90)
                
                local slider_inner = library.create("Frame", {
                    Parent = slider_frame,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    BackgroundColor3 = library.theme.SectionOuterBorder,
                    BorderSizePixel = 0
                })
                
                local slider_slide_holder = library.create("Frame", {
                    Parent = slider_frame,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    BackgroundTransparency = 1
                })
                
                local slider_slide = library.create("Frame", {
                    Parent = slider_slide_holder,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = library.theme.Accent,
                    BorderSizePixel = 0
                })
                library.add_gradient(slider_slide, 90)
                
                local slider_value = library.create("TextLabel", {
                    Parent = slider_slide,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(1, 5, 0.5, 0),
                    Size = UDim2.new(0, 45, 0, 14),
                    BackgroundTransparency = 1,
                    Text = "",
                    FontFace = library.font,
                    TextSize = 10,
                    TextColor3 = library.theme.Text
                })
                
                local function sanitize(v)
                    if type(v) ~= "number" then v = slider.min end
                    v = math.clamp(v, slider.min, slider.max)
                    local mult = 10 ^ slider.decimals
                    return math.floor(v * mult + 0.5) / mult
                end
                
                local function format_value(v)
                    if slider.decimals <= 0 then return tostring(math.floor(v + 0.5)) .. slider.suffix end
                    return string.format("%." .. math.floor(slider.decimals) .. "f", v) .. slider.suffix
                end
                
                local function set_value(val)
                    if type(val) ~= "number" then val = slider.min end
                    slider.state = sanitize(val)
                    local percent = (slider.state - slider.min) / (slider.max - slider.min)
                    slider_slide.Size = UDim2.new(percent, 0, 1, 0)
                    slider_value.Text = format_value(slider.state)
                    slider_value.Position = UDim2.new(1, 5, 1, 0)
                    library.flags[flag] = slider.state
                    slider.callback(slider.state)
                end
                
                local input_changed_conn = nil
                local input_ended_conn = nil
                
                local function start_dragging()
                    slider.holding = true
                    
                    local function refresh_on_move(input)
                        if slider.holding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local mouse_pos = library.services.UserInputService:GetMouseLocation()
                            local holder_pos = slider_slide_holder.AbsolutePosition
                            local holder_size = slider_slide_holder.AbsoluteSize
                            if holder_pos and holder_size and holder_size.X > 0 then
                                local mouse_x = mouse_pos.X
                                local holder_left = holder_pos.X
                                local holder_right = holder_pos.X + holder_size.X
                                if mouse_x >= holder_left and mouse_x <= holder_right then
                                    local percent = math.clamp((mouse_x - holder_left) / holder_size.X, 0, 1)
                                    set_value(slider.min + (slider.max - slider.min) * percent)
                                end
                            end
                        end
                    end
                    
                    local function stop_dragging()
                        slider.holding = false
                        if input_changed_conn then input_changed_conn:Disconnect() input_changed_conn = nil end
                        if input_ended_conn then input_ended_conn:Disconnect() input_ended_conn = nil end
                    end
                    
                    local mouse_pos = library.services.UserInputService:GetMouseLocation()
                    local holder_pos = slider_slide_holder.AbsolutePosition
                    local holder_size = slider_slide_holder.AbsoluteSize
                    if holder_pos and holder_size and holder_size.X > 0 then
                        local mouse_x = mouse_pos.X
                        local holder_left = holder_pos.X
                        local holder_right = holder_pos.X + holder_size.X
                        if mouse_x >= holder_left and mouse_x <= holder_right then
                            local percent = math.clamp((mouse_x - holder_left) / holder_size.X, 0, 1)
                            set_value(slider.min + (slider.max - slider.min) * percent)
                        end
                    end
                    
                    input_changed_conn = library.services.UserInputService.InputChanged:Connect(refresh_on_move)
                    input_ended_conn = library.services.UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then stop_dragging() end
                    end)
                end
                
                slider_button.MouseButton1Down:Connect(start_dragging)
                set_value(slider.state)
                
                local element = {
                    set = set_value,
                    get = function() return slider.state end,
                    remove = function()
                        if input_changed_conn then input_changed_conn:Disconnect() end
                        if input_ended_conn then input_ended_conn:Disconnect() end
                        content_holder:Destroy()
                        update_section_height()
                    end
                }
                
                table.insert(section.elements, element)
                update_section_height()
                return element
            end

            function section:new_textbox(box_cfg)
                local info = box_cfg or {}
                local flag = info.flag or library.next_flag()
                
                local content_holder = library.create("Frame", {
                    Parent = content_frame,
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1
                })
                
                local textbox_title = library.create("TextLabel", {
                    Parent = content_holder,
                    Size = UDim2.new(1, -16, 0, 14),
                    Position = UDim2.new(0, 16, 0, 0),
                    BackgroundTransparency = 1,
                    Text = info.name or info.text or "new textbox",
                    FontFace = library.font,
                    TextSize = 12,
                    TextColor3 = library.theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local textbox = library.create("TextBox", {
                    Parent = content_holder,
                    Position = UDim2.new(0, 16, 0, 16),
                    Size = UDim2.new(1, -32, 0, 20),
                    BackgroundColor3 = library.theme.ObjectBg,
                    BorderSizePixel = 1,
                    BorderColor3 = library.theme.SectionOuterBorder,
                    Text = info.default or "",
                    PlaceholderText = info.placeholder or "...",
                    FontFace = library.font,
                    TextSize = 12,
                    TextColor3 = library.theme.Text,
                    ClearTextOnFocus = false
                })
                library.add_gradient(textbox, 90)
                
                textbox.FocusLost:Connect(function()
                    library.flags[flag] = textbox.Text
                    if info.callback then info.callback(textbox.Text) end
                end)
                
                local element = {
                    set = function(v) textbox.Text = v; library.flags[flag] = v end,
                    get = function() return textbox.Text end,
                    remove = function()
                        content_holder:Destroy()
                        update_section_height()
                    end
                }
                
                table.insert(section.elements, element)
                update_section_height()
                return element
            end

            function section:new_dropdown(drop_cfg)
                local cfg = {
                    name = drop_cfg.name or "Dropdown",
                    flag = drop_cfg.flag or library.next_flag(),
                    items = {},
                    option_instances = {},
                    selected = nil,
                    open = false,
                    callback = drop_cfg.callback or function() end
                }
                
                for _, v in ipairs(drop_cfg.options or {}) do
                    table.insert(cfg.items, v)
                end
                
                cfg.selected = drop_cfg.default or cfg.items[1] or "None"
                
                local content_holder = library.create("Frame", {
                    Parent = content_frame,
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1
                })
                
                local dropdown_title = library.create("TextLabel", {
                    Parent = content_holder,
                    Size = UDim2.new(1, -16, 0, 14),
                    Position = UDim2.new(0, 16, 0, 0),
                    BackgroundTransparency = 1,
                    Text = cfg.name,
                    FontFace = library.font,
                    TextSize = 12,
                    TextColor3 = library.theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local dropdown_button = library.create("TextButton", {
                    Parent = content_holder,
                    Position = UDim2.new(0, 16, 0, 16),
                    Size = UDim2.new(1, -32, 0, 20),
                    BackgroundColor3 = library.theme.ObjectBg,
                    BorderSizePixel = 1,
                    BorderColor3 = library.theme.SectionOuterBorder,
                    Text = "  " .. tostring(cfg.selected),
                    FontFace = library.font,
                    TextSize = 12,
                    TextColor3 = library.theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                library.add_gradient(dropdown_button, 90)
                
                local arrow = library.create("ImageLabel", {
                    Parent = dropdown_button,
                    Image = "rbxassetid://116204929609664",
                    Position = UDim2.new(1, -15, 0, 7),
                    Size = UDim2.new(0, 8, 0, 5),
                    BackgroundTransparency = 1,
                    ImageColor3 = library.theme.Text
                })
                
                local dropdown_frame = library.create("Frame", {
                    Parent = dropdown_button,
                    Position = UDim2.new(0, 0, 1, 2),
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = library.theme.ObjectBg,
                    BorderSizePixel = 1,
                    BorderColor3 = library.theme.SectionOuterBorder,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 10
                })
                
                local scroll = library.create("ScrollingFrame", {
                    Parent = dropdown_frame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 4,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0
                })
                
                local layout = library.create("UIListLayout", {
                    Parent = scroll,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 1)
                })
                
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
                end)
                
                local function refresh_options()
                    for _, v in ipairs(cfg.option_instances) do
                        if v and v.Parent then
                            v:Destroy()
                        end
                    end
                    
                    table.clear(cfg.option_instances)
                    
                    for _, opt in ipairs(cfg.items) do
                        local opt_btn = library.create("TextButton", {
                            Parent = scroll,
                            Size = UDim2.new(1, 0, 0, 20),
                            BackgroundColor3 = library.theme.ObjectBg,
                            BorderSizePixel = 0,
                            Text = "  " .. tostring(opt),
                            FontFace = library.font,
                            TextSize = 12,
                            TextColor3 = library.theme.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                            ZIndex = 11
                        })
                        
                        table.insert(cfg.option_instances, opt_btn)
                        
                        library.add_gradient(opt_btn, 90)
                        
                        if opt == cfg.selected then
                            library.create("Frame", {
                                Parent = opt_btn,
                                Size = UDim2.new(0, 3, 1, 0),
                                BackgroundColor3 = library.theme.Accent,
                                BorderSizePixel = 0
                            })
                        end
                        
                        local opt_value = opt
                        
                        opt_btn.MouseButton1Click:Connect(function()
                            cfg.selected = opt_value
                            dropdown_button.Text = "  " .. tostring(cfg.selected)
                            dropdown_frame.Visible = false
                            cfg.open = false
                            library.flags[cfg.flag] = cfg.selected
                            cfg.callback(cfg.selected)
                            refresh_options()
                        end)
                    end
                    
                    local height = math.min(#cfg.items * 21, 120)
                    dropdown_frame.Size = UDim2.new(1, 0, 0, height)
                end
                
                dropdown_button.MouseButton1Click:Connect(function()
                    cfg.open = not cfg.open
                    dropdown_frame.Visible = cfg.open
                    
                    if cfg.open then
                        refresh_options()
                    end
                end)
                
                refresh_options()
                library.flags[cfg.flag] = cfg.selected
                
                local element = {
                    set = function(v)
                        if table.find(cfg.items, v) then
                            cfg.selected = v
                            dropdown_button.Text = "  " .. tostring(cfg.selected)
                            library.flags[cfg.flag] = cfg.selected
                            cfg.callback(cfg.selected)
                            refresh_options()
                        end
                    end,
                    
                    get = function()
                        return cfg.selected
                    end,
                    
                    add = function(opt)
                        if table.find(cfg.items, opt) then
                            return
                        end
                        
                        table.insert(cfg.items, opt)
                        
                        if not cfg.selected or cfg.selected == "None" then
                            cfg.selected = opt
                            dropdown_button.Text = "  " .. tostring(cfg.selected)
                        end
                        
                        refresh_options()
                    end,
                    
                    remove = function(opt)
                        local idx = table.find(cfg.items, opt)
                        
                        if idx then
                            table.remove(cfg.items, idx)
                            
                            if cfg.selected == opt then
                                cfg.selected = cfg.items[1] or "None"
                                dropdown_button.Text = "  " .. tostring(cfg.selected)
                                library.flags[cfg.flag] = cfg.selected
                            end
                            
                            refresh_options()
                        end
                    end,
                    
                    refresh = function(new_items)
                        cfg.items = {}
                        
                        for _, opt in ipairs(new_items or {}) do
                            if not table.find(cfg.items, opt) then
                                table.insert(cfg.items, opt)
                            end
                        end
                        
                        cfg.selected = cfg.items[1] or "None"
                        dropdown_button.Text = "  " .. tostring(cfg.selected)
                        library.flags[cfg.flag] = cfg.selected
                        
                        refresh_options()
                    end,
                    
                    remove_self = function()
                        content_holder:Destroy()
                        update_section_height()
                    end
                }
                
                table.insert(section.elements, element)
                update_section_height()
                
                return element
            end
function section:new_listbox(lcfg)
    local flag = lcfg.flag or library.next_flag()
    local options = lcfg.options or {}
    local current = lcfg.default or ""
    local list_height = lcfg.height or 100

    local holder = library.create("Frame", {
        Parent = content_frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, list_height + 20),
        ZIndex = 15
    })
    
    library.create("TextLabel", {
        Parent = holder,
        Text = lcfg.name,
        TextColor3 = library.theme.Text,
        TextSize = 13,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 13),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = library.font
    })

    local background = library.create("ScrollingFrame", {
        Parent = holder,
        BackgroundColor3 = library.theme.ObjectBg,
        Size = UDim2.new(1, 0, 0, list_height),
        Position = UDim2.new(0, 0, 0, 18),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = library.theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 16
    })
    library.outline(background, library.theme.SectionInnerBorder, 1)
    library.add_gradient(background, 90)
    
    local list_layout = library.create("UIListLayout", {
        Parent = background,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })

    local function update_val(val)
        current = val
        library.flags[flag] = val
        if lcfg.callback then lcfg.callback(val) end
    end

    local function build()
        for _, v in pairs(background:GetChildren()) do
            if v:IsA("TextButton") then
                v:Destroy()
            end
        end
        
        for _, opt in pairs(options) do
            local btn = library.create("TextButton", {
                Parent = background,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundColor3 = library.theme.PageSelected,
                BackgroundTransparency = (current == opt) and 0.8 or 1,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 17
            })
            
            local txt = library.create("TextLabel", {
                Parent = btn,
                Text = tostring(opt),
                TextColor3 = (current == opt) and library.theme.Accent or library.theme.Text,
                TextSize = 12,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0, 0),
                Size = UDim2.new(1, -5, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = library.font,
                ZIndex = 18
            })

            btn.MouseButton1Click:Connect(function()
                for _, child in pairs(background:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundTransparency = 1
                        if child.TextLabel then
                            child.TextLabel.TextColor3 = library.theme.Text
                        end
                    end
                end
                btn.BackgroundTransparency = 0.8
                txt.TextColor3 = library.theme.Accent
                update_val(opt)
            end)
        end
        background.CanvasSize = UDim2.new(0, 0, 0, list_layout.AbsoluteContentSize.Y)
    end

    build()
    if current ~= "" then update_val(current) end

    local list_methods = {}
    
    function list_methods:refresh(new_options)
        options = new_options or {}
        build()
    end

    function list_methods:add(val)
        local found = false
        for _, v in pairs(options) do
            if v == val then
                found = true
                break
            end
        end
        if not found then
            table.insert(options, val)
            build()
        end
    end

    function list_methods:remove(val)
        for i, v in pairs(options) do
            if v == val then
                table.remove(options, i)
                if current == val then
                    current = ""
                end
                build()
                break
            end
        end
    end

    function list_methods:set(val)
        current = val
        build()
        update_val(val)
    end

    return list_methods
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
    for flag, value in pairs(config_data) do        if library.flags[flag] ~= nil then
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

return library
