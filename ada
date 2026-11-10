--[[
    COMBINED HUB
    1) Plays the intro
    2) Opens one GUI with: Unique Booster + Fake Dupe
    3) Live toast notifications + warning
]]

---------------------------------------------------------------------
-- CONFIG
---------------------------------------------------------------------
local INTRO_URL  = "https://pastebin.com/raw/DBzgFdTC"
local INTRO_WAIT = 6 -- seconds to let the intro play before the GUI opens (change if your intro is longer/shorter)

local WARNING_TEXT = "⚠️ IF YOU EXECUTE THIS ON YOUR PRIVATE SERVER 100% NOT WORKING ⚠️"

local SCRIPTS = {
    {
        name  = "Unique Booster",
        icon  = "🚀",
        desc  = "Load the Unique Booster script",
        url   = "https://pastebin.com/raw/sa12W9ER",
        color = Color3.fromRGB(88, 101, 242),
    },
    {
        name  = "Fake Dupe Script",
        icon  = "🧪",
        desc  = "Load the Fake Dupe script",
        url   = "https://pastebin.com/raw/4mtMitJ7",
        color = Color3.fromRGB(235, 69, 158),
    },
}

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- 1) INTRO
---------------------------------------------------------------------
task.spawn(function()
    local ok, err = pcall(function()
        loadstring(game:HttpGet(INTRO_URL))()
    end)
    if not ok then
        warn("[Hub] Intro failed: " .. tostring(err))
    end
end)

task.wait(INTRO_WAIT)

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function getParent()
    local ok, ui = pcall(function() return gethui and gethui() end)
    if ok and ui then return ui end
    local ok2 = pcall(function() return CoreGui.Name end)
    if ok2 then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function tween(obj, time, props, style, dir)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

-- remove old copy
local parent = getParent()
local old = parent:FindFirstChild("CombinedHub")
if old then old:Destroy() end

---------------------------------------------------------------------
-- SCREEN GUI
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "CombinedHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = parent

---------------------------------------------------------------------
-- TOAST NOTIFICATIONS (live)
---------------------------------------------------------------------
local toastHolder = Instance.new("Frame")
toastHolder.Name = "Toasts"
toastHolder.BackgroundTransparency = 1
toastHolder.AnchorPoint = Vector2.new(1, 0)
toastHolder.Position = UDim2.new(1, -16, 0, 16)
toastHolder.Size = UDim2.new(0, 300, 1, -32)
toastHolder.Parent = gui

local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 8)
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
toastLayout.Parent = toastHolder

local toastCount = 0
local function notify(text, accent, duration)
    accent = accent or Color3.fromRGB(88, 101, 242)
    duration = duration or 5
    toastCount += 1

    local slot = Instance.new("Frame") -- slot keeps layout stable while animating
    slot.BackgroundTransparency = 1
    slot.Size = UDim2.new(1, 0, 0, 0)
    slot.AutomaticSize = Enum.AutomaticSize.Y
    slot.LayoutOrder = toastCount
    slot.Parent = toastHolder

    local toast = Instance.new("Frame")
    toast.BackgroundColor3 = Color3.fromRGB(24, 25, 34)
    toast.Size = UDim2.new(1, 0, 0, 0)
    toast.AutomaticSize = Enum.AutomaticSize.Y
    toast.Position = UDim2.new(1, 320, 0, 0)
    toast.Parent = slot
    corner(toast, 10)
    stroke(toast, accent, 1.5, 0.2)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = toast

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(235, 235, 245)
    label.Text = text
    label.Parent = toast

    -- progress bar
    local bar = Instance.new("Frame")
    bar.AnchorPoint = Vector2.new(0, 1)
    bar.Position = UDim2.new(0, 0, 1, 10)
    bar.Size = UDim2.new(1, 0, 0, 3)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    bar.Parent = toast
    corner(bar, 2)

    tween(toast, 0.45, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
    tween(bar, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        local t = tween(toast, 0.35, { Position = UDim2.new(1, 320, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        t.Completed:Wait()
        slot:Destroy()
    end)
end

---------------------------------------------------------------------
-- MAIN WINDOW
---------------------------------------------------------------------
local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, 0, 0, 0) -- animates open
main.BackgroundColor3 = Color3.fromRGB(18, 19, 27)
main.ClipsDescendants = true
main.Parent = gui
corner(main, 16)
stroke(main, Color3.fromRGB(88, 101, 242), 2, 0.1)

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 31, 48)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 15, 22)),
})
bgGradient.Rotation = 90
bgGradient.Parent = main

local FULL_SIZE = UDim2.new(0, 380, 0, 360)
local MINI_SIZE = UDim2.new(0, 380, 0, 48)

