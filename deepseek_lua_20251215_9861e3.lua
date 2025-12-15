-- ============================================
-- AUTO FARM SYSTEM v2.5 - TOUCH ENABLED GUI
-- For Development & Testing Purposes Only
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ============================================
-- DRAGGABLE UI MODULE
-- ============================================

local DraggableUIModule = {}
DraggableUIModule.__index = DraggableUIModule

function DraggableUIModule.new(frame, dragButton)
    local self = setmetatable({}, DraggableUIModule)
    
    self.Frame = frame
    self.DragButton = dragButton or frame
    self.Dragging = false
    self.DragInput = nil
    self.DragStart = nil
    self.StartPosition = nil
    
    self:Initialize()
    
    return self
end

function DraggableUIModule:Initialize()
    -- Mouse and touch input handling
    local function updateInput(input)
        local delta = input.Position - self.DragStart
        local newPosition = UDim2.new(
            self.StartPosition.X.Scale,
            self.StartPosition.X.Offset + delta.X,
            self.StartPosition.Y.Scale,
            self.StartPosition.Y.Offset + delta.Y
        )
        
        -- Apply bounds checking
        newPosition = self:ApplyBounds(newPosition)
        
        -- Smooth movement with tween
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(self.Frame, tweenInfo, {Position = newPosition})
        tween:Play()
    end
    
    -- Mouse button down/touch started
    self.DragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            
            self.Dragging = true
            self.DragStart = input.Position
            self.StartPosition = self.Frame.Position
            
            -- Change button appearance when dragging
            if self.DragButton:IsA("GuiObject") then
                self.DragButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
            end
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.Dragging = false
                    if self.DragButton:IsA("GuiObject") then
                        self.DragButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
                    end
                end
            end)
        end
    end)
    
    -- Mouse/touch movement
    self.DragButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            self.DragInput = input
        end
    end)
    
    -- Handle input changed events
    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch) then
            updateInput(input)
        end
    end)
end

function DraggableUIModule:ApplyBounds(position)
    -- Get screen dimensions
    local screenSize = workspace.CurrentCamera.ViewportSize
    
    -- Get frame size
    local frameSize = self.Frame.AbsoluteSize
    
    -- Calculate bounds
    local minX = 0
    local maxX = screenSize.X - frameSize.X
    local minY = 0
    local maxY = screenSize.Y - frameSize.Y
    
    -- Convert UDim2 to absolute pixels
    local absX = position.X.Offset + (position.X.Scale * screenSize.X)
    local absY = position.Y.Offset + (position.Y.Scale * screenSize.Y)
    
    -- Clamp position
    absX = math.clamp(absX, minX, maxX)
    absY = math.clamp(absY, minY, maxY)
    
    -- Convert back to UDim2
    return UDim2.new(0, absX, 0, absY)
end

-- ============================================
-- TOUCH-OPTIMIZED BUTTON MODULE
-- ============================================

local TouchButtonModule = {}
TouchButtonModule.__index = TouchButtonModule

function TouchButtonModule.new(button)
    local self = setmetatable({}, TouchButtonModule)
    
    self.Button = button
    self.OriginalColor = button.BackgroundColor3
    self.OriginalSize = button.Size
    
    self:Initialize()
    
    return self
end

function TouchButtonModule:Initialize()
    -- Touch feedback
    self.Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            
            -- Visual feedback
            self.Button.BackgroundColor3 = Color3.fromRGB(
                math.clamp(self.OriginalColor.R * 255 * 0.7, 0, 255),
                math.clamp(self.OriginalColor.G * 255 * 0.7, 0, 255),
                math.clamp(self.OriginalColor.B * 255 * 0.7, 0, 255)
            )
            
            -- Slight scale effect for touch
            if input.UserInputType == Enum.UserInputType.Touch then
                local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(self.Button, tweenInfo, {
                    Size = UDim2.new(
                        self.OriginalSize.X.Scale * 0.95,
                        self.OriginalSize.X.Offset * 0.95,
                        self.OriginalSize.Y.Scale * 0.95,
                        self.OriginalSize.Y.Offset * 0.95
                    )
                })
                tween:Play()
            end
        end
    end)
    
    self.Button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            
            -- Restore original appearance
            self.Button.BackgroundColor3 = self.OriginalColor
            
            if input.UserInputType == Enum.UserInputType.Touch then
                local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(self.Button, tweenInfo, {Size = self.OriginalSize})
                tween:Play()
            end
        end
    end)
