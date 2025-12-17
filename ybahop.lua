-- YBA NPC Finder Script
-- Tác giả: [Your Name Here]
-- Mô tả: Script tìm NPC "Jesus" trong game YBA (Your Bizarre Adventure)

-- Kiểm tra xem đang trong môi trường Roblox Studio không
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YBAJesusFinder"
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- Tạo main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Tạo corner radius
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Tạo shadow effect
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 80)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.BackgroundTransparency = 0
Title.Text = "YBA Jesus Finder"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Nội dung
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Trạng thái NPC
local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(1, 0, 0, 60)
StatusFrame.Position = UDim2.new(0, 0, 0, 0)
StatusFrame.BackgroundTransparency = 1
StatusFrame.Parent = Content

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(0.6, 0, 1, 0)
StatusLabel.Position = UDim2.new(0, 0, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái NPC Jesus:"
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 16
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusFrame

local StatusIcon = Instance.new("TextLabel")
StatusIcon.Name = "StatusIcon"
StatusIcon.Size = UDim2.new(0, 40, 0, 40)
StatusIcon.Position = UDim2.new(1, -40, 0.5, -20)
StatusIcon.BackgroundTransparency = 1
StatusIcon.Text = "❌"
StatusIcon.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusIcon.Font = Enum.Font.GothamBold
StatusIcon.TextSize = 30
StatusIcon.Parent = StatusFrame

-- Thông tin server
local ServerFrame = Instance.new("Frame")
ServerFrame.Name = "ServerFrame"
ServerFrame.Size = UDim2.new(1, 0, 0, 60)
ServerFrame.Position = UDim2.new(0, 0, 0, 70)
ServerFrame.BackgroundTransparency = 1
ServerFrame.Parent = Content

local ServerLabel = Instance.new("TextLabel")
ServerLabel.Name = "ServerLabel"
ServerLabel.Size = UDim2.new(0.6, 0, 1, 0)
ServerLabel.Position = UDim2.new(0, 0, 0, 0)
ServerLabel.BackgroundTransparency = 1
ServerLabel.Text = "Đang kiểm tra server..."
ServerLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
ServerLabel.Font = Enum.Font.Gotham
ServerLabel.TextSize = 16
ServerLabel.TextXAlignment = Enum.TextXAlignment.Left
ServerLabel.Parent = ServerFrame

local ServerIdLabel = Instance.new("TextLabel")
ServerIdLabel.Name = "ServerIdLabel"
ServerIdLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
ServerIdLabel.Position = UDim2.new(0.6, 0, 0, 0)
ServerIdLabel.BackgroundTransparency = 1
ServerIdLabel.Text = "ID: " .. game.JobId
ServerIdLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
ServerLabel.Font = Enum.Font.Gotham
ServerIdLabel.TextSize = 14
ServerIdLabel.TextXAlignment = Enum.TextXAlignment.Right
ServerIdLabel.Parent = ServerFrame

-- Nút điều khiển
local ControlFrame = Instance.new("Frame")
ControlFrame.Name = "ControlFrame"
ControlFrame.Size = UDim2.new(1, 0, 0, 40)
ControlFrame.Position = UDim2.new(0, 0, 1, -40)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = Content

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 100, 1, 0)
CloseButton.Position = UDim2.new(1, -100, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseButton.Text = "Đóng"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = ControlFrame

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(0, 6)
CloseButtonCorner.Parent = CloseButton

local HopButton = Instance.new("TextButton")
HopButton.Name = "HopButton"
HopButton.Size = UDim2.new(0, 100, 1, 0)
HopButton.Position = UDim2.new(0, 0, 0, 0)
HopButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
HopButton.Text = "Hop Server"
HopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HopButton.Font = Enum.Font.GothamBold
HopButton.TextSize = 14
HopButton.Parent = ControlFrame

local HopButtonCorner = Instance.new("UICorner")
HopButtonCorner.CornerRadius = UDim.new(0, 6)
HopButtonCorner.Parent = HopButton

-- Thêm chức năng di chuyển bằng cảm ứng (cho mobile)
local isDragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if isDragging and (input == dragInput) then
        updateInput(input)
    end
end)

-- Chức năng đóng GUI
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Biến và hàm chính
local foundJesus = false
local scanning = false
local hopDelay = 5 -- Thời gian chờ giữa các lần hop server (giây)

-- Hàm kiểm tra NPC Jesus
function checkForJesus()
    foundJesus = false
    
    -- Tìm tất cả các NPC trong workspace
    local workspaceChildren = workspace:GetChildren()
    
    for _, child in pairs(workspaceChildren) do
        if child:IsA("Model") and child.Name == "Jesus" then
            foundJesus = true
            break
        end
    end
    
    -- Kiểm tra trong các folder con
    if not foundJesus then
        for _, child in pairs(workspace:GetDescendants()) do
            if child:IsA("Model") and child.Name == "Jesus" then
                foundJesus = true
                break
            end
        end
    end
    
    -- Cập nhật GUI
    if foundJesus then
        StatusIcon.Text = "✔️"
        StatusIcon.TextColor3 = Color3.fromRGB(80, 255, 80)
        ServerLabel.Text = "Đã tìm thấy Jesus!"
        HopButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
        HopButton.Text = "Jesus Spawned!"
        
        -- Phát âm thanh thông báo (nếu có)
        if not scanning then
            warn("[YBA Finder] Đã tìm thấy NPC Jesus trong server!")
        end
    else
        StatusIcon.Text = "❌"
        StatusIcon.TextColor3 = Color3.fromRGB(255, 80, 80)
        ServerLabel.Text = "Không có Jesus"
        HopButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        HopButton.Text = "Hop Server"
    end
    
    return foundJesus
