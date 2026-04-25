local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ContextActionService = game:GetService("ContextActionService")

local localPlayer = Players.LocalPlayer

local function clamp(val, min, max) return math.max(min, math.min(max, val)) end
local function lerp(a, b, t) return a + (b - a) * t end
local function newUDim2(xs, xo, ys, yo) return UDim2.new(xs, xo, ys, yo) end

local library = {
    windows = {},
    flags = {},
    options = {},
    connections = {},
    notifications = {},
    theme = {},
    cheatname = "octohook",
    gamename = "universal",
    fileext = ".txt",
    directory = "octohook",
    open = false,
    hasInit = false,
    draggingSlider = nil,
    CurrentTooltip = nil,
    stats = { fps = 0, ping = 0 },
    zindex = {
        window = 1000,
        dropdown = 1200,
        colorpicker = 1100,
        watermark = 1300,
        notification = 1400,
        tooltip = 1500,
    }
}

if not isfolder(library.directory) then makefolder(library.directory) end
if not isfolder(library.directory .. "/fonts") then makefolder(library.directory .. "/fonts") end

local fontPath = library.directory .. "/fonts/main.ttf"
local fontJsonPath = library.directory .. "/fonts/main_encoded.ttf"

if not isfile(fontPath) then
    writefile(fontPath, game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/fs-tahoma-8px.ttf"))
end

local tahoma = {
    name = "SmallestPixel7",
    faces = {
        {
            name = "Regular",
            weight = 400,
            style = "normal",
            assetId = getcustomasset(fontPath)
        }
    }
}

if not isfile(fontJsonPath) then
    writefile(fontJsonPath, HttpService:JSONEncode(tahoma))
end

local customFontData = HttpService:JSONDecode(readfile(fontJsonPath))
local customFont = Font.new(customFontData, Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local function create(class, properties)
    local obj = Instance.new(class)
    for prop, val in pairs(properties or {}) do
        obj[prop] = val
    end
    return obj
end

local function applyGradient(obj, rotation)
    local gradient = create("UIGradient", {
        Rotation = rotation or 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(155, 155, 155))
        }
    })
    gradient.Parent = obj
    return gradient
end

local screenGui = create("ScreenGui", {
    Name = "OctohookUI",
    ResetOnSpawn = false,
    Parent = CoreGui
})
if syn then syn.protect_gui(screenGui) end

local mainContainer = create("Frame", {
    Name = "MainContainer",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Visible = false,
    Parent = screenGui
})

local tooltipFrame = create("Frame", {
    Name = "Tooltip",
    Size = UDim2.new(0, 100, 0, 20),
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    BorderColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 1,
    Visible = false,
    ZIndex = library.zindex.tooltip,
    Parent = screenGui
})

local tooltipText = create("TextLabel", {
    Name = "Text",
    Size = UDim2.new(1, -6, 1, 0),
    Position = UDim2.new(0, 3, 0, 2),
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(235, 235, 235),
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    FontFace = customFont,
    Parent = tooltipFrame
})

local watermarkFrame = create("Frame", {
    Name = "Watermark",
    Size = UDim2.new(0, 200, 0, 20),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = library.zindex.watermark,
    Parent = screenGui
})

local watermarkBorder1 = create("Frame", {
    Size = UDim2.new(1, 2, 1, 2),
    Position = UDim2.new(0, -1, 0, -1),
    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
    BorderSizePixel = 0,
    Parent = watermarkFrame
})

local watermarkBorder2 = create("Frame", {
    Size = UDim2.new(1, 2, 1, 2),
    Position = UDim2.new(0, -1, 0, -1),
    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    BorderSizePixel = 0,
    Parent = watermarkBorder1
})

local watermarkTopBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Color3.fromRGB(255, 135, 255),
    BorderSizePixel = 0,
    Parent = watermarkFrame
})

local watermarkText = create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 2),
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(235, 235, 235),
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Center,
    FontFace = customFont,
    Parent = watermarkFrame
})

local keyIndicatorFrame = create("Frame", {
    Name = "KeyIndicator",
    Size = UDim2.new(0, 200, 0, 16),
    Position = UDim2.new(0, 15, 0, 300),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = library.zindex.watermark - 50,
    Parent = screenGui
})

local keyIndicatorBorder1 = create("Frame", {
    Size = UDim2.new(1, 2, 1, 2),
    Position = UDim2.new(0, -1, 0, -1),
    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
    BorderSizePixel = 0,
    Parent = keyIndicatorFrame
})

local keyIndicatorBorder2 = create("Frame", {
    Size = UDim2.new(1, 2, 1, 2),
    Position = UDim2.new(0, -1, 0, -1),
    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    BorderSizePixel = 0,
    Parent = keyIndicatorBorder1
})

local keyIndicatorTopBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Color3.fromRGB(255, 135, 255),
    BorderSizePixel = 0,
    Parent = keyIndicatorFrame
})

local keyIndicatorTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 1),
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(235, 235, 235),
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Center,
    FontFace = customFont,
    Text = "Keybinds",
    Parent = keyIndicatorFrame
})

local keyIndicatorContent = create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    Position = UDim2.new(0, 0, 0, 16),
    BackgroundTransparency = 1,
    Parent = keyIndicatorFrame
})