end

-- ============================================
-- TOUCH SCROLL MODULE
-- ============================================

local TouchScrollModule = {}
TouchScrollModule.__index = TouchScrollModule

function TouchScrollModule.new(scrollingFrame)
    local self = setmetatable({}, TouchScrollModule)
    
    self.ScrollingFrame = scrollingFrame
    self.IsScrolling = false
    self.ScrollStart = nil
    self.StartPosition = nil
    
    self:Initialize()
    
    return self
end

function TouchScrollModule:Initialize()
    self.ScrollingFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            self.IsScrolling = true
            self.ScrollStart = input.Position.Y
            self.StartPosition = self.ScrollingFrame.CanvasPosition.Y
        end
    end)
    
    self.ScrollingFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            self.IsScrolling = false
        end
    end)
    
    self.ScrollingFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and self.IsScrolling then
            local delta = self.ScrollStart - input.Position.Y
            local newPosition = self.StartPosition + delta
            
            -- Apply bounds
            newPosition = math.clamp(newPosition, 0, self.ScrollingFrame.CanvasSize.Y.Offset - self.ScrollingFrame.AbsoluteWindowSize.Y)
            
            -- Smooth scrolling
            local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(self.ScrollingFrame, tweenInfo, {CanvasPosition = Vector2.new(0, newPosition)})
            tween:Play()
        end
    end)
end

-- ============================================
-- AUTO FARM CORE (UPDATED WITH TOUCH UI)
-- ============================================

local AutoFarmCore = {}
AutoFarmCore.__index = AutoFarmCore

AutoFarmCore.States = {
    IDLE = "IDLE",
    FARMING = "FARMING",
    PAUSED = "PAUSED",
    COMPLETED = "COMPLETED",
    ERROR = "ERROR"
}

function AutoFarmCore.new()
    local self = setmetatable({}, AutoFarmCore)
    
    -- Core state
    self.State = AutoFarmCore.States.IDLE
    self.IsRunning = false
    self.CurrentLevel = 1
    self.TargetLevel = 30
    
    -- Configuration
    self.Config = {
        AutoEquip = true,
        AutoAcceptQuest = true,
        SafeMode = true,
        DebugMode = false,
        HumanLikeDelays = true,
        TouchMode = true  -- Thêm chế độ cảm ứng
    }
    
    -- Statistics
    self.Stats = {
        StartTime = 0,
        MobsKilled = 0,
        QuestsCompleted = 0,
        LevelsGained = 0,
        Deaths = 0
    }
    
    -- References
    self.Player = Player
    self.Character = Character
    
    -- UI Components
    self.UI = {}
    self.DraggableUI = nil
    
    -- Coroutines
    self.MainCoroutine = nil
    self.UpdateCoroutine = nil
    
    -- Events
    self.Events = {
        OnStateChanged = Instance.new("BindableEvent"),
        OnLevelUp = Instance.new("BindableEvent"),
        OnQuestAccepted = Instance.new("BindableEvent")
    }
    
    return self
end

