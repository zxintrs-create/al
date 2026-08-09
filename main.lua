Pemain lokal = game:GetService("Pemain")
RunService lokal = permainan:GetService("RunService")
Layanan Tween lokal = game:GetService("Layanan Tween")
Pemain lokal = Pemain.PemainLokal

jika _G.AutoWalkScriptLoaded maka kembalikan akhir
_G.AutoWalkScriptLoaded = true

_G.recordData = _G.recordData atau {}
_G.perekaman = salah
_G.playing = false
_G.looping = false

karakter lokal, humanoid, hrp
fungsi lokal getChar()
    karakter = pemain.Karakter atau pemain.KarakterDitambahkan:Tunggu()
    humanoid = karakter:TungguAnak("Humanoid")
    hrp = karakter:TungguAnak("BagianAkarHumanoid")
akhir
getChar()

pemain.KarakterDitambahkan:Hubungkan(fungsi())
    getChar()
    buatGUI()
akhir)

Tema lokal = {
    MainBG = Color3.fromRGB(15, 15, 15),
    Aksen = Warna3.dariRGB(138, 43, 226),
    Sekunder = Warna3.dariRGB(30, 30, 30),
    Teks = Warna3.dariRGB(255, 255, 255),
    Font = Enum.Font.GothamBold
}

fungsi createGUI()
    jika _G.AutoWalkGUI maka
        _G.AutoWalkGUI:Hancurkan()
    akhir

    _G.AutoWalkGUI = Instance.new("ScreenGui")
    _G.AutoWalkGUI.Name = "PremiumAutoWalk"
    _G.AutoWalkGUI.Parent = player:WaitForChild("PlayerGui")

    mainFrame lokal = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 240, 0, 260)
    mainFrame.Position = UDim2.new(0.5, -120, 0.4, 0)
    mainFrame.BackgroundColor3 = Theme.MainBG
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = _G.AutoWalkGUI

    local mainCorner = Instance.new("UICorner")
    Sudut utama.Radius sudut = UDim.baru(0, 12)
    Sudut utama.Induk = Bingkai utama

    local mainStroke = Instance.new("UIStroke")
    Ketebalan Garis Utama = 2
    mainStroke.Color = Theme.Accent
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Theme.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    Sudut Judul.Induk = Bilah Judul

    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 150))
    })
    titleGradient.Parent = titleBar

    Label judul lokal = Instance.new("Label Teks")
    Ukuran Label Judul = UDim2.baru(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "PREMIUM AUTO-WALK"
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Theme.Font
    Ukuran Teks Label Judul = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Theme.Text
    closeBtn.Font = Theme.Font
    Ukuran Teks Tombol Tutup = 14
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    status lokal = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Posisi = UDim2.baru(0, 10, 1, -30)
    status.TransparansiLatarBelakang = 1
    status.TeksWarna3 = Warna3.dariRGB(180, 180, 180)
    status.Text = "Status: Tidak Aktif"
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.Induk = mainFrame

    fungsi lokal makeButton(teks, posY, callback)
        local btn = Instance.new("TextButton")
        Ukuran tombol = UDim2.baru(1, -30, 0, 35)
        btn.Posisi = UDim2.baru(0, 15, 0, posY)
        btn.BackgroundColor3 = Theme.Secondary
        btn.TextColor3 = Theme.Text
        btn.Font = Theme.Font
        Ukuran Teks tombol = 13
        tombol.Teks = teks
        WarnaTombolOtomatis = benar
        btn.Parent = mainFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Ketebalan = 1
        btnStroke.Color = Theme.Accent
        btnStroke.Transparency = 0.5
        btnStroke.Parent = btn

        btn.MouseButton1Click:Connect(function()
            btn.BackgroundColor3 = Theme.Accent
            tugas.tunggu(0.1)
            btn.BackgroundColor3 = Theme.Secondary
            callback()
        akhir)
        kembali tombol
    akhir

    koneksi lokal
    fungsi lokal startRecord()
        _G.perekaman = benar
        _G.recordData = {}
        status.Text = "Status: Sedang merekam..."
        local startTick = tick()
        conn = RunService.Heartbeat:Connect(function()
            jika tidak hrp maka kembalikan akhir
            table.insert(_G.recordData, {cf = hrp.CFrame, jump = humanoid.Jump, t = tick() - startTick})
        akhir)
    akhir

    fungsi lokal stopRecord()
        _G.perekaman = salah
        jika terhubung maka terhubung:Putuskan sambungan()
        status.Text = "Status: Direkam " .. tostring(#_G.recordData) .. " langkah"
    akhir

    fungsi lokal playRecord()
        jika #_G.recordData == 0 atau _G.playing maka kembalikan
        _G.playing = true
        status.Text = "Status: Sedang diputar..."
        local startTick = tick()
        untuk i, langkah dalam ipairs(_G.recordData) lakukan
            jika tidak _G.playing maka break end
            waktu tunggu lokal = (startTick + step.t) - tick()
            Jika waitTime > 0 maka task.wait(waitTime) selesai

            local targetPos = step.cf.Position
            jarak lokal = (hrp.Posisi - targetPosisi).Besaran
            jika dist > 15 maka hrp.CFrame = step.cf else humanoid:MoveTo(targetPos) end
            Jika langkah.lompat maka humanoid.Lompat = benar
        akhir
        _G.playing = false
        status.Text = "Status: Selesai"
    akhir

    fungsi lokal stopPlay()
        _G.playing = false
        _G.looping = false
        status.Text = "Status: Berhenti"
    akhir

    fungsi lokal loopRecord()
        jika #_G.recordData == 0 atau _G.looping maka kembalikan akhir
        _G.looping = true
        status.Text = "Status: Berulang..."
        tugas.munculkan(fungsi())
            sementara _G.looping lakukan
                playRecord()
                tugas.tunggu(0.1)
            akhir
        akhir)
    akhir

    fungsi lokal stopLoop()
        _G.looping = false
        status.Text = "Status: Loop Dihentikan"
    akhir

    makeButton("Mulai Merekam", 55, startRecord)
    makeButton("Stop Recording", 95, stopRecord)
    makeButton("Putar Rekaman", 135, playRecord)
    makeButton("Hentikan Eksekusi", 175, stopPlay)
    makeButton("Loop Tak Terbatas", 215, loopRecord)
    makeButton("Stop Loop", 255, stopLoop)

    mainFrame.Size = UDim2.new(0, 240, 0, 300)

    closeBtn.MouseButton1Click:Connect(function()
        _G.AutoWalkGUI:Hancurkan()
    akhir)
akhir

buatGUI()