-- header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
header.BorderSizePixel = 0
header.Parent = main

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 69, 158)),
})
headerGradient.Parent = header

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 16, 0, 0)
title.Size = UDim2.new(1, -100, 1, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "✨ COMBINED HUB"
title.Parent = header

local function headerButton(text, xOffset)
    local b = Instance.new("TextButton")
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, xOffset, 0.5, 0)
    b.Size = UDim2.new(0, 28, 0, 28)
    b.BackgroundColor3 = Color3.new(0, 0, 0)
    b.BackgroundTransparency = 0.7
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.AutoButtonColor = false
    b.Parent = header
    corner(b, 8)
    b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundTransparency = 0.4 }) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, { BackgroundTransparency = 0.7 }) end)
    return b
end

local closeBtn = headerButton("✕", -10)
local miniBtn  = headerButton("–", -44)

-- body
local body = Instance.new("Frame")
body.Name = "Body"
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 0, 0, 48)
body.Size = UDim2.new(1, 0, 1, -48)
body.Parent = main

local bodyPad = Instance.new("UIPadding")
bodyPad.PaddingTop = UDim.new(0, 14)
bodyPad.PaddingLeft = UDim.new(0, 14)
bodyPad.PaddingRight = UDim.new(0, 14)
bodyPad.PaddingBottom = UDim.new(0, 14)
bodyPad.Parent = body

local bodyLayout = Instance.new("UIListLayout")
bodyLayout.Padding = UDim.new(0, 10)
bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
bodyLayout.Parent = body

-- warning banner
local warnBox = Instance.new("Frame")
warnBox.LayoutOrder = 1
warnBox.Size = UDim2.new(1, 0, 0, 58)
warnBox.BackgroundColor3 = Color3.fromRGB(60, 40, 18)
warnBox.Parent = body
corner(warnBox, 10)
local warnStroke = stroke(warnBox, Color3.fromRGB(255, 184, 0), 1.5, 0.1)

local warnLabel = Instance.new("TextLabel")
warnLabel.BackgroundTransparency = 1
warnLabel.Size = UDim2.new(1, -16, 1, 0)
warnLabel.Position = UDim2.new(0, 8, 0, 0)
warnLabel.Font = Enum.Font.GothamBold
warnLabel.TextSize = 12
warnLabel.TextWrapped = true
warnLabel.TextColor3 = Color3.fromRGB(255, 210, 90)
warnLabel.Text = WARNING_TEXT
warnLabel.Parent = warnBox