function AutoFarmCore:InitializeUI()
    -- Tạo ScreenGui với ZIndexBehavior cho touch
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFarmUITouch"
    screenGui.Parent = self.Player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true  -- Quan trọng cho thiết bị di động
    
    -- Main Container với corner radius cho touch-friendly
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    
    -- Thêm corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Thêm shadow/drop shadow effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 16)
    shadowCorner.Parent = shadow
    
    shadow.Parent = mainFrame
    mainFrame.Parent = screenGui
    
    -- TITLE BAR với nút kéo - LÀM LỚN HƠN CHO TOUCH
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)  -- Cao hơn cho touch
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    titleBar.Parent = mainFrame
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Text = "🤖 AUTO FARM TOUCH"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18  -- To hơn cho touch
    titleText.TextScaled = false
    titleText.Parent = titleBar
    
    -- Touch Handle Icon (cho biết có thể kéo)
    local dragIcon = Instance.new("TextLabel")
    dragIcon.Name = "DragIcon"
    dragIcon.Text = "☰"
    dragIcon.Size = UDim2.new(0, 40, 0, 40)
    dragIcon.Position = UDim2.new(1, -50, 0.5, -20)
    dragIcon.AnchorPoint = Vector2.new(1, 0.5)
    dragIcon.BackgroundTransparency = 1
    dragIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
    dragIcon.Font = Enum.Font.GothamBold
    dragIcon.TextSize = 24
    dragIcon.Parent = titleBar
    
    -- Close/Minimize Button - LỚN HƠN
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "─"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -10, 0.5, -20)
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.white
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.Parent = titleBar
    
    -- MAIN TOGGLE BUTTON - RẤT LỚN CHO TOUCH
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Text = "▶ START FARMING"
    toggleButton.Size = UDim2.new(0.9, 0, 0, 70)  -- Rất cao
    toggleButton.Position = UDim2.new(0.05, 0, 0.12, 50)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    toggleButton.TextColor3 = Color3.white
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 22  -- Chữ to
    toggleButton.TextScaled = false
    toggleButton.AutoButtonColor = true
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleButton
    
    toggleButton.Parent = mainFrame
    
    -- STATUS PANEL
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(0.9, 0, 0, 150)  -- Cao hơn
    statusFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    statusFrame.BorderSizePixel = 0
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 10)
    statusCorner.Parent = statusFrame
    
    statusFrame.Parent = mainFrame
    
    -- Status Title
    local statusTitle = Instance.new("TextLabel")
    statusTitle.Text = "📊 STATUS"
    statusTitle.Size = UDim2.new(1, 0, 0, 35)  -- Cao hơn
    statusTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    statusTitle.TextColor3 = Color3.white
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.TextSize = 16
    
    local statusTitleCorner = Instance.new("UICorner")
    statusTitleCorner.CornerRadius = UDim.new(0, 10)
    statusTitleCorner.Parent = statusTitle
    
    statusTitle.Parent = statusFrame
    
    -- Level Label
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Text = "Level: 1/30"
    levelLabel.Size = UDim2.new(1, -20, 0, 30)
    levelLabel.Position = UDim2.new(0, 10, 0, 40)
    levelLabel.BackgroundTransparency = 1
    levelLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Font = Enum.Font.Gotham
    levelLabel.TextSize = 16
    levelLabel.Parent = statusFrame
    
    -- State Label
    local stateLabel = Instance.new("TextLabel")
    stateLabel.Name = "StateLabel"
    stateLabel.Text = "State: IDLE"
    stateLabel.Size = UDim2.new(1, -20, 0, 30)
    stateLabel.Position = UDim2.new(0, 10, 0, 75)
    stateLabel.BackgroundTransparency = 1
    stateLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    stateLabel.TextXAlignment = Enum.TextXAlignment.Left
    stateLabel.Font = Enum.Font.Gotham
    stateLabel.TextSize = 16
    stateLabel.Parent = statusFrame
    
    -- Quest Label
    local questLabel = Instance.new("TextLabel")
    questLabel.Name = "QuestLabel"
    questLabel.Text = "Quest: None"
    questLabel.Size = UDim2.new(1, -20, 0, 30)
    questLabel.Position = UDim2.new(0, 10, 0, 110)
    questLabel.BackgroundTransparency = 1
    questLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    questLabel.TextXAlignment = Enum.TextXAlignment.Left
    questLabel.Font = Enum.Font.Gotham
    questLabel.TextSize = 16
    questLabel.Parent = statusFrame
    
    -- PROGRESS BAR
    local progressFrame = Instance.new("Frame")
    progressFrame.Name = "ProgressFrame"
    progressFrame.Size = UDim2.new(0.9, 0, 0, 35)  -- Cao hơn
    progressFrame.Position = UDim2.new(0.05, 0, 0.6, 0)
    progressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    progressFrame.BorderSizePixel = 0
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 8)
    progressCorner.Parent = progressFrame
    
    progressFrame.Parent = mainFrame
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    progressBar.BorderSizePixel = 0
    
    local progressBarCorner = Instance.new("UICorner")
    progressBarCorner.CornerRadius = UDim.new(0, 8)
    progressBarCorner.Parent = progressBar
    
    progressBar.Parent = progressFrame
    
    local progressText = Instance.new("TextLabel")
    progressText.Name = "ProgressText"
    progressText.Text = "0%"
    progressText.Size = UDim2.new(1, 0, 1, 0)
    progressText.BackgroundTransparency = 1
    progressText.TextColor3 = Color3.white
    progressText.Font = Enum.Font.GothamBold
    progressText.TextSize = 16
    progressText.Parent = progressFrame
    
    -- STATS PANEL với scrolling touch-friendly
    local statsFrame = Instance.new("ScrollingFrame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Size = UDim2.new(0.9, 0, 0, 120)
    statsFrame.Position = UDim2.new(0.05, 0, 0.68, 0)
    statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    statsFrame.ScrollBarThickness = 8  -- Dày hơn cho touch
    statsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    statsFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
    statsFrame.BorderSizePixel = 0
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 10)
    statsCorner.Parent = statsFrame
    
    statsFrame.Parent = mainFrame
    
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Text = "📈 STATISTICS"
    statsTitle.Size = UDim2.new(1, 0, 0, 35)
    statsTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    statsTitle.TextColor3 = Color3.white
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.TextSize = 16
    
    local statsTitleCorner = Instance.new("UICorner")
    statsTitleCorner.CornerRadius = UDim.new(0, 10)
    statsTitleCorner.Parent = statsTitle
    
    statsTitle.Parent = statsFrame
    
    -- Thêm các stat labels
    local statLabels = {
        {name = "MobsKilled", text = "Mobs Killed: 0", pos = 40},
        {name = "QuestsCompleted", text = "Quests Completed: 0", pos = 75},
        {name = "LevelsGained", text = "Levels Gained: 0", pos = 110},
        {name = "Deaths", text = "Deaths: 0", pos = 145},
        {name = "Time", text = "Running Time: 0s", pos = 180}
    }
    
    for _, stat in ipairs(statLabels) do
        local label = Instance.new("TextLabel")
        label.Name = stat.name
        label.Text = stat.text
        label.Size = UDim2.new(1, -20, 0, 30)
        label.Position = UDim2.new(0, 10, 0, stat.pos)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(200, 255, 200)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = statsFrame
    end
    
    -- CONFIG PANEL với nút touch lớn
    local configFrame = Instance.new("Frame")
    configFrame.Name = "ConfigFrame"
    configFrame.Size = UDim2.new(0.9, 0, 0, 90)  -- Cao hơn
    configFrame.Position = UDim2.new(0.05, 0, 0.88, 0)
    configFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    configFrame.BorderSizePixel = 0
    
    local configCorner = Instance.new("UICorner")
    configCorner.CornerRadius = UDim.new(0, 10)
    configCorner.Parent = configFrame
    
    configFrame.Parent = mainFrame
    
    local configTitle = Instance.new("TextLabel")
    configTitle.Text = "⚙️ CONFIGURATION"
    configTitle.Size = UDim2.new(1, 0, 0, 30)
    configTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    configTitle.TextColor3 = Color3.white
    configTitle.Font = Enum.Font.GothamBold
    configTitle.TextSize = 16
    
    local configTitleCorner = Instance.new("UICorner")
    configTitleCorner.CornerRadius = UDim.new(0, 10)
    configTitleCorner.Parent = configTitle
    
    configTitle.Parent = configFrame
    
    -- Auto Equip Toggle Button - LỚN
    local autoEquipButton = Instance.new("TextButton")
    autoEquipButton.Name = "AutoEquipButton"
    autoEquipButton.Text = "Auto Equip: ON"
    autoEquipButton.Size = UDim2.new(0.45, 0, 0, 40)
    autoEquipButton.Position = UDim2.new(0.025, 0, 0.5, 5)
    autoEquipButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    autoEquipButton.TextColor3 = Color3.white
    autoEquipButton.Font = Enum.Font.Gotham
    autoEquipButton.TextSize = 14
    autoEquipButton.AutoButtonColor = true
    
    local equipCorner = Instance.new("UICorner")
    equipCorner.CornerRadius = UDim.new(0, 8)
    equipCorner.Parent = autoEquipButton
    
    autoEquipButton.Parent = configFrame
    
    -- Safe Mode Toggle Button - LỚN
    local safeModeButton = Instance.new("TextButton")
    safeModeButton.Name = "SafeModeButton"
    safeModeButton.Text = "Safe Mode: ON"
    safeModeButton.Size = UDim2.new(0.45, 0, 0, 40)
    safeModeButton.Position = UDim2.new(0.525, 0, 0.5, 5)
    safeModeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    safeModeButton.TextColor3 = Color3.white
    safeModeButton.Font = Enum.Font.Gotham
    safeModeButton.TextSize = 14
    safeModeButton.AutoButtonColor = true
    
    local safeCorner = Instance.new("UICorner")
    safeCorner.CornerRadius = UDim.new(0, 8)
    safeCorner.Parent = safeModeButton
    
    safeModeButton.Parent = configFrame
    
    -- THÊM NÚT ĐẶC BIỆT CHO TOUCH
    local quickActionsFrame = Instance.new("Frame")
    quickActionsFrame.Name = "QuickActions"
    quickActionsFrame.Size = UDim2.new(0.9, 0, 0, 50)
    quickActionsFrame.Position = UDim2.new(0.05, 0, 1.02, 0)
    quickActionsFrame.BackgroundTransparency = 1
    quickActionsFrame.Parent = mainFrame
    
    -- Emergency Stop Button (lớn, màu đỏ)
    local emergencyButton = Instance.new("TextButton")
    emergencyButton.Name = "EmergencyButton"
    emergencyButton.Text = "🛑 EMERGENCY STOP"
    emergencyButton.Size = UDim2.new(1, 0, 1, 0)
    emergencyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    emergencyButton.TextColor3 = Color3.white
    emergencyButton.Font = Enum.Font.GothamBold
    emergencyButton.TextSize = 16
    
    local emergencyCorner = Instance.new("UICorner")
    emergencyCorner.CornerRadius = UDim.new(0, 10)
    emergencyCorner.Parent = emergencyButton
    
    emergencyButton.Parent = quickActionsFrame
    
    -- Lưu references
    self.UI = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TitleBar = titleBar,
        ToggleButton = toggleButton,
        CloseButton = closeButton,
        LevelLabel = levelLabel,
        StateLabel = stateLabel,
        QuestLabel = questLabel,
        ProgressBar = progressBar,
        ProgressText = progressText,
        StatsFrame = statsFrame,
        AutoEquipButton = autoEquipButton,
        SafeModeButton = safeModeButton,
        EmergencyButton = emergencyButton
    }
    
    -- Khởi tạo Draggable UI
    self.DraggableUI = DraggableUIModule.new(mainFrame, titleBar)
    
    -- Khởi tạo Touch Buttons
    TouchButtonModule.new(toggleButton)
    TouchButtonModule.new(autoEquipButton)
    TouchButtonModule.new(safeModeButton)
    TouchButtonModule.new(emergencyButton)
    TouchButtonModule.new(closeButton)
    
    -- Khởi tạo Touch Scrolling
    TouchScrollModule.new(statsFrame)
    
    -- Kết nối sự kiện
    self:ConnectUIEvents()
