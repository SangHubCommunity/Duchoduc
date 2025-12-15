-- ============================================
-- AUTO FARM SYSTEM v2.0 - COMPLETE FRAMEWORK
-- For Development & Testing Purposes Only
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ============================================
-- CORE MODULE
-- ============================================

local AutoFarmCore = {}
AutoFarmCore.__index = AutoFarmCore

-- State definitions
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
    
    -- Farm parameters
    self.StartLevel = 1
    self.TargetLevel = 30
    self.CurrentLevel = 1
    
    -- Configuration
    self.Config = {
        AutoEquip = true,
        AutoAcceptQuest = true,
        AutoSellDrops = false,
        SafeMode = true,
        DebugMode = false,
        HumanLikeDelays = true
    }
    
    -- Statistics
    self.Stats = {
        StartTime = 0,
        TotalTime = 0,
        MobsKilled = 0,
        QuestsCompleted = 0,
        LevelsGained = 0,
        Deaths = 0,
        ExperienceGained = 0
    }
    
    -- Internal references
    self.Player = Player
    self.Character = Character
    self.Humanoid = Character:WaitForChild("Humanoid")
    
    -- Modules
    self.EquipmentManager = nil
    self.QuestManager = nil
    self.CombatManager = nil
    self.NavigationManager = nil
    self.UI = nil
    
    -- Coroutine handles
    self.MainCoroutine = nil
    self.UpdateCoroutine = nil
    
    -- Event system
    self.Events = {
        OnStateChanged = Instance.new("BindableEvent"),
        OnLevelUp = Instance.new("BindableEvent"),
        OnQuestAccepted = Instance.new("BindableEvent"),
        OnMobKilled = Instance.new("BindableEvent"),
        OnError = Instance.new("BindableEvent")
    }
    
    -- Queues and buffers
    self.ActionQueue = {}
    self.DetectedMobs = {}
    self.AvailableQuests = {}
    
    -- Anti-pattern protection
    self.LastActions = {}
    self.ActionHistory = {}
    self.RandomizerSeed = math.random(1, 10000)
    
    return self
end

function AutoFarmCore:Initialize()
    print("[AutoFarm] Initializing system...")
    
    -- Load modules
    self:LoadModules()
    
    -- Setup event listeners
    self:SetupEventListeners()
    
    -- Initialize UI
    self:InitializeUI()
    
    -- Setup keybinds
    self:SetupKeybinds()
    
    print("[AutoFarm] System initialized successfully")
end