-- pulsing warning border
task.spawn(function()
    while gui.Parent do
        tween(warnStroke, 0.8, { Transparency = 0.8 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Wait()
        if not gui.Parent then break end
        tween(warnStroke, 0.8, { Transparency = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Wait()
    end
end)

-- status line
local status = Instance.new("TextLabel")
status.LayoutOrder = 2
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, 0, 0, 18)
status.Font = Enum.Font.GothamMedium
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = Color3.fromRGB(150, 155, 180)
status.Text = "🟢 Status: Ready"
status.Parent = body

local function setStatus(text, color)
    status.Text = text
    status.TextColor3 = color or Color3.fromRGB(150, 155, 180)
end

---------------------------------------------------------------------
-- SCRIPT BUTTONS
---------------------------------------------------------------------
local function runRemote(url)
    local okGet, src = pcall(function() return game:HttpGet(url) end)
    if not okGet then return false, "Download failed: " .. tostring(src) end

    local fn, compileErr = loadstring(src)
    if not fn then return false, "Compile error: " .. tostring(compileErr) end

    local okRun, runErr = pcall(fn)
    if not okRun then return false, "Runtime error: " .. tostring(runErr) end

    return true
end

local function makeScriptButton(info, order)
    local card = Instance.new("TextButton")
    card.LayoutOrder = order
    card.Size = UDim2.new(1, 0, 0, 74)
    card.BackgroundColor3 = Color3.fromRGB(30, 32, 46)
    card.AutoButtonColor = false
    card.Text = ""
    card.Parent = body
    corner(card, 12)
    local cardStroke = stroke(card, info.color, 1.5, 0.55)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 5, 1, -20)
    accent.Position = UDim2.new(0, 10, 0, 10)
    accent.BackgroundColor3 = info.color
    accent.BorderSizePixel = 0
    accent.Parent = card
    corner(accent, 3)

    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, 22, 0, 0)
    icon.Size = UDim2.new(0, 44, 1, 0)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 28
    icon.Text = info.icon
    icon.Parent = card

    local nameLbl = Instance.new("TextLabel")
    nameLbl.BackgroundTransparency = 1
    nameLbl.Position = UDim2.new(0, 72, 0, 14)
    nameLbl.Size = UDim2.new(1, -150, 0, 22)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 15
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextColor3 = Color3.new(1, 1, 1)
    nameLbl.Text = info.name
    nameLbl.Parent = card

    local descLbl = Instance.new("TextLabel")
    descLbl.BackgroundTransparency = 1
    descLbl.Position = UDim2.new(0, 72, 0, 38)
    descLbl.Size = UDim2.new(1, -150, 0, 20)
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 12
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextColor3 = Color3.fromRGB(150, 155, 180)
    descLbl.Text = info.desc
    descLbl.Parent = card

    local pill = Instance.new("TextLabel")
    pill.AnchorPoint = Vector2.new(1, 0.5)
    pill.Position = UDim2.new(1, -14, 0.5, 0)
    pill.Size = UDim2.new(0, 64, 0, 28)
    pill.BackgroundColor3 = info.color
    pill.Font = Enum.Font.GothamBold
    pill.TextSize = 12
    pill.TextColor3 = Color3.new(1, 1, 1)
    pill.Text = "EXECUTE"
    pill.Parent = card
    corner(pill, 8)

    card.MouseEnter:Connect(function()
        tween(card, 0.2, { BackgroundColor3 = Color3.fromRGB(40, 43, 62) })
        tween(cardStroke, 0.2, { Transparency = 0 })
    end)
    card.MouseLeave:Connect(function()
        tween(card, 0.2, { BackgroundColor3 = Color3.fromRGB(30, 32, 46) })
        tween(cardStroke, 0.2, { Transparency = 0.55 })
    end)

    local busy, loaded = false, false
    card.MouseButton1Click:Connect(function()
        if busy then return end
        if loaded then
            notify("ℹ️ " .. info.name .. " is already loaded.", Color3.fromRGB(88, 160, 242), 3)
            return
        end

        busy = true
        pill.Text = "..."
        setStatus("🟡 Loading " .. info.name .. "...", Color3.fromRGB(255, 210, 90))
        notify(info.icon .. " Loading " .. info.name .. "...", info.color, 3)

        local ok, err = runRemote(info.url)

        if ok then
            loaded = true
            pill.Text = "LOADED"
            pill.BackgroundColor3 = Color3.fromRGB(46, 160, 90)
            setStatus("🟢 " .. info.name .. " loaded", Color3.fromRGB(90, 220, 140))
            notify("✅ " .. info.name .. " executed successfully!", Color3.fromRGB(46, 160, 90), 4)
        else
            pill.Text = "RETRY"
            setStatus("🔴 " .. info.name .. " failed", Color3.fromRGB(255, 100, 100))
            notify("❌ " .. info.name .. " failed:\n" .. tostring(err), Color3.fromRGB(230, 70, 70), 6)
        end
        busy = false
    end)
end

for i, info in ipairs(SCRIPTS) do
    makeScriptButton(info, 2 + i)
end

-- footer
local footer = Instance.new("TextLabel")
footer.LayoutOrder = 10
footer.BackgroundTransparency = 1
footer.Size = UDim2.new(1, 0, 0, 16)
footer.Font = Enum.Font.Gotham
footer.TextSize = 11
footer.TextColor3 = Color3.fromRGB(110, 115, 140)
footer.Text = "Drag the title bar to move • – to minimize"
footer.Parent = body

---------------------------------------------------------------------
-- DRAGGING
---------------------------------------------------------------------
do
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

---------------------------------------------------------------------
-- MINIMIZE / CLOSE
---------------------------------------------------------------------
local minimized = false
miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    miniBtn.Text = minimized and "+" or "–"
    tween(main, 0.3, { Size = minimized and MINI_SIZE or FULL_SIZE })
end)

closeBtn.MouseButton1Click:Connect(function()
    local t = tween(main, 0.3, { Size = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    t.Completed:Wait()
    gui:Destroy()
end)

---------------------------------------------------------------------
-- OPEN ANIMATION + LIVE NOTIFICATIONS
---------------------------------------------------------------------
tween(main, 0.5, { Size = FULL_SIZE }, Enum.EasingStyle.Back)

task.delay(0.6, function()
    notify("👋 Welcome, " .. LocalPlayer.DisplayName .. "! Hub loaded.", Color3.fromRGB(88, 101, 242), 4)
end)
task.delay(1.2, function()
    notify(WARNING_TEXT, Color3.fromRGB(255, 184, 0), 8)
end)

-- repeating live warning
task.spawn(function()
    while gui.Parent do
        task.wait(30)
        if not gui.Parent then break end
        notify(WARNING_TEXT, Color3.fromRGB(255, 184, 0), 6)
    end
end)