end

function AutoFarmCore:ConnectUIEvents()
    -- Toggle Button
    self.UI.ToggleButton.MouseButton1Click:Connect(function()
        self:ToggleFarming()
    end)
    
    -- Close/Minimize Button
    self.UI.CloseButton.MouseButton1Click:Connect(function()
        self.UI.MainFrame.Visible = not self.UI.MainFrame.Visible
    end)
    
    -- Auto Equip Toggle
    self.UI.AutoEquipButton.MouseButton1Click:Connect(function()
        self.Config.AutoEquip = not self.Config.AutoEquip
        self.UI.AutoEquipButton.Text = "Auto Equip: " .. (self.Config.AutoEquip and "ON" or "OFF")
        self.UI.AutoEquipButton.BackgroundColor3 = self.Config.AutoEquip and 
            Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
    
    -- Safe Mode Toggle
    self.UI.SafeModeButton.MouseButton1Click:Connect(function()
        self.Config.SafeMode = not self.Config.SafeMode
        self.UI.SafeModeButton.Text = "Safe Mode: " .. (self.Config.SafeMode and "ON" or "OFF")
        self.UI.SafeModeButton.BackgroundColor3 = self.Config.SafeMode and 
            Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
    
    -- Emergency Stop
    self.UI.EmergencyButton.MouseButton1Click:Connect(function()
        self:StopFarming()
        
        -- Visual feedback
        self.UI.EmergencyButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        task.wait(0.3)
        self.UI.EmergencyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end)
    
    -- Touch gesture để ẩn/hiện UI
    local lastTapTime = 0
    UserInputService.TouchTap:Connect(function(touchPositions, processed)
        if processed then return end
        
        local currentTime = tick()
        if currentTime - lastTapTime < 0.3 then
            -- Double tap để ẩn/hiện UI
            self.UI.MainFrame.Visible = not self.UI.MainFrame.Visible
        end
        lastTapTime = currentTime
    end)
end

function AutoFarmCore:UpdateUI()
    -- Update level
    self.UI.LevelLabel.Text = string.format("Level: %d/30", self.CurrentLevel)
    
    -- Update state với màu sắc
    local stateColors = {
        IDLE = Color3.fromRGB(200, 200, 255),
        FARMING = Color3.fromRGB(100, 255, 100),
        PAUSED = Color3.fromRGB(255, 255, 100),
        COMPLETED = Color3.fromRGB(100, 200, 255),
        ERROR = Color3.fromRGB(255, 100, 100)
    }
    
    self.UI.StateLabel.Text = string.format("State: %s", self.State)
    self.UI.StateLabel.TextColor3 = stateColors[self.State] or Color3.fromRGB(200, 200, 255)
    
    -- Update quest
    local questText = "Quest: "
    if self.QuestManager and self.QuestManager.CurrentQuest then
        questText = questText .. string.format("%s (%d/%d)", 
            self.QuestManager.CurrentQuest.Name,
            self.QuestManager.QuestProgress or 0,
            self.QuestManager.QuestTarget or 0)
    else
        questText = questText .. "None"
    end
    self.UI.QuestLabel.Text = questText
    
    -- Update progress
    local progress = ((self.CurrentLevel - 1) / 29) * 100
    self.UI.ProgressBar.Size = UDim2.new(progress / 100, 0, 1, 0)
    self.UI.ProgressText.Text = string.format("%.1f%%", progress)
    
    -- Update stats
    if self.Stats then
        self.UI.StatsFrame.MobsKilled.Text = string.format("Mobs Killed: %d", self.Stats.MobsKilled or 0)
        self.UI.StatsFrame.QuestsCompleted.Text = string.format("Quests Completed: %d", self.Stats.QuestsCompleted or 0)
        self.UI.StatsFrame.LevelsGained.Text = string.format("Levels Gained: %d", self.Stats.LevelsGained or 0)
        self.UI.StatsFrame.Deaths.Text = string.format("Deaths: %d", self.Stats.Deaths or 0)
        self.UI.StatsFrame.Time.Text = string.format("Running Time: %ds", 
            math.floor((tick() - (self.Stats.StartTime or tick()))))
    end
    
    -- Update toggle button
    if self.State == AutoFarmCore.States.FARMING then
        self.UI.ToggleButton.Text = "⏹ STOP FARMING"
        self.UI.ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        self.UI.ToggleButton.Text = "▶ START FARMING"
        self.UI.ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    end
end

-- Các method khác giữ nguyên từ code trước...
function AutoFarmCore:Initialize()
    print("[AutoFarm] Initializing Touch UI System...")
    self:InitializeUI()
    self:LoadModules()
    self:SetupEventListeners()
    self:SetupKeybinds()
    print("[AutoFarm] Touch UI System initialized")
end

function AutoFarmCore:LoadModules()
    -- Simplified modules for demo
    self.QuestManager = {
        CurrentQuest = nil,
        QuestProgress = 0,
        QuestTarget = 0,
        
        GetQuestForLevel = function(level)
            return {Name = "Bandit", Required = 10}
        end,
        
        AcceptQuest = function(quest)
            self.QuestManager.CurrentQuest = quest
            self.QuestManager.QuestTarget = quest.Required
        end
    }
end

function AutoFarmCore:SetupEventListeners()
    -- Character events
    if self.Character then
        local humanoid = self.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                self.Stats.Deaths = (self.Stats.Deaths or 0) + 1
            end)
        end
    end
    
    self.Player.CharacterAdded:Connect(function(char)
        self.Character = char
    end)
end

function AutoFarmCore:SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        -- F6 to toggle
        if input.KeyCode == Enum.KeyCode.F6 then
            self:ToggleFarming()
        end
        
        -- F7 to show/hide
        if input.KeyCode == Enum.KeyCode.F7 then
            self.UI.MainFrame.Visible = not self.UI.MainFrame.Visible
        end
    end)