function AutoFarmCore:LoadModules()
    -- Equipment Manager
    self.EquipmentManager = {
        CurrentTool = nil,
        BestTool = nil,
        
        GetBestTool = function()
            local backpack = self.Player.Backpack
            local tools = {}
            
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(tools, item)
                end
            end
            
            if #tools > 0 then
                -- Simple selection - choose first sword/tool
                for _, tool in ipairs(tools) do
                    if string.find(tool.Name:lower(), "sword") or 
                       string.find(tool.Name:lower(), "dagger") or
                       string.find(tool.Name:lower(), "blade") then
                        return tool
                    end
                end
                return tools[1]
            end
            return nil
        end,
        
        EquipTool = function(tool)
            if tool and self.Character then
                tool.Parent = self.Character
                self.EquipmentManager.CurrentTool = tool
                print("[Equipment] Equipped: " .. tool.Name)
                return true
            end
            return false
        end,
        
        AutoEquip = function()
            local bestTool = self.EquipmentManager.GetBestTool()
            if bestTool then
                return self.EquipmentManager.EquipTool(bestTool)
            end
            return false
        end
    }
    
    -- Quest Manager
    self.QuestManager = {
        CurrentQuest = nil,
        QuestProgress = 0,
        QuestTarget = 0,
        
        QuestDatabase = {
            [1] = {Name = "Bandit", NPC = "Bandit Leader", Required = 10, Reward = 100},
            [5] = {Name = "Monkey", NPC = "Monkey Boss", Required = 15, Reward = 250},
            [10] = {Name = "Pirate", NPC = "Pirate Captain", Required = 20, Reward = 500},
            [15] = {Name = "Brute", NPC = "Brute Boss", Required = 25, Reward = 1000},
            [20] = {Name = "Desert", NPC = "Desert Bandit", Required = 30, Reward = 1500},
            [25] = {Name = "Snow", NPC = "Snow Bandit", Required = 35, Reward = 2000}
        },
        
        GetQuestForLevel = function(level)
            for minLevel, quest in pairs(self.QuestManager.QuestDatabase) do
                if level >= minLevel and level < minLevel + 5 then
                    return quest
                end
            end
            return self.QuestManager.QuestDatabase[1] -- Default
        end,
        
        AcceptQuest = function(quest)
            if quest then
                self.QuestManager.CurrentQuest = quest
                self.QuestManager.QuestProgress = 0
                self.QuestManager.QuestTarget = quest.Required
                
                print("[Quest] Accepted: " .. quest.Name .. " (Kill " .. quest.Required .. ")")
                self.Events.OnQuestAccepted:Fire(quest)
                return true
            end
            return false
        end,
        
        UpdateProgress = function()
            if self.QuestManager.CurrentQuest then
                self.QuestManager.QuestProgress = self.QuestManager.QuestProgress + 1
                
                if self.QuestManager.QuestProgress >= self.QuestManager.QuestTarget then
                    self:CompleteQuest()
                    return true
                end
            end
            return false
        end,
        
        CompleteQuest = function()
            if self.QuestManager.CurrentQuest then
                print("[Quest] Completed: " .. self.QuestManager.CurrentQuest.Name)
                self.QuestManager.CurrentQuest = nil
                self.Stats.QuestsCompleted = self.Stats.QuestsCompleted + 1
                
                -- Level up logic
                self.CurrentLevel = self.CurrentLevel + 1
                self.Stats.LevelsGained = self.Stats.LevelsGained + 1
                self.Events.OnLevelUp:Fire(self.CurrentLevel)
                
                return true
            end
            return false
        end
    }
    
    -- Combat Manager
    self.CombatManager = {
        CurrentTarget = nil,
        AttackRange = 15,
        AttackCooldown = 1,
        LastAttack = 0,
        
        FindNearestMob = function()
            local nearest = nil
            local nearestDist = math.huge
            local characterPos = self.Character.HumanoidRootPart.Position
            
            -- Simple mob detection (you need to customize based on your game)
            for _, mob in ipairs(Workspace:GetChildren()) do
                if mob:FindFirstChild("Humanoid") and 
                   mob:FindFirstChild("HumanoidRootPart") and
                   mob.Humanoid.Health > 0 then
                   
                    -- Check if it's an enemy (customize this)
                    if string.find(mob.Name:lower(), "bandit") or
                       string.find(mob.Name:lower(), "monkey") or
                       string.find(mob.Name:lower(), "pirate") then
                       
                        local dist = (mob.HumanoidRootPart.Position - characterPos).Magnitude
                        if dist < nearestDist and dist < 100 then
                            nearestDist = dist
                            nearest = mob
                        end
                    end
                end
            end
            
            return nearest
        end,
        
        AttackTarget = function(target)
            if not target or not target:FindFirstChild("Humanoid") then return false end
            
            local tool = self.EquipmentManager.CurrentTool
            if not tool then return false end
            
            -- Move to target
            self.NavigationManager.MoveTo(target.HumanoidRootPart.Position)
            
            -- Wait until in range
            local startTime = tick()
            while (target.HumanoidRootPart.Position - self.Character.HumanoidRootPart.Position).Magnitude > self.CombatManager.AttackRange do
                if tick() - startTime > 5 then break end -- Timeout
                RunService.Heartbeat:Wait()
            end
            
            -- Attack
            if tool:FindFirstChild("Activate") then
                tool.Activate:Fire()
            else
                -- Alternative attack method
                self.Character.Humanoid:LoadAnimation(tool:FindFirstChildOfType("Animation")):Play()
            end
            
            self.CombatManager.LastAttack = tick()
            self.Stats.MobsKilled = self.Stats.MobsKilled + 1
            self.Events.OnMobKilled:Fire(target)
            
            -- Quest progress
            self.QuestManager.UpdateProgress()
            
            return true
        end,
        
        AutoAttack = function()
            local target = self.CombatManager.FindNearestMob()
            if target then
                return self.CombatManager.AttackTarget(target)
            end
            return false
        end
    }
    
    -- Navigation Manager
    self.NavigationManager = {
        Moving = false,
        Destination = nil,
        
        MoveTo = function(position)
            self.NavigationManager.Moving = true
            self.NavigationManager.Destination = position
            
            -- Simple pathfinding (for demo - implement proper pathfinding)
            local humanoid = self.Character.Humanoid
            humanoid:MoveTo(position)
            
            -- Wait for arrival
            local startTime = tick()
            while (position - self.Character.HumanoidRootPart.Position).Magnitude > 5 do
                if tick() - startTime > 10 then break end -- Timeout
                RunService.Heartbeat:Wait()
            end
            
            self.NavigationManager.Moving = false
            return true
        end,
        
        FindQuestNPC = function(quest)
            -- Simple NPC finding (customize for your game)
            if quest and quest.NPC then
                for _, npc in ipairs(Workspace:GetChildren()) do
                    if npc.Name == quest.NPC then
                        return npc
                    end
                end
            end
            return nil
        end
    }