function library:NewWindow(data)
    local window = {
        title = data.title or "",
        tabs = {},
        objects = {},
        open = true,
        colorpicker = { objects = {}, color = Color3.new(1, 0, 0), trans = 0, selected = nil },
        dropdown = { objects = {}, selected = nil, max = 5 }
    }
    
    table.insert(library.windows, window)
    
    local size = data.size or UDim2.new(0, 525, 0, 650)
    local position = data.position or UDim2.new(0, 250, 0, 150)
    local z = library.zindex.window
    
    local background = create("Frame", {
        Size = size,
        Position = position,
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        ZIndex = z,
        Parent = mainContainer
    })
    
    local innerBorder1 = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 0,
        ZIndex = z - 1,
        Parent = background
    })
    
    local innerBorder2 = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        ZIndex = z - 2,
        Parent = innerBorder1
    })
    
    local midBorder = create("Frame", {
        Size = UDim2.new(1, 10, 1, 25),
        Position = UDim2.new(0, -5, 0, -20),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        ZIndex = z - 3,
        Parent = innerBorder2
    })
    
    local outerBorder1 = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        ZIndex = z - 4,
        Parent = midBorder
    })
    
    local outerBorder2 = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 0,
        ZIndex = z - 5,
        Parent = outerBorder1
    })
    
    local topBorder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 135, 255),
        BorderSizePixel = 0,
        ZIndex = z + 1,
        Parent = background
    })
    
    local title = create("TextLabel", {
        Position = UDim2.new(0, 7, 0, 2),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(235, 235, 235),
        TextSize = 13,
        FontFace = customFont,
        Text = window.title,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = z + 1,
        Parent = midBorder
    })
    
    local groupBackground = create("Frame", {
        Size = UDim2.new(1, -16, 1, -(16 + 23)),
        Position = UDim2.new(0, 8, 0, 8 + 23),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        ZIndex = z + 5,
        Parent = background
    })
    
    local groupInnerBorder = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        ZIndex = z + 4,
        Parent = groupBackground
    })
    
    local groupOuterBorder = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 0,
        ZIndex = z + 3,
        Parent = groupInnerBorder
    })
    
    local tabHolder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, -21),
        BackgroundTransparency = 1,
        ZIndex = z + 1,
        Parent = groupBackground
    })
    
    local columnholder1 = create("Frame", {
        Size = UDim2.new(0.48, 0, 0.96, 0),
        Position = UDim2.new(0.01, 0, 0.02, 0),
        BackgroundTransparency = 1,
        ZIndex = z + 6,
        Parent = groupBackground
    })
    
    local columnholder2 = create("Frame", {
        Size = UDim2.new(0.48, 0, 0.96, 0),
        Position = UDim2.new(1 - (0.48 + 0.01), 0, 0.02, 0),
        BackgroundTransparency = 1,
        ZIndex = z + 6,
        Parent = groupBackground
    })
    
    local dragdetector = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = z + 2,
        Parent = midBorder
    })
    
    local dragging = false
    local dragStart
    local objStart
    
    local function onDragStart(pos)
        dragging = true
        dragStart = UDim2.new(0, pos.X, 0, pos.Y)
        objStart = background.Position
    end
    
    local function onDragEnd()
        dragging = false
    end
    
    local function onDragMove(pos)
        if dragging and window.open then
            background.Position = objStart + UDim2.new(0, pos.X, 0, pos.Y) - dragStart
        else
            dragging = false
        end
    end
    
    dragdetector.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and window.open then
            onDragStart(UserInputService:GetMouseLocation())
        end
    end)
    
    dragdetector.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onDragEnd()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            onDragMove(UserInputService:GetMouseLocation())
        end
    end)
    
    local dropdownBackground = create("Frame", {
        Visible = false,
        Size = UDim2.new(1, -3, 0, 50),
        Position = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        ZIndex = library.zindex.dropdown,
        Parent = background
    })
    
    local dropdownBorder1 = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = library.zindex.dropdown - 1,
        Parent = dropdownBackground
    })
    
    local dropdownBorder2 = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        ZIndex = library.zindex.dropdown - 2,
        Parent = dropdownBorder1
    })
    
    local dropdownBorder3 = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = library.zindex.dropdown - 3,
        Parent = dropdownBorder2
    })
    
    local dropdownScroll = create("ScrollingFrame", {
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Color3.fromRGB(255, 135, 255),
        ZIndex = library.zindex.dropdown,
        Parent = dropdownBackground
    })
    
    local dropdownList = create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dropdownScroll
    })
    
    local colorpickerBackground = create("Frame", {
        Visible = false,
        Size = UDim2.new(0, 200, 0, 242),
        Position = UDim2.new(1, -200, 1, 10),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        ZIndex = library.zindex.colorpicker,
        Parent = background
    })
    
    local colorpickerBorder1 = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = library.zindex.colorpicker - 1,
        Parent = colorpickerBackground
    })
    
    local colorpickerBorder2 = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        ZIndex = library.zindex.colorpicker - 2,
        Parent = colorpickerBorder1
    })
    
    local colorpickerBorder3 = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = library.zindex.colorpicker - 3,
        Parent = colorpickerBorder2
    })
    
    local colorpickerStatus = create("TextLabel", {
        Position = UDim2.new(0, 5, 0, 4),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(245, 245, 245),
        TextSize = 13,
        FontFace = customFont,
        Text = "colorpicker_status_text",
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = library.zindex.colorpicker + 1,
        Parent = colorpickerBackground
    })
    
    local colorpickerMain = create("Frame", {
        Size = UDim2.new(0, 175, 0, 175),
        Position = UDim2.new(0, 5, 0, 25),
        BackgroundColor3 = Color3.new(1, 0, 0),
        BorderSizePixel = 0,
        ZIndex = library.zindex.colorpicker + 2,
        Parent = colorpickerBackground
    })
    
    local colorpickerMainBorder = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = library.zindex.colorpicker + 1,
        Parent = colorpickerMain
    })
    
    local colorpickerSatOverlay = create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxassetid://4155751252",
        BackgroundTransparency = 1,
        ZIndex = library.zindex.colorpicker + 3,
        Parent = colorpickerMain
    })
    
    local colorpickerHue = create("ImageLabel", {
        Size = UDim2.new(0, 175, 0, 10),
        Position = UDim2.new(0, 5, 0, 205),
        Image = "rbxassetid://4155807220",
        BackgroundTransparency = 1,
        ZIndex = library.zindex.colorpicker + 2,
        Parent = colorpickerBackground
    })
    
    local colorpickerHueBorder = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = library.zindex.colorpicker + 1,
        Parent = colorpickerHue
    })
    
    local colorpickerTrans = create("Frame", {
        Size = UDim2.new(0, 10, 0, 175),
        Position = UDim2.new(0, 185, 0, 25),
        BackgroundColor3 = Color3.new(1, 0, 0),
        BorderSizePixel = 0,
        ZIndex = library.zindex.colorpicker + 2,
        Parent = colorpickerBackground
    })
    
    local colorpickerTransBorder = create("Frame", {
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = library.zindex.colorpicker + 1,
        Parent = colorpickerTrans
    })
    
    local colorpickerTransOverlay = create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxassetid://4155808427",
        BackgroundTransparency = 1,
        ZIndex = library.zindex.colorpicker + 3,
        Parent = colorpickerTrans
    })
    
    local colorpickerPointer = create("Frame", {
        Size = UDim2.new(0, 4, 0, 4),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = library.zindex.colorpicker + 6,
        Parent = colorpickerMain
    })
    
    local colorpickerHueSlider = create("Frame", {
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = library.zindex.colorpicker + 4,
        Parent = colorpickerHue
    })
    
    local colorpickerTransSlider = create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = library.zindex.colorpicker + 5,
        Parent = colorpickerTrans
    })
    
    local colorpickerR = create("Frame", {
        Size = UDim2.new(0, 56, 0, 15),
        Position = UDim2.new(0, 5, 1, -20),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = library.zindex.colorpicker + 5,
        Parent = colorpickerBackground
    })
    
    local colorpickerRText = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 50, 50),
        TextSize = 13,
        FontFace = customFont,
        Text = "R",
        ZIndex = library.zindex.colorpicker + 6,
        Parent = colorpickerR
    })
    
    local colorpickerG = create("Frame", {
        Size = UDim2.new(0, 56, 0, 15),
        Position = UDim2.new(0, 66, 1, -20),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = library.zindex.colorpicker + 5,
        Parent = colorpickerBackground
    })
    
    local colorpickerGText = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(50, 255, 50),
        TextSize = 13,
        FontFace = customFont,
        Text = "G",
        ZIndex = library.zindex.colorpicker + 6,
        Parent = colorpickerG
    })
    
    local colorpickerB = create("Frame", {
        Size = UDim2.new(0, 56, 0, 15),
        Position = UDim2.new(0, 127, 1, -20),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = library.zindex.colorpicker + 5,
        Parent = colorpickerBackground
    })
    
    local colorpickerBText = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(50, 50, 255),
        TextSize = 13,
        FontFace = customFont,
        Text = "B",
        ZIndex = library.zindex.colorpicker + 6,
        Parent = colorpickerB
    })
    
    window.objects = {
        background = background,
        title = title,
        groupBackground = groupBackground,
        tabHolder = tabHolder,
        columnholder1 = columnholder1,
        columnholder2 = columnholder2
    }
    
    window.dropdown.objects = {
        background = dropdownBackground,
        scroll = dropdownScroll,
        list = dropdownList
    }
    
    window.colorpicker.objects = {
        background = colorpickerBackground,
        statusText = colorpickerStatus,
        mainColor = colorpickerMain,
        satOverlay = colorpickerSatOverlay,
        hue = colorpickerHue,
        trans = colorpickerTrans,
        transOverlay = colorpickerTransOverlay,
        pointer = colorpickerPointer,
        hueSlider = colorpickerHueSlider,
        transSlider = colorpickerTransSlider,
        r = colorpickerR,
        g = colorpickerG,
        b = colorpickerB
    }
    
    function window:SetOpen(bool)
        window.open = bool
        background.Visible = bool
        if not bool then
            dropdownBackground.Visible = false
            colorpickerBackground.Visible = false
            if library.dropdownSelected == window.dropdown then
                library.dropdownSelected = nil
            end
            if library.colorpickerSelected == window.colorpicker then
                library.colorpickerSelected = nil
            end
        end
    end
    
    function window:UpdateTabs()
        local offset = 0
        for _, tab in ipairs(window.tabs) do
            local tabObj = tab.objects.background
            local selected = tab == window.selectedTab
            tabObj.Size = UDim2.new(0, tab.objects.text.TextBounds.X + 14, 1, 0)
            tabObj.Position = UDim2.new(0, offset, 0, 0)
            tabObj.BackgroundColor3 = selected and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(18, 18, 18)
            tab.objects.topBar.BackgroundColor3 = selected and Color3.fromRGB(255, 135, 255) or Color3.fromRGB(18, 18, 18)
            tab.objects.text.TextColor3 = selected and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(145, 145, 145)
            offset = offset + tabObj.Size.X.Offset + 1
            tab:UpdateSections()
        end
    end
    
    function window:AddTab(text, order)
        local tab = {
            text = text,
            order = order or #window.tabs + 1,
            sections = {},
            objects = {},
            selected = false
        }
        
        local background = create("Frame", {
            Size = UDim2.new(0, 50, 1, 0),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BorderSizePixel = 0,
            ZIndex = library.zindex.window + 5,
            Parent = tabHolder
        })
        
        local innerBorder = create("Frame", {
            Size = UDim2.new(1, 2, 1, 2),
            Position = UDim2.new(0, -1, 0, -1),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            BorderSizePixel = 0,
            ZIndex = library.zindex.window + 4,
            Parent = background
        })
        
        local outerBorder = create("Frame", {
            Size = UDim2.new(1, 2, 1, 2),
            Position = UDim2.new(0, -1, 0, -1),
            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
            BorderSizePixel = 0,
            ZIndex = library.zindex.window + 3,
            Parent = innerBorder
        })
        
        local topBar = create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BorderSizePixel = 0,
            ZIndex = library.zindex.window + 6,
            Parent = background
        })
        
        local text = create("TextLabel", {
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(145, 145, 145),
            TextSize = 13,
            FontFace = customFont,
            Text = text,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = library.zindex.window + 6,
            Position = UDim2.new(0.5, 0, 0, 3),
            Parent = background
        })
        
        
        text.Size = UDim2.new(0, text.TextBounds.X, 0, text.TextBounds.Y)
        
        tab.objects = {
            background = background,
            topBar = topBar,
            text = text
        }
        
        function tab:UpdateSections()
            local last1 = nil
            local last2 = nil
            local padding = 15
            for _, section in ipairs(tab.sections) do
                if section.enabled and tab.selected then
                    section.objects.background.Visible = true
                    if section.side == 1 then
                        if last1 then
                            section.objects.background.Position = UDim2.new(0, 0, 0, last1.objects.background.Position.Y.Offset + last1.objects.background.Size.Y.Offset + padding)
                        else
                            section.objects.background.Position = UDim2.new(0, 0, 0, 0)
                        end
                        last1 = section
                    else
                        if last2 then
                            section.objects.background.Position = UDim2.new(0, 0, 0, last2.objects.background.Position.Y.Offset + last2.objects.background.Size.Y.Offset + padding)
                        else
                            section.objects.background.Position = UDim2.new(0, 0, 0, 0)
                        end
                        last2 = section
                    end
                else
                    section.objects.background.Visible = false
                end
                section:UpdateOptions()
            end
        end
        
        function tab:Select()
            window.selectedTab = tab
            for _, t in ipairs(window.tabs) do
                t.selected = t == tab
            end
            window:UpdateTabs()
        end
        
        function tab:AddSection(text, side, order)
            local section = {
                text = text,
                side = side or 1,
                order = order or #tab.sections + 1,
                enabled = true,
                options = {},
                objects = {}
            }
            
            local column = side == 1 and columnholder1 or columnholder2
            
            local background = create("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                BorderSizePixel = 0,
                ZIndex = library.zindex.window + 15,
                Parent = column
            })
            
            local innerBorder = create("Frame", {
                Size = UDim2.new(1, 2, 1, 1),
                Position = UDim2.new(0, -1, 0, 0),
                BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                BorderSizePixel = 0,
                ZIndex = library.zindex.window + 14,
                Parent = background
            })
            
            local outerBorder = create("Frame", {
                Size = UDim2.new(1, 2, 1, 1),
                Position = UDim2.new(0, -1, 0, 0),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 0,
                ZIndex = library.zindex.window + 13,
                Parent = innerBorder
            })
            
            local topBorder1 = create("Frame", {
                Size = UDim2.new(0.025, 1, 0, 1),
                Position = UDim2.new(0, -1, 0, 0),
                BackgroundColor3 = Color3.fromRGB(255, 135, 255),
                BorderSizePixel = 0,
                ZIndex = library.zindex.window + 16,
                Parent = background
            })
            
            local topBorder2 = create("Frame", {
                Size = UDim2.new(0, 100, 0, 1),
                Position = UDim2.new(1, 1, 0, 0),
                BackgroundColor3 = Color3.fromRGB(255, 135, 255),
                BorderSizePixel = 0,
                ZIndex = library.zindex.window + 16,
                Parent = background
            })
            
            local textLabel = create("TextLabel", {
                Position = UDim2.new(0.0425, 0, 0, -7),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(235, 235, 235),
                TextSize = 13,
                FontFace = customFont,
                Text = text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = library.zindex.window + 16,
                Parent = background
            })
            
            local optionHolder = create("Frame", {
                Size = UDim2.new(1 - 0.03, 0, 1, -15),
                Position = UDim2.new(0.015, 0, 0, 13),
                BackgroundTransparency = 1,
                ZIndex = library.zindex.window + 16,
                Parent = background
            })
            
            local optionList = create("UIListLayout", {
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optionHolder
            })
            
            section.objects = {
                background = background,
                textLabel = textLabel,
                optionHolder = optionHolder,
                optionList = optionList,
                topBorder2 = topBorder2
            }
            
            function section:SetText(txt)
                section.text = txt
                textLabel.Text = txt
                local x = background.Size.X.Offset - textLabel.TextBounds.X - 13
                topBorder2.Size = UDim2.new(0, x, 0, 1)
                topBorder2.Position = UDim2.new(1, 1 - x, 0, 0)
            end
            
            function section:UpdateOptions()
                local height = 0
                for _, opt in ipairs(section.options) do
                    if opt.enabled then
                        opt.objects.holder.Visible = true
                        height = height + opt.objects.holder.Size.Y.Offset + 2
                    else
                        opt.objects.holder.Visible = false
                    end
                end
                background.Size = UDim2.new(1, 0, 0, math.max(50, height + 20))
                optionHolder.Size = UDim2.new(1 - 0.03, 0, 1, -15)
            end
            
            function section:SetEnabled(bool)
                section.enabled = bool
                tab:UpdateSections()
            end
            
            function section:AddToggle(data)
                local toggle = {
                    class = "toggle",
                    flag = data.flag,
                    text = data.text or "",
                    tooltip = data.tooltip or "",
                    state = data.state or false,
                    risky = data.risky or false,
                    callback = data.callback or function() end,
                    enabled = true,
                    order = #section.options + 1,
                    objects = {}
                }
                
                local holder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 17),
                    BackgroundTransparency = 1,
                    ZIndex = library.zindex.window + 25,
                    Parent = optionHolder
                })
                
                local background = create("Frame", {
                    Size = UDim2.new(0, 8, 0, 8),
                    Position = UDim2.new(0, 2, 0, 4),
                    BackgroundColor3 = toggle.state and Color3.fromRGB(255, 135, 255) or Color3.fromRGB(35, 35, 35),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 23,
                    Parent = holder
                })
                
                applyGradient(background, 45)
                background.UIGradient.Transparency = NumberSequence.new(0.25)
                
                local border1 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = toggle.state and Color3.fromRGB(255, 135, 255) or Color3.fromRGB(50, 50, 50),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 22,
                    Parent = background
                })
                
                local border2 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 21,
                    Parent = border1
                })
                
                local text = create("TextLabel", {
                    Position = UDim2.new(0, 19, 0, 1),
                    Size = UDim2.new(1, -19, 1, -2),
                    BackgroundTransparency = 1,
                    TextColor3 = toggle.state and (toggle.risky and Color3.fromRGB(255, 41, 41) or Color3.fromRGB(245, 245, 245)) or (toggle.risky and Color3.fromRGB(175, 21, 21) or Color3.fromRGB(145, 145, 145)),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = toggle.text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = library.zindex.window + 26,
                    Parent = holder
                })
                
                toggle.objects = {
                    holder = holder,
                    background = background,
                    border1 = border1,
                    text = text
                }
                
                function toggle:SetState(bool, nocallback)
                    toggle.state = bool
                    if toggle.flag then
                        library.flags[toggle.flag] = bool
                    end
                    background.BackgroundColor3 = bool and Color3.fromRGB(255, 135, 255) or Color3.fromRGB(35, 35, 35)
                    border1.BackgroundColor3 = bool and Color3.fromRGB(255, 135, 255) or Color3.fromRGB(50, 50, 50)
                    text.TextColor3 = bool and (toggle.risky and Color3.fromRGB(255, 41, 41) or Color3.fromRGB(245, 245, 245)) or (toggle.risky and Color3.fromRGB(175, 21, 21) or Color3.fromRGB(145, 145, 145))
                    if not nocallback then
                        toggle.callback(bool)
                    end
                end
                
                function toggle:SetText(txt)
                    toggle.text = txt
                    text.Text = txt
                end
                
                holder.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        toggle:SetState(not toggle.state)
                    end
                end)
                
                holder.MouseEnter:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(255, 135, 255)
                end)
                
                holder.MouseLeave:Connect(function()
                    border1.BackgroundColor3 = toggle.state and Color3.fromRGB(255, 135, 255) or Color3.fromRGB(50, 50, 50)
                end)
                
                if toggle.tooltip and toggle.tooltip ~= "" then
                    holder.MouseEnter:Connect(function()
                        tooltipFrame.Visible = true
                        tooltipText.Text = toggle.tooltip
                        local pos = UserInputService:GetMouseLocation()
                        tooltipFrame.Position = UDim2.new(0, pos.X + 15, 0, pos.Y + 15)
                        tooltipFrame.Size = UDim2.new(0, tooltipText.TextBounds.X + 10, 0, 20)
                        library.CurrentTooltip = toggle
                    end)
                    holder.MouseLeave:Connect(function()
                        if library.CurrentTooltip == toggle then
                            tooltipFrame.Visible = false
                            library.CurrentTooltip = nil
                        end
                    end)
                end
                
                table.insert(section.options, toggle)
                if toggle.flag then
                    library.options[toggle.flag] = toggle
                end
                toggle:SetText(toggle.text)
                toggle:SetState(toggle.state, true)
                section:UpdateOptions()
                return toggle
            end
            
            function section:AddSlider(data)
                local slider = {
                    class = "slider",
                    flag = data.flag,
                    text = data.text or "",
                    suffix = data.suffix or "",
                    min = data.min or 0,
                    max = data.max or 100,
                    value = data.value or 0,
                    increment = data.increment or 1,
                    risky = data.risky or false,
                    callback = data.callback or function() end,
                    enabled = true,
                    order = #section.options + 1,
                    objects = {}
                }
                
                local holder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    ZIndex = library.zindex.window + 25,
                    Parent = optionHolder
                })
                
                local text = create("TextLabel", {
                    Position = UDim2.new(0, 2, 0, 1),
                    Size = UDim2.new(1, -4, 0, 14),
                    BackgroundTransparency = 1,
                    TextColor3 = slider.risky and Color3.fromRGB(175, 21, 21) or Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = slider.text .. ": " .. slider.value .. slider.suffix,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = library.zindex.window + 26,
                    Parent = holder
                })
                
                local bg = create("Frame", {
                    Size = UDim2.new(1, -4, 0, 11),
                    Position = UDim2.new(0, 2, 1, -14),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 22,
                    Parent = holder
                })
                
                applyGradient(bg, 90)
                bg.UIGradient.Transparency = NumberSequence.new(0.65)
                
                local border1 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 21,
                    Parent = bg
                })
                
                local border2 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 20,
                    Parent = border1
                })
                
                local fill = create("Frame", {
                    Size = UDim2.new((slider.value - slider.min) / (slider.max - slider.min), 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 135, 255),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 23,
                    Parent = bg
                })
                
                local minus = create("TextButton", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(1, -28, 0, 1),
                    BackgroundTransparency = 1,
                    Text = "-",
                    TextColor3 = Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    ZIndex = library.zindex.window + 26,
                    Parent = holder
                })
                
                local plus = create("TextButton", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(1, -14, 0, 1),
                    BackgroundTransparency = 1,
                    Text = "+",
                    TextColor3 = Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    ZIndex = library.zindex.window + 26,
                    Parent = holder
                })
                
                slider.objects = {
                    holder = holder,
                    text = text,
                    bg = bg,
                    fill = fill,
                    border1 = border1,
                    minus = minus,
                    plus = plus
                }
                
                function slider:SetValue(val, nocallback)
                    local newVal = clamp(math.floor(val / slider.increment) * slider.increment, slider.min, slider.max)
                    slider.value = newVal
                    if slider.flag then
                        library.flags[slider.flag] = newVal
                    end
                    fill.Size = UDim2.new((newVal - slider.min) / (slider.max - slider.min), 0, 1, 0)
                    text.Text = slider.text .. ": " .. newVal .. slider.suffix
                    local isMin = newVal == slider.min
                    text.TextColor3 = (slider.risky and isMin) and Color3.fromRGB(175, 21, 21) or (slider.risky and Color3.fromRGB(255, 41, 41)) or (isMin and Color3.fromRGB(145, 145, 145) or Color3.fromRGB(245, 245, 245))
                    if not nocallback then
                        slider.callback(newVal)
                    end
                end
                
                minus.MouseButton1Click:Connect(function()
                    slider:SetValue(slider.value - slider.increment)
                end)
                
                plus.MouseButton1Click:Connect(function()
                    slider:SetValue(slider.value + slider.increment)
                end)
                
                local dragging = false
                bg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        library.draggingSlider = slider
                        local relX = UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X
                        local val = slider.min + (relX / bg.AbsoluteSize.X) * (slider.max - slider.min)
                        slider:SetValue(val)
                    end
                end)
                
                bg.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        library.draggingSlider = nil
                    end
                end)
                
                bg.MouseEnter:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(255, 135, 255)
                end)
                
                bg.MouseLeave:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and library.draggingSlider == slider then
                        local relX = UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X
                        local val = slider.min + (relX / bg.AbsoluteSize.X) * (slider.max - slider.min)
                        slider:SetValue(val)
                    end
                end)
                
                if slider.tooltip and slider.tooltip ~= "" then
                    holder.MouseEnter:Connect(function()
                        tooltipFrame.Visible = true
                        tooltipText.Text = slider.tooltip
                        local pos = UserInputService:GetMouseLocation()
                        tooltipFrame.Position = UDim2.new(0, pos.X + 15, 0, pos.Y + 15)
                        tooltipFrame.Size = UDim2.new(0, tooltipText.TextBounds.X + 10, 0, 20)
                        library.CurrentTooltip = slider
                    end)
                    holder.MouseLeave:Connect(function()
                        if library.CurrentTooltip == slider then
                            tooltipFrame.Visible = false
                            library.CurrentTooltip = nil
                        end
                    end)
                end
                
                table.insert(section.options, slider)
                if slider.flag then
                    library.options[slider.flag] = slider
                end
                slider:SetValue(slider.value, true)
                section:UpdateOptions()
                return slider
            end
            
            function section:AddButton(data)
                local button = {
                    class = "button",
                    flag = data.flag,
                    text = data.text or "",
                    tooltip = data.tooltip or "",
                    confirm = data.confirm or false,
                    risky = data.risky or false,
                    callback = data.callback or function() end,
                    enabled = true,
                    order = #section.options + 1,
                    objects = {},
                    subbuttons = {}
                }
                
                local holder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    ZIndex = library.zindex.window + 25,
                    Parent = optionHolder
                })
                
                local bg = create("Frame", {
                    Size = UDim2.new(1, -4, 0, 14),
                    Position = UDim2.new(0, 2, 0, 4),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 22,
                    Parent = holder
                })
                
                applyGradient(bg, 90)
                bg.UIGradient.Transparency = NumberSequence.new(0.65)
                
                local border1 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 21,
                    Parent = bg
                })
                
                local border2 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 20,
                    Parent = border1
                })
                
                local text = create("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = button.risky and Color3.fromRGB(175, 21, 21) or Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = button.text,
                    ZIndex = library.zindex.window + 26,
                    Parent = bg
                })
                
                button.objects = {
                    holder = holder,
                    bg = bg,
                    border1 = border1,
                    text = text
                }
                
                local confirmState = false
                local confirmThread = nil
                
                bg.MouseButton1Click:Connect(function()
                    if button.confirm then
                        if confirmState then
                            if confirmThread then
                                coroutine.close(confirmThread)
                            end
                            confirmState = false
                            text.Text = button.text
                            text.TextColor3 = button.risky and Color3.fromRGB(175, 21, 21) or Color3.fromRGB(145, 145, 145)
                            button.callback()
                        else
                            confirmState = true
                            text.Text = "Confirm " .. button.text .. "? 3"
                            confirmThread = coroutine.create(function()
                                for i = 3, 1, -1 do
                                    task.wait(1)
                                    if not confirmState then break end
                                    text.Text = "Confirm " .. button.text .. "? " .. i
                                end
                                if confirmState then
                                    confirmState = false
                                    text.Text = button.text
                                    text.TextColor3 = button.risky and Color3.fromRGB(175, 21, 21) or Color3.fromRGB(145, 145, 145)
                                end
                            end)
                            coroutine.resume(confirmThread)
                        end
                    else
                        button.callback()
                    end
                end)
                
                bg.MouseEnter:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(255, 135, 255)
                    text.TextColor3 = button.risky and Color3.fromRGB(255, 41, 41) or Color3.fromRGB(245, 245, 245)
                end)
                
                bg.MouseLeave:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    if not button.confirm or not confirmState then
                        text.TextColor3 = button.risky and Color3.fromRGB(175, 21, 21) or Color3.fromRGB(145, 145, 145)
                    end
                end)
                
                function button:AddButton(subData)
                    local sub = {
                        class = "button",
                        flag = subData.flag,
                        text = subData.text or "",
                        confirm = subData.confirm or false,
                        callback = subData.callback or function() end,
                        objects = {}
                    }
                    
                    local subBg = create("Frame", {
                        Size = UDim2.new(1, -4, 0, 14),
                        Position = UDim2.new(0, 2, 0, 4),
                        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                        BorderSizePixel = 0,
                        ZIndex = library.zindex.window + 22,
                        Parent = holder
                    })
                    
                    applyGradient(subBg, 90)
                    subBg.UIGradient.Transparency = NumberSequence.new(0.65)
                    
                    local subBorder1 = create("Frame", {
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                        BorderSizePixel = 0,
                        ZIndex = library.zindex.window + 21,
                        Parent = subBg
                    })
                    
                    local subBorder2 = create("Frame", {
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ZIndex = library.zindex.window + 20,
                        Parent = subBorder1
                    })
                    
                    local subText = create("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.fromRGB(145, 145, 145),
                        TextSize = 13,
                        FontFace = customFont,
                        Text = sub.text,
                        ZIndex = library.zindex.window + 26,
                        Parent = subBg
                    })
                    
                    sub.objects = {
                        bg = subBg,
                        border1 = subBorder1,
                        text = subText
                    }
                    
                    local subConfirm = false
                    subBg.MouseButton1Click:Connect(function()
                        if sub.confirm then
                            if subConfirm then
                                subConfirm = false
                                subText.Text = sub.text
                                subText.TextColor3 = Color3.fromRGB(145, 145, 145)
                                sub.callback()
                            else
                                subConfirm = true
                                subText.Text = "Confirm " .. sub.text .. "? 3"
                                task.spawn(function()
                                    for i = 3, 1, -1 do
                                        task.wait(1)
                                        if not subConfirm then break end
                                        subText.Text = "Confirm " .. sub.text .. "? " .. i
                                    end
                                    if subConfirm then
                                        subConfirm = false
                                        subText.Text = sub.text
                                        subText.TextColor3 = Color3.fromRGB(145, 145, 145)
                                    end
                                end)
                            end
                        else
                            sub.callback()
                        end
                    end)
                    
                    subBg.MouseEnter:Connect(function()
                        subBorder1.BackgroundColor3 = Color3.fromRGB(255, 135, 255)
                        subText.TextColor3 = Color3.fromRGB(245, 245, 245)
                    end)
                    
                    subBg.MouseLeave:Connect(function()
                        subBorder1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        if not sub.confirm or not subConfirm then
                            subText.TextColor3 = Color3.fromRGB(145, 145, 145)
                        end
                    end)
                    
                    table.insert(button.subbuttons, sub)
                    
                    local total = 1 + #button.subbuttons
                    local width = (1 / total) - 0.005
                    bg.Size = UDim2.new(width, -4, 0, 14)
                    local offset = width + 0.01
                    for i, sb in ipairs(button.subbuttons) do
                        sb.objects.bg.Size = UDim2.new(width, -4, 0, 14)
                        sb.objects.bg.Position = UDim2.new(offset * i, 0, 0, 4)
                    end
                end
                
                table.insert(section.options, button)
                if button.flag then
                    library.options[button.flag] = button
                end
                section:UpdateOptions()
                return button
            end
            
            function section:AddSeparator(data)
                local sep = {
                    class = "separator",
                    text = data.text or "",
                    order = #section.options + 1,
                    objects = {}
                }
                
                local holder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    ZIndex = library.zindex.window + 25,
                    Parent = optionHolder
                })
                
                local line1 = create("Frame", {
                    Size = UDim2.new(0.4, 0, 0, 1),
                    Position = UDim2.new(0, 1, 0.5, -1),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    BorderSizePixel = 0,
                    Parent = holder
                })
                
                local line2 = create("Frame", {
                    Size = UDim2.new(0.4, 0, 0, 1),
                    Position = UDim2.new(0.6, -1, 0.5, -1),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    BorderSizePixel = 0,
                    Parent = holder
                })
                
                local text = create("TextLabel", {
                    Position = UDim2.new(0.5, 0, 0, 1),
                    Size = UDim2.new(0, 0, 0, 14),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = sep.text,
                    ZIndex = library.zindex.window + 26,
                    Parent = holder
                })
                
                sep.objects = {
                    holder = holder,
                    line1 = line1,
                    line2 = line2,
                    text = text
                }
                
                function sep:SetText(txt)
                    sep.text = txt
                    text.Text = txt
                    text.Size = UDim2.new(0, text.TextBounds.X, 0, 14)
                    local half = (1 - (text.TextBounds.X / holder.AbsoluteSize.X)) / 2
                    line1.Size = UDim2.new(half - 0.02, 0, 0, 1)
                    line2.Size = UDim2.new(half - 0.02, 0, 0, 1)
                    line2.Position = UDim2.new(1 - (half - 0.02), -1, 0.5, -1)
                    text.Position = UDim2.new(0.5, -text.TextBounds.X / 2, 0, 1)
                end
                
                table.insert(section.options, sep)
                sep:SetText(sep.text)
                section:UpdateOptions()
                return sep
            end
            
            function section:AddList(data)
                local list = {
                    class = "list",
                    flag = data.flag,
                    text = data.text or "",
                    values = data.values or {},
                    selected = data.selected or (data.multi and {} or (data.values and data.values[1] or "")),
                    multi = data.multi or false,
                    tooltip = data.tooltip or "",
                    callback = data.callback or function() end,
                    enabled = true,
                    open = false,
                    order = #section.options + 1,
                    objects = {}
                }
                
                local holder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                    ZIndex = library.zindex.window + 25,
                    Parent = optionHolder
                })
                
                local text = create("TextLabel", {
                    Position = UDim2.new(0, 2, 0, 2),
                    Size = UDim2.new(1, -4, 0, 14),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = list.text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = library.zindex.window + 26,
                    Parent = holder
                })
                
                local bg = create("Frame", {
                    Size = UDim2.new(1, -4, 0, 15),
                    Position = UDim2.new(0, 2, 1, -19),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 22,
                    Parent = holder
                })
                
                applyGradient(bg, 90)
                bg.UIGradient.Transparency = NumberSequence.new(0.65)
                
                local border1 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 21,
                    Parent = bg
                })
                
                local border2 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 20,
                    Parent = border1
                })
                
                local inputText = create("TextLabel", {
                    Position = UDim2.new(0, 4, 0, 0),
                    Size = UDim2.new(1, -20, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(195, 195, 195),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = type(list.selected) == "table" and (table.concat(list.selected, ", ") or "none") or tostring(list.selected),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = library.zindex.window + 27,
                    Parent = bg
                })
                
                local openText = create("TextLabel", {
                    Position = UDim2.new(1, -12, 0, 0),
                    Size = UDim2.new(0, 10, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = "+",
                    ZIndex = library.zindex.window + 27,
                    Parent = bg
                })
                
                list.objects = {
                    holder = holder,
                    text = text,
                    bg = bg,
                    border1 = border1,
                    inputText = inputText,
                    openText = openText
                }
                
                function list:Select(option, nocallback)
                    if list.multi then
                        local newSelected = {}
                        for _, v in pairs(list.selected) do
                            if v ~= "none" then
                                newSelected[v] = true
                            end
                        end
                        if type(option) == "table" then
                            for _, v in pairs(option) do
                                newSelected[v] = true
                            end
                        else
                            newSelected[option] = not newSelected[option]
                        end
                        local final = {}
                        for k, v in pairs(newSelected) do
                            if v then
                                table.insert(final, k)
                            end
                        end
                        if #final == 0 then
                            table.insert(final, "none")
                        end
                        list.selected = final
                        inputText.Text = table.concat(final, ", ")
                    else
                        list.selected = option
                        inputText.Text = tostring(option)
                    end
                    if inputText.TextBounds.X > bg.AbsoluteSize.X - 20 then
                        local short = inputText.Text:sub(1, 20) .. "..."
                        inputText.Text = short
                    end
                    if list.flag then
                        library.flags[list.flag] = list.selected
                    end
                    if not nocallback then
                        list.callback(list.selected)
                    end
                end
                
                local function refreshDropdown()
                    for _, child in pairs(dropdownScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for i, val in ipairs(list.values) do
                        local btn = create("TextButton", {
                            Size = UDim2.new(1, -8, 0, 18),
                            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                            BorderSizePixel = 1,
                            BorderColor3 = Color3.fromRGB(50, 50, 50),
                            TextColor3 = Color3.fromRGB(195, 195, 195),
                            TextSize = 13,
                            FontFace = customFont,
                            Text = tostring(val),
                            ZIndex = library.zindex.dropdown + 5,
                            Parent = dropdownScroll
                        })
                        btn.MouseButton1Click:Connect(function()
                            list:Select(val)
                            if not list.multi then
                                list.open = false
                                openText.Text = "+"
                                dropdownBackground.Visible = false
                                library.dropdownSelected = nil
                            end
                            refreshDropdown()
                        end)
                        if list.multi then
                            local checked = false
                            for _, s in pairs(list.selected) do
                                if s == val then
                                    checked = true
                                    break
                                end
                            end
                            btn.BackgroundColor3 = checked and Color3.fromRGB(255, 135, 255) or Color3.fromRGB(25, 25, 25)
                            btn.TextColor3 = checked and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(195, 195, 195)
                        elseif list.selected == val then
                            btn.BackgroundColor3 = Color3.fromRGB(255, 135, 255)
                            btn.TextColor3 = Color3.fromRGB(0, 0, 0)
                        end
                    end
                    local count = #list.values
                    dropdownBackground.Size = UDim2.new(1, -6, 0, math.min(count, window.dropdown.max) * 20 + 6)
                end
                
                bg.MouseButton1Click:Connect(function()
                    if list.open then
                        list.open = false
                        openText.Text = "+"
                        dropdownBackground.Visible = false
                        if library.dropdownSelected == list then
                            library.dropdownSelected = nil
                        end
                    else
                        if library.dropdownSelected then
                            library.dropdownSelected.open = false
                            library.dropdownSelected.objects.openText.Text = "+"
                        end
                        list.open = true
                        openText.Text = "-"
                        library.dropdownSelected = list
                        dropdownBackground.Visible = true
                        dropdownBackground.Parent = bg
                        dropdownBackground.Position = UDim2.new(0, -bg.AbsolutePosition.X + holder.AbsolutePosition.X, 1, 2)
                        refreshDropdown()
                    end
                end)
                
                bg.MouseEnter:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(255, 135, 255)
                end)
                
                bg.MouseLeave:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end)
                
                if list.tooltip and list.tooltip ~= "" then
                    holder.MouseEnter:Connect(function()
                        tooltipFrame.Visible = true
                        tooltipText.Text = list.tooltip
                        local pos = UserInputService:GetMouseLocation()
                        tooltipFrame.Position = UDim2.new(0, pos.X + 15, 0, pos.Y + 15)
                        tooltipFrame.Size = UDim2.new(0, tooltipText.TextBounds.X + 10, 0, 20)
                        library.CurrentTooltip = list
                    end)
                    holder.MouseLeave:Connect(function()
                        if library.CurrentTooltip == list then
                            tooltipFrame.Visible = false
                            library.CurrentTooltip = nil
                        end
                    end)
                end
                
                table.insert(section.options, list)
                if list.flag then
                    library.options[list.flag] = list
                end
                list:Select(list.selected, true)
                section:UpdateOptions()
                return list
            end
            
            function section:AddColor(data)
                local color = {
                    class = "color",
                    flag = data.flag,
                    text = data.text or "",
                    color = data.color or Color3.new(1, 1, 1),
                    trans = data.trans or 0,
                    tooltip = data.tooltip or "",
                    callback = data.callback or function() end,
                    enabled = true,
                    open = false,
                    order = #section.options + 1,
                    objects = {}
                }
                
                local holder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 19),
                    BackgroundTransparency = 1,
                    ZIndex = library.zindex.window + 25,
                    Parent = optionHolder
                })
                
                local text = create("TextLabel", {
                    Position = UDim2.new(0, 2, 0, 2),
                    Size = UDim2.new(1, -24, 0, 14),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = color.text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = library.zindex.window + 26,
                    Parent = holder
                })
                
                local colorBox = create("Frame", {
                    Size = UDim2.new(0, 15, 0, 8),
                    Position = UDim2.new(1, -17, 0, 5),
                    BackgroundColor3 = color.color,
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 23,
                    Parent = holder
                })
                
                applyGradient(colorBox, 45)
                colorBox.UIGradient.Transparency = NumberSequence.new(0.25)
                
                local border1 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 22,
                    Parent = colorBox
                })
                
                local border2 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 21,
                    Parent = border1
                })
                
                color.objects = {
                    holder = holder,
                    text = text,
                    colorBox = colorBox,
                    border1 = border1
                }
                
                function color:SetColor(c3, nocallback)
                    color.color = c3
                    colorBox.BackgroundColor3 = c3
                    if color.open and window.colorpicker.selected == color then
                        window.colorpicker:Visualize(c3, color.trans)
                    end
                    if color.flag then
                        library.flags[color.flag] = c3
                    end
                    if not nocallback then
                        color.callback(c3, color.trans)
                    end
                end
                
                function color:SetTrans(t, nocallback)
                    color.trans = t
                    if color.open and window.colorpicker.selected == color then
                        window.colorpicker:Visualize(color.color, t)
                    end
                    if not nocallback then
                        color.callback(color.color, t)
                    end
                end
                
                function window.colorpicker:Visualize(c3, t)
                    local h, s, v = c3:ToHSV()
                    colorpickerMain.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    colorpickerTrans.BackgroundColor3 = Color3.fromHSV(h, s, v)
                    colorpickerHueSlider.Position = UDim2.new(1 - h, -1, 0, 0)
                    colorpickerTransSlider.Position = UDim2.new(0, 0, t, -1)
                    colorpickerPointer.Position = UDim2.new(1 - s, -2, 1 - v, -2)
                    colorpickerStatus.Text = "Editing: " .. (color.text or color.flag or "Unknown")
                end
                
                local draggingSat = false
                local draggingHue = false
                local draggingTrans = false
                
                colorpickerMain.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and window.colorpicker.selected == color then
                        draggingSat = true
                        local pos = UserInputService:GetMouseLocation()
                        local x = (pos.X - colorpickerMain.AbsolutePosition.X) / colorpickerMain.AbsoluteSize.X
                        local y = (pos.Y - colorpickerMain.AbsolutePosition.Y) / colorpickerMain.AbsoluteSize.Y
                        local h = color.color:ToHSV()
                        color:SetColor(Color3.fromHSV(h, clamp(1 - x, 0, 1), clamp(1 - y, 0, 1)))
                    end
                end)
                
                colorpickerHue.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and window.colorpicker.selected == color then
                        draggingHue = true
                        local pos = UserInputService:GetMouseLocation()
                        local x = (pos.X - colorpickerHue.AbsolutePosition.X) / colorpickerHue.AbsoluteSize.X
                        local h = 1 - clamp(x, 0, 1)
                        local h2, s, v = color.color:ToHSV()
                        color:SetColor(Color3.fromHSV(h, s, v))
                    end
                end)
                
                colorpickerTrans.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and window.colorpicker.selected == color then
                        draggingTrans = true
                        local pos = UserInputService:GetMouseLocation()
                        local y = (pos.Y - colorpickerTrans.AbsolutePosition.Y) / colorpickerTrans.AbsoluteSize.Y
                        color:SetTrans(clamp(y, 0, 1))
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingSat and window.colorpicker.selected == color then
                            local pos = UserInputService:GetMouseLocation()
                            local x = (pos.X - colorpickerMain.AbsolutePosition.X) / colorpickerMain.AbsoluteSize.X
                            local y = (pos.Y - colorpickerMain.AbsolutePosition.Y) / colorpickerMain.AbsoluteSize.Y
                            local h = color.color:ToHSV()
                            color:SetColor(Color3.fromHSV(h, clamp(1 - x, 0, 1), clamp(1 - y, 0, 1)))
                        elseif draggingHue and window.colorpicker.selected == color then
                            local pos = UserInputService:GetMouseLocation()
                            local x = (pos.X - colorpickerHue.AbsolutePosition.X) / colorpickerHue.AbsoluteSize.X
                            local h = 1 - clamp(x, 0, 1)
                            local h2, s, v = color.color:ToHSV()
                            color:SetColor(Color3.fromHSV(h, s, v))
                        elseif draggingTrans and window.colorpicker.selected == color then
                            local pos = UserInputService:GetMouseLocation()
                            local y = (pos.Y - colorpickerTrans.AbsolutePosition.Y) / colorpickerTrans.AbsoluteSize.Y
                            color:SetTrans(clamp(y, 0, 1))
                        end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSat = false
                        draggingHue = false
                        draggingTrans = false
                    end
                end)
                
                colorBox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if color.open then
                            color.open = false
                            colorpickerBackground.Visible = false
                            if window.colorpicker.selected == color then
                                window.colorpicker.selected = nil
                            end
                        else
                            if window.colorpicker.selected then
                                window.colorpicker.selected.open = false
                            end
                            color.open = true
                            window.colorpicker.selected = color
                            colorpickerBackground.Visible = true
                            colorpickerBackground.Parent = colorBox
                            colorpickerBackground.Position = UDim2.new(1, -200, 0, 15)
                            window.colorpicker:Visualize(color.color, color.trans)
                        end
                    end
                end)
                
                colorBox.MouseEnter:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(255, 135, 255)
                end)
                
                colorBox.MouseLeave:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end)
                
                if color.tooltip and color.tooltip ~= "" then
                    holder.MouseEnter:Connect(function()
                        tooltipFrame.Visible = true
                        tooltipText.Text = color.tooltip
                        local pos = UserInputService:GetMouseLocation()
                        tooltipFrame.Position = UDim2.new(0, pos.X + 15, 0, pos.Y + 15)
                        tooltipFrame.Size = UDim2.new(0, tooltipText.TextBounds.X + 10, 0, 20)
                        library.CurrentTooltip = color
                    end)
                    holder.MouseLeave:Connect(function()
                        if library.CurrentTooltip == color then
                            tooltipFrame.Visible = false
                            library.CurrentTooltip = nil
                        end
                    end)
                end
                
                table.insert(section.options, color)
                if color.flag then
                    library.options[color.flag] = color
                end
                color:SetColor(color.color, true)
                color:SetTrans(color.trans, true)
                section:UpdateOptions()
                return color
            end
            
            function section:AddBox(data)
                local box = {
                    class = "box",
                    flag = data.flag,
                    text = data.text or "",
                    input = data.input or "",
                    tooltip = data.tooltip or "",
                    callback = data.callback or function() end,
                    enabled = true,
                    focused = false,
                    order = #section.options + 1,
                    objects = {}
                }
                
                local holder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 37),
                    BackgroundTransparency = 1,
                    ZIndex = library.zindex.window + 25,
                    Parent = optionHolder
                })
                
                local text = create("TextLabel", {
                    Position = UDim2.new(0, 2, 0, 2),
                    Size = UDim2.new(1, -4, 0, 14),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = box.text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = library.zindex.window + 26,
                    Parent = holder
                })
                
                local bg = create("Frame", {
                    Size = UDim2.new(1, -4, 0, 15),
                    Position = UDim2.new(0, 2, 1, -17),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 22,
                    Parent = holder
                })
                
                applyGradient(bg, 90)
                bg.UIGradient.Transparency = NumberSequence.new(0.65)
                
                local border1 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 21,
                    Parent = bg
                })
                
                local border2 = create("Frame", {
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, -1, 0, -1),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = library.zindex.window + 20,
                    Parent = border1
                })
                
                local inputText = create("TextLabel", {
                    Position = UDim2.new(0, 4, 0, 0),
                    Size = UDim2.new(1, -8, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(195, 195, 195),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = box.input,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = library.zindex.window + 27,
                    Parent = bg
                })
                
                box.objects = {
                    holder = holder,
                    text = text,
                    bg = bg,
                    border1 = border1,
                    inputText = inputText
                }
                
                function box:SetInput(str, nocallback)
                    box.input = str
                    inputText.Text = str
                    if box.flag then
                        library.flags[box.flag] = str
                    end
                    if not nocallback then
                        box.callback(str)
                    end
                end
                
                local inputConnection = nil
                local currentInput = box.input
                
                bg.MouseButton1Click:Connect(function()
                    if box.focused then
                        if inputConnection then
                            inputConnection:Disconnect()
                        end
                        box.focused = false
                        inputText.TextColor3 = Color3.fromRGB(195, 195, 195)
                        ContextActionService:UnbindAction("FreezeMovement")
                    else
                        box.focused = true
                        inputText.TextColor3 = Color3.fromRGB(245, 245, 245)
                        currentInput = box.input
                        inputText.Text = currentInput .. "_"
                        ContextActionService:BindAction("FreezeMovement", function() return Enum.ContextActionResult.Sink end, false, unpack(Enum.PlayerActions:GetEnumItems()))
                        inputConnection = UserInputService.InputBegan:Connect(function(inp)
                            if inp.KeyCode == Enum.KeyCode.Return then
                                box:SetInput(currentInput)
                                box.focused = false
                                inputText.TextColor3 = Color3.fromRGB(195, 195, 195)
                                inputConnection:Disconnect()
                                ContextActionService:UnbindAction("FreezeMovement")
                            elseif inp.KeyCode == Enum.KeyCode.Escape then
                                box.focused = false
                                inputText.Text = box.input
                                inputText.TextColor3 = Color3.fromRGB(195, 195, 195)
                                inputConnection:Disconnect()
                                ContextActionService:UnbindAction("FreezeMovement")
                            elseif inp.KeyCode == Enum.KeyCode.Backspace then
                                currentInput = currentInput:sub(1, -2)
                                inputText.Text = currentInput .. "_"
                            elseif #inp.KeyCode.Name == 1 or inp.KeyCode.Name == "Space" then
                                local char = inp.KeyCode.Name == "Space" and " " or inp.KeyCode.Name
                                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                                    char = char:upper()
                                else
                                    char = char:lower()
                                end
                                currentInput = currentInput .. char
                                inputText.Text = currentInput .. "_"
                            end
                        end)
                    end
                end)
                
                bg.MouseEnter:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(255, 135, 255)
                end)
                
                bg.MouseLeave:Connect(function()
                    border1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end)
                
                if box.tooltip and box.tooltip ~= "" then
                    holder.MouseEnter:Connect(function()
                        tooltipFrame.Visible = true
                        tooltipText.Text = box.tooltip
                        local pos = UserInputService:GetMouseLocation()
                        tooltipFrame.Position = UDim2.new(0, pos.X + 15, 0, pos.Y + 15)
                        tooltipFrame.Size = UDim2.new(0, tooltipText.TextBounds.X + 10, 0, 20)
                        library.CurrentTooltip = box
                    end)
                    holder.MouseLeave:Connect(function()
                        if library.CurrentTooltip == box then
                            tooltipFrame.Visible = false
                            library.CurrentTooltip = nil
                        end
                    end)
                end
                
                table.insert(section.options, box)
                if box.flag then
                    library.options[box.flag] = box
                end
                box:SetInput(box.input, true)
                section:UpdateOptions()
                return box
            end
            
            function section:AddBind(data)
                local bind = {
                    class = "bind",
                    flag = data.flag,
                    text = data.text or "",
                    bind = data.bind or "none",
                    mode = data.mode or "toggle",
                    nomouse = data.nomouse or false,
                    tooltip = data.tooltip or "",
                    callback = data.callback or function() end,
                    enabled = true,
                    binding = false,
                    order = #section.options + 1,
                    objects = {}
                }
                
                local holder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 19),
                    BackgroundTransparency = 1,
                    ZIndex = library.zindex.window + 25,
                    Parent = optionHolder
                })
                
                local text = create("TextLabel", {
                    Position = UDim2.new(0, 2, 0, 2),
                    Size = UDim2.new(1, -80, 0, 14),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = bind.text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = library.zindex.window + 26,
                    Parent = holder
                })
                
                local keyText = create("TextLabel", {
                    Position = UDim2.new(1, -5, 0, 2),
                    Size = UDim2.new(0, 70, 0, 14),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(145, 145, 145),
                    TextSize = 13,
                    FontFace = customFont,
                    Text = "[NONE]",
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = library.zindex.window + 26,
                    Parent = holder
                })
                
                bind.objects = {
                    holder = holder,
                    text = text,
                    keyText = keyText
                }
                
                local keyNames = {
                    [Enum.KeyCode.LeftControl] = "LCTRL",
                    [Enum.KeyCode.RightControl] = "RCTRL",
                    [Enum.KeyCode.LeftShift] = "LSHIFT",
                    [Enum.KeyCode.RightShift] = "RSHIFT",
                    [Enum.UserInputType.MouseButton1] = "MB1",
                    [Enum.UserInputType.MouseButton2] = "MB2",
                    [Enum.UserInputType.MouseButton3] = "MB3"
                }
                
                function bind:SetBind(key)
                    if key == Enum.KeyCode.Backspace then
                        bind.bind = "none"
                        keyText.Text = "[NONE]"
                    else
                        bind.bind = key
                        local name = keyNames[key] or key.Name
                        keyText.Text = "[" .. name:upper() .. "]"
                    end
                    if bind.flag then
                        library.flags[bind.flag] = false
                    end
                    bind.callback(false)
                end
                
                local holdConnection = nil
                
                UserInputService.InputBegan:Connect(function(inp)
                    if UserInputService:GetFocusedTextBox() then return end
                    if bind.binding then
                        local key = (not bind.nomouse and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.MouseButton2)) and inp.UserInputType or inp.KeyCode
                        if key and key ~= Enum.KeyCode.Unknown then
                            bind:SetBind(key)
                            bind.binding = false
                            keyText.TextColor3 = Color3.fromRGB(145, 145, 145)
                        end
                    elseif bind.bind ~= "none" and (inp.KeyCode == bind.bind or inp.UserInputType == bind.bind) then
                        if bind.mode == "toggle" then
                            local newState = not (library.flags[bind.flag] or false)
                            library.flags[bind.flag] = newState
                            bind.callback(newState)
                        elseif bind.mode == "hold" then
                            library.flags[bind.flag] = true
                            bind.callback(true)
                            holdConnection = RunService.RenderStepped:Connect(function()
                                bind.callback(true)
                            end)
                        end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(inp)
                    if bind.bind ~= "none" and (inp.KeyCode == bind.bind or inp.UserInputType == bind.bind) and bind.mode == "hold" then
                        if holdConnection then
                            holdConnection:Disconnect()
                            holdConnection = nil
                        end
                        library.flags[bind.flag] = false
                        bind.callback(false)
                    end
                end)
                
                holder.MouseButton1Click:Connect(function()
                    if not bind.binding then
                        bind.binding = true
                        keyText.Text = "[...]"
                        keyText.TextColor3 = Color3.fromRGB(255, 135, 255)
                    end
                end)
                
                holder.MouseEnter:Connect(function()
                    if not bind.binding then
                        keyText.TextColor3 = Color3.fromRGB(255, 135, 255)
                    end
                end)
                
                holder.MouseLeave:Connect(function()
                    if not bind.binding then
                        keyText.TextColor3 = Color3.fromRGB(145, 145, 145)
                    end
                end)
                
                if bind.tooltip and bind.tooltip ~= "" then
                    holder.MouseEnter:Connect(function()
                        tooltipFrame.Visible = true
                        tooltipText.Text = bind.tooltip
                        local pos = UserInputService:GetMouseLocation()
                        tooltipFrame.Position = UDim2.new(0, pos.X + 15, 0, pos.Y + 15)
                        tooltipFrame.Size = UDim2.new(0, tooltipText.TextBounds.X + 10, 0, 20)
                        library.CurrentTooltip = bind
                    end)
                    holder.MouseLeave:Connect(function()
                        if library.CurrentTooltip == bind then
                            tooltipFrame.Visible = false
                            library.CurrentTooltip = nil
                        end
                    end)
                end
                
                table.insert(section.options, bind)
                if bind.flag then
                    library.options[bind.flag] = bind
                end
                bind:SetBind(bind.bind)
                section:UpdateOptions()
                return bind
            end
            
            section:SetText(section.text)
            tab:UpdateSections()
            return section
        end
        
        table.insert(window.tabs, tab)
        if not window.selectedTab then
            tab:Select()
        end
        window:UpdateTabs()
        return tab
    end
    
    return window