end

function AutoFarmCore:StartFarming()
    if self.State == AutoFarmCore.States.FARMING then return end
    
    self.State = AutoFarmCore.States.FARMING
    self.IsRunning = true
    self.Stats.StartTime = tick()
    
    -- Start farm loop
    self.MainCoroutine = coroutine.create(function()
        while self.IsRunning and self.CurrentLevel < self.TargetLevel do
            -- Simulate farming
            self.Stats.MobsKilled = (self.Stats.MobsKilled or 0) + 1
            
            -- Simulate quest progress
            if self.QuestManager.CurrentQuest then
                self.QuestManager.QuestProgress = (self.QuestManager.QuestProgress or 0) + 1
                
                if self.QuestManager.QuestProgress >= self.QuestManager.QuestTarget then
                    self.CurrentLevel = self.CurrentLevel + 1
                    self.Stats.LevelsGained = (self.Stats.LevelsGained or 0) + 1
                    self.Stats.QuestsCompleted = (self.Stats.QuestsCompleted or 0) + 1
                    self.QuestManager.CurrentQuest = nil
                    
                    if self.CurrentLevel >= self.TargetLevel then
                        self.State = AutoFarmCore.States.COMPLETED
                        self.IsRunning = false
                    end
                end
            else
                -- Accept new quest
                local quest = self.QuestManager.GetQuestForLevel(self.CurrentLevel)
                if quest then
                    self.QuestManager.AcceptQuest(quest)
                end
            end
            
            task.wait(1) -- Simulate delay
        end
    end)
    
    coroutine.resume(self.MainCoroutine)
    
    -- Start UI update
    self.UpdateCoroutine = coroutine.create(function()
        while self.IsRunning do
            self:UpdateUI()
            task.wait(0.5)
        end
    end)
    
    coroutine.resume(self.UpdateCoroutine)
    
    print("[AutoFarm] Farming started")