end

function AutoFarmCore:SetupEventListeners()
    -- Character death
    self.Humanoid.Died:Connect(function()
        self.Stats.Deaths = self.Stats.Deaths + 1
        print("[AutoFarm] Character died. Deaths: " .. self.Stats.Deaths)
        
        if self.State == AutoFarmCore.States.FARMING then
            task.wait(5) -- Respawn delay
            self:ResumeFarming()
        end
    end)
    
    -- Character added
    self.Player.CharacterAdded:Connect(function(char)
        self.Character = char
        self.Humanoid = char:WaitForChild("Humanoid")
        print("[AutoFarm] Character loaded")
    end)
end

function AutoFarmCore:InitializeUI()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFarmUI"
    screenGui.Parent = self.Player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(1, -370, 0.5, -250)
    mainFrame.AnchorPoint = Vector2.new(0, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    titleBar.Parent = mainFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Text = "🤖 AUTO FARM SYSTEM v2.0"
    titleText.Size = UDim2.new(1, -10, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0.5, -15)
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.white
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    -- Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Text = "▶ START FARMING (1-30)"
    toggleButton.Size = UDim2.new(0.9, 0, 0, 50)
    toggleButton.Position = UDim2.new(0.05, 0, 0.1, 40)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    toggleButton.TextColor3 = Color3.white
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 18
    toggleButton.Parent = mainFrame
    
    -- Status Display
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(0.9, 0, 0, 120)
    statusFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    statusFrame.Parent = mainFrame
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.Text = "📊 STATUS"
    statusTitle.Size = UDim2.new(1, 0, 0, 25)
    statusTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    statusTitle.TextColor3 = Color3.white
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.Parent = statusFrame
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Text = "Level: 1/30"
    levelLabel.Size = UDim2.new(1, -10, 0, 25)
    levelLabel.Position = UDim2.new(0, 5, 0, 30)
    levelLabel.BackgroundTransparency = 1
    levelLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Font = Enum.Font.Gotham
    levelLabel.Parent = statusFrame
    
    local stateLabel = Instance.new("TextLabel")
    stateLabel.Name = "StateLabel"
    stateLabel.Text = "State: IDLE"
    stateLabel.Size = UDim2.new(1, -10, 0, 25)
    stateLabel.Position = UDim2.new(0, 5, 0, 55)
    stateLabel.BackgroundTransparency = 1
    stateLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    stateLabel.TextXAlignment = Enum.TextXAlignment.Left
    stateLabel.Font = Enum.Font.Gotham
    stateLabel.Parent = statusFrame
    
    local questLabel = Instance.new("TextLabel")
    questLabel.Name = "QuestLabel"
    questLabel.Text = "Quest: None"
    questLabel.Size = UDim2.new(1, -10, 0, 25)
    questLabel.Position = UDim2.new(0, 5, 0, 80)
    questLabel.BackgroundTransparency = 1
    questLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    questLabel.TextXAlignment = Enum.TextXAlignment.Left
    questLabel.Font = Enum.Font.Gotham
    questLabel.Parent = statusFrame
    
    -- Progress Bar
    local progressFrame = Instance.new("Frame")
    progressFrame.Name = "ProgressFrame"
    progressFrame.Size = UDim2.new(0.9, 0, 0, 25)
    progressFrame.Position = UDim2.new(0.05, 0, 0.55, 0)
    progressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    progressFrame.Parent = mainFrame
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressFrame
    
    local progressText = Instance.new("TextLabel")
    progressText.Name = "ProgressText"
    progressText.Text = "0%"
    progressText.Size = UDim2.new(1, 0, 1, 0)
    progressText.BackgroundTransparency = 1
    progressText.TextColor3 = Color3.white
    progressText.Font = Enum.Font.GothamBold
    progressText.Parent = progressFrame
    
    -- Stats Panel
    local statsFrame = Instance.new("ScrollingFrame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Size = UDim2.new(0.9, 0, 0, 150)
    statsFrame.Position = UDim2.new(0.05, 0, 0.62, 0)
    statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    statsFrame.ScrollBarThickness = 5
    statsFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
    statsFrame.Parent = mainFrame
    
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Text = "📈 STATISTICS"
    statsTitle.Size = UDim2.new(1, 0, 0, 25)
    statsTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    statsTitle.TextColor3 = Color3.white
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.Parent = statsFrame
    
    -- Stats will be populated dynamically
    local statLabels = {
        "Mobs Killed: 0",
        "Quests Completed: 0",
        "Levels Gained: 0",
        "Deaths: 0",
        "Running Time: 0s"
    }
    
    for i, statText in ipairs(statLabels) do
        local label = Instance.new("TextLabel")
        label.Name = "Stat" .. i
        label.Text = statText
        label.Size = UDim2.new(1, -10, 0, 25)
        label.Position = UDim2.new(0, 5, 0, 25 + (i-1)*30)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(200, 255, 200)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = statsFrame
    end
    
    -- Config Panel
    local configFrame = Instance.new("Frame")
    configFrame.Name = "ConfigFrame"
    configFrame.Size = UDim2.new(0.9, 0, 0, 100)
    configFrame.Position = UDim2.new(0.05, 0, 0.85, 0)
    configFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    configFrame.Parent = mainFrame
    
    local configTitle = Instance.new("TextLabel")
    configTitle.Text = "⚙️ CONFIGURATION"
    configTitle.Size = UDim2.new(1, 0, 0, 25)
    configTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    configTitle.TextColor3 = Color3.white
    configTitle.Font = Enum.Font.GothamBold
    configTitle.Parent = configFrame
    
    -- Auto Equip Toggle
    local autoEquipToggle = Instance.new("TextButton")
    autoEquipToggle.Name = "AutoEquipToggle"
    autoEquipToggle.Text = "Auto Equip: ON"
    autoEquipToggle.Size = UDim2.new(0.45, 0, 0, 30)
    autoEquipToggle.Position = UDim2.new(0.025, 0, 0.5, 0)
    autoEquipToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    autoEquipToggle.TextColor3 = Color3.white
    autoEquipToggle.Font = Enum.Font.Gotham
    autoEquipToggle.Parent = configFrame
    
    autoEquipToggle.MouseButton1Click:Connect(function()
        self.Config.AutoEquip = not self.Config.AutoEquip
        autoEquipToggle.Text = "Auto Equip: " .. (self.Config.AutoEquip and "ON" or "OFF")
        autoEquipToggle.BackgroundColor3 = self.Config.AutoEquip and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
    
    -- Safe Mode Toggle
    local safeModeToggle = Instance.new("TextButton")
    safeModeToggle.Name = "SafeModeToggle"
    safeModeToggle.Text = "Safe Mode: ON"
    safeModeToggle.Size = UDim2.new(0.45, 0, 0, 30)
    safeModeToggle.Position = UDim2.new(0.525, 0, 0.5, 0)
    safeModeToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    safeModeToggle.TextColor3 = Color3.white
    safeModeToggle.Font = Enum.Font.Gotham
    safeModeToggle.Parent = configFrame
    
    safeModeToggle.MouseButton1Click:Connect(function()
        self.Config.SafeMode = not self.Config.SafeMode
        safeModeToggle.Text = "Safe Mode: " .. (self.Config.SafeMode and "ON" or "OFF")
        safeModeToggle.BackgroundColor3 = self.Config.SafeMode and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
    
    -- Store UI references
    self.UI = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        ToggleButton = toggleButton,
        LevelLabel = levelLabel,
        StateLabel = stateLabel,
        QuestLabel = questLabel,
        ProgressBar = progressBar,
        ProgressText = progressText,
        StatsFrame = statsFrame,
        ConfigFrame = configFrame
    }
    
    -- Connect toggle button
    toggleButton.MouseButton1Click:Connect(function()
        self:ToggleFarming()
    end)
end

function AutoFarmCore:SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        -- F6 to toggle farm
        if input.KeyCode == Enum.KeyCode.F6 then
            self:ToggleFarming()
            
        -- F7 to show/hide UI
        elseif input.KeyCode == Enum.KeyCode.F7 then
            self.UI.MainFrame.Visible = not self.UI.MainFrame.Visible
            
        -- F8 to emergency stop
        elseif input.KeyCode == Enum.KeyCode.F8 then
            self:StopFarming()
        end
    end)
end

function AutoFarmCore:UpdateUI()
    -- Update level display
    self.UI.LevelLabel.Text = string.format("Level: %d/30", self.CurrentLevel)
    
    -- Update state display
    self.UI.StateLabel.Text = string.format("State: %s", self.State)
    
    -- Update quest display
    local questText = "Quest: "
    if self.QuestManager.CurrentQuest then
        questText = questText .. string.format("%s (%d/%d)", 
            self.QuestManager.CurrentQuest.Name,
            self.QuestManager.QuestProgress,
            self.QuestManager.QuestTarget)
    else
        questText = questText .. "None"
    end
    self.UI.QuestLabel.Text = questText
    
    -- Update progress bar
    local progress = ((self.CurrentLevel - 1) / 29) * 100
    self.UI.ProgressBar.Size = UDim2.new(progress / 100, 0, 1, 0)
    self.UI.ProgressText.Text = string.format("%.1f%%", progress)
    
    -- Update statistics
    local statLabels = self.UI.StatsFrame:GetChildren()
    for i, label in ipairs(statLabels) do
        if label:IsA("TextLabel") and label.Name ~= "StatsTitle" then
            if i == 1 then
                label.Text = string.format("Mobs Killed: %d", self.Stats.MobsKilled)
            elseif i == 2 then
                label.Text = string.format("Quests Completed: %d", self.Stats.QuestsCompleted)
            elseif i == 3 then
                label.Text = string.format("Levels Gained: %d", self.Stats.LevelsGained)
            elseif i == 4 then
                label.Text = string.format("Deaths: %d", self.Stats.Deaths)
            elseif i == 5 then
                label.Text = string.format("Running Time: %ds", math.floor(tick() - self.Stats.StartTime))
            end
        end
    end
    
    -- Update toggle button
    if self.State == AutoFarmCore.States.FARMING then
        self.UI.ToggleButton.Text = "⏹ STOP FARMING"
        self.UI.ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        self.UI.ToggleButton.Text = "▶ START FARMING (1-30)"
        self.UI.ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    end
end

function AutoFarmCore:StartFarming()
    if self.State == AutoFarmCore.States.FARMING then
        print("[AutoFarm] Already farming")
        return
    end
    
    print("[AutoFarm] Starting auto farm...")
    
    -- Reset state
    self.State = AutoFarmCore.States.FARMING
    self.IsRunning = true
    self.CurrentLevel = self.StartLevel
    self.Stats.StartTime = tick()
    
    -- Start main coroutine
    self.MainCoroutine = coroutine.create(function()
        self:FarmLoop()
    end)
    
    coroutine.resume(self.MainCoroutine)
    
    -- Start UI update coroutine
    self.UpdateCoroutine = coroutine.create(function()
        while self.IsRunning do
            self:UpdateUI()
            task.wait(0.5)
        end
    end)
    
    coroutine.resume(self.UpdateCoroutine)
    
    self.Events.OnStateChanged:Fire(self.State)
    print("[AutoFarm] Farm started successfully")
end

function AutoFarmCore:StopFarming()
    if not self.IsRunning then return end
    
    print("[AutoFarm] Stopping farm...")
    
    self.IsRunning = false
    self.State = AutoFarmCore.States.IDLE
    
    -- Terminate coroutines
    if self.MainCoroutine then
        coroutine.close(self.MainCoroutine)
    end
    
    if self.UpdateCoroutine then
        coroutine.close(self.UpdateCoroutine)
    end
    
    self.Events.OnStateChanged:Fire(self.State)
    print("[AutoFarm] Farm stopped")
end

function AutoFarmCore:ToggleFarming()
    if self.State == AutoFarmCore.States.FARMING then
        self:StopFarming()
    else
        self:StartFarming()
    end
end

function AutoFarmCore:PauseFarming()
    if self.State == AutoFarmCore.States.FARMING then
        self.State = AutoFarmCore.States.PAUSED
        self.Events.OnStateChanged:Fire(self.State)
        print("[AutoFarm] Farming paused")
    end
end

function AutoFarmCore:ResumeFarming()
    if self.State == AutoFarmCore.States.PAUSED then
        self.State = AutoFarmCore.States.FARMING
        self.Events.OnStateChanged:Fire(self.State)
        print("[AutoFarm] Farming resumed")
    end
end

function AutoFarmCore:FarmLoop()
    while self.IsRunning and self.CurrentLevel < self.TargetLevel do
        -- Main farming cycle
        self:ExecuteFarmCycle()
        
        -- Add human-like delay if enabled
        if self.Config.HumanLikeDelays then
            local delay = 0.5 + math.random() * 2
            task.wait(delay)
        end
        
        -- Check for completion
        if self.CurrentLevel >= self.TargetLevel then
            self.State = AutoFarmCore.States.COMPLETED
            self.IsRunning = false
            self:UpdateUI()
            print("[AutoFarm] Target level reached! Farming completed.")
            break
        end
    end
end

function AutoFarmCore:ExecuteFarmCycle()
    -- 1. Ensure character exists
    if not self.Character or not self.Character:FindFirstChild("Humanoid") then
        print("[AutoFarm] Waiting for character...")
        task.wait(3)
        return
    end
    
    -- 2. Check health
    if self.Character.Humanoid.Health <= 0 then
        print("[AutoFarm] Character is dead, waiting for respawn...")
        task.wait(5)
        return
    end
    
    -- 3. Auto equip if enabled
    if self.Config.AutoEquip and not self.EquipmentManager.CurrentTool then
        self.EquipmentManager.AutoEquip()
    end
    
    -- 4. Get or accept quest
    if not self.QuestManager.CurrentQuest then
        local quest = self.QuestManager.GetQuestForLevel(self.CurrentLevel)
        if quest then
            self.QuestManager.AcceptQuest(quest)
        end
    end
    
    -- 5. Find and attack mobs
    local target = self.CombatManager.FindNearestMob()
    if target then
        -- Check if we need to equip better tool
        if self.Config.AutoEquip and tick() - (self.LastToolCheck or 0) > 30 then
            self.EquipmentManager.AutoEquip()
            self.LastToolCheck = tick()
        end
        
        -- Attack the target
        local success = self.CombatManager.AttackTarget(target)
        
        if success and self.Config.SafeMode then
            -- Safe mode: wait a bit after killing
            task.wait(1 + math.random())
        end
    else
        -- No mobs found, move around a bit
        if math.random() < 0.3 then
            local randomPos = self.Character.HumanoidRootPart.Position + 
                            Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
            self.NavigationManager.MoveTo(randomPos)
        end
        task.wait(2)
    end
    
    -- 6. Check quest completion
    if self.QuestManager.CurrentQuest and 
       self.QuestManager.QuestProgress >= self.QuestManager.QuestTarget then
        self.QuestManager.CompleteQuest()
    end
    
    -- 7. Record action for anti-pattern detection
    table.insert(self.ActionHistory, tick())
    if #self.ActionHistory > 10 then
        table.remove(self.ActionHistory, 1)
    end
end

function AutoFarmCore:GetHumanDelay()
    if not self.Config.HumanLikeDelays then return 0 end
    
    -- Generate more human-like delays
    local baseDelay = 0.3
    local randomDelay = math.random() * 1.5
    local thinkingDelay = math.random() * 0.8
    
    return baseDelay + randomDelay + thinkingDelay
end

function AutoFarmCore:Log(message)
    if self.Config.DebugMode then
        print("[AutoFarm DEBUG] " .. message)
    end
end

-- ============================================
-- MAIN EXECUTION
-- ============================================

-- Wait for game to fully load
task.wait(3)

-- Initialize Auto Farm System
local AutoFarm = AutoFarmCore.new()

-- Initialize the system
AutoFarm:Initialize()

-- Make it accessible globally for debugging
_G.AutoFarm = AutoFarm

print("=========================================")
print("🤖 AUTO FARM SYSTEM v2.0 LOADED")
print("=========================================")
print("Controls:")
print("  F6 - Start/Stop Farming")
print("  F7 - Show/Hide UI")
print("  F8 - Emergency Stop")
print("  UI Button - Start/Stop")
print("=========================================")
print("Target: Level 1 → 30")
print("Features: Auto Equip, Auto Quest, Statistics")
print("=========================================")

-- Auto-start if desired (comment out if not needed)
-- task.wait(5)
-- AutoFarm:StartFarming()

return AutoFarm