end

function library:CreateSettingsTab(menu)
    local settings = menu:AddTab("Settings", 999)
    local configSection = settings:AddSection("Config", 2)
    local mainSection = settings:AddSection("Main", 1)
    
    configSection:AddBox({ text = "Config Name", flag = "configinput" })
    
    local configList = configSection:AddList({ text = "Config", flag = "selectedconfig", values = {} })
    
    local function refreshConfigs()
        configList:ClearValues()
        if isfolder(library.directory .. "/" .. library.gamename .. "/configs") then
            for _, v in ipairs(listfiles(library.directory .. "/" .. library.gamename .. "/configs")) do
                local name = v:match("([^/]+)%." .. library.fileext:sub(2))
                if name then
                    configList:AddValue(name)
                end
            end
        end
    end
    
    refreshConfigs()
    
    configSection:AddButton({ text = "Load", confirm = true, callback = function()
        local name = library.flags.selectedconfig
        if name and isfile(library.directory .. "/" .. library.gamename .. "/configs/" .. name .. library.fileext) then
            local data = HttpService:JSONDecode(readfile(library.directory .. "/" .. library.gamename .. "/configs/" .. name .. library.fileext))
            for flag, value in pairs(data) do
                local opt = library.options[flag]
                if opt then
                    if opt.class == "toggle" then
                        opt:SetState(value == 1)
                    elseif opt.class == "slider" then
                        opt:SetValue(value)
                    elseif opt.class == "list" then
                        opt:Select(value)
                    elseif opt.class == "box" then
                        opt:SetInput(value)
                    elseif opt.class == "color" then
                        opt:SetColor(Color3.new(value[1], value[2], value[3]))
                        opt:SetTrans(value[4])
                    elseif opt.class == "bind" then
                        if value == "none" then
                            opt:SetBind("none")
                        else
                            local key = Enum.KeyCode[value] or Enum.UserInputType[value]
                            if key then opt:SetBind(key) end
                        end
                    end
                end
            end
            library:SendNotification("Loaded " .. name, 3)
        end
    end })
    
    configSection:AddButton({ text = "Save", confirm = true, callback = function()
        local name = library.flags.selectedconfig
        if name then
            local data = {}
            for flag, opt in pairs(library.options) do
                if opt.class == "toggle" then
                    data[flag] = opt.state and 1 or 0
                elseif opt.class == "slider" then
                    data[flag] = opt.value
                elseif opt.class == "list" then
                    data[flag] = opt.selected
                elseif opt.class == "box" then
                    data[flag] = opt.input
                elseif opt.class == "color" then
                    data[flag] = { opt.color.R, opt.color.G, opt.color.B, opt.trans }
                elseif opt.class == "bind" then
                    data[flag] = opt.bind == "none" and "none" or (type(opt.bind) == "EnumItem" and opt.bind.Name or "none")
                end
            end
            writefile(library.directory .. "/" .. library.gamename .. "/configs/" .. name .. library.fileext, HttpService:JSONEncode(data))
            library:SendNotification("Saved " .. name, 3)
        end
    end })
    
    configSection:AddButton({ text = "Create", confirm = true, callback = function()
        local name = library.flags.configinput
        if name and name ~= "" then
            if not isfile(library.directory .. "/" .. library.gamename .. "/configs/" .. name .. library.fileext) then
                writefile(library.directory .. "/" .. library.gamename .. "/configs/" .. name .. library.fileext, "{}")
                refreshConfigs()
                library:SendNotification("Created " .. name, 3)
            end
        end
    end })
    
    configSection:AddButton({ text = "Delete", confirm = true, callback = function()
        local name = library.flags.selectedconfig
        if name and isfile(library.directory .. "/" .. library.gamename .. "/configs/" .. name .. library.fileext) then
            delfile(library.directory .. "/" .. library.gamename .. "/configs/" .. name .. library.fileext)
            refreshConfigs()
            library:SendNotification("Deleted " .. name, 3)
        end
    end })
    
    local toggleKey = Enum.KeyCode.End
    mainSection:AddBind({ text = "Open / Close", flag = "togglebind", bind = toggleKey, nomouse = true, callback = function(state)
        if state then
            library.open = not library.open
            mainContainer.Visible = library.open
            watermarkFrame.Visible = library.open and (library.flags.watermark_enabled or false)
            if library.open and library.flags.disablemenumovement then
                ContextActionService:BindAction("FreezeMovement", function() return Enum.ContextActionResult.Sink end, false, unpack(Enum.PlayerActions:GetEnumItems()))
            elseif not library.open then
                ContextActionService:UnbindAction("FreezeMovement")
            end
        end
    end })
    
    mainSection:AddToggle({ text = "Disable Movement If Open", flag = "disablemenumovement", callback = function(bool)
        if library.open and bool then
            ContextActionService:BindAction("FreezeMovement", function() return Enum.ContextActionResult.Sink end, false, unpack(Enum.PlayerActions:GetEnumItems()))
        else
            ContextActionService:UnbindAction("FreezeMovement")
        end
    end })
    
    mainSection:AddButton({ text = "Unload", confirm = true, callback = function()
        screenGui:Destroy()
        library.hasInit = false
    end })
    
    mainSection:AddSeparator({ text = "Watermark" })
    mainSection:AddToggle({ text = "Enabled", flag = "watermark_enabled", callback = function(bool)
        watermarkFrame.Visible = bool and library.open
    end })
    
    local posList = mainSection:AddList({ text = "Position", flag = "watermark_pos", values = { "Top Left", "Top Right", "Bottom Left", "Bottom Right", "Top", "Custom" }, selected = "Top Right" })
    mainSection:AddSlider({ text = "Custom X", flag = "watermark_x", min = 0, max = 100, value = 90 })
    mainSection:AddSlider({ text = "Custom Y", flag = "watermark_y", min = 0, max = 100, value = 5 })
    
    mainSection:AddSeparator({ text = "Key Indicator" })
    mainSection:AddToggle({ text = "Enabled", flag = "key_indicator", callback = function(bool)
        keyIndicatorFrame.Visible = bool
    end })
    mainSection:AddSlider({ text = "Position X", flag = "key_indicator_x", min = 0, max = 100, value = 1, callback = function()
        keyIndicatorFrame.Position = UDim2.new(library.flags.key_indicator_x / 100, 0, library.flags.key_indicator_y / 100, 0)
    end })
    mainSection:AddSlider({ text = "Position Y", flag = "key_indicator_y", min = 0, max = 100, value = 30, callback = function()
        keyIndicatorFrame.Position = UDim2.new(library.flags.key_indicator_x / 100, 0, library.flags.key_indicator_y / 100, 0)
    end })
    
    local themeNames = { "Custom" }
    for _, v in ipairs(library.themes or {}) do
        table.insert(themeNames, v.name)
    end
    
    local themeTab = menu:AddTab("Theme", 998)
    local themeSection = themeTab:AddSection("Theme", 1)
    
    local presetList = themeSection:AddList({ text = "Presets", flag = "theme_preset", values = themeNames, selected = "Default" })
    
    library.theme = {
        Accent = Color3.fromRGB(255, 135, 255),
        Background = Color3.fromRGB(18, 18, 18),
        Border1 = Color3.fromRGB(60, 60, 60),
        Border2 = Color3.fromRGB(35, 35, 35),
        Border3 = Color3.fromRGB(10, 10, 10),
        PrimaryText = Color3.fromRGB(235, 235, 235),
        GroupBackground = Color3.fromRGB(35, 35, 35),
        OptionBackground = Color3.fromRGB(35, 35, 35),
        OptionText1 = Color3.fromRGB(245, 245, 245),
        OptionText2 = Color3.fromRGB(195, 195, 195),
        OptionText3 = Color3.fromRGB(145, 145, 145)
    }
    
    presetList.callback = function(selected)
        if selected ~= "Custom" then
            for _, themeData in ipairs(library.themes or {}) do
                if themeData.name == selected then
                    for key, color in pairs(themeData.theme) do
                        local opt = library.options[key]
                        if opt and opt.class == "color" then
                            opt:SetColor(color)
                        end
                        library.theme[key] = color
                    end
                    break
                end
            end
        end
    end
    
    for key, defaultColor in pairs(library.theme) do
        themeSection:AddColor({ text = key, flag = key, color = defaultColor, callback = function(c3)
            library.theme[key] = c3
            presetList:Select("Custom")
            if key == "Accent" then
                watermarkTopBar.BackgroundColor3 = c3
                keyIndicatorTopBar.BackgroundColor3 = c3
            elseif key == "Background" then
                watermarkFrame.BackgroundColor3 = c3
                keyIndicatorFrame.BackgroundColor3 = c3
            elseif key == "PrimaryText" then
                watermarkText.TextColor3 = c3
                keyIndicatorTitle.TextColor3 = c3
            end
        end })
    end
    
    library.themePreset = library.themes and library.themes[1]
    if library.themePreset then
        presetList:Select(library.themePreset.name)
    end
    
    return settings