end

function AutoFarmCore:StopFarming()
    self.IsRunning = false
    self.State = AutoFarmCore.States.IDLE
    
    if self.MainCoroutine then
        coroutine.close(self.MainCoroutine)
    end
    
    if self.UpdateCoroutine then
        coroutine.close(self.UpdateCoroutine)
    end
    
    self:UpdateUI()
    print("[AutoFarm] Farming stopped")
end

function AutoFarmCore:ToggleFarming()
    if self.State == AutoFarmCore.States.FARMING then
        self:StopFarming()
    else
        self:StartFarming()
    end
end

-- ============================================
-- MAIN EXECUTION
-- ============================================

task.wait(3) -- Wait for game to load

local AutoFarm = AutoFarmCore.new()
AutoFarm:Initialize()

-- Make accessible globally
_G.AutoFarm = AutoFarm

print("========================================")
print("🤖 AUTO FARM TOUCH UI v2.5 LOADED")
print("========================================")
print("Touch Controls:")
print("  • Drag title bar to move")
print("  • Double tap screen to hide/show")
print("  • Large buttons for easy touch")
print("  • Touch-friendly scrolling")
print("========================================")
print("Keyboard Controls:")
print("  F6 - Start/Stop")
print("  F7 - Show/Hide UI")
print("========================================")

return AutoFarm