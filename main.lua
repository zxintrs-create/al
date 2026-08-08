-- [[ HEAVELYNE ART: PREMIUM HUD & PATH SYSTEM ]] --

-- [ 1. FRAME UTAMA ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "ContainerFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 360)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Visible = false

-- [ 2. SIDEBAR (MENU PANEL) ]
local MenuPanel = Instance.new("Frame", MainFrame)
MenuPanel.Name = "MenuPanel"
MenuPanel.Size = UDim2.new(0, 150, 1, -50)
MenuPanel.Position = UDim2.new(0, 0, 0, 50)
MenuPanel.BackgroundTransparency = 1

local MenuTitle = Instance.new("TextLabel", MenuPanel)
MenuTitle.Size = UDim2.new(1, 0, 0, 30)
MenuTitle.Text = "MENU"
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.BackgroundTransparency = 1

-- [ 3. SCROLLING LIST UNTUK SEMUA MENU ]
-- Di sinilah tempat Anda menambah menu baru (MAIN RP, SETTINGS, DLL)
local MenuListScroll = Instance.new("ScrollingFrame", MenuPanel)
MenuListScroll.Size = UDim2.new(1, 0, 1, -30)
MenuListScroll.Position = UDim2.new(0, 0, 0, 30)
MenuListScroll.BackgroundTransparency = 1
MenuListScroll.ScrollBarThickness = 2
MenuListScroll.CanvasSize = UDim2.new(0, 0, 0, 500) -- Sesuaikan jika list panjang

local ListLayout = Instance.new("UIListLayout", MenuListScroll)
ListLayout.Padding = UDim.new(0, 5)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [ 4. FUNGSI MENAMBAH MENU BARU ]
-- Anda cukup panggil ini untuk menambah MAIN RP atau fitur lain
local function addMenuButton(name, callback)
    local btn = Instance.new("TextButton", MenuListScroll)
    btn.Size = UDim2.new(0, 130, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
end

-- [ 5. IMPLEMENTASI FITUR (Contoh MAIN RP) ]
-- Jika ingin tambah fitur baru, tinggal tambahkan addMenuButton di bawah ini
addMenuButton("MAIN RP", function()
    print("Main RP Selected")
    -- Jalankan logika MAIN RP Anda di sini
end)

-- Anda bisa menambah menu lain dengan mudah tanpa mengacak fungsi:
addMenuButton("SETTINGS", function()
    print("Settings Selected")
end)