end

function library:SendNotification(msg, duration)
    duration = duration or 3
    local notif = create("Frame", {
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(1, -210, 0, 10),
        BackgroundColor3 = library.theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = library.theme.Border1,
        ZIndex = library.zindex.notification,
        Parent = screenGui
    })
    
    local text = create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = library.theme.PrimaryText,
        TextSize = 13,
        FontFace = customFont,
        Text = msg,
        ZIndex = library.zindex.notification + 1,
        Parent = notif
    })
    
    local bar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = library.theme.Accent,
        BorderSizePixel = 0,
        ZIndex = library.zindex.notification + 1,
        Parent = notif
    })
    
    notif:TweenPosition(UDim2.new(1, -210, 0, 10), "Out", "Quad", 0.3, true)
    task.wait(duration)
    local tween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(1, 0, 0, 10) })
    tween:Play()
    tween.Completed:Connect(function()
        notif:Destroy()
    end)
end

function library:AddKeybindIndicator(key, value)
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Parent = keyIndicatorContent
    })
    
    local keyLabel = create("TextLabel", {
        Size = UDim2.new(0.5, -5, 1, 0),
        Position = UDim2.new(0, 3, 0, 1),
        BackgroundTransparency = 1,
        TextColor3 = library.theme.OptionText2,
        TextSize = 13,
        FontFace = customFont,
        Text = key,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local valueLabel = create("TextLabel", {
        Size = UDim2.new(0.5, -5, 1, 0),
        Position = UDim2.new(0.5, 3, 0, 1),
        BackgroundTransparency = 1,
        TextColor3 = library.theme.OptionText2,
        TextSize = 13,
        FontFace = customFont,
        Text = value,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    keyIndicatorContent.Size = UDim2.new(1, 0, 0, keyIndicatorContent.Size.Y.Offset + 18)
    keyIndicatorFrame.Size = UDim2.new(0, 200, 0, keyIndicatorContent.Size.Y.Offset + 18)
    
    return {
        SetKey = function(txt) keyLabel.Text = txt end,
        SetValue = function(txt) valueLabel.Text = txt end,
        SetEnabled = function(bool) frame.Visible = bool end
    }
end

RunService.RenderStepped:Connect(function(dt)
    library.stats.fps = math.floor(1 / dt)
    local statsService = game:GetService("Stats")
    library.stats.ping = math.floor(statsService.Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
    
    local text = library.cheatname .. " | " .. library.gamename .. " | " .. library.stats.fps .. " fps | " .. library.stats.ping .. " ms"
    watermarkText.Text = text
    watermarkFrame.Size = UDim2.new(0, watermarkText.TextBounds.X + 20, 0, 20)
    
    local posMode = library.flags.watermark_pos or "Top Right"
    local camSize = workspace.CurrentCamera.ViewportSize
    if posMode == "Top Left" then
        watermarkFrame.Position = UDim2.new(0, 10, 0, 10)
    elseif posMode == "Top Right" then
        watermarkFrame.Position = UDim2.new(1, -(watermarkFrame.Size.X.Offset + 10), 0, 10)
    elseif posMode == "Bottom Left" then
        watermarkFrame.Position = UDim2.new(0, 10, 1, -(watermarkFrame.Size.Y.Offset + 10))
    elseif posMode == "Bottom Right" then
        watermarkFrame.Position = UDim2.new(1, -(watermarkFrame.Size.X.Offset + 10), 1, -(watermarkFrame.Size.Y.Offset + 10))
    elseif posMode == "Top" then
        watermarkFrame.Position = UDim2.new(0.5, -watermarkFrame.Size.X.Offset / 2, 0, 10)
    else
        watermarkFrame.Position = UDim2.new(library.flags.watermark_x / 100, 0, library.flags.watermark_y / 100, 0)
    end
end)

library.hasInit = true
library.open = true
mainContainer.Visible = true

getgenv().library = library
return library