end

-- Hàm hop server
function hopServer()
    if scanning then return end
    
    scanning = true
    HopButton.BackgroundColor3 = Color3.fromRGB(200, 160, 60)
    HopButton.Text = "Đang hop..."
    
    -- Thử sử dụng dịch vụ TeleportService để chuyển server
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    
    -- Tìm server khác
    local success, result = pcall(function()
        -- Lấy PlaceId hiện tại
        local placeId = game.PlaceId
        
        -- Lấy thông tin server
        local servers = {}
        local page = "0"
        
        -- Thử tìm server (trong môi trường thực tế cần xử lý khác)
        return TeleportService:GetPlayerPlaceInstanceAsync(Players.LocalPlayer.UserId, placeId)
    end)
    
    if success then
        -- Nếu có thể lấy thông tin server
        ServerLabel.Text = "Đang chuyển server..."
        
        -- Trong thực tế, bạn sẽ cần một hàm hop server thực sự
        -- Đây chỉ là minh họa
        warn("[YBA Finder] Đang thử hop server...")
        
        -- Giả lập delay
        wait(hopDelay)
        
        -- Reset trạng thái
        scanning = false
        HopButton.Text = "Hop Server"
        HopButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        
        -- Trong thực tế, đây là nơi bạn sẽ gọi hàm hop server thực sự
        warn("[YBA Finder] Vui lòng thêm hàm hop server thực sự tại đây")
    else
        -- Nếu không thể hop server
        warn("[YBA Finder] Không thể hop server: " .. tostring(result))
        ServerLabel.Text = "Lỗi khi hop server"
        
        scanning = false
        HopButton.Text = "Thử lại"
        HopButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
end

-- Kết nối nút hop server
HopButton.MouseButton1Click:Connect(function()
    if not foundJesus then
        hopServer()
    else
        warn("[YBA Finder] Jesus đã spawn, không cần hop server!")
    end
end)

-- Hàm quét tự động
function autoScan()
    while true do
        -- Kiểm tra Jesus
        checkForJesus()
        
        -- Nếu không tìm thấy và đang ở chế độ tự động
        if not foundJesus and scanning then
            -- Tự động hop server sau một khoảng thời gian
            wait(hopDelay)
            hopServer()
        else
            -- Nếu đã tìm thấy, chỉ kiểm tra lại sau 10 giây
            wait(10)
        end
    end
end

-- Nút bật/tắt auto scan
local AutoScanButton = Instance.new("TextButton")
AutoScanButton.Name = "AutoScanButton"
AutoScanButton.Size = UDim2.new(0, 120, 0, 30)
AutoScanButton.Position = UDim2.new(0.5, -60, 0, 120)
AutoScanButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
AutoScanButton.Text = "Bật Auto Scan"
AutoScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoScanButton.Font = Enum.Font.GothamBold
AutoScanButton.TextSize = 14
AutoScanButton.Parent = Content

local AutoScanButtonCorner = Instance.new("UICorner")
AutoScanButtonCorner.CornerRadius = UDim.new(0, 6)
AutoScanButtonCorner.Parent = AutoScanButton

-- Xử lý nút auto scan
AutoScanButton.MouseButton1Click:Connect(function()
    scanning = not scanning
    
    if scanning then
        AutoScanButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
        AutoScanButton.Text = "Tắt Auto Scan"
        ServerLabel.Text = "Đang tự động quét..."
        warn("[YBA Finder] Đã bật chế độ tự động quét")
        
        -- Bắt đầu quét tự động trong một coroutine riêng
        spawn(function()
            while scanning do
                checkForJesus()
                
                if not foundJesus then
                    -- Nếu không tìm thấy, đợi một chút rồi hop
                    wait(hopDelay)
                    
                    if scanning and not foundJesus then
                        hopServer()
                    end
                else
                    -- Nếu tìm thấy, đợi lâu hơn trước khi kiểm tra lại
                    wait(30)
                end
                
                wait(0.1) -- Tránh lặp vô hạn
            end
        end)
    else
        AutoScanButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        AutoScanButton.Text = "Bật Auto Scan"
        ServerLabel.Text = "Tự động quét đã tắt"
        warn("[YBA Finder] Đã tắt chế độ tự động quét")
    end
end)

-- Kiểm tra lần đầu khi khởi động
checkForJesus()

-- Cập nhật thông tin server
ServerLabel.Text = "Server ID: " .. game.JobId

-- Thêm thông tin hướng dẫn
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoLabel"
InfoLabel.Size = UDim2.new(1, -20, 0, 40)
InfoLabel.Position = UDim2.new(0, 10, 0, 150)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Chạm và giữ để di chuyển GUI"
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 12
InfoLabel.TextXAlignment = Enum.TextXAlignment.Center
InfoLabel.Parent = MainFrame

-- Thông báo khởi động
warn("[YBA Finder] Script đã được khởi động!")
warn("[YBA Finder] Đang tìm NPC Jesus...")

-- Tự động kiểm tra khi có model mới được thêm vào workspace
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant.Name == "Jesus" then
        checkForJesus()
    end
end)

-- Cập nhật GUI mỗi 5 giây
spawn(function()
    while ScreenGui.Parent do
        checkForJesus()
        wait(5)
    end
end)

return ScreenGui