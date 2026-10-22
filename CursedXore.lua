local G2L = {};

-- StarterGui.OPF:R UPDATED
G2L["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["IgnoreGuiInset"] = true;
G2L["1"]["ScreenInsets"] = Enum.ScreenInsets.None;
G2L["1"]["Name"] = [[OPF:R UPDATED]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
G2L["1"]["ResetOnSpawn"] = false;


-- StarterGui.OPF:R UPDATED.Scrollup
G2L["2"] = Instance.new("LocalScript", G2L["1"]);
G2L["2"]["Name"] = [[Scrollup]];


-- StarterGui.OPF:R UPDATED.txtbox
G2L["3"] = Instance.new("LocalScript", G2L["1"]);
G2L["3"]["Name"] = [[txtbox]];


-- StarterGui.OPF:R UPDATED.LocalScript
G2L["4"] = Instance.new("LocalScript", G2L["1"]);



-- StarterGui.OPF:R UPDATED.MainFrame
G2L["5"] = Instance.new("Frame", G2L["1"]);
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(230, 76, 60);
G2L["5"]["Selectable"] = true;
G2L["5"]["ClipsDescendants"] = true;
G2L["5"]["Size"] = UDim2.new(0, 442, 0, 293);
G2L["5"]["Position"] = UDim2.new(0, 300, 0, 250);
G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5"]["Name"] = [[MainFrame]];
G2L["5"]["BackgroundTransparency"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Smooth GUI Dragging
G2L["6"] = Instance.new("LocalScript", G2L["5"]);
G2L["6"]["Name"] = [[Smooth GUI Dragging]];


-- StarterGui.OPF:R UPDATED.MainFrame.Darkness
G2L["7"] = Instance.new("ImageButton", G2L["5"]);
G2L["7"]["BorderSizePixel"] = 0;
G2L["7"]["Visible"] = false;
G2L["7"]["BackgroundTransparency"] = 0.8;
G2L["7"]["BackgroundColor3"] = Color3.fromRGB(46, 50, 46);
G2L["7"]["ZIndex"] = 10;
G2L["7"]["Size"] = UDim2.new(0, 272, 0, 273);
G2L["7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["7"]["Name"] = [[Darkness]];
G2L["7"]["Position"] = UDim2.new(0.385, 0, 0.06857, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Darkness.LocalScript
G2L["8"] = Instance.new("LocalScript", G2L["7"]);



-- StarterGui.OPF:R UPDATED.MainFrame.TopBar
G2L["9"] = Instance.new("Frame", G2L["5"]);
G2L["9"]["BorderSizePixel"] = 0;
G2L["9"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["9"]["Size"] = UDim2.new(0, 442, 0, 44);
G2L["9"]["Position"] = UDim2.new(-0, 0, 0.06857, 0);
G2L["9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["9"]["Name"] = [[TopBar]];


-- StarterGui.OPF:R UPDATED.MainFrame.TopBar.Title
G2L["a"] = Instance.new("TextLabel", G2L["9"]);
G2L["a"]["TextWrapped"] = true;
G2L["a"]["ZIndex"] = 3;
G2L["a"]["BorderSizePixel"] = 0;
G2L["a"]["TextSize"] = 54;
G2L["a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["a"]["TextScaled"] = true;
G2L["a"]["BackgroundColor3"] = Color3.fromRGB(168, 235, 255);
G2L["a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["a"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a"]["BackgroundTransparency"] = 1;
G2L["a"]["Size"] = UDim2.new(0, 160, 0, 35);
G2L["a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["a"]["Text"] = [[OPFinality Revived]];
G2L["a"]["Name"] = [[Title]];
G2L["a"]["Position"] = UDim2.new(0.31674, 0, 0.09302, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.TopBar.OpenMenu
G2L["b"] = Instance.new("ImageButton", G2L["9"]);
G2L["b"]["BorderSizePixel"] = 0;
G2L["b"]["BackgroundTransparency"] = 1;
G2L["b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b"]["Image"] = [[rbxassetid://1280184088]];
G2L["b"]["Size"] = UDim2.new(0.091, 0, 1.02, 0);
G2L["b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["b"]["Name"] = [[OpenMenu]];


-- StarterGui.OPF:R UPDATED.MainFrame.TopBar.OpenMenu.LocalScript
G2L["c"] = Instance.new("LocalScript", G2L["b"]);



-- StarterGui.OPF:R UPDATED.MainFrame.TopBar2
G2L["d"] = Instance.new("Frame", G2L["5"]);
G2L["d"]["BorderSizePixel"] = 0;
G2L["d"]["BackgroundColor3"] = Color3.fromRGB(192, 57, 43);
G2L["d"]["Size"] = UDim2.new(0, 442, 0, 20);
G2L["d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["d"]["Name"] = [[TopBar2]];


-- StarterGui.OPF:R UPDATED.MainFrame.TopBar2.minimize
G2L["e"] = Instance.new("TextButton", G2L["d"]);
G2L["e"]["BorderSizePixel"] = 0;
G2L["e"]["TextSize"] = 25;
G2L["e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["e"]["FontFace"] = Font.new([[rbxasset://fonts/families/ComicNeueAngular.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["e"]["BackgroundTransparency"] = 1;
G2L["e"]["Size"] = UDim2.new(0, 19, 0, 16);
G2L["e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["e"]["Text"] = [[X]];
G2L["e"]["Name"] = [[minimize]];
G2L["e"]["Position"] = UDim2.new(0.95435, 0, 0.1, 0);
G2L["f"] = Instance.new("LocalScript", G2L["e"]);

G2L["10"] = Instance.new("Frame", G2L["5"]);
G2L["10"]["ZIndex"] = 2;
G2L["10"]["BorderSizePixel"] = 0;
G2L["10"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["10"]["ClipsDescendants"] = true;
G2L["10"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["10"]["Position"] = UDim2.new(0, 0, 0.21755, 0);
G2L["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["10"]["Name"] = [[Pages]];

G2L["11"] = Instance.new("LocalScript", G2L["10"]);
G2L["11"]["Name"] = [[Handler]];

G2L["12"] = Instance.new("LocalScript", G2L["10"]);
G2L["12"]["Enabled"] = false;
G2L["12"]["Name"] = [[bruh]];
G2L["12"]["Disabled"] = true;

G2L["13"] = Instance.new("Frame", G2L["10"]);
G2L["13"]["ZIndex"] = 2;
G2L["13"]["BorderSizePixel"] = 0;
G2L["13"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["13"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["13"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["13"]["Name"] = [[PageInfo]];

G2L["14"] = Instance.new("Frame", G2L["13"]);
G2L["14"]["ZIndex"] = 2;
G2L["14"]["BorderSizePixel"] = 0;
G2L["14"]["BackgroundColor3"] = Color3.fromRGB(53, 152, 220);
G2L["14"]["Size"] = UDim2.new(0.81821, 0, 0.227, 0);
G2L["14"]["Position"] = UDim2.new(0.18179, 0, 0.36385, 0);
G2L["14"]["Name"] = [[Info_Background]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.PageInfo.Info_Bar
G2L["15"] = Instance.new("Frame", G2L["13"]);
G2L["15"]["BorderSizePixel"] = 0;
G2L["15"]["BackgroundColor3"] = Color3.fromRGB(41, 129, 185);
G2L["15"]["Size"] = UDim2.new(0.02272, 0, 0.2274, 0);
G2L["15"]["Position"] = UDim2.new(0.15907, 0, 0.36385, 0);
G2L["15"]["Name"] = [[Info_Bar]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.PageInfo.Warning_Background
G2L["16"] = Instance.new("Frame", G2L["13"]);
G2L["16"]["BorderSizePixel"] = 0;
G2L["16"]["BackgroundColor3"] = Color3.fromRGB(241, 197, 15);
G2L["16"]["Size"] = UDim2.new(0.70445, 0, 0.31955, 0);
G2L["16"]["Position"] = UDim2.new(0, 0, 0.63673, 0);
G2L["16"]["Name"] = [[Warning_Background]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.PageInfo.Warning_Bar
G2L["17"] = Instance.new("Frame", G2L["13"]);
G2L["17"]["BorderSizePixel"] = 0;
G2L["17"]["BackgroundColor3"] = Color3.fromRGB(243, 157, 18);
G2L["17"]["Size"] = UDim2.new(0.02272, 0, 0.31955, 0);
G2L["17"]["Position"] = UDim2.new(0.70445, 0, 0.63673, 0);
G2L["17"]["Name"] = [[Warning_Bar]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.PageInfo.Image_FE_ENABLED
G2L["18"] = Instance.new("ImageLabel", G2L["13"]);
G2L["18"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["18"]["Image"] = [[http://www.roblox.com/asset/?id=1281289312]];
G2L["18"]["Size"] = UDim2.new(0.13635, 0, 0.26339, 0);
G2L["18"]["BackgroundTransparency"] = 1;
G2L["18"]["Name"] = [[Image_FE_ENABLED]];
G2L["18"]["Position"] = UDim2.new(0.02272, 0, 0.04548, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.PageInfo.Info_Image
G2L["19"] = Instance.new("ImageLabel", G2L["13"]);
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["19"]["Image"] = [[http://www.roblox.com/asset/?id=1281284684]];
G2L["19"]["Size"] = UDim2.new(0.0909, 0, 0.1756, 0);
G2L["19"]["BackgroundTransparency"] = 1;
G2L["19"]["Name"] = [[Info_Image]];
G2L["19"]["Position"] = UDim2.new(0.04545, 0, 0.39509, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.PageInfo.Warn_Image
G2L["1a"] = Instance.new("ImageLabel", G2L["13"]);
G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1a"]["Image"] = [[http://www.roblox.com/asset/?id=1281286925]];
G2L["1a"]["Size"] = UDim2.new(0.0909, 0, 0.1756, 0);
G2L["1a"]["BackgroundTransparency"] = 1;
G2L["1a"]["Name"] = [[Warn_Image]];
G2L["1a"]["Position"] = UDim2.new(0.74038, 0, 0.678, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.PageInfo.OPFin_Description
G2L["1b"] = Instance.new("TextLabel", G2L["13"]);
G2L["1b"]["TextWrapped"] = true;
G2L["1b"]["ZIndex"] = 3;
G2L["1b"]["TextSize"] = 18;
G2L["1b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1b"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1b"]["BackgroundTransparency"] = 1;
G2L["1b"]["Size"] = UDim2.new(0.78167, 0, 0.18192, 0);
G2L["1b"]["Text"] = [[OPFinality Revived is an FE GUI developed by Urban1 made for giving you power in Filtering Enabled games.]];
G2L["1b"]["Name"] = [[OPFin_Description]];
G2L["1b"]["Position"] = UDim2.new(0.19595, 0, 0.388, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.PageInfo.OPFin_Warning
G2L["1c"] = Instance.new("TextLabel", G2L["13"]);
G2L["1c"]["TextWrapped"] = true;
G2L["1c"]["ZIndex"] = 2;
G2L["1c"]["TextSize"] = 18;
G2L["1c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1c"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1c"]["BackgroundTransparency"] = 1;
G2L["1c"]["Size"] = UDim2.new(0.659, 0, 0.31955, 0);
G2L["1c"]["Text"] = [[This script was originally coded by illremember, used in FE games. Because of roblox patching exploits, many have been added or removed.]];
G2L["1c"]["Name"] = [[OPFin_Warning]];
G2L["1c"]["Position"] = UDim2.new(0.02272, 0, 0.63673, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.PageInfo.Text_FE_ENABLED
G2L["1d"] = Instance.new("TextLabel", G2L["13"]);
G2L["1d"]["TextSize"] = 19;
G2L["1d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["1d"]["BackgroundTransparency"] = 1;
G2L["1d"]["Size"] = UDim2.new(0.79535, 0, 0.2274, 0);
G2L["1d"]["Text"] = [[This game is Filtering Enabled! Enjoy using OPFinality]];
G2L["1d"]["Name"] = [[Text_FE_ENABLED]];
G2L["1d"]["Position"] = UDim2.new(0.159, 0, 0.067, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.PageInfo.WhatIsOPFinality
G2L["1e"] = Instance.new("TextLabel", G2L["13"]);
G2L["1e"]["TextSize"] = 25;
G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["1e"]["BackgroundTransparency"] = 1;
G2L["1e"]["Size"] = UDim2.new(0.52266, 0, 0.13644, 0);
G2L["1e"]["Text"] = [[What is OPFinality Revived?]];
G2L["1e"]["Name"] = [[WhatIsOPFinality]];
G2L["1e"]["Position"] = UDim2.new(0.24997, 0, 0.2274, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1
G2L["1f"] = Instance.new("Frame", G2L["10"]);
G2L["1f"]["ZIndex"] = 2;
G2L["1f"]["BorderSizePixel"] = 0;
G2L["1f"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1f"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["1f"]["Position"] = UDim2.new(1.005, 0, 0, 0);
G2L["1f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1f"]["Name"] = [[Character_1]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar
G2L["20"] = Instance.new("Frame", G2L["1f"]);
G2L["20"]["BorderSizePixel"] = 0;
G2L["20"]["BackgroundColor3"] = Color3.fromRGB(39, 175, 97);
G2L["20"]["Size"] = UDim2.new(0, 92, 0, 118);
G2L["20"]["Position"] = UDim2.new(0.077, 0, 0.483, 0);
G2L["20"]["Name"] = [[BackGroundChar]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar.HipHeight
G2L["21"] = Instance.new("TextButton", G2L["20"]);
G2L["21"]["BorderSizePixel"] = 0;
G2L["21"]["TextSize"] = 22;
G2L["21"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["21"]["BackgroundColor3"] = Color3.fromRGB(46, 205, 113);
G2L["21"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["21"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["21"]["Text"] = [[HipHeight]];
G2L["21"]["Name"] = [[HipHeight]];
G2L["21"]["Position"] = UDim2.new(0, 0, 0.67905, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar.HipHeight.LocalScript
G2L["22"] = Instance.new("LocalScript", G2L["21"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar.JumpHeight
G2L["23"] = Instance.new("TextButton", G2L["20"]);
G2L["23"]["BorderSizePixel"] = 0;
G2L["23"]["TextSize"] = 20;
G2L["23"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["23"]["BackgroundColor3"] = Color3.fromRGB(46, 205, 113);
G2L["23"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["23"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["23"]["Text"] = [[JumpHeight]];
G2L["23"]["Name"] = [[JumpHeight]];
G2L["23"]["Position"] = UDim2.new(0, 0, 0.38197, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar.JumpHeight.LocalScript
G2L["24"] = Instance.new("LocalScript", G2L["23"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar.Speed
G2L["25"] = Instance.new("TextButton", G2L["20"]);
G2L["25"]["BorderSizePixel"] = 0;
G2L["25"]["TextSize"] = 22;
G2L["25"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["25"]["BackgroundColor3"] = Color3.fromRGB(46, 205, 113);
G2L["25"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["25"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["25"]["Text"] = [[Speed]];
G2L["25"]["Name"] = [[Speed]];
G2L["25"]["Position"] = UDim2.new(0, 0, 0.08488, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar.Speed.LocalScript
G2L["26"] = Instance.new("LocalScript", G2L["25"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar2
G2L["27"] = Instance.new("Frame", G2L["1f"]);
G2L["27"]["BorderSizePixel"] = 0;
G2L["27"]["BackgroundColor3"] = Color3.fromRGB(39, 175, 97);
G2L["27"]["Size"] = UDim2.new(0, 242, 0, 40);
G2L["27"]["Position"] = UDim2.new(0.372, 0, 0.47427, 0);
G2L["27"]["Name"] = [[BackGroundChar2]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar2.EditLast
G2L["28"] = Instance.new("TextButton", G2L["27"]);
G2L["28"]["BorderSizePixel"] = 0;
G2L["28"]["TextSize"] = 22;
G2L["28"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["28"]["BackgroundColor3"] = Color3.fromRGB(46, 205, 113);
G2L["28"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["28"]["Size"] = UDim2.new(0, 100, 0, 25);
G2L["28"]["Text"] = [[Edit Last]];
G2L["28"]["Name"] = [[EditLast]];
G2L["28"]["Position"] = UDim2.new(0.06203, 0, 0.1252, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar2.EditLast.LocalScript
G2L["29"] = Instance.new("LocalScript", G2L["28"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar2.FilterBypass
G2L["2a"] = Instance.new("TextButton", G2L["27"]);
G2L["2a"]["BorderSizePixel"] = 0;
G2L["2a"]["TextSize"] = 22;
G2L["2a"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["2a"]["BackgroundColor3"] = Color3.fromRGB(46, 205, 113);
G2L["2a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["2a"]["Size"] = UDim2.new(0, 100, 0, 25);
G2L["2a"]["Text"] = [[Filter Bypass]];
G2L["2a"]["Name"] = [[FilterBypass]];
G2L["2a"]["Position"] = UDim2.new(0.52484, 0, 0.1252, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar2.FilterBypass.LocalScript
G2L["2b"] = Instance.new("LocalScript", G2L["2a"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar3
G2L["2c"] = Instance.new("Frame", G2L["1f"]);
G2L["2c"]["BorderSizePixel"] = 0;
G2L["2c"]["BackgroundColor3"] = Color3.fromRGB(22, 161, 134);
G2L["2c"]["Size"] = UDim2.new(0, 242, 0, 43);
G2L["2c"]["Position"] = UDim2.new(0.372, 0, 0.743, 0);
G2L["2c"]["Name"] = [[BackGroundChar3]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar3.Noclip
G2L["2d"] = Instance.new("TextButton", G2L["2c"]);
G2L["2d"]["BorderSizePixel"] = 0;
G2L["2d"]["TextSize"] = 22;
G2L["2d"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(27, 189, 157);
G2L["2d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["2d"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["2d"]["Text"] = [[Noclip]];
G2L["2d"]["Name"] = [[Noclip]];
G2L["2d"]["Position"] = UDim2.new(0.558, 0, 0.208, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar3.Noclip.LocalScript
G2L["2e"] = Instance.new("LocalScript", G2L["2d"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar3.InfJump
G2L["2f"] = Instance.new("TextButton", G2L["2c"]);
G2L["2f"]["BorderSizePixel"] = 0;
G2L["2f"]["TextSize"] = 22;
G2L["2f"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["2f"]["BackgroundColor3"] = Color3.fromRGB(27, 189, 157);
G2L["2f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["2f"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["2f"]["Text"] = [[InfJump]];
G2L["2f"]["Name"] = [[InfJump]];
G2L["2f"]["Position"] = UDim2.new(0.062, 0, 0.208, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar3.InfJump.LocalScript
G2L["30"] = Instance.new("LocalScript", G2L["2f"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.TXTBOX_Chat
G2L["31"] = Instance.new("TextBox", G2L["1f"]);
G2L["31"]["Name"] = [[TXTBOX_Chat]];
G2L["31"]["BorderSizePixel"] = 6;
G2L["31"]["TextWrapped"] = true;
G2L["31"]["TextSize"] = 14;
G2L["31"]["TextScaled"] = true;
G2L["31"]["BackgroundColor3"] = Color3.fromRGB(245, 248, 249);
G2L["31"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["31"]["Size"] = UDim2.new(0.52074, 0, 0.08786, 0);
G2L["31"]["Position"] = UDim2.new(0.3849, 0, 0.3734, 0);
G2L["31"]["BorderColor3"] = Color3.fromRGB(39, 175, 97);
G2L["31"]["Text"] = [[]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.TXTBOX_Stats
G2L["32"] = Instance.new("TextBox", G2L["1f"]);
G2L["32"]["Name"] = [[TXTBOX_Stats]];
G2L["32"]["BorderSizePixel"] = 6;
G2L["32"]["TextWrapped"] = true;
G2L["32"]["TextSize"] = 14;
G2L["32"]["TextScaled"] = true;
G2L["32"]["BackgroundColor3"] = Color3.fromRGB(245, 248, 249);
G2L["32"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["32"]["Size"] = UDim2.new(0.18113, 0, 0.08786, 0);
G2L["32"]["Position"] = UDim2.new(0.09056, 0, 0.3734, 0);
G2L["32"]["BorderColor3"] = Color3.fromRGB(39, 175, 97);
G2L["32"]["Text"] = [[]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.Char_Image
G2L["33"] = Instance.new("ImageLabel", G2L["1f"]);
G2L["33"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["33"]["Image"] = [[http://www.roblox.com/asset/?id=1281299598]];
G2L["33"]["Size"] = UDim2.new(0.0909, 0, 0.1756, 0);
G2L["33"]["BackgroundTransparency"] = 1;
G2L["33"]["Name"] = [[Char_Image]];
G2L["33"]["Position"] = UDim2.new(0.07924, 0, 0.10982, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.CharacterText
G2L["34"] = Instance.new("TextLabel", G2L["1f"]);
G2L["34"]["TextWrapped"] = true;
G2L["34"]["TextSize"] = 19;
G2L["34"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["34"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["34"]["BackgroundTransparency"] = 1;
G2L["34"]["Size"] = UDim2.new(0.67923, 0, 0.17572, 0);
G2L["34"]["Text"] = [[Change your character's speed and other stats, give yourself fly, noclip and more!]];
G2L["34"]["Name"] = [[CharacterText]];
G2L["34"]["Position"] = UDim2.new(0.14717, 0, 0.10982, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.CharacterTitle
G2L["35"] = Instance.new("TextLabel", G2L["1f"]);
G2L["35"]["TextSize"] = 25;
G2L["35"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["35"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["35"]["BackgroundTransparency"] = 1;
G2L["35"]["Size"] = UDim2.new(0.52266, 0, 0.13644, 0);
G2L["35"]["Text"] = [[Character]];
G2L["35"]["Name"] = [[CharacterTitle]];
G2L["35"]["Position"] = UDim2.new(0.22641, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.Next
G2L["36"] = Instance.new("TextButton", G2L["1f"]);
G2L["36"]["BorderSizePixel"] = 0;
G2L["36"]["TextSize"] = 22;
G2L["36"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["36"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["36"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["36"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["36"]["Text"] = [[Next]];
G2L["36"]["Name"] = [[Next]];
G2L["36"]["Position"] = UDim2.new(0.82, 0, 0.044, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.Next.Character_toPAGE2_IMAGE
G2L["37"] = Instance.new("ImageLabel", G2L["36"]);
G2L["37"]["BorderSizePixel"] = 0;
G2L["37"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["37"]["Image"] = [[http://www.roblox.com/asset/?id=1282737326]];
G2L["37"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["37"]["Name"] = [[Character_toPAGE2_IMAGE]];
G2L["37"]["Position"] = UDim2.new(0.90066, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3
G2L["38"] = Instance.new("Frame", G2L["10"]);
G2L["38"]["ZIndex"] = 3;
G2L["38"]["BorderSizePixel"] = 0;
G2L["38"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["38"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["38"]["Position"] = UDim2.new(1.005, 0, 0, 0);
G2L["38"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["38"]["Name"] = [[Others_3]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.Char_Image
G2L["39"] = Instance.new("ImageLabel", G2L["38"]);
G2L["39"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["39"]["Image"] = [[rbxassetid://1281286925]];
G2L["39"]["Size"] = UDim2.new(0.0909, 0, 0.18238, 0);
G2L["39"]["BackgroundTransparency"] = 1;
G2L["39"]["Name"] = [[Char_Image]];
G2L["39"]["Position"] = UDim2.new(0.06567, 0, 0.17939, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.CharacterText
G2L["3a"] = Instance.new("TextLabel", G2L["38"]);
G2L["3a"]["TextWrapped"] = true;
G2L["3a"]["TextSize"] = 19;
G2L["3a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["3a"]["BackgroundTransparency"] = 1;
G2L["3a"]["Size"] = UDim2.new(0.67923, 0, 0.18148, 0);
G2L["3a"]["Text"] = [[Fling people, kill them, annoy them, do whatever you want! Supports partial names.]];
G2L["3a"]["Name"] = [[CharacterText]];
G2L["3a"]["Position"] = UDim2.new(0.15622, 0, 0.17939, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.CharacterTitle
G2L["3b"] = Instance.new("TextLabel", G2L["38"]);
G2L["3b"]["TextSize"] = 25;
G2L["3b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3b"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["3b"]["BackgroundTransparency"] = 1;
G2L["3b"]["Size"] = UDim2.new(0.52266, 0, 0.13644, 0);
G2L["3b"]["Text"] = [[Abusive]];
G2L["3b"]["Name"] = [[CharacterTitle]];
G2L["3b"]["Position"] = UDim2.new(0.23093, 0, 0.03913, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3
G2L["3c"] = Instance.new("Frame", G2L["38"]);
G2L["3c"]["BorderSizePixel"] = 0;
G2L["3c"]["BackgroundColor3"] = Color3.fromRGB(192, 57, 43);
G2L["3c"]["Size"] = UDim2.new(0.70845, 0, 0.48323, 0);
G2L["3c"]["Position"] = UDim2.new(0.25848, 0, 0.42335, 0);
G2L["3c"]["Name"] = [[othersBaseBackground3]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.Bring
G2L["3d"] = Instance.new("TextButton", G2L["3c"]);
G2L["3d"]["BorderSizePixel"] = 0;
G2L["3d"]["TextSize"] = 22;
G2L["3d"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["3d"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["3d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["3d"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["3d"]["Text"] = [[Bring]];
G2L["3d"]["Name"] = [[Bring]];
G2L["3d"]["Position"] = UDim2.new(0.67697, 0, 0.68291, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.Bring.LocalScript
G2L["3e"] = Instance.new("LocalScript", G2L["3d"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.Fling
G2L["3f"] = Instance.new("TextButton", G2L["3c"]);
G2L["3f"]["BorderSizePixel"] = 0;
G2L["3f"]["TextSize"] = 22;
G2L["3f"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["3f"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["3f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["3f"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["3f"]["Text"] = [[Fling]];
G2L["3f"]["Name"] = [[Fling]];
G2L["3f"]["Position"] = UDim2.new(0.36792, 0, 0.36422, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.Fling.LocalScript
G2L["40"] = Instance.new("LocalScript", G2L["3f"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.Weld
G2L["41"] = Instance.new("TextButton", G2L["3c"]);
G2L["41"]["BorderSizePixel"] = 0;
G2L["41"]["TextSize"] = 22;
G2L["41"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["41"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["41"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["41"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["41"]["Text"] = [[Weld]];
G2L["41"]["Name"] = [[Weld]];
G2L["41"]["Position"] = UDim2.new(0.67697, 0, 0.36422, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.Weld.LocalScript
G2L["42"] = Instance.new("LocalScript", G2L["41"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.LoopFling
G2L["43"] = Instance.new("TextButton", G2L["3c"]);
G2L["43"]["BorderSizePixel"] = 0;
G2L["43"]["TextSize"] = 22;
G2L["43"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["43"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["43"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["43"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["43"]["Text"] = [[LoopFling]];
G2L["43"]["Name"] = [[LoopFling]];
G2L["43"]["Position"] = UDim2.new(0.36792, 0, 0.68291, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.LoopFling.LocalScript
G2L["44"] = Instance.new("LocalScript", G2L["43"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.LoopTKill
G2L["45"] = Instance.new("TextButton", G2L["3c"]);
G2L["45"]["BorderSizePixel"] = 0;
G2L["45"]["TextSize"] = 22;
G2L["45"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["45"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["45"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["45"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["45"]["Text"] = [[LoopTKill]];
G2L["45"]["Name"] = [[LoopTKill]];
G2L["45"]["Position"] = UDim2.new(0.05887, 0, 0.68291, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.LoopTKill.LocalScript
G2L["46"] = Instance.new("LocalScript", G2L["45"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.ToolKill
G2L["47"] = Instance.new("TextButton", G2L["3c"]);
G2L["47"]["BorderSizePixel"] = 0;
G2L["47"]["TextSize"] = 22;
G2L["47"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["47"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["47"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["47"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["47"]["Text"] = [[ToolKill]];
G2L["47"]["Name"] = [[ToolKill]];
G2L["47"]["Position"] = UDim2.new(0.05887, 0, 0.36422, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.ToolKill.LocalScript
G2L["48"] = Instance.new("LocalScript", G2L["47"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.TXTBOX_PlrName
G2L["49"] = Instance.new("TextBox", G2L["38"]);
G2L["49"]["Name"] = [[TXTBOX_PlrName]];
G2L["49"]["ZIndex"] = 2;
G2L["49"]["BorderSizePixel"] = 0;
G2L["49"]["TextWrapped"] = true;
G2L["49"]["TextSize"] = 14;
G2L["49"]["TextScaled"] = true;
G2L["49"]["BackgroundColor3"] = Color3.fromRGB(245, 248, 249);
G2L["49"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["49"]["Size"] = UDim2.new(0.52074, 0, 0.08786, 0);
G2L["49"]["Position"] = UDim2.new(0.36896, 0, 0.47978, 0);
G2L["49"]["BorderColor3"] = Color3.fromRGB(39, 175, 97);
G2L["49"]["Text"] = [[]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.Next
G2L["4a"] = Instance.new("TextButton", G2L["38"]);
G2L["4a"]["BorderSizePixel"] = 0;
G2L["4a"]["TextSize"] = 22;
G2L["4a"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["4a"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["4a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["4a"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["4a"]["Text"] = [[Next]];
G2L["4a"]["Name"] = [[Next]];
G2L["4a"]["Position"] = UDim2.new(0.82, 0, 0.044, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.Next.Character_toPAGE2_IMAGE
G2L["4b"] = Instance.new("ImageLabel", G2L["4a"]);
G2L["4b"]["BorderSizePixel"] = 0;
G2L["4b"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["4b"]["Image"] = [[http://www.roblox.com/asset/?id=1282737326]];
G2L["4b"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["4b"]["Name"] = [[Character_toPAGE2_IMAGE]];
G2L["4b"]["Position"] = UDim2.new(0.9, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.Back
G2L["4c"] = Instance.new("TextButton", G2L["38"]);
G2L["4c"]["BorderSizePixel"] = 0;
G2L["4c"]["TextSize"] = 22;
G2L["4c"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["4c"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["4c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["4c"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["4c"]["Text"] = [[Prev]];
G2L["4c"]["Name"] = [[Back]];
G2L["4c"]["Position"] = UDim2.new(0.06792, 0, 0.04393, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.Back.Character_toPAGE1_IMAGE
G2L["4d"] = Instance.new("ImageLabel", G2L["4c"]);
G2L["4d"]["BorderSizePixel"] = 0;
G2L["4d"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["4d"]["Image"] = [[http://www.roblox.com/asset/?id=1282894968]];
G2L["4d"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["4d"]["Name"] = [[Character_toPAGE1_IMAGE]];
G2L["4d"]["Position"] = UDim2.new(-0.40029, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.BackGroundChar
G2L["4e"] = Instance.new("Frame", G2L["38"]);
G2L["4e"]["BorderSizePixel"] = 0;
G2L["4e"]["BackgroundColor3"] = Color3.fromRGB(193, 58, 44);
G2L["4e"]["Size"] = UDim2.new(0, 92, 0, 65);
G2L["4e"]["Position"] = UDim2.new(0.02949, 0, 0.38645, 0);
G2L["4e"]["Name"] = [[BackGroundChar]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.BackGroundChar.TouchFling
G2L["4f"] = Instance.new("TextButton", G2L["4e"]);
G2L["4f"]["BorderSizePixel"] = 0;
G2L["4f"]["TextSize"] = 22;
G2L["4f"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["4f"]["BackgroundColor3"] = Color3.fromRGB(232, 77, 61);
G2L["4f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["4f"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["4f"]["Text"] = [[TouchFling]];
G2L["4f"]["Name"] = [[TouchFling]];
G2L["4f"]["Position"] = UDim2.new(0, 0, 0.55715, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.BackGroundChar.TouchFling.LocalScript
G2L["50"] = Instance.new("LocalScript", G2L["4f"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.BackGroundChar.ClickFling
G2L["51"] = Instance.new("TextButton", G2L["4e"]);
G2L["51"]["BorderSizePixel"] = 0;
G2L["51"]["TextSize"] = 22;
G2L["51"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["51"]["BackgroundColor3"] = Color3.fromRGB(232, 77, 61);
G2L["51"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["51"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["51"]["Text"] = [[ClickFling]];
G2L["51"]["Name"] = [[ClickFling]];
G2L["51"]["Position"] = UDim2.new(0, 0, 0.07561, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.BackGroundChar.ClickFling.LocalScript
G2L["52"] = Instance.new("LocalScript", G2L["51"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1
G2L["53"] = Instance.new("Frame", G2L["10"]);
G2L["53"]["ZIndex"] = 2;
G2L["53"]["BorderSizePixel"] = 0;
G2L["53"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["53"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["53"]["Position"] = UDim2.new(1.005, 0, 0, 0);
G2L["53"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["53"]["Name"] = [[Credits_1]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1.Name
G2L["54"] = Instance.new("TextLabel", G2L["53"]);
G2L["54"]["TextSize"] = 21;
G2L["54"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["54"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["54"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.ExtraLight, Enum.FontStyle.Normal);
G2L["54"]["BackgroundTransparency"] = 1;
G2L["54"]["Size"] = UDim2.new(0.15999, 0, 0.07583, 0);
G2L["54"]["Text"] = [[Moonhad]];
G2L["54"]["Name"] = [[Name]];
G2L["54"]["Position"] = UDim2.new(0.01693, 0, 0.38393, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1.Title
G2L["55"] = Instance.new("TextLabel", G2L["53"]);
G2L["55"]["TextSize"] = 25;
G2L["55"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["55"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["55"]["BackgroundTransparency"] = 1;
G2L["55"]["Size"] = UDim2.new(0.52266, 0, 0.13644, 0);
G2L["55"]["Text"] = [[CREDITS:]];
G2L["55"]["Name"] = [[Title]];
G2L["55"]["Position"] = UDim2.new(0.2477, 0, 0.0361, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1.Title
G2L["56"] = Instance.new("TextLabel", G2L["53"]);
G2L["56"]["TextSize"] = 25;
G2L["56"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["56"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["56"]["BackgroundTransparency"] = 1;
G2L["56"]["Size"] = UDim2.new(0.2886, 0, 0.13644, 0);
G2L["56"]["Text"] = [[Helpers]];
G2L["56"]["Name"] = [[Title]];
G2L["56"]["Position"] = UDim2.new(-0.01248, 0, 0.24045, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1.Title
G2L["57"] = Instance.new("TextLabel", G2L["53"]);
G2L["57"]["TextSize"] = 25;
G2L["57"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["57"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["57"]["BackgroundTransparency"] = 1;
G2L["57"]["Size"] = UDim2.new(0.2886, 0, 0.13644, 0);
G2L["57"]["Text"] = [[Developers]];
G2L["57"]["Name"] = [[Title]];
G2L["57"]["Position"] = UDim2.new(0.32463, 0, 0.2361, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1.Title
G2L["58"] = Instance.new("TextLabel", G2L["53"]);
G2L["58"]["TextSize"] = 25;
G2L["58"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["58"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["58"]["BackgroundTransparency"] = 1;
G2L["58"]["Size"] = UDim2.new(0.2886, 0, 0.13644, 0);
G2L["58"]["Text"] = [[Others]];
G2L["58"]["Name"] = [[Title]];
G2L["58"]["Position"] = UDim2.new(0.65721, 0, 0.2361, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1.Name
G2L["59"] = Instance.new("TextLabel", G2L["53"]);
G2L["59"]["TextSize"] = 11;
G2L["59"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["59"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["59"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.ExtraLight, Enum.FontStyle.Normal);
G2L["59"]["BackgroundTransparency"] = 1;
G2L["59"]["Size"] = UDim2.new(0.15999, 0, 0.06777, 0);
G2L["59"]["Text"] = [[(john_james_shedletsky_the_iii) ]];
G2L["59"]["Name"] = [[Name]];
G2L["59"]["Position"] = UDim2.new(0.01693, 0, 0.47088, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1.Name
G2L["5a"] = Instance.new("TextLabel", G2L["53"]);
G2L["5a"]["TextSize"] = 21;
G2L["5a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["5a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.ExtraLight, Enum.FontStyle.Normal);
G2L["5a"]["BackgroundTransparency"] = 1;
G2L["5a"]["Size"] = UDim2.new(0.15999, 0, 0.06777, 0);
G2L["5a"]["Text"] = [[FeV]];
G2L["5a"]["Name"] = [[Name]];
G2L["5a"]["Position"] = UDim2.new(0.01693, 0, 0.54045, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1.Name
G2L["5b"] = Instance.new("TextLabel", G2L["53"]);
G2L["5b"]["TextSize"] = 21;
G2L["5b"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["5b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5b"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.ExtraLight, Enum.FontStyle.Normal);
G2L["5b"]["BackgroundTransparency"] = 1;
G2L["5b"]["Size"] = UDim2.new(0.15999, 0, 0.06777, 0);
G2L["5b"]["Text"] = [[Urban1]];
G2L["5b"]["Name"] = [[Name]];
G2L["5b"]["Position"] = UDim2.new(0.36083, 0, 0.38393, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1.Name
G2L["5c"] = Instance.new("TextLabel", G2L["53"]);
G2L["5c"]["TextWrapped"] = true;
G2L["5c"]["TextSize"] = 16;
G2L["5c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["5c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.ExtraLight, Enum.FontStyle.Normal);
G2L["5c"]["BackgroundTransparency"] = 1;
G2L["5c"]["Size"] = UDim2.new(0.22334, 0, 0.06777, 0);
G2L["5c"]["Text"] = [[(pwnmaster99) ]];
G2L["5c"]["Name"] = [[Name]];
G2L["5c"]["Position"] = UDim2.new(0.3563, 0, 0.4448, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Credits_1.Name
G2L["5d"] = Instance.new("TextLabel", G2L["53"]);
G2L["5d"]["TextSize"] = 21;
G2L["5d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["5d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.ExtraLight, Enum.FontStyle.Normal);
G2L["5d"]["BackgroundTransparency"] = 1;
G2L["5d"]["Size"] = UDim2.new(0.15999, 0, 0.06777, 0);
G2L["5d"]["Text"] = [[Illremember]];
G2L["5d"]["Name"] = [[Name]];
G2L["5d"]["Position"] = UDim2.new(0.7296, 0, 0.37523, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1
G2L["5e"] = Instance.new("Frame", G2L["10"]);
G2L["5e"]["ZIndex"] = 2;
G2L["5e"]["BorderSizePixel"] = 0;
G2L["5e"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["5e"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["5e"]["Position"] = UDim2.new(1.005, 0, 0, 0);
G2L["5e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5e"]["Name"] = [[Others_1]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground
G2L["5f"] = Instance.new("Frame", G2L["5e"]);
G2L["5f"]["BorderSizePixel"] = 0;
G2L["5f"]["BackgroundColor3"] = Color3.fromRGB(41, 129, 185);
G2L["5f"]["Size"] = UDim2.new(0.8351, 0, 0.56574, 0);
G2L["5f"]["Position"] = UDim2.new(0.07301, 0, 0.37865, 0);
G2L["5f"]["Name"] = [[othersBaseBackground]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.Follow
G2L["60"] = Instance.new("TextButton", G2L["5f"]);
G2L["60"]["BorderSizePixel"] = 0;
G2L["60"]["TextSize"] = 22;
G2L["60"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["60"]["BackgroundColor3"] = Color3.fromRGB(53, 152, 220);
G2L["60"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["60"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["60"]["Text"] = [[Follow]];
G2L["60"]["Name"] = [[Follow]];
G2L["60"]["Position"] = UDim2.new(0.02943, 0, 0.66157, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.Follow.LocalScript
G2L["61"] = Instance.new("LocalScript", G2L["60"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.TeleportTo
G2L["62"] = Instance.new("TextButton", G2L["5f"]);
G2L["62"]["BorderSizePixel"] = 0;
G2L["62"]["TextSize"] = 22;
G2L["62"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["62"]["BackgroundColor3"] = Color3.fromRGB(53, 152, 220);
G2L["62"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["62"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["62"]["Text"] = [[Teleport To]];
G2L["62"]["Name"] = [[TeleportTo]];
G2L["62"]["Position"] = UDim2.new(0.02943, 0, 0.35223, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.TeleportTo.LocalScript
G2L["63"] = Instance.new("LocalScript", G2L["62"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.View
G2L["64"] = Instance.new("TextButton", G2L["5f"]);
G2L["64"]["BorderSizePixel"] = 0;
G2L["64"]["TextSize"] = 22;
G2L["64"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["64"]["BackgroundColor3"] = Color3.fromRGB(53, 152, 220);
G2L["64"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["64"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["64"]["Text"] = [[View]];
G2L["64"]["Name"] = [[View]];
G2L["64"]["Position"] = UDim2.new(0.36792, 0, 0.35223, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.View.LocalScript
G2L["65"] = Instance.new("LocalScript", G2L["64"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.Orbit
G2L["66"] = Instance.new("TextButton", G2L["5f"]);
G2L["66"]["BorderSizePixel"] = 0;
G2L["66"]["TextSize"] = 22;
G2L["66"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["66"]["BackgroundColor3"] = Color3.fromRGB(53, 152, 220);
G2L["66"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["66"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["66"]["Text"] = [[Orbit]];
G2L["66"]["Name"] = [[Orbit]];
G2L["66"]["Position"] = UDim2.new(0.706, 0, 0.35253, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.Orbit.LocalScript
G2L["67"] = Instance.new("LocalScript", G2L["66"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.LookAt
G2L["68"] = Instance.new("TextButton", G2L["5f"]);
G2L["68"]["BorderSizePixel"] = 0;
G2L["68"]["TextSize"] = 22;
G2L["68"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["68"]["BackgroundColor3"] = Color3.fromRGB(53, 152, 220);
G2L["68"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["68"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["68"]["Text"] = [[LookAt]];
G2L["68"]["Name"] = [[LookAt]];
G2L["68"]["Position"] = UDim2.new(0.706, 0, 0.662, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.LookAt.LocalScript
G2L["69"] = Instance.new("LocalScript", G2L["68"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.PathFollow
G2L["6a"] = Instance.new("TextButton", G2L["5f"]);
G2L["6a"]["BorderSizePixel"] = 0;
G2L["6a"]["TextSize"] = 22;
G2L["6a"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["6a"]["BackgroundColor3"] = Color3.fromRGB(53, 152, 220);
G2L["6a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["6a"]["Size"] = UDim2.new(0, 92, 0, 25);
G2L["6a"]["Text"] = [[PathFollow]];
G2L["6a"]["Name"] = [[PathFollow]];
G2L["6a"]["Position"] = UDim2.new(0.368, 0, 0.662, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.PathFollow.LocalScript
G2L["6b"] = Instance.new("LocalScript", G2L["6a"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.TXTBOX_PlrName
G2L["6c"] = Instance.new("TextBox", G2L["5e"]);
G2L["6c"]["Name"] = [[TXTBOX_PlrName]];
G2L["6c"]["ZIndex"] = 2;
G2L["6c"]["BorderSizePixel"] = 0;
G2L["6c"]["TextWrapped"] = true;
G2L["6c"]["TextSize"] = 14;
G2L["6c"]["TextScaled"] = true;
G2L["6c"]["BackgroundColor3"] = Color3.fromRGB(245, 248, 249);
G2L["6c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["6c"]["Size"] = UDim2.new(0.56477, 0, 0.12141, 0);
G2L["6c"]["Position"] = UDim2.new(0.20806, 0, 0.41882, 0);
G2L["6c"]["BorderColor3"] = Color3.fromRGB(39, 175, 97);
G2L["6c"]["Text"] = [[]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.OthersText
G2L["6d"] = Instance.new("TextLabel", G2L["5e"]);
G2L["6d"]["TextWrapped"] = true;
G2L["6d"]["TextSize"] = 19;
G2L["6d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["6d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["6d"]["BackgroundTransparency"] = 1;
G2L["6d"]["Size"] = UDim2.new(0.84716, 0, 0.18918, 0);
G2L["6d"]["Text"] = [[Use a set of basic commands on other players! supports partial names.]];
G2L["6d"]["Name"] = [[OthersText]];
G2L["6d"]["Position"] = UDim2.new(0.06675, 0, 0.18238, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.OthersTitle
G2L["6e"] = Instance.new("TextLabel", G2L["5e"]);
G2L["6e"]["TextSize"] = 25;
G2L["6e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["6e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["6e"]["BackgroundTransparency"] = 1;
G2L["6e"]["Size"] = UDim2.new(0.56685, 0, 0.10072, 0);
G2L["6e"]["Text"] = [[Others]];
G2L["6e"]["Name"] = [[OthersTitle]];
G2L["6e"]["Position"] = UDim2.new(0.19954, 0, 0.08958, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.Char_Image
G2L["6f"] = Instance.new("ImageLabel", G2L["5e"]);
G2L["6f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["6f"]["Image"] = [[http://www.roblox.com/asset/?id=1281476978]];
G2L["6f"]["Size"] = UDim2.new(0.09995, 0, 0.19593, 0);
G2L["6f"]["BackgroundTransparency"] = 1;
G2L["6f"]["Name"] = [[Char_Image]];
G2L["6f"]["Position"] = UDim2.new(0.02037, 0, 0.02264, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.Next
G2L["70"] = Instance.new("TextButton", G2L["5e"]);
G2L["70"]["BorderSizePixel"] = 0;
G2L["70"]["TextSize"] = 22;
G2L["70"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["70"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["70"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["70"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["70"]["Text"] = [[Next]];
G2L["70"]["Name"] = [[Next]];
G2L["70"]["Position"] = UDim2.new(0.82, 0, 0.044, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.Next.Character_toPAGE2_IMAGE
G2L["71"] = Instance.new("ImageLabel", G2L["70"]);
G2L["71"]["BorderSizePixel"] = 0;
G2L["71"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["71"]["Image"] = [[http://www.roblox.com/asset/?id=1282737326]];
G2L["71"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["71"]["Name"] = [[Character_toPAGE2_IMAGE]];
G2L["71"]["Position"] = UDim2.new(0.90066, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2
G2L["72"] = Instance.new("Frame", G2L["10"]);
G2L["72"]["ZIndex"] = 2;
G2L["72"]["BorderSizePixel"] = 0;
G2L["72"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["72"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["72"]["Position"] = UDim2.new(1.005, 0, 0, 0);
G2L["72"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["72"]["Name"] = [[Others_2]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldHandler
G2L["73"] = Instance.new("LocalScript", G2L["72"]);
G2L["73"]["Enabled"] = false;
G2L["73"]["Name"] = [[WeldHandler]];
G2L["73"]["Disabled"] = true;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldHandler
G2L["74"] = Instance.new("LocalScript", G2L["72"]);
G2L["74"]["Name"] = [[WeldHandler]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.Next
G2L["75"] = Instance.new("TextButton", G2L["72"]);
G2L["75"]["BorderSizePixel"] = 0;
G2L["75"]["TextSize"] = 22;
G2L["75"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["75"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["75"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["75"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["75"]["Text"] = [[Next]];
G2L["75"]["Name"] = [[Next]];
G2L["75"]["Position"] = UDim2.new(0.82, 0, 0.044, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.Next.Character_toPAGE2_IMAGE
G2L["76"] = Instance.new("ImageLabel", G2L["75"]);
G2L["76"]["BorderSizePixel"] = 0;
G2L["76"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["76"]["Image"] = [[http://www.roblox.com/asset/?id=1282737326]];
G2L["76"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["76"]["Name"] = [[Character_toPAGE2_IMAGE]];
G2L["76"]["Position"] = UDim2.new(0.90066, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.Back
G2L["77"] = Instance.new("TextButton", G2L["72"]);
G2L["77"]["BorderSizePixel"] = 0;
G2L["77"]["TextSize"] = 22;
G2L["77"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["77"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["77"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["77"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["77"]["Text"] = [[Prev]];
G2L["77"]["Name"] = [[Back]];
G2L["77"]["Position"] = UDim2.new(0.06792, 0, 0.04393, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.Back.Character_toPAGE1_IMAGE
G2L["78"] = Instance.new("ImageLabel", G2L["77"]);
G2L["78"]["BorderSizePixel"] = 0;
G2L["78"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["78"]["Image"] = [[http://www.roblox.com/asset/?id=1282894968]];
G2L["78"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["78"]["Name"] = [[Character_toPAGE1_IMAGE]];
G2L["78"]["Position"] = UDim2.new(-0.40029, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon1
G2L["79"] = Instance.new("Frame", G2L["72"]);
G2L["79"]["BorderSizePixel"] = 0;
G2L["79"]["BackgroundColor3"] = Color3.fromRGB(116, 94, 255);
G2L["79"]["Size"] = UDim2.new(0.21484, 0, 0.43563, 0);
G2L["79"]["Position"] = UDim2.new(0.04224, 0, 0.51745, 0);
G2L["79"]["Name"] = [[WeldColon1]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon1.Elevator
G2L["7a"] = Instance.new("TextButton", G2L["79"]);
G2L["7a"]["TextWrapped"] = true;
G2L["7a"]["BorderSizePixel"] = 0;
G2L["7a"]["TextSize"] = 14;
G2L["7a"]["TextScaled"] = true;
G2L["7a"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["7a"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["7a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["7a"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["7a"]["Text"] = [[Elevator]];
G2L["7a"]["Name"] = [[Elevator]];
G2L["7a"]["Position"] = UDim2.new(0, 0, 0.65, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon1.Elevator.PO
G2L["7b"] = Instance.new("Vector3Value", G2L["7a"]);
G2L["7b"]["Name"] = [[PO]];
G2L["7b"]["Value"] = Vector3.new(0, -3, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon1.Elevator.RO
G2L["7c"] = Instance.new("StringValue", G2L["7a"]);
G2L["7c"]["Name"] = [[RO]];
G2L["7c"]["Value"] = [[CFrame.Angles(math.rad(-90), 0, math.rad(3.34))]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon1.NoJump
G2L["7d"] = Instance.new("TextButton", G2L["79"]);
G2L["7d"]["TextWrapped"] = true;
G2L["7d"]["BorderSizePixel"] = 0;
G2L["7d"]["TextSize"] = 14;
G2L["7d"]["TextScaled"] = true;
G2L["7d"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["7d"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["7d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["7d"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["7d"]["Text"] = [[NoJump]];
G2L["7d"]["Name"] = [[NoJump]];
G2L["7d"]["Position"] = UDim2.new(0, 0, 0.39, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon1.NoJump.PO
G2L["7e"] = Instance.new("Vector3Value", G2L["7d"]);
G2L["7e"]["Name"] = [[PO]];
G2L["7e"]["Value"] = Vector3.new(0, 3.5, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon1.NoJump.RO
G2L["7f"] = Instance.new("StringValue", G2L["7d"]);
G2L["7f"]["Name"] = [[RO]];
G2L["7f"]["Value"] = [[CFrame.Angles(math.rad(-90), 0, 0)]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon1.Annoy
G2L["80"] = Instance.new("TextButton", G2L["79"]);
G2L["80"]["TextWrapped"] = true;
G2L["80"]["BorderSizePixel"] = 0;
G2L["80"]["TextSize"] = 14;
G2L["80"]["TextScaled"] = true;
G2L["80"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["80"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["80"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["80"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["80"]["Text"] = [[Annoy]];
G2L["80"]["Name"] = [[Annoy]];
G2L["80"]["Position"] = UDim2.new(0, 0, 0.13, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon2
G2L["81"] = Instance.new("Frame", G2L["72"]);
G2L["81"]["BorderSizePixel"] = 0;
G2L["81"]["BackgroundColor3"] = Color3.fromRGB(116, 94, 255);
G2L["81"]["Size"] = UDim2.new(0.21484, 0, 0.43563, 0);
G2L["81"]["Position"] = UDim2.new(0.27856, 0, 0.51745, 0);
G2L["81"]["Name"] = [[WeldColon2]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon2.InfJump
G2L["82"] = Instance.new("TextButton", G2L["81"]);
G2L["82"]["TextWrapped"] = true;
G2L["82"]["BorderSizePixel"] = 0;
G2L["82"]["TextSize"] = 14;
G2L["82"]["TextScaled"] = true;
G2L["82"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["82"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["82"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["82"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["82"]["Text"] = [[InfJump]];
G2L["82"]["Name"] = [[InfJump]];
G2L["82"]["Position"] = UDim2.new(0, 0, 0.65, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon2.InfJump.RO
G2L["83"] = Instance.new("StringValue", G2L["82"]);
G2L["83"]["Name"] = [[RO]];
G2L["83"]["Value"] = [[CFrame.Angles(0, 0, 0)]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon2.InfJump.PO
G2L["84"] = Instance.new("Vector3Value", G2L["82"]);
G2L["84"]["Name"] = [[PO]];
G2L["84"]["Value"] = Vector3.new(0, -5.75, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon2.HeadStand
G2L["85"] = Instance.new("TextButton", G2L["81"]);
G2L["85"]["TextWrapped"] = true;
G2L["85"]["BorderSizePixel"] = 0;
G2L["85"]["TextSize"] = 14;
G2L["85"]["TextScaled"] = true;
G2L["85"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["85"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["85"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["85"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["85"]["Text"] = [[HeadStand]];
G2L["85"]["Name"] = [[HeadStand]];
G2L["85"]["Position"] = UDim2.new(0, 0, 0.39, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon2.HeadStand.RO
G2L["86"] = Instance.new("StringValue", G2L["85"]);
G2L["86"]["Name"] = [[RO]];
G2L["86"]["Value"] = [[CFrame.Angles(0, 0, 0)]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon2.HeadStand.PO
G2L["87"] = Instance.new("Vector3Value", G2L["85"]);
G2L["87"]["Name"] = [[PO]];
G2L["87"]["Value"] = Vector3.new(0, 4.25, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon2.Carpet
G2L["88"] = Instance.new("TextButton", G2L["81"]);
G2L["88"]["TextWrapped"] = true;
G2L["88"]["BorderSizePixel"] = 0;
G2L["88"]["TextSize"] = 14;
G2L["88"]["TextScaled"] = true;
G2L["88"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["88"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["88"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["88"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["88"]["Text"] = [[Carpet]];
G2L["88"]["Name"] = [[Carpet]];
G2L["88"]["Position"] = UDim2.new(0, 0, 0.13, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon2.Carpet.RO
G2L["89"] = Instance.new("StringValue", G2L["88"]);
G2L["89"]["Name"] = [[RO]];
G2L["89"]["Value"] = [[CFrame.Angles(math.rad(-90), 0, 0)]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon2.Carpet.PO
G2L["8a"] = Instance.new("Vector3Value", G2L["88"]);
G2L["8a"]["Name"] = [[PO]];
G2L["8a"]["Value"] = Vector3.new(0, -3.6, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon3
G2L["8b"] = Instance.new("Frame", G2L["72"]);
G2L["8b"]["BorderSizePixel"] = 0;
G2L["8b"]["BackgroundColor3"] = Color3.fromRGB(116, 94, 255);
G2L["8b"]["Size"] = UDim2.new(0.21484, 0, 0.43563, 0);
G2L["8b"]["Position"] = UDim2.new(0.51489, 0, 0.51745, 0);
G2L["8b"]["Name"] = [[WeldColon3]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon3.Weird
G2L["8c"] = Instance.new("TextButton", G2L["8b"]);
G2L["8c"]["TextWrapped"] = true;
G2L["8c"]["BorderSizePixel"] = 0;
G2L["8c"]["TextSize"] = 14;
G2L["8c"]["TextScaled"] = true;
G2L["8c"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["8c"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["8c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["8c"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["8c"]["Text"] = [[Weird]];
G2L["8c"]["Name"] = [[Weird]];
G2L["8c"]["Position"] = UDim2.new(0, 0, 0.65, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon3.Weird.RO
G2L["8d"] = Instance.new("StringValue", G2L["8c"]);
G2L["8d"]["Name"] = [[RO]];
G2L["8d"]["Value"] = [[CFrame.Angles(math.rad(-90), 0, 0)]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon3.Weird.PO
G2L["8e"] = Instance.new("Vector3Value", G2L["8c"]);
G2L["8e"]["Name"] = [[PO]];
G2L["8e"]["Value"] = Vector3.new(0, 2, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon3.Invert
G2L["8f"] = Instance.new("TextButton", G2L["8b"]);
G2L["8f"]["TextWrapped"] = true;
G2L["8f"]["BorderSizePixel"] = 0;
G2L["8f"]["TextSize"] = 14;
G2L["8f"]["TextScaled"] = true;
G2L["8f"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["8f"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["8f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["8f"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["8f"]["Text"] = [[Invert]];
G2L["8f"]["Name"] = [[Invert]];
G2L["8f"]["Position"] = UDim2.new(0, 0, 0.39, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon3.Invert.PO
G2L["90"] = Instance.new("Vector3Value", G2L["8f"]);
G2L["90"]["Name"] = [[PO]];
G2L["90"]["Value"] = Vector3.new(0, 0.7, -0.8);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon3.Invert.RO
G2L["91"] = Instance.new("StringValue", G2L["8f"]);
G2L["91"]["Name"] = [[RO]];
G2L["91"]["Value"] = [[CFrame.Angles(0, 0, 0)]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon3.Platform
G2L["92"] = Instance.new("TextButton", G2L["8b"]);
G2L["92"]["TextWrapped"] = true;
G2L["92"]["BorderSizePixel"] = 0;
G2L["92"]["TextSize"] = 14;
G2L["92"]["TextScaled"] = true;
G2L["92"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["92"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["92"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["92"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["92"]["Text"] = [[Platform]];
G2L["92"]["Name"] = [[Platform]];
G2L["92"]["Position"] = UDim2.new(0, 0, 0.13, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon3.Platform.RO
G2L["93"] = Instance.new("StringValue", G2L["92"]);
G2L["93"]["Name"] = [[RO]];
G2L["93"]["Value"] = [[CFrame.Angles(math.rad(-90), 0, 0)]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon3.Platform.PO
G2L["94"] = Instance.new("Vector3Value", G2L["92"]);
G2L["94"]["Name"] = [[PO]];
G2L["94"]["Value"] = Vector3.new(0, -4, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon4
G2L["95"] = Instance.new("Frame", G2L["72"]);
G2L["95"]["BorderSizePixel"] = 0;
G2L["95"]["BackgroundColor3"] = Color3.fromRGB(116, 94, 255);
G2L["95"]["Size"] = UDim2.new(0.21484, 0, 0.43563, 0);
G2L["95"]["Position"] = UDim2.new(0.75122, 0, 0.51745, 0);
G2L["95"]["Name"] = [[WeldColon4]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon4.Speed 3
G2L["96"] = Instance.new("TextButton", G2L["95"]);
G2L["96"]["TextWrapped"] = true;
G2L["96"]["BorderSizePixel"] = 0;
G2L["96"]["TextSize"] = 14;
G2L["96"]["TextScaled"] = true;
G2L["96"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["96"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["96"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["96"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["96"]["Text"] = [[Speed 3]];
G2L["96"]["Name"] = [[Speed 3]];
G2L["96"]["Position"] = UDim2.new(0, 0, 0.65, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon4.Speed 3.RO
G2L["97"] = Instance.new("StringValue", G2L["96"]);
G2L["97"]["Name"] = [[RO]];
G2L["97"]["Value"] = [[CFrame.Angles(0, 0, 0)]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon4.Speed 3.PO
G2L["98"] = Instance.new("Vector3Value", G2L["96"]);
G2L["98"]["Name"] = [[PO]];
G2L["98"]["Value"] = Vector3.new(0, 0.7, 1);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon4.Speed 5
G2L["99"] = Instance.new("TextButton", G2L["95"]);
G2L["99"]["TextWrapped"] = true;
G2L["99"]["BorderSizePixel"] = 0;
G2L["99"]["TextSize"] = 14;
G2L["99"]["TextScaled"] = true;
G2L["99"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["99"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["99"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["99"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["99"]["Text"] = [[Speed 5]];
G2L["99"]["Name"] = [[Speed 5]];
G2L["99"]["Position"] = UDim2.new(0, 0, 0.39, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon4.Speed 5.RO
G2L["9a"] = Instance.new("StringValue", G2L["99"]);
G2L["9a"]["Name"] = [[RO]];
G2L["9a"]["Value"] = [[CFrame.Angles(0, 0, 0)]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon4.Speed 5.PO
G2L["9b"] = Instance.new("Vector3Value", G2L["99"]);
G2L["9b"]["Name"] = [[PO]];
G2L["9b"]["Value"] = Vector3.new(0, 0.7, 0.5);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon4.Speed 10
G2L["9c"] = Instance.new("TextButton", G2L["95"]);
G2L["9c"]["TextWrapped"] = true;
G2L["9c"]["BorderSizePixel"] = 0;
G2L["9c"]["TextSize"] = 14;
G2L["9c"]["TextScaled"] = true;
G2L["9c"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["9c"]["BackgroundColor3"] = Color3.fromRGB(136, 115, 255);
G2L["9c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["9c"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["9c"]["Text"] = [[Speed 10]];
G2L["9c"]["Name"] = [[Speed 10]];
G2L["9c"]["Position"] = UDim2.new(0, 0, 0.13, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon4.Speed 10.RO
G2L["9d"] = Instance.new("StringValue", G2L["9c"]);
G2L["9d"]["Name"] = [[RO]];
G2L["9d"]["Value"] = [[CFrame.Angles(0, 0, 0)]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldColon4.Speed 10.PO
G2L["9e"] = Instance.new("Vector3Value", G2L["9c"]);
G2L["9e"]["Name"] = [[PO]];
G2L["9e"]["Value"] = Vector3.new(0, 0.7, 0.1);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.TXTBOX_WeldName
G2L["9f"] = Instance.new("TextBox", G2L["72"]);
G2L["9f"]["Name"] = [[TXTBOX_WeldName]];
G2L["9f"]["ZIndex"] = 2;
G2L["9f"]["BorderSizePixel"] = 8;
G2L["9f"]["TextWrapped"] = true;
G2L["9f"]["TextSize"] = 14;
G2L["9f"]["TextScaled"] = true;
G2L["9f"]["BackgroundColor3"] = Color3.fromRGB(245, 248, 249);
G2L["9f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["9f"]["Size"] = UDim2.new(0.55939, 0, 0.11365, 0);
G2L["9f"]["Position"] = UDim2.new(0.23637, 0, 0.3348, 0);
G2L["9f"]["BorderColor3"] = Color3.fromRGB(116, 94, 255);
G2L["9f"]["Text"] = [[]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.Weld_Image
G2L["a0"] = Instance.new("ImageLabel", G2L["72"]);
G2L["a0"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a0"]["Image"] = [[rbxassetid://139226106981703]];
G2L["a0"]["Size"] = UDim2.new(0.11347, 0, 0.2181, 0);
G2L["a0"]["BackgroundTransparency"] = 1;
G2L["a0"]["Name"] = [[Weld_Image]];
G2L["a0"]["Position"] = UDim2.new(0.05441, 0, 0.22699, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.OthersText
G2L["a1"] = Instance.new("TextLabel", G2L["72"]);
G2L["a1"]["TextWrapped"] = true;
G2L["a1"]["TextSize"] = 19;
G2L["a1"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a1"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["a1"]["BackgroundTransparency"] = 1;
G2L["a1"]["Size"] = UDim2.new(0.66899, 0, 0.18094, 0);
G2L["a1"]["Text"] = [[Lets you weld onto others, forcing them to move in weird ways! supports partial names.]];
G2L["a1"]["Name"] = [[OthersText]];
G2L["a1"]["Position"] = UDim2.new(0.17428, 0, 0.1119, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.OthersTitle
G2L["a2"] = Instance.new("TextLabel", G2L["72"]);
G2L["a2"]["TextSize"] = 25;
G2L["a2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a2"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["a2"]["BackgroundTransparency"] = 1;
G2L["a2"]["Size"] = UDim2.new(0.52266, 0, 0.09633, 0);
G2L["a2"]["Text"] = [[Welding]];
G2L["a2"]["Name"] = [[OthersTitle]];
G2L["a2"]["Position"] = UDim2.new(0.2513, 0, 0.01917, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4
G2L["a3"] = Instance.new("Frame", G2L["10"]);
G2L["a3"]["ZIndex"] = 2;
G2L["a3"]["BorderSizePixel"] = 0;
G2L["a3"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["a3"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["a3"]["Position"] = UDim2.new(1.005, 0, 0, 0);
G2L["a3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["a3"]["Name"] = [[Others_4]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.OthersTitle
G2L["a4"] = Instance.new("TextLabel", G2L["a3"]);
G2L["a4"]["TextSize"] = 25;
G2L["a4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a4"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["a4"]["BackgroundTransparency"] = 1;
G2L["a4"]["Size"] = UDim2.new(0.52266, 0, 0.09575, 0);
G2L["a4"]["Text"] = [[Misc.]];
G2L["a4"]["Name"] = [[OthersTitle]];
G2L["a4"]["Position"] = UDim2.new(0.23998, 0, 0.05818, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.OthersText
G2L["a5"] = Instance.new("TextLabel", G2L["a3"]);
G2L["a5"]["TextWrapped"] = true;
G2L["a5"]["TextSize"] = 19;
G2L["a5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a5"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["a5"]["BackgroundTransparency"] = 1;
G2L["a5"]["Size"] = UDim2.new(0.78111, 0, 0.17985, 0);
G2L["a5"]["Text"] = [[Hidden info about other players!]];
G2L["a5"]["Name"] = [[OthersText]];
G2L["a5"]["Position"] = UDim2.new(0.11546, 0, 0.0904, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Weld_Image
G2L["a6"] = Instance.new("ImageLabel", G2L["a3"]);
G2L["a6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a6"]["Image"] = [[rbxassetid://1281477720]];
G2L["a6"]["Size"] = UDim2.new(0.0909, 0, 0.17262, 0);
G2L["a6"]["BackgroundTransparency"] = 1;
G2L["a6"]["Name"] = [[Weld_Image]];
G2L["a6"]["Position"] = UDim2.new(0.11992, 0, 0.19487, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.TXTBOX_PlrName
G2L["a7"] = Instance.new("TextBox", G2L["a3"]);
G2L["a7"]["Name"] = [[TXTBOX_PlrName]];
G2L["a7"]["ZIndex"] = 2;
G2L["a7"]["BorderSizePixel"] = 8;
G2L["a7"]["TextWrapped"] = true;
G2L["a7"]["TextSize"] = 14;
G2L["a7"]["TextScaled"] = true;
G2L["a7"]["BackgroundColor3"] = Color3.fromRGB(245, 248, 249);
G2L["a7"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["a7"]["Size"] = UDim2.new(0.52074, 0, 0.11542, 0);
G2L["a7"]["Position"] = UDim2.new(0.24453, 0, 0.27953, 0);
G2L["a7"]["BorderColor3"] = Color3.fromRGB(252, 227, 16);
G2L["a7"]["Text"] = [[]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon
G2L["a8"] = Instance.new("Frame", G2L["a3"]);
G2L["a8"]["BorderSizePixel"] = 0;
G2L["a8"]["BackgroundColor3"] = Color3.fromRGB(252, 227, 16);
G2L["a8"]["Size"] = UDim2.new(0.2, 0, 0.44241, 0);
G2L["a8"]["Position"] = UDim2.new(0.0638, 0, 0.46502, 0);
G2L["a8"]["Name"] = [[Colon]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon.Inspect
G2L["a9"] = Instance.new("TextButton", G2L["a8"]);
G2L["a9"]["TextWrapped"] = true;
G2L["a9"]["BorderSizePixel"] = 0;
G2L["a9"]["TextSize"] = 14;
G2L["a9"]["TextScaled"] = true;
G2L["a9"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["a9"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["a9"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["a9"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["a9"]["Text"] = [[Inspect]];
G2L["a9"]["Name"] = [[Inspect]];
G2L["a9"]["Position"] = UDim2.new(0, 0, 0.65, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon.Inspect.LocalScript
G2L["aa"] = Instance.new("LocalScript", G2L["a9"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon.Age
G2L["ab"] = Instance.new("TextButton", G2L["a8"]);
G2L["ab"]["TextWrapped"] = true;
G2L["ab"]["BorderSizePixel"] = 0;
G2L["ab"]["TextSize"] = 14;
G2L["ab"]["TextScaled"] = true;
G2L["ab"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["ab"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["ab"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["ab"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["ab"]["Text"] = [[Age]];
G2L["ab"]["Name"] = [[Age]];
G2L["ab"]["Position"] = UDim2.new(0, 0, 0.13, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon.Age.LocalScript
G2L["ac"] = Instance.new("LocalScript", G2L["ab"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon.JoinDate
G2L["ad"] = Instance.new("TextButton", G2L["a8"]);
G2L["ad"]["TextWrapped"] = true;
G2L["ad"]["BorderSizePixel"] = 0;
G2L["ad"]["TextSize"] = 14;
G2L["ad"]["TextScaled"] = true;
G2L["ad"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["ad"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["ad"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["ad"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["ad"]["Text"] = [[JoinDate]];
G2L["ad"]["Name"] = [[JoinDate]];
G2L["ad"]["Position"] = UDim2.new(0, 0, 0.39, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon.JoinDate.LocalScript
G2L["ae"] = Instance.new("LocalScript", G2L["ad"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon2
G2L["af"] = Instance.new("Frame", G2L["a3"]);
G2L["af"]["BorderSizePixel"] = 0;
G2L["af"]["BackgroundColor3"] = Color3.fromRGB(252, 227, 16);
G2L["af"]["Size"] = UDim2.new(0.2, 0, 0.44241, 0);
G2L["af"]["Position"] = UDim2.new(0.2838, 0, 0.46502, 0);
G2L["af"]["Name"] = [[Colon2]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon2.CopyTools
G2L["b0"] = Instance.new("TextButton", G2L["af"]);
G2L["b0"]["TextWrapped"] = true;
G2L["b0"]["BorderSizePixel"] = 0;
G2L["b0"]["TextSize"] = 14;
G2L["b0"]["TextScaled"] = true;
G2L["b0"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["b0"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["b0"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b0"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["b0"]["Text"] = [[CopyTools]];
G2L["b0"]["Name"] = [[CopyTools]];
G2L["b0"]["Position"] = UDim2.new(0, 0, 0.65, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon2.CopyTools.LocalScript
G2L["b1"] = Instance.new("LocalScript", G2L["b0"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon2.CopyAnims
G2L["b2"] = Instance.new("TextButton", G2L["af"]);
G2L["b2"]["TextWrapped"] = true;
G2L["b2"]["BorderSizePixel"] = 0;
G2L["b2"]["TextSize"] = 14;
G2L["b2"]["TextScaled"] = true;
G2L["b2"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["b2"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["b2"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b2"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["b2"]["Text"] = [[CopyAnims]];
G2L["b2"]["Name"] = [[CopyAnims]];
G2L["b2"]["Position"] = UDim2.new(0, 0, 0.39, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon2.CopyAnims.LocalScript
G2L["b3"] = Instance.new("LocalScript", G2L["b2"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon2.CopyID
G2L["b4"] = Instance.new("TextButton", G2L["af"]);
G2L["b4"]["TextWrapped"] = true;
G2L["b4"]["BorderSizePixel"] = 0;
G2L["b4"]["TextSize"] = 14;
G2L["b4"]["TextScaled"] = true;
G2L["b4"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["b4"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["b4"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b4"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["b4"]["Text"] = [[CopyID]];
G2L["b4"]["Name"] = [[CopyID]];
G2L["b4"]["Position"] = UDim2.new(0, 0, 0.13, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon2.CopyID.LocalScript
G2L["b5"] = Instance.new("LocalScript", G2L["b4"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon4
G2L["b6"] = Instance.new("Frame", G2L["a3"]);
G2L["b6"]["BorderSizePixel"] = 0;
G2L["b6"]["BackgroundColor3"] = Color3.fromRGB(252, 227, 16);
G2L["b6"]["Size"] = UDim2.new(0.2, 0, 0.44241, 0);
G2L["b6"]["Position"] = UDim2.new(0.7238, 0, 0.46502, 0);
G2L["b6"]["Name"] = [[WeldColon4]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon4.Health
G2L["b7"] = Instance.new("TextButton", G2L["b6"]);
G2L["b7"]["TextWrapped"] = true;
G2L["b7"]["BorderSizePixel"] = 0;
G2L["b7"]["TextSize"] = 14;
G2L["b7"]["TextScaled"] = true;
G2L["b7"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["b7"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["b7"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b7"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["b7"]["Text"] = [[Health]];
G2L["b7"]["Name"] = [[Health]];
G2L["b7"]["Position"] = UDim2.new(0, 0, 0.65, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon4.Health.LocalScript
G2L["b8"] = Instance.new("LocalScript", G2L["b7"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon4.FullName
G2L["b9"] = Instance.new("TextButton", G2L["b6"]);
G2L["b9"]["TextWrapped"] = true;
G2L["b9"]["BorderSizePixel"] = 0;
G2L["b9"]["TextSize"] = 14;
G2L["b9"]["TextScaled"] = true;
G2L["b9"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["b9"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["b9"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b9"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["b9"]["Text"] = [[FullName]];
G2L["b9"]["Name"] = [[FullName]];
G2L["b9"]["Position"] = UDim2.new(0, 0, 0.39, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon4.FullName.LocalScript
G2L["ba"] = Instance.new("LocalScript", G2L["b9"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon4.SimRadius
G2L["bb"] = Instance.new("TextButton", G2L["b6"]);
G2L["bb"]["TextWrapped"] = true;
G2L["bb"]["BorderSizePixel"] = 0;
G2L["bb"]["TextSize"] = 14;
G2L["bb"]["TextScaled"] = true;
G2L["bb"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["bb"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["bb"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["bb"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["bb"]["Text"] = [[SimRadius]];
G2L["bb"]["Name"] = [[SimRadius]];
G2L["bb"]["Position"] = UDim2.new(0, 0, 0.13, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon4.SimRadius.LocalScript
G2L["bc"] = Instance.new("LocalScript", G2L["bb"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon3
G2L["bd"] = Instance.new("Frame", G2L["a3"]);
G2L["bd"]["BorderSizePixel"] = 0;
G2L["bd"]["BackgroundColor3"] = Color3.fromRGB(252, 227, 16);
G2L["bd"]["Size"] = UDim2.new(0.2, 0, 0.44241, 0);
G2L["bd"]["Position"] = UDim2.new(0.5038, 0, 0.46502, 0);
G2L["bd"]["Name"] = [[WeldColon3]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon3.Friends
G2L["be"] = Instance.new("TextButton", G2L["bd"]);
G2L["be"]["TextWrapped"] = true;
G2L["be"]["BorderSizePixel"] = 0;
G2L["be"]["TextSize"] = 14;
G2L["be"]["TextScaled"] = true;
G2L["be"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["be"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["be"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["be"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["be"]["Text"] = [[Friends]];
G2L["be"]["Name"] = [[Friends]];
G2L["be"]["Position"] = UDim2.new(0, 0, 0.65, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon3.Friends.LocalScript
G2L["bf"] = Instance.new("LocalScript", G2L["be"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon3.Team
G2L["c0"] = Instance.new("TextButton", G2L["bd"]);
G2L["c0"]["TextWrapped"] = true;
G2L["c0"]["BorderSizePixel"] = 0;
G2L["c0"]["TextSize"] = 14;
G2L["c0"]["TextScaled"] = true;
G2L["c0"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["c0"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["c0"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c0"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["c0"]["Text"] = [[Team]];
G2L["c0"]["Name"] = [[Team]];
G2L["c0"]["Position"] = UDim2.new(0, 0, 0.39, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon3.Team.LocalScript
G2L["c1"] = Instance.new("LocalScript", G2L["c0"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon3.Membership
G2L["c2"] = Instance.new("TextButton", G2L["bd"]);
G2L["c2"]["TextWrapped"] = true;
G2L["c2"]["BorderSizePixel"] = 0;
G2L["c2"]["TextSize"] = 14;
G2L["c2"]["TextScaled"] = true;
G2L["c2"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["c2"]["BackgroundColor3"] = Color3.fromRGB(244, 157, 19);
G2L["c2"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c2"]["Size"] = UDim2.new(1, 0, 0.2096, 0);
G2L["c2"]["Text"] = [[Membership]];
G2L["c2"]["Name"] = [[Membership]];
G2L["c2"]["Position"] = UDim2.new(0, 0, 0.13, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon3.Membership.LocalScript
G2L["c3"] = Instance.new("LocalScript", G2L["c2"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Back
G2L["c4"] = Instance.new("TextButton", G2L["a3"]);
G2L["c4"]["BorderSizePixel"] = 0;
G2L["c4"]["TextSize"] = 22;
G2L["c4"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["c4"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["c4"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["c4"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["c4"]["Text"] = [[Prev]];
G2L["c4"]["Name"] = [[Back]];
G2L["c4"]["Position"] = UDim2.new(0.06792, 0, 0.04393, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Back.Character_toPAGE1_IMAGE
G2L["c5"] = Instance.new("ImageLabel", G2L["c4"]);
G2L["c5"]["BorderSizePixel"] = 0;
G2L["c5"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["c5"]["Image"] = [[http://www.roblox.com/asset/?id=1282894968]];
G2L["c5"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["c5"]["Name"] = [[Character_toPAGE1_IMAGE]];
G2L["c5"]["Position"] = UDim2.new(-0.40029, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3
G2L["c6"] = Instance.new("Frame", G2L["10"]);
G2L["c6"]["ZIndex"] = 2;
G2L["c6"]["BorderSizePixel"] = 0;
G2L["c6"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["c6"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["c6"]["Position"] = UDim2.new(1.005, 0, 0, 0);
G2L["c6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["c6"]["Name"] = [[Character_3]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio
G2L["c7"] = Instance.new("Frame", G2L["c6"]);
G2L["c7"]["BorderSizePixel"] = 0;
G2L["c7"]["BackgroundColor3"] = Color3.fromRGB(27, 189, 157);
G2L["c7"]["Size"] = UDim2.new(0.3655, 0, 0.64277, 0);
G2L["c7"]["Position"] = UDim2.new(0.5313, 0, 0.33204, 0);
G2L["c7"]["Name"] = [[Coolio]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Density
G2L["c8"] = Instance.new("TextButton", G2L["c7"]);
G2L["c8"]["BorderSizePixel"] = 0;
G2L["c8"]["TextSize"] = 17;
G2L["c8"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["c8"]["BackgroundColor3"] = Color3.fromRGB(22, 161, 134);
G2L["c8"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c8"]["Size"] = UDim2.new(0, 134, 0, 23);
G2L["c8"]["Text"] = [[Density]];
G2L["c8"]["Name"] = [[Density]];
G2L["c8"]["Position"] = UDim2.new(0.09016, 0, 0.07694, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Density.Density
G2L["c9"] = Instance.new("LocalScript", G2L["c8"]);
G2L["c9"]["Name"] = [[Density]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Trip
G2L["ca"] = Instance.new("TextButton", G2L["c7"]);
G2L["ca"]["BorderSizePixel"] = 0;
G2L["ca"]["TextSize"] = 17;
G2L["ca"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["ca"]["BackgroundColor3"] = Color3.fromRGB(22, 161, 134);
G2L["ca"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["ca"]["Size"] = UDim2.new(0, 134, 0, 23);
G2L["ca"]["Text"] = [[Trip]];
G2L["ca"]["Name"] = [[Trip]];
G2L["ca"]["Position"] = UDim2.new(0.09016, 0, 0.51379, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Trip.LocalScript
G2L["cb"] = Instance.new("LocalScript", G2L["ca"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.BreakJoints
G2L["cc"] = Instance.new("TextButton", G2L["c7"]);
G2L["cc"]["BorderSizePixel"] = 0;
G2L["cc"]["TextSize"] = 17;
G2L["cc"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["cc"]["BackgroundColor3"] = Color3.fromRGB(22, 161, 134);
G2L["cc"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["cc"]["Size"] = UDim2.new(0, 134, 0, 23);
G2L["cc"]["Text"] = [[BreakJoints]];
G2L["cc"]["Name"] = [[BreakJoints]];
G2L["cc"]["Position"] = UDim2.new(0.09016, 0, 0.73221, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.BreakJoints.LocalScript
G2L["cd"] = Instance.new("LocalScript", G2L["cc"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.ExtraBaseBackGround2Side
G2L["ce"] = Instance.new("Frame", G2L["c7"]);
G2L["ce"]["BorderSizePixel"] = 0;
G2L["ce"]["BackgroundColor3"] = Color3.fromRGB(22, 161, 134);
G2L["ce"]["Size"] = UDim2.new(1, 0, 0.10955, 0);
G2L["ce"]["Position"] = UDim2.new(0, 0, -0.10507, 0);
G2L["ce"]["Name"] = [[ExtraBaseBackGround2Side]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.R6
G2L["cf"] = Instance.new("TextButton", G2L["c7"]);
G2L["cf"]["BorderSizePixel"] = 0;
G2L["cf"]["TextSize"] = 17;
G2L["cf"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["cf"]["BackgroundColor3"] = Color3.fromRGB(22, 161, 134);
G2L["cf"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["cf"]["Size"] = UDim2.new(0, 134, 0, 23);
G2L["cf"]["Text"] = [[R15 -> R6]];
G2L["cf"]["Name"] = [[R6]];
G2L["cf"]["Position"] = UDim2.new(0.09016, 0, 0.29536, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.R6.LocalScript
G2L["d0"] = Instance.new("LocalScript", G2L["cf"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio
G2L["d1"] = Instance.new("Frame", G2L["c6"]);
G2L["d1"]["BorderSizePixel"] = 0;
G2L["d1"]["BackgroundColor3"] = Color3.fromRGB(241, 197, 15);
G2L["d1"]["Size"] = UDim2.new(0.3655, 0, 0.64277, 0);
G2L["d1"]["Position"] = UDim2.new(0.1, 0, 0.33204, 0);
G2L["d1"]["Name"] = [[Coolio]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Hampster
G2L["d2"] = Instance.new("TextButton", G2L["d1"]);
G2L["d2"]["BorderSizePixel"] = 0;
G2L["d2"]["TextSize"] = 17;
G2L["d2"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["d2"]["BackgroundColor3"] = Color3.fromRGB(243, 157, 18);
G2L["d2"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["d2"]["Size"] = UDim2.new(0, 134, 0, 23);
G2L["d2"]["Text"] = [[Hampster Ball]];
G2L["d2"]["Name"] = [[Hampster]];
G2L["d2"]["Position"] = UDim2.new(0.09016, 0, 0.07694, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Hampster.LocalScript
G2L["d3"] = Instance.new("LocalScript", G2L["d2"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.ExtraBaseBackGround1Side
G2L["d4"] = Instance.new("Frame", G2L["d1"]);
G2L["d4"]["BorderSizePixel"] = 0;
G2L["d4"]["BackgroundColor3"] = Color3.fromRGB(243, 157, 18);
G2L["d4"]["Size"] = UDim2.new(1, 0, 0.10955, 0);
G2L["d4"]["Position"] = UDim2.new(0, 0, -0.10507, 0);
G2L["d4"]["Name"] = [[ExtraBaseBackGround1Side]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Freeze
G2L["d5"] = Instance.new("TextButton", G2L["d1"]);
G2L["d5"]["BorderSizePixel"] = 0;
G2L["d5"]["TextSize"] = 17;
G2L["d5"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["d5"]["BackgroundColor3"] = Color3.fromRGB(243, 157, 18);
G2L["d5"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["d5"]["Size"] = UDim2.new(0, 134, 0, 23);
G2L["d5"]["Text"] = [[Freeze]];
G2L["d5"]["Name"] = [[Freeze]];
G2L["d5"]["Position"] = UDim2.new(0.09016, 0, 0.29536, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Freeze.LocalScript
G2L["d6"] = Instance.new("LocalScript", G2L["d5"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.No Gravity
G2L["d7"] = Instance.new("TextButton", G2L["d1"]);
G2L["d7"]["BorderSizePixel"] = 0;
G2L["d7"]["TextSize"] = 17;
G2L["d7"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["d7"]["BackgroundColor3"] = Color3.fromRGB(243, 157, 18);
G2L["d7"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["d7"]["Size"] = UDim2.new(0, 134, 0, 23);
G2L["d7"]["Text"] = [[No Gravity]];
G2L["d7"]["Name"] = [[No Gravity]];
G2L["d7"]["Position"] = UDim2.new(0.09016, 0, 0.51379, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.No Gravity.Grav
G2L["d8"] = Instance.new("LocalScript", G2L["d7"]);
G2L["d8"]["Name"] = [[Grav]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Dash
G2L["d9"] = Instance.new("TextButton", G2L["d1"]);
G2L["d9"]["BorderSizePixel"] = 0;
G2L["d9"]["TextSize"] = 17;
G2L["d9"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["d9"]["BackgroundColor3"] = Color3.fromRGB(243, 157, 18);
G2L["d9"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["d9"]["Size"] = UDim2.new(0, 134, 0, 23);
G2L["d9"]["Text"] = [[Dash]];
G2L["d9"]["Name"] = [[Dash]];
G2L["d9"]["Position"] = UDim2.new(0.09016, 0, 0.73221, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Dash.LocalScript
G2L["da"] = Instance.new("LocalScript", G2L["d9"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.OthersText
G2L["db"] = Instance.new("TextLabel", G2L["c6"]);
G2L["db"]["TextWrapped"] = true;
G2L["db"]["TextSize"] = 19;
G2L["db"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["db"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["db"]["BackgroundTransparency"] = 1;
G2L["db"]["Size"] = UDim2.new(0.78111, 0, 0.1126, 0);
G2L["db"]["Text"] = [[Some extra commands for yourself!]];
G2L["db"]["Name"] = [[OthersText]];
G2L["db"]["Position"] = UDim2.new(0.11998, 0, 0.14075, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.OthersTitle
G2L["dc"] = Instance.new("TextLabel", G2L["c6"]);
G2L["dc"]["TextSize"] = 25;
G2L["dc"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["dc"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["dc"]["BackgroundTransparency"] = 1;
G2L["dc"]["Size"] = UDim2.new(0.52266, 0, 0.0956, 0);
G2L["dc"]["Text"] = [[Extra]];
G2L["dc"]["Name"] = [[OthersTitle]];
G2L["dc"]["Position"] = UDim2.new(0.23772, 0, 0.04828, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Char_Image
G2L["dd"] = Instance.new("ImageLabel", G2L["c6"]);
G2L["dd"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["dd"]["Image"] = [[rbxassetid://1281477720]];
G2L["dd"]["Size"] = UDim2.new(0.0909, 0, 0.17234, 0);
G2L["dd"]["BackgroundTransparency"] = 1;
G2L["dd"]["Name"] = [[Char_Image]];
G2L["dd"]["Position"] = UDim2.new(0.32354, 0, 0.00653, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Back
G2L["de"] = Instance.new("TextButton", G2L["c6"]);
G2L["de"]["BorderSizePixel"] = 0;
G2L["de"]["TextSize"] = 22;
G2L["de"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["de"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["de"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["de"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["de"]["Text"] = [[Prev]];
G2L["de"]["Name"] = [[Back]];
G2L["de"]["Position"] = UDim2.new(0.06792, 0, 0.04393, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Back.Character_toPAGE1_IMAGE
G2L["df"] = Instance.new("ImageLabel", G2L["de"]);
G2L["df"]["BorderSizePixel"] = 0;
G2L["df"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["df"]["Image"] = [[http://www.roblox.com/asset/?id=1282894968]];
G2L["df"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["df"]["Name"] = [[Character_toPAGE1_IMAGE]];
G2L["df"]["Position"] = UDim2.new(-0.40029, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1
G2L["e0"] = Instance.new("Frame", G2L["10"]);
G2L["e0"]["ZIndex"] = 2;
G2L["e0"]["BorderSizePixel"] = 0;
G2L["e0"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["e0"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["e0"]["Position"] = UDim2.new(1.005, 0, 0, 0);
G2L["e0"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["e0"]["Name"] = [[Animations_1]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.HANDLER
G2L["e1"] = Instance.new("LocalScript", G2L["e0"]);
G2L["e1"]["Name"] = [[HANDLER]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1
G2L["e2"] = Instance.new("Frame", G2L["e0"]);
G2L["e2"]["BorderSizePixel"] = 0;
G2L["e2"]["BackgroundColor3"] = Color3.fromRGB(192, 57, 43);
G2L["e2"]["Size"] = UDim2.new(0.2, 0, 0.70674, 0);
G2L["e2"]["Position"] = UDim2.new(0.08605, 0, 0.26953, 0);
G2L["e2"]["Name"] = [[AnimColon1]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Bee
G2L["e3"] = Instance.new("TextButton", G2L["e2"]);
G2L["e3"]["TextWrapped"] = true;
G2L["e3"]["BorderSizePixel"] = 0;
G2L["e3"]["TextSize"] = 14;
G2L["e3"]["TextScaled"] = true;
G2L["e3"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["e3"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["e3"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["e3"]["Size"] = UDim2.new(1, 0, 0.12, 0);
G2L["e3"]["Text"] = [[Bee]];
G2L["e3"]["Name"] = [[Bee]];
G2L["e3"]["Position"] = UDim2.new(0, 0, 0.11425, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Bee.SPEED
G2L["e4"] = Instance.new("NumberValue", G2L["e3"]);
G2L["e4"]["Name"] = [[SPEED]];
G2L["e4"]["Value"] = 2;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Bee.WEIGHT
G2L["e5"] = Instance.new("NumberValue", G2L["e3"]);
G2L["e5"]["Name"] = [[WEIGHT]];
G2L["e5"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Bee.ANIM
G2L["e6"] = Instance.new("NumberValue", G2L["e3"]);
G2L["e6"]["Name"] = [[ANIM]];
G2L["e6"]["Value"] = 90814669;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Headless
G2L["e7"] = Instance.new("TextButton", G2L["e2"]);
G2L["e7"]["TextWrapped"] = true;
G2L["e7"]["BorderSizePixel"] = 0;
G2L["e7"]["TextSize"] = 14;
G2L["e7"]["TextScaled"] = true;
G2L["e7"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["e7"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["e7"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["e7"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["e7"]["Text"] = [[Headless]];
G2L["e7"]["Name"] = [[Headless]];
G2L["e7"]["Position"] = UDim2.new(0, 0, 0.27, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Headless.SPEED
G2L["e8"] = Instance.new("NumberValue", G2L["e7"]);
G2L["e8"]["Name"] = [[SPEED]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Headless.ANIM
G2L["e9"] = Instance.new("NumberValue", G2L["e7"]);
G2L["e9"]["Name"] = [[ANIM]];
G2L["e9"]["Value"] = 68339848;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Headless.WEIGHT
G2L["ea"] = Instance.new("NumberValue", G2L["e7"]);
G2L["ea"]["Name"] = [[WEIGHT]];
G2L["ea"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.NoArms
G2L["eb"] = Instance.new("TextButton", G2L["e2"]);
G2L["eb"]["TextWrapped"] = true;
G2L["eb"]["BorderSizePixel"] = 0;
G2L["eb"]["TextSize"] = 14;
G2L["eb"]["TextScaled"] = true;
G2L["eb"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["eb"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["eb"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["eb"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["eb"]["Text"] = [[No Arms]];
G2L["eb"]["Name"] = [[NoArms]];
G2L["eb"]["Position"] = UDim2.new(0, 0, 0.42, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.NoArms.WEIGHT
G2L["ec"] = Instance.new("NumberValue", G2L["eb"]);
G2L["ec"]["Name"] = [[WEIGHT]];
G2L["ec"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.NoArms.SPEED
G2L["ed"] = Instance.new("NumberValue", G2L["eb"]);
G2L["ed"]["Name"] = [[SPEED]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.NoArms.ANIM
G2L["ee"] = Instance.new("NumberValue", G2L["eb"]);
G2L["ee"]["Name"] = [[ANIM]];
G2L["ee"]["Value"] = 103798833;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.NoArms.TIME
G2L["ef"] = Instance.new("NumberValue", G2L["eb"]);
G2L["ef"]["Name"] = [[TIME]];
G2L["ef"]["Value"] = 1.9;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.ClassicDance
G2L["f0"] = Instance.new("TextButton", G2L["e2"]);
G2L["f0"]["TextWrapped"] = true;
G2L["f0"]["BorderSizePixel"] = 0;
G2L["f0"]["TextSize"] = 14;
G2L["f0"]["TextScaled"] = true;
G2L["f0"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["f0"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["f0"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["f0"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["f0"]["Text"] = [[Classic Dance]];
G2L["f0"]["Name"] = [[ClassicDance]];
G2L["f0"]["Position"] = UDim2.new(0, 0, 0.57, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.ClassicDance.ANIM
G2L["f1"] = Instance.new("NumberValue", G2L["f0"]);
G2L["f1"]["Name"] = [[ANIM]];
G2L["f1"]["Value"] = 27789359;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.ClassicDance.WEIGHT
G2L["f2"] = Instance.new("NumberValue", G2L["f0"]);
G2L["f2"]["Name"] = [[WEIGHT]];
G2L["f2"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.ClassicDance.SPEED
G2L["f3"] = Instance.new("NumberValue", G2L["f0"]);
G2L["f3"]["Name"] = [[SPEED]];
G2L["f3"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Spinny arm
G2L["f4"] = Instance.new("TextButton", G2L["e2"]);
G2L["f4"]["TextWrapped"] = true;
G2L["f4"]["BorderSizePixel"] = 0;
G2L["f4"]["TextSize"] = 14;
G2L["f4"]["TextScaled"] = true;
G2L["f4"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["f4"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["f4"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["f4"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["f4"]["Text"] = [[Spinny arm]];
G2L["f4"]["Name"] = [[Spinny arm]];
G2L["f4"]["Position"] = UDim2.new(0, 0, 0.72, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Spinny arm.WEIGHT
G2L["f5"] = Instance.new("NumberValue", G2L["f4"]);
G2L["f5"]["Name"] = [[WEIGHT]];
G2L["f5"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Spinny arm.SPEED
G2L["f6"] = Instance.new("NumberValue", G2L["f4"]);
G2L["f6"]["Name"] = [[SPEED]];
G2L["f6"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon1.Spinny arm.ANIM
G2L["f7"] = Instance.new("NumberValue", G2L["f4"]);
G2L["f7"]["Name"] = [[ANIM]];
G2L["f7"]["Value"] = 57862093;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2
G2L["f8"] = Instance.new("Frame", G2L["e0"]);
G2L["f8"]["BorderSizePixel"] = 0;
G2L["f8"]["BackgroundColor3"] = Color3.fromRGB(192, 57, 43);
G2L["f8"]["Size"] = UDim2.new(0.2, 0, 0.70674, 0);
G2L["f8"]["Position"] = UDim2.new(0.29419, 0, 0.26953, 0);
G2L["f8"]["Name"] = [[AnimColon2]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.WavyHands
G2L["f9"] = Instance.new("TextButton", G2L["f8"]);
G2L["f9"]["TextWrapped"] = true;
G2L["f9"]["BorderSizePixel"] = 0;
G2L["f9"]["TextSize"] = 14;
G2L["f9"]["TextScaled"] = true;
G2L["f9"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["f9"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["f9"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["f9"]["Size"] = UDim2.new(1, 0, 0.12, 0);
G2L["f9"]["Text"] = [[Wavy Hands]];
G2L["f9"]["Name"] = [[WavyHands]];
G2L["f9"]["Position"] = UDim2.new(0, 0, 0.11425, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.WavyHands.WEIGHT
G2L["fa"] = Instance.new("NumberValue", G2L["f9"]);
G2L["fa"]["Name"] = [[WEIGHT]];
G2L["fa"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.WavyHands.SPEED
G2L["fb"] = Instance.new("NumberValue", G2L["f9"]);
G2L["fb"]["Name"] = [[SPEED]];
G2L["fb"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.WavyHands.ANIM
G2L["fc"] = Instance.new("NumberValue", G2L["f9"]);
G2L["fc"]["Name"] = [[ANIM]];
G2L["fc"]["Value"] = 85568863;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Flat legs
G2L["fd"] = Instance.new("TextButton", G2L["f8"]);
G2L["fd"]["TextWrapped"] = true;
G2L["fd"]["BorderSizePixel"] = 0;
G2L["fd"]["TextSize"] = 14;
G2L["fd"]["TextScaled"] = true;
G2L["fd"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["fd"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["fd"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["fd"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["fd"]["Text"] = [[Flat legs]];
G2L["fd"]["Name"] = [[Flat legs]];
G2L["fd"]["Position"] = UDim2.new(0, 0, 0.27, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Flat legs.ANIM
G2L["fe"] = Instance.new("NumberValue", G2L["fd"]);
G2L["fe"]["Name"] = [[ANIM]];
G2L["fe"]["Value"] = 87986341;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Flat legs.SPEED
G2L["ff"] = Instance.new("NumberValue", G2L["fd"]);
G2L["ff"]["Name"] = [[SPEED]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Flat legs.WEIGHT
G2L["100"] = Instance.new("NumberValue", G2L["fd"]);
G2L["100"]["Name"] = [[WEIGHT]];
G2L["100"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Flat Head
G2L["101"] = Instance.new("TextButton", G2L["f8"]);
G2L["101"]["TextWrapped"] = true;
G2L["101"]["BorderSizePixel"] = 0;
G2L["101"]["TextSize"] = 14;
G2L["101"]["TextScaled"] = true;
G2L["101"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["101"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["101"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["101"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["101"]["Text"] = [[Flat head]];
G2L["101"]["Name"] = [[Flat Head]];
G2L["101"]["Position"] = UDim2.new(0, 0, 0.42, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Flat Head.WEIGHT
G2L["102"] = Instance.new("NumberValue", G2L["101"]);
G2L["102"]["Name"] = [[WEIGHT]];
G2L["102"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Flat Head.SPEED
G2L["103"] = Instance.new("NumberValue", G2L["101"]);
G2L["103"]["Name"] = [[SPEED]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Flat Head.ANIM
G2L["104"] = Instance.new("NumberValue", G2L["101"]);
G2L["104"]["Name"] = [[ANIM]];
G2L["104"]["Value"] = 88016955;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Scream
G2L["105"] = Instance.new("TextButton", G2L["f8"]);
G2L["105"]["TextWrapped"] = true;
G2L["105"]["BorderSizePixel"] = 0;
G2L["105"]["TextSize"] = 14;
G2L["105"]["TextScaled"] = true;
G2L["105"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["105"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["105"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["105"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["105"]["Text"] = [[Scream]];
G2L["105"]["Name"] = [[Scream]];
G2L["105"]["Position"] = UDim2.new(0, 0, 0.57, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Scream.WEIGHT
G2L["106"] = Instance.new("NumberValue", G2L["105"]);
G2L["106"]["Name"] = [[WEIGHT]];
G2L["106"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Scream.SPEED
G2L["107"] = Instance.new("NumberValue", G2L["105"]);
G2L["107"]["Name"] = [[SPEED]];
G2L["107"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Scream.ANIM
G2L["108"] = Instance.new("NumberValue", G2L["105"]);
G2L["108"]["Name"] = [[ANIM]];
G2L["108"]["Value"] = 93648331;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Psycho walk
G2L["109"] = Instance.new("TextButton", G2L["f8"]);
G2L["109"]["TextWrapped"] = true;
G2L["109"]["BorderSizePixel"] = 0;
G2L["109"]["TextSize"] = 14;
G2L["109"]["TextScaled"] = true;
G2L["109"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["109"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["109"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["109"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["109"]["Text"] = [[Psycho walk]];
G2L["109"]["Name"] = [[Psycho walk]];
G2L["109"]["Position"] = UDim2.new(0, 0, 0.72, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Psycho walk.WEIGHT
G2L["10a"] = Instance.new("NumberValue", G2L["109"]);
G2L["10a"]["Name"] = [[WEIGHT]];
G2L["10a"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Psycho walk.SPEED
G2L["10b"] = Instance.new("NumberValue", G2L["109"]);
G2L["10b"]["Name"] = [[SPEED]];
G2L["10b"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon2.Psycho walk.ANIM
G2L["10c"] = Instance.new("NumberValue", G2L["109"]);
G2L["10c"]["Name"] = [[ANIM]];
G2L["10c"]["Value"] = 95415492;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3
G2L["10d"] = Instance.new("Frame", G2L["e0"]);
G2L["10d"]["BorderSizePixel"] = 0;
G2L["10d"]["BackgroundColor3"] = Color3.fromRGB(192, 57, 43);
G2L["10d"]["Size"] = UDim2.new(0.2, 0, 0.70674, 0);
G2L["10d"]["Position"] = UDim2.new(0.5046, 0, 0.26953, 0);
G2L["10d"]["Name"] = [[AnimColon3]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.StopLegs
G2L["10e"] = Instance.new("TextButton", G2L["10d"]);
G2L["10e"]["TextWrapped"] = true;
G2L["10e"]["BorderSizePixel"] = 0;
G2L["10e"]["TextSize"] = 14;
G2L["10e"]["TextScaled"] = true;
G2L["10e"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["10e"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["10e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["10e"]["Size"] = UDim2.new(1, 0, 0.12, 0);
G2L["10e"]["Text"] = [[Stop legs]];
G2L["10e"]["Name"] = [[StopLegs]];
G2L["10e"]["Position"] = UDim2.new(0, 0, 0.11425, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.StopLegs.WEIGHT
G2L["10f"] = Instance.new("NumberValue", G2L["10e"]);
G2L["10f"]["Name"] = [[WEIGHT]];
G2L["10f"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.StopLegs.SPEED
G2L["110"] = Instance.new("NumberValue", G2L["10e"]);
G2L["110"]["Name"] = [[SPEED]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.StopLegs.ANIM
G2L["111"] = Instance.new("NumberValue", G2L["10e"]);
G2L["111"]["Name"] = [[ANIM]];
G2L["111"]["Value"] = 109530008;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Nope
G2L["112"] = Instance.new("TextButton", G2L["10d"]);
G2L["112"]["TextWrapped"] = true;
G2L["112"]["BorderSizePixel"] = 0;
G2L["112"]["TextSize"] = 14;
G2L["112"]["TextScaled"] = true;
G2L["112"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["112"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["112"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["112"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["112"]["Text"] = [[Nope]];
G2L["112"]["Name"] = [[Nope]];
G2L["112"]["Position"] = UDim2.new(0, 0, 0.27, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Nope.WEIGHT
G2L["113"] = Instance.new("NumberValue", G2L["112"]);
G2L["113"]["Name"] = [[WEIGHT]];
G2L["113"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Nope.SPEED
G2L["114"] = Instance.new("NumberValue", G2L["112"]);
G2L["114"]["Name"] = [[SPEED]];
G2L["114"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Nope.ANIM
G2L["115"] = Instance.new("NumberValue", G2L["112"]);
G2L["115"]["Name"] = [[ANIM]];
G2L["115"]["Value"] = 121574294;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.AxisRotation
G2L["116"] = Instance.new("TextButton", G2L["10d"]);
G2L["116"]["TextWrapped"] = true;
G2L["116"]["BorderSizePixel"] = 0;
G2L["116"]["TextSize"] = 14;
G2L["116"]["TextScaled"] = true;
G2L["116"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["116"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["116"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["116"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["116"]["Text"] = [[Axis Rotation]];
G2L["116"]["Name"] = [[AxisRotation]];
G2L["116"]["Position"] = UDim2.new(0, 0, 0.42, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.AxisRotation.WEIGHT
G2L["117"] = Instance.new("NumberValue", G2L["116"]);
G2L["117"]["Name"] = [[WEIGHT]];
G2L["117"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.AxisRotation.SPEED
G2L["118"] = Instance.new("NumberValue", G2L["116"]);
G2L["118"]["Name"] = [[SPEED]];
G2L["118"]["Value"] = 1.5;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.AxisRotation.ANIM
G2L["119"] = Instance.new("NumberValue", G2L["116"]);
G2L["119"]["Name"] = [[ANIM]];
G2L["119"]["Value"] = 136807365;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Ski
G2L["11a"] = Instance.new("TextButton", G2L["10d"]);
G2L["11a"]["TextWrapped"] = true;
G2L["11a"]["BorderSizePixel"] = 0;
G2L["11a"]["TextSize"] = 14;
G2L["11a"]["TextScaled"] = true;
G2L["11a"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["11a"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["11a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["11a"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["11a"]["Text"] = [[Ski]];
G2L["11a"]["Name"] = [[Ski]];
G2L["11a"]["Position"] = UDim2.new(0, 0, 0.57, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Ski.WEIGHT
G2L["11b"] = Instance.new("NumberValue", G2L["11a"]);
G2L["11b"]["Name"] = [[WEIGHT]];
G2L["11b"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Ski.SPEED
G2L["11c"] = Instance.new("NumberValue", G2L["11a"]);
G2L["11c"]["Name"] = [[SPEED]];
G2L["11c"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Ski.ANIM
G2L["11d"] = Instance.new("NumberValue", G2L["11a"]);
G2L["11d"]["Name"] = [[ANIM]];
G2L["11d"]["Value"] = 142890187;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Offset
G2L["11e"] = Instance.new("TextButton", G2L["10d"]);
G2L["11e"]["TextWrapped"] = true;
G2L["11e"]["BorderSizePixel"] = 0;
G2L["11e"]["TextSize"] = 14;
G2L["11e"]["TextScaled"] = true;
G2L["11e"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["11e"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["11e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["11e"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["11e"]["Text"] = [[Offset]];
G2L["11e"]["Name"] = [[Offset]];
G2L["11e"]["Position"] = UDim2.new(0, 0, 0.72, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Offset.ANIM
G2L["11f"] = Instance.new("NumberValue", G2L["11e"]);
G2L["11f"]["Name"] = [[ANIM]];
G2L["11f"]["Value"] = 215384594;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Offset.SPEED
G2L["120"] = Instance.new("NumberValue", G2L["11e"]);
G2L["120"]["Name"] = [[SPEED]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Offset.WEIGHT
G2L["121"] = Instance.new("NumberValue", G2L["11e"]);
G2L["121"]["Name"] = [[WEIGHT]];
G2L["121"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon3.Offset.TIME
G2L["122"] = Instance.new("NumberValue", G2L["11e"]);
G2L["122"]["Name"] = [[TIME]];
G2L["122"]["Value"] = 1.2;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4
G2L["123"] = Instance.new("Frame", G2L["e0"]);
G2L["123"]["BorderSizePixel"] = 0;
G2L["123"]["BackgroundColor3"] = Color3.fromRGB(192, 57, 43);
G2L["123"]["Size"] = UDim2.new(0.2, 0, 0.70674, 0);
G2L["123"]["Position"] = UDim2.new(0.71274, 0, 0.26953, 0);
G2L["123"]["Name"] = [[AnimColon4]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.DinoWalk
G2L["124"] = Instance.new("TextButton", G2L["123"]);
G2L["124"]["TextWrapped"] = true;
G2L["124"]["BorderSizePixel"] = 0;
G2L["124"]["TextSize"] = 14;
G2L["124"]["TextScaled"] = true;
G2L["124"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["124"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["124"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["124"]["Size"] = UDim2.new(1, 0, 0.12, 0);
G2L["124"]["Text"] = [[DinoWalk]];
G2L["124"]["Name"] = [[DinoWalk]];
G2L["124"]["Position"] = UDim2.new(0, 0, 0.11425, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.DinoWalk.WEIGHT
G2L["125"] = Instance.new("NumberValue", G2L["124"]);
G2L["125"]["Name"] = [[WEIGHT]];
G2L["125"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.DinoWalk.SPEED
G2L["126"] = Instance.new("NumberValue", G2L["124"]);
G2L["126"]["Name"] = [[SPEED]];
G2L["126"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.DinoWalk.ANIM
G2L["127"] = Instance.new("NumberValue", G2L["124"]);
G2L["127"]["Name"] = [[ANIM]];
G2L["127"]["Value"] = 204328711;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Windmill
G2L["128"] = Instance.new("TextButton", G2L["123"]);
G2L["128"]["TextWrapped"] = true;
G2L["128"]["BorderSizePixel"] = 0;
G2L["128"]["TextSize"] = 14;
G2L["128"]["TextScaled"] = true;
G2L["128"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["128"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["128"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["128"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["128"]["Text"] = [[Windmill]];
G2L["128"]["Name"] = [[Windmill]];
G2L["128"]["Position"] = UDim2.new(0, 0, 0.42, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Windmill.SPEED
G2L["129"] = Instance.new("NumberValue", G2L["128"]);
G2L["129"]["Name"] = [[SPEED]];
G2L["129"]["Value"] = 1.5;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Windmill.WEIGHT
G2L["12a"] = Instance.new("NumberValue", G2L["128"]);
G2L["12a"]["Name"] = [[WEIGHT]];
G2L["12a"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Windmill.ANIM
G2L["12b"] = Instance.new("NumberValue", G2L["128"]);
G2L["12b"]["Name"] = [[ANIM]];
G2L["12b"]["Value"] = 259438880;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Charleston
G2L["12c"] = Instance.new("TextButton", G2L["123"]);
G2L["12c"]["TextWrapped"] = true;
G2L["12c"]["BorderSizePixel"] = 0;
G2L["12c"]["TextSize"] = 14;
G2L["12c"]["TextScaled"] = true;
G2L["12c"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["12c"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["12c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["12c"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["12c"]["Text"] = [[Charleston]];
G2L["12c"]["Name"] = [[Charleston]];
G2L["12c"]["Position"] = UDim2.new(0, 0, 0.57, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Charleston.WEIGHT
G2L["12d"] = Instance.new("NumberValue", G2L["12c"]);
G2L["12d"]["Name"] = [[WEIGHT]];
G2L["12d"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Charleston.SPEED
G2L["12e"] = Instance.new("NumberValue", G2L["12c"]);
G2L["12e"]["Name"] = [[SPEED]];
G2L["12e"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Charleston.ANIM
G2L["12f"] = Instance.new("NumberValue", G2L["12c"]);
G2L["12f"]["Name"] = [[ANIM]];
G2L["12f"]["Value"] = 429703734;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Hawking
G2L["130"] = Instance.new("TextButton", G2L["123"]);
G2L["130"]["TextWrapped"] = true;
G2L["130"]["BorderSizePixel"] = 0;
G2L["130"]["TextSize"] = 14;
G2L["130"]["TextScaled"] = true;
G2L["130"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["130"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["130"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["130"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["130"]["Text"] = [[Hawking]];
G2L["130"]["Name"] = [[Hawking]];
G2L["130"]["Position"] = UDim2.new(0, 0, 0.72, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Hawking.WEIGHT
G2L["131"] = Instance.new("NumberValue", G2L["130"]);
G2L["131"]["Name"] = [[WEIGHT]];
G2L["131"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Hawking.SPEED
G2L["132"] = Instance.new("NumberValue", G2L["130"]);
G2L["132"]["Name"] = [[SPEED]];
G2L["132"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.Hawking.ANIM
G2L["133"] = Instance.new("NumberValue", G2L["130"]);
G2L["133"]["Name"] = [[ANIM]];
G2L["133"]["Value"] = 283545583;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.JeffRun
G2L["134"] = Instance.new("TextButton", G2L["123"]);
G2L["134"]["TextWrapped"] = true;
G2L["134"]["BorderSizePixel"] = 0;
G2L["134"]["TextSize"] = 14;
G2L["134"]["TextScaled"] = true;
G2L["134"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["134"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["134"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["134"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["134"]["Text"] = [[Jeff Run]];
G2L["134"]["Name"] = [[JeffRun]];
G2L["134"]["Position"] = UDim2.new(0, 0, 0.27, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.JeffRun.WEIGHT
G2L["135"] = Instance.new("NumberValue", G2L["134"]);
G2L["135"]["Name"] = [[WEIGHT]];
G2L["135"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.JeffRun.SPEED
G2L["136"] = Instance.new("NumberValue", G2L["134"]);
G2L["136"]["Name"] = [[SPEED]];
G2L["136"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimColon4.JeffRun.ANIM
G2L["137"] = Instance.new("NumberValue", G2L["134"]);
G2L["137"]["Name"] = [[ANIM]];
G2L["137"]["Value"] = 252557606;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimsTitle
G2L["138"] = Instance.new("TextLabel", G2L["e0"]);
G2L["138"]["TextSize"] = 25;
G2L["138"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["138"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["138"]["BackgroundTransparency"] = 1;
G2L["138"]["Size"] = UDim2.new(0.52266, 0, 0.08817, 0);
G2L["138"]["Text"] = [[Animations]];
G2L["138"]["Name"] = [[AnimsTitle]];
G2L["138"]["Position"] = UDim2.new(0.22641, 0, 0.02871, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.AnimsTitle
G2L["139"] = Instance.new("TextLabel", G2L["e0"]);
G2L["139"]["TextSize"] = 25;
G2L["139"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["139"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["139"]["BackgroundTransparency"] = 1;
G2L["139"]["Size"] = UDim2.new(0.52266, 0, 0.08817, 0);
G2L["139"]["Text"] = [[R6]];
G2L["139"]["Name"] = [[AnimsTitle]];
G2L["139"]["Position"] = UDim2.new(0.23546, 0, 0.15255, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.Next
G2L["13a"] = Instance.new("TextButton", G2L["e0"]);
G2L["13a"]["BorderSizePixel"] = 0;
G2L["13a"]["TextSize"] = 22;
G2L["13a"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["13a"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["13a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["13a"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["13a"]["Text"] = [[Next]];
G2L["13a"]["Name"] = [[Next]];
G2L["13a"]["Position"] = UDim2.new(0.82, 0, 0.044, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.Next.Character_toPAGE2_IMAGE
G2L["13b"] = Instance.new("ImageLabel", G2L["13a"]);
G2L["13b"]["BorderSizePixel"] = 0;
G2L["13b"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["13b"]["Image"] = [[http://www.roblox.com/asset/?id=1282737326]];
G2L["13b"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["13b"]["Name"] = [[Character_toPAGE2_IMAGE]];
G2L["13b"]["Position"] = UDim2.new(0.90066, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.T_AnimationsImage
G2L["13c"] = Instance.new("ImageLabel", G2L["e0"]);
G2L["13c"]["ZIndex"] = 2;
G2L["13c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["13c"]["Image"] = [[rbxassetid://117644623910680]];
G2L["13c"]["Size"] = UDim2.new(0.08354, 0, 0.14685, 0);
G2L["13c"]["BackgroundTransparency"] = 1;
G2L["13c"]["Name"] = [[T_AnimationsImage]];
G2L["13c"]["Position"] = UDim2.new(0.23588, 0, 0.08041, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2
G2L["13d"] = Instance.new("Frame", G2L["10"]);
G2L["13d"]["ZIndex"] = 2;
G2L["13d"]["BorderSizePixel"] = 0;
G2L["13d"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["13d"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["13d"]["Position"] = UDim2.new(1.005, 0, 0, 0);
G2L["13d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["13d"]["Name"] = [[Animations_2]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.HANDLER
G2L["13e"] = Instance.new("LocalScript", G2L["13d"]);
G2L["13e"]["Name"] = [[HANDLER]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.AnimsTitle
G2L["13f"] = Instance.new("TextLabel", G2L["13d"]);
G2L["13f"]["TextSize"] = 25;
G2L["13f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["13f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["13f"]["BackgroundTransparency"] = 1;
G2L["13f"]["Size"] = UDim2.new(0.52266, 0, 0.08817, 0);
G2L["13f"]["Text"] = [[Animations]];
G2L["13f"]["Name"] = [[AnimsTitle]];
G2L["13f"]["Position"] = UDim2.new(0.22641, 0, 0.02871, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.AnimsTitle
G2L["140"] = Instance.new("TextLabel", G2L["13d"]);
G2L["140"]["TextSize"] = 25;
G2L["140"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["140"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["140"]["BackgroundTransparency"] = 1;
G2L["140"]["Size"] = UDim2.new(0.52266, 0, 0.08817, 0);
G2L["140"]["Text"] = [[R15]];
G2L["140"]["Name"] = [[AnimsTitle]];
G2L["140"]["Position"] = UDim2.new(0.21962, 0, 0.14385, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE
G2L["141"] = Instance.new("Frame", G2L["13d"]);
G2L["141"]["BorderSizePixel"] = 0;
G2L["141"]["BackgroundColor3"] = Color3.fromRGB(105, 0, 79);
G2L["141"]["Size"] = UDim2.new(0.2, 0, 0.71599, 0);
G2L["141"]["Position"] = UDim2.new(0.71274, 0, 0.27833, 0);
G2L["141"]["Name"] = [[R15_AnimColon4MARKETPLACE]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.GangnamStyle
G2L["142"] = Instance.new("TextButton", G2L["141"]);
G2L["142"]["TextWrapped"] = true;
G2L["142"]["BorderSizePixel"] = 0;
G2L["142"]["TextSize"] = 14;
G2L["142"]["TextScaled"] = true;
G2L["142"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["142"]["BackgroundColor3"] = Color3.fromRGB(191, 0, 144);
G2L["142"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["142"]["Size"] = UDim2.new(1, 0, 0.12, 0);
G2L["142"]["Text"] = [[Gangnum Style]];
G2L["142"]["Name"] = [[GangnamStyle]];
G2L["142"]["Position"] = UDim2.new(0, 0, 0.11425, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.GangnamStyle.WEIGHT
G2L["143"] = Instance.new("NumberValue", G2L["142"]);
G2L["143"]["Name"] = [[WEIGHT]];
G2L["143"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.GangnamStyle.SPEED
G2L["144"] = Instance.new("NumberValue", G2L["142"]);
G2L["144"]["Name"] = [[SPEED]];
G2L["144"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.GangnamStyle.ANIM
G2L["145"] = Instance.new("NumberValue", G2L["142"]);
G2L["145"]["Name"] = [[ANIM]];
G2L["145"]["Value"] = 116468071022853;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.CaramellDansen
G2L["146"] = Instance.new("TextButton", G2L["141"]);
G2L["146"]["TextWrapped"] = true;
G2L["146"]["BorderSizePixel"] = 0;
G2L["146"]["TextSize"] = 14;
G2L["146"]["TextScaled"] = true;
G2L["146"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["146"]["BackgroundColor3"] = Color3.fromRGB(191, 0, 144);
G2L["146"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["146"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["146"]["Text"] = [[Caramelldansen]];
G2L["146"]["Name"] = [[CaramellDansen]];
G2L["146"]["Position"] = UDim2.new(0, 0, 0.42, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.CaramellDansen.WEIGHT
G2L["147"] = Instance.new("NumberValue", G2L["146"]);
G2L["147"]["Name"] = [[WEIGHT]];
G2L["147"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.CaramellDansen.SPEED
G2L["148"] = Instance.new("NumberValue", G2L["146"]);
G2L["148"]["Name"] = [[SPEED]];
G2L["148"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.CaramellDansen.ANIM
G2L["149"] = Instance.new("NumberValue", G2L["146"]);
G2L["149"]["Name"] = [[ANIM]];
G2L["149"]["Value"] = 92900132509399;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.Birdbrain
G2L["14a"] = Instance.new("TextButton", G2L["141"]);
G2L["14a"]["TextWrapped"] = true;
G2L["14a"]["BorderSizePixel"] = 0;
G2L["14a"]["TextSize"] = 14;
G2L["14a"]["TextScaled"] = true;
G2L["14a"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["14a"]["BackgroundColor3"] = Color3.fromRGB(191, 0, 144);
G2L["14a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["14a"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["14a"]["Text"] = [[Birdbrain]];
G2L["14a"]["Name"] = [[Birdbrain]];
G2L["14a"]["Position"] = UDim2.new(0, 0, 0.57, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.Birdbrain.WEIGHT
G2L["14b"] = Instance.new("NumberValue", G2L["14a"]);
G2L["14b"]["Name"] = [[WEIGHT]];
G2L["14b"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.Birdbrain.SPEED
G2L["14c"] = Instance.new("NumberValue", G2L["14a"]);
G2L["14c"]["Name"] = [[SPEED]];
G2L["14c"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.Birdbrain.ANIM
G2L["14d"] = Instance.new("NumberValue", G2L["14a"]);
G2L["14d"]["Name"] = [[ANIM]];
G2L["14d"]["Value"] = 77736870260603;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.California
G2L["14e"] = Instance.new("TextButton", G2L["141"]);
G2L["14e"]["TextWrapped"] = true;
G2L["14e"]["BorderSizePixel"] = 0;
G2L["14e"]["TextSize"] = 14;
G2L["14e"]["TextScaled"] = true;
G2L["14e"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["14e"]["BackgroundColor3"] = Color3.fromRGB(191, 0, 144);
G2L["14e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["14e"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["14e"]["Text"] = [[California]];
G2L["14e"]["Name"] = [[California]];
G2L["14e"]["Position"] = UDim2.new(0, 0, 0.72, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.California.WEIGHT
G2L["14f"] = Instance.new("NumberValue", G2L["14e"]);
G2L["14f"]["Name"] = [[WEIGHT]];
G2L["14f"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.California.SPEED
G2L["150"] = Instance.new("NumberValue", G2L["14e"]);
G2L["150"]["Name"] = [[SPEED]];
G2L["150"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.California.ANIM
G2L["151"] = Instance.new("NumberValue", G2L["14e"]);
G2L["151"]["Name"] = [[ANIM]];
G2L["151"]["Value"] = 84430246447182;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.Default
G2L["152"] = Instance.new("TextButton", G2L["141"]);
G2L["152"]["TextWrapped"] = true;
G2L["152"]["BorderSizePixel"] = 0;
G2L["152"]["TextSize"] = 14;
G2L["152"]["TextScaled"] = true;
G2L["152"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["152"]["BackgroundColor3"] = Color3.fromRGB(191, 0, 144);
G2L["152"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["152"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["152"]["Text"] = [[Default]];
G2L["152"]["Name"] = [[Default]];
G2L["152"]["Position"] = UDim2.new(0, 0, 0.27, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.Default.WEIGHT
G2L["153"] = Instance.new("NumberValue", G2L["152"]);
G2L["153"]["Name"] = [[WEIGHT]];
G2L["153"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.Default.SPEED
G2L["154"] = Instance.new("NumberValue", G2L["152"]);
G2L["154"]["Name"] = [[SPEED]];
G2L["154"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon4MARKETPLACE.Default.ANIM
G2L["155"] = Instance.new("NumberValue", G2L["152"]);
G2L["155"]["Name"] = [[ANIM]];
G2L["155"]["Value"] = 109296653791944;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3
G2L["156"] = Instance.new("Frame", G2L["13d"]);
G2L["156"]["BorderSizePixel"] = 0;
G2L["156"]["BackgroundColor3"] = Color3.fromRGB(192, 57, 43);
G2L["156"]["Size"] = UDim2.new(0.2, 0, 0.71599, 0);
G2L["156"]["Position"] = UDim2.new(0.5046, 0, 0.27833, 0);
G2L["156"]["Name"] = [[R15_AnimColon3]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Propeller
G2L["157"] = Instance.new("TextButton", G2L["156"]);
G2L["157"]["TextWrapped"] = true;
G2L["157"]["BorderSizePixel"] = 0;
G2L["157"]["TextSize"] = 14;
G2L["157"]["TextScaled"] = true;
G2L["157"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["157"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["157"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["157"]["Size"] = UDim2.new(1, 0, 0.12, 0);
G2L["157"]["Text"] = [[Propeller]];
G2L["157"]["Name"] = [[Propeller]];
G2L["157"]["Position"] = UDim2.new(0, 0, 0.11425, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Propeller.WEIGHT
G2L["158"] = Instance.new("NumberValue", G2L["157"]);
G2L["158"]["Name"] = [[WEIGHT]];
G2L["158"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Propeller.SPEED
G2L["159"] = Instance.new("NumberValue", G2L["157"]);
G2L["159"]["Name"] = [[SPEED]];
G2L["159"]["Value"] = 2;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Propeller.ANIM
G2L["15a"] = Instance.new("NumberValue", G2L["157"]);
G2L["15a"]["Name"] = [[ANIM]];
G2L["15a"]["Value"] = 2516930867;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Windmill
G2L["15b"] = Instance.new("TextButton", G2L["156"]);
G2L["15b"]["TextWrapped"] = true;
G2L["15b"]["BorderSizePixel"] = 0;
G2L["15b"]["TextSize"] = 14;
G2L["15b"]["TextScaled"] = true;
G2L["15b"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["15b"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["15b"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["15b"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["15b"]["Text"] = [[Windmill]];
G2L["15b"]["Name"] = [[Windmill]];
G2L["15b"]["Position"] = UDim2.new(0, 0, 0.27, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Windmill.WEIGHT
G2L["15c"] = Instance.new("NumberValue", G2L["15b"]);
G2L["15c"]["Name"] = [[WEIGHT]];
G2L["15c"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Windmill.SPEED
G2L["15d"] = Instance.new("NumberValue", G2L["15b"]);
G2L["15d"]["Name"] = [[SPEED]];
G2L["15d"]["Value"] = 2.5;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Windmill.ANIM
G2L["15e"] = Instance.new("NumberValue", G2L["15b"]);
G2L["15e"]["Name"] = [[ANIM]];
G2L["15e"]["Value"] = 900850443;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Forearm Move
G2L["15f"] = Instance.new("TextButton", G2L["156"]);
G2L["15f"]["TextWrapped"] = true;
G2L["15f"]["BorderSizePixel"] = 0;
G2L["15f"]["TextSize"] = 14;
G2L["15f"]["TextScaled"] = true;
G2L["15f"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["15f"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["15f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["15f"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["15f"]["Text"] = [[Forearm Move]];
G2L["15f"]["Name"] = [[Forearm Move]];
G2L["15f"]["Position"] = UDim2.new(0, 0, 0.42, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Forearm Move.WEIGHT
G2L["160"] = Instance.new("NumberValue", G2L["15f"]);
G2L["160"]["Name"] = [[WEIGHT]];
G2L["160"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Forearm Move.SPEED
G2L["161"] = Instance.new("NumberValue", G2L["15f"]);
G2L["161"]["Name"] = [[SPEED]];
G2L["161"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Forearm Move.ANIM
G2L["162"] = Instance.new("NumberValue", G2L["15f"]);
G2L["162"]["Name"] = [[ANIM]];
G2L["162"]["Value"] = 696096087;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Victory
G2L["163"] = Instance.new("TextButton", G2L["156"]);
G2L["163"]["TextWrapped"] = true;
G2L["163"]["BorderSizePixel"] = 0;
G2L["163"]["TextSize"] = 14;
G2L["163"]["TextScaled"] = true;
G2L["163"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["163"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["163"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["163"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["163"]["Text"] = [[Victory]];
G2L["163"]["Name"] = [[Victory]];
G2L["163"]["Position"] = UDim2.new(0, 0, 0.57, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Victory.WEIGHT
G2L["164"] = Instance.new("NumberValue", G2L["163"]);
G2L["164"]["Name"] = [[WEIGHT]];
G2L["164"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Victory.SPEED
G2L["165"] = Instance.new("NumberValue", G2L["163"]);
G2L["165"]["Name"] = [[SPEED]];
G2L["165"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Victory.ANIM
G2L["166"] = Instance.new("NumberValue", G2L["163"]);
G2L["166"]["Name"] = [[ANIM]];
G2L["166"]["Value"] = 15505456446;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Hype
G2L["167"] = Instance.new("TextButton", G2L["156"]);
G2L["167"]["TextWrapped"] = true;
G2L["167"]["BorderSizePixel"] = 0;
G2L["167"]["TextSize"] = 14;
G2L["167"]["TextScaled"] = true;
G2L["167"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["167"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["167"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["167"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["167"]["Text"] = [[Hype]];
G2L["167"]["Name"] = [[Hype]];
G2L["167"]["Position"] = UDim2.new(0, 0, 0.72, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Hype.WEIGHT
G2L["168"] = Instance.new("NumberValue", G2L["167"]);
G2L["168"]["Name"] = [[WEIGHT]];
G2L["168"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Hype.SPEED
G2L["169"] = Instance.new("NumberValue", G2L["167"]);
G2L["169"]["Name"] = [[SPEED]];
G2L["169"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon3.Hype.ANIM
G2L["16a"] = Instance.new("NumberValue", G2L["167"]);
G2L["16a"]["Name"] = [[ANIM]];
G2L["16a"]["Value"] = 10714369624;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2
G2L["16b"] = Instance.new("Frame", G2L["13d"]);
G2L["16b"]["BorderSizePixel"] = 0;
G2L["16b"]["BackgroundColor3"] = Color3.fromRGB(192, 57, 43);
G2L["16b"]["Size"] = UDim2.new(0.2, 0, 0.71599, 0);
G2L["16b"]["Position"] = UDim2.new(0.29419, 0, 0.27833, 0);
G2L["16b"]["Name"] = [[R15_AnimColon2]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Fancy
G2L["16c"] = Instance.new("TextButton", G2L["16b"]);
G2L["16c"]["TextWrapped"] = true;
G2L["16c"]["BorderSizePixel"] = 0;
G2L["16c"]["TextSize"] = 14;
G2L["16c"]["TextScaled"] = true;
G2L["16c"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["16c"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["16c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["16c"]["Size"] = UDim2.new(1, 0, 0.12, 0);
G2L["16c"]["Text"] = [[Fancy]];
G2L["16c"]["Name"] = [[Fancy]];
G2L["16c"]["Position"] = UDim2.new(0, 0, 0.11425, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Fancy.ANIM
G2L["16d"] = Instance.new("NumberValue", G2L["16c"]);
G2L["16d"]["Name"] = [[ANIM]];
G2L["16d"]["Value"] = 10714076981;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Fancy.SPEED
G2L["16e"] = Instance.new("NumberValue", G2L["16c"]);
G2L["16e"]["Name"] = [[SPEED]];
G2L["16e"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Fancy.WEIGHT
G2L["16f"] = Instance.new("NumberValue", G2L["16c"]);
G2L["16f"]["Name"] = [[WEIGHT]];
G2L["16f"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Spinning Head
G2L["170"] = Instance.new("TextButton", G2L["16b"]);
G2L["170"]["TextWrapped"] = true;
G2L["170"]["BorderSizePixel"] = 0;
G2L["170"]["TextSize"] = 14;
G2L["170"]["TextScaled"] = true;
G2L["170"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["170"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["170"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["170"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["170"]["Text"] = [[Spinning Head]];
G2L["170"]["Name"] = [[Spinning Head]];
G2L["170"]["Position"] = UDim2.new(0, 0, 0.27, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Spinning Head.WEIGHT
G2L["171"] = Instance.new("NumberValue", G2L["170"]);
G2L["171"]["Name"] = [[WEIGHT]];
G2L["171"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Spinning Head.SPEED
G2L["172"] = Instance.new("NumberValue", G2L["170"]);
G2L["172"]["Name"] = [[SPEED]];
G2L["172"]["Value"] = 2;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Spinning Head.ANIM
G2L["173"] = Instance.new("NumberValue", G2L["170"]);
G2L["173"]["Name"] = [[ANIM]];
G2L["173"]["Value"] = 10714066964;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Spinning Head.TIME
G2L["174"] = Instance.new("NumberValue", G2L["170"]);
G2L["174"]["Name"] = [[TIME]];
G2L["174"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Flair
G2L["175"] = Instance.new("TextButton", G2L["16b"]);
G2L["175"]["TextWrapped"] = true;
G2L["175"]["BorderSizePixel"] = 0;
G2L["175"]["TextSize"] = 14;
G2L["175"]["TextScaled"] = true;
G2L["175"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["175"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["175"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["175"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["175"]["Text"] = [[Flair]];
G2L["175"]["Name"] = [[Flair]];
G2L["175"]["Position"] = UDim2.new(0, 0, 0.42, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Flair.WEIGHT
G2L["176"] = Instance.new("NumberValue", G2L["175"]);
G2L["176"]["Name"] = [[WEIGHT]];
G2L["176"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Flair.SPEED
G2L["177"] = Instance.new("NumberValue", G2L["175"]);
G2L["177"]["Name"] = [[SPEED]];
G2L["177"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Flair.ANIM
G2L["178"] = Instance.new("NumberValue", G2L["175"]);
G2L["178"]["Name"] = [[ANIM]];
G2L["178"]["Value"] = 10214311282;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Slam
G2L["179"] = Instance.new("TextButton", G2L["16b"]);
G2L["179"]["TextWrapped"] = true;
G2L["179"]["BorderSizePixel"] = 0;
G2L["179"]["TextSize"] = 14;
G2L["179"]["TextScaled"] = true;
G2L["179"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["179"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["179"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["179"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["179"]["Text"] = [[Slam]];
G2L["179"]["Name"] = [[Slam]];
G2L["179"]["Position"] = UDim2.new(0, 0, 0.57, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Slam.WEIGHT
G2L["17a"] = Instance.new("NumberValue", G2L["179"]);
G2L["17a"]["Name"] = [[WEIGHT]];
G2L["17a"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Slam.SPEED
G2L["17b"] = Instance.new("NumberValue", G2L["179"]);
G2L["17b"]["Name"] = [[SPEED]];
G2L["17b"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Slam.ANIM
G2L["17c"] = Instance.new("NumberValue", G2L["179"]);
G2L["17c"]["Name"] = [[ANIM]];
G2L["17c"]["Value"] = 2733837253;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Sleep
G2L["17d"] = Instance.new("TextButton", G2L["16b"]);
G2L["17d"]["TextWrapped"] = true;
G2L["17d"]["BorderSizePixel"] = 0;
G2L["17d"]["TextSize"] = 14;
G2L["17d"]["TextScaled"] = true;
G2L["17d"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["17d"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["17d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["17d"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["17d"]["Text"] = [[Sleep]];
G2L["17d"]["Name"] = [[Sleep]];
G2L["17d"]["Position"] = UDim2.new(0, 0, 0.72, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Sleep.WEIGHT
G2L["17e"] = Instance.new("NumberValue", G2L["17d"]);
G2L["17e"]["Name"] = [[WEIGHT]];
G2L["17e"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Sleep.SPEED
G2L["17f"] = Instance.new("NumberValue", G2L["17d"]);
G2L["17f"]["Name"] = [[SPEED]];
G2L["17f"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon2.Sleep.ANIM
G2L["180"] = Instance.new("NumberValue", G2L["17d"]);
G2L["180"]["Name"] = [[ANIM]];
G2L["180"]["Value"] = 2695918332;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1
G2L["181"] = Instance.new("Frame", G2L["13d"]);
G2L["181"]["BorderSizePixel"] = 0;
G2L["181"]["BackgroundColor3"] = Color3.fromRGB(192, 57, 43);
G2L["181"]["Size"] = UDim2.new(0.2, 0, 0.71599, 0);
G2L["181"]["Position"] = UDim2.new(0.08605, 0, 0.27833, 0);
G2L["181"]["Name"] = [[R15_AnimColon1]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Trump Dance
G2L["182"] = Instance.new("TextButton", G2L["181"]);
G2L["182"]["TextWrapped"] = true;
G2L["182"]["BorderSizePixel"] = 0;
G2L["182"]["TextSize"] = 14;
G2L["182"]["TextScaled"] = true;
G2L["182"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["182"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["182"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["182"]["Size"] = UDim2.new(1, 0, 0.12, 0);
G2L["182"]["Text"] = [[ChaCha]];
G2L["182"]["Name"] = [[Trump Dance]];
G2L["182"]["Position"] = UDim2.new(0, 0, 0.11425, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Trump Dance.WEIGHT
G2L["183"] = Instance.new("NumberValue", G2L["182"]);
G2L["183"]["Name"] = [[WEIGHT]];
G2L["183"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Trump Dance.SPEED
G2L["184"] = Instance.new("NumberValue", G2L["182"]);
G2L["184"]["Name"] = [[SPEED]];
G2L["184"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Trump Dance.ANIM
G2L["185"] = Instance.new("NumberValue", G2L["182"]);
G2L["185"]["Name"] = [[ANIM]];
G2L["185"]["Value"] = 16553163212;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Punch
G2L["186"] = Instance.new("TextButton", G2L["181"]);
G2L["186"]["TextWrapped"] = true;
G2L["186"]["BorderSizePixel"] = 0;
G2L["186"]["TextSize"] = 14;
G2L["186"]["TextScaled"] = true;
G2L["186"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["186"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["186"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["186"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["186"]["Text"] = [[Punch]];
G2L["186"]["Name"] = [[Punch]];
G2L["186"]["Position"] = UDim2.new(0, 0, 0.27, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Punch.WEIGHT
G2L["187"] = Instance.new("NumberValue", G2L["186"]);
G2L["187"]["Name"] = [[WEIGHT]];
G2L["187"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Punch.SPEED
G2L["188"] = Instance.new("NumberValue", G2L["186"]);
G2L["188"]["Name"] = [[SPEED]];
G2L["188"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Punch.ANIM
G2L["189"] = Instance.new("NumberValue", G2L["186"]);
G2L["189"]["Name"] = [[ANIM]];
G2L["189"]["Value"] = 10717116749;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Robot
G2L["18a"] = Instance.new("TextButton", G2L["181"]);
G2L["18a"]["TextWrapped"] = true;
G2L["18a"]["BorderSizePixel"] = 0;
G2L["18a"]["TextSize"] = 14;
G2L["18a"]["TextScaled"] = true;
G2L["18a"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["18a"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["18a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["18a"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["18a"]["Text"] = [[Robot]];
G2L["18a"]["Name"] = [[Robot]];
G2L["18a"]["Position"] = UDim2.new(0, 0, 0.42, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Robot.WEIGHT
G2L["18b"] = Instance.new("NumberValue", G2L["18a"]);
G2L["18b"]["Name"] = [[WEIGHT]];
G2L["18b"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Robot.SPEED
G2L["18c"] = Instance.new("NumberValue", G2L["18a"]);
G2L["18c"]["Name"] = [[SPEED]];
G2L["18c"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Robot.ANIM
G2L["18d"] = Instance.new("NumberValue", G2L["18a"]);
G2L["18d"]["Name"] = [[ANIM]];
G2L["18d"]["Value"] = 10714392151;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Kamehamema
G2L["18e"] = Instance.new("TextButton", G2L["181"]);
G2L["18e"]["TextWrapped"] = true;
G2L["18e"]["BorderSizePixel"] = 0;
G2L["18e"]["TextSize"] = 14;
G2L["18e"]["TextScaled"] = true;
G2L["18e"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["18e"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["18e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["18e"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["18e"]["Text"] = [[Kamehamema]];
G2L["18e"]["Name"] = [[Kamehamema]];
G2L["18e"]["Position"] = UDim2.new(0, 0, 0.57, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Kamehamema.WEIGHT
G2L["18f"] = Instance.new("NumberValue", G2L["18e"]);
G2L["18f"]["Name"] = [[WEIGHT]];
G2L["18f"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Kamehamema.SPEED
G2L["190"] = Instance.new("NumberValue", G2L["18e"]);
G2L["190"]["Name"] = [[SPEED]];
G2L["190"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Kamehamema.ANIM
G2L["191"] = Instance.new("NumberValue", G2L["18e"]);
G2L["191"]["Name"] = [[ANIM]];
G2L["191"]["Value"] = 10714389396;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Floss
G2L["192"] = Instance.new("TextButton", G2L["181"]);
G2L["192"]["TextWrapped"] = true;
G2L["192"]["BorderSizePixel"] = 0;
G2L["192"]["TextSize"] = 14;
G2L["192"]["TextScaled"] = true;
G2L["192"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["192"]["BackgroundColor3"] = Color3.fromRGB(231, 76, 60);
G2L["192"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["192"]["Size"] = UDim2.new(1, 0, 0.119, 0);
G2L["192"]["Text"] = [[Floss]];
G2L["192"]["Name"] = [[Floss]];
G2L["192"]["Position"] = UDim2.new(0, 0, 0.72, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Floss.WEIGHT
G2L["193"] = Instance.new("NumberValue", G2L["192"]);
G2L["193"]["Name"] = [[WEIGHT]];
G2L["193"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Floss.SPEED
G2L["194"] = Instance.new("NumberValue", G2L["192"]);
G2L["194"]["Name"] = [[SPEED]];
G2L["194"]["Value"] = 1;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.R15_AnimColon1.Floss.ANIM
G2L["195"] = Instance.new("NumberValue", G2L["192"]);
G2L["195"]["Name"] = [[ANIM]];
G2L["195"]["Value"] = 10714340543;


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.AnimsTitle
G2L["196"] = Instance.new("TextLabel", G2L["13d"]);
G2L["196"]["TextSize"] = 18;
G2L["196"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["196"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Italic);
G2L["196"]["BackgroundTransparency"] = 1;
G2L["196"]["Size"] = UDim2.new(0.27672, 0, 0.09717, 0);
G2L["196"]["Text"] = [[Marketplace]];
G2L["196"]["Name"] = [[AnimsTitle]];
G2L["196"]["Position"] = UDim2.new(0.67664, 0, 0.18958, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.Back
G2L["197"] = Instance.new("TextButton", G2L["13d"]);
G2L["197"]["BorderSizePixel"] = 0;
G2L["197"]["TextSize"] = 22;
G2L["197"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["197"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["197"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["197"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["197"]["Text"] = [[Prev]];
G2L["197"]["Name"] = [[Back]];
G2L["197"]["Position"] = UDim2.new(0.06792, 0, 0.04393, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.Back.Character_toPAGE1_IMAGE
G2L["198"] = Instance.new("ImageLabel", G2L["197"]);
G2L["198"]["BorderSizePixel"] = 0;
G2L["198"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["198"]["Image"] = [[http://www.roblox.com/asset/?id=1282894968]];
G2L["198"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["198"]["Name"] = [[Character_toPAGE1_IMAGE]];
G2L["198"]["Position"] = UDim2.new(-0.40029, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.T_AnimationsImage
G2L["199"] = Instance.new("ImageLabel", G2L["13d"]);
G2L["199"]["ZIndex"] = 2;
G2L["199"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["199"]["Image"] = [[rbxassetid://117644623910680]];
G2L["199"]["Size"] = UDim2.new(0.08354, 0, 0.14685, 0);
G2L["199"]["BackgroundTransparency"] = 1;
G2L["199"]["Name"] = [[T_AnimationsImage]];
G2L["199"]["Position"] = UDim2.new(0.23588, 0, 0.08041, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2
G2L["19a"] = Instance.new("Frame", G2L["10"]);
G2L["19a"]["ZIndex"] = 2;
G2L["19a"]["BorderSizePixel"] = 0;
G2L["19a"]["BackgroundColor3"] = Color3.fromRGB(236, 241, 241);
G2L["19a"]["Size"] = UDim2.new(0, 442, 0, 230);
G2L["19a"]["Position"] = UDim2.new(1.005, 0, 0, 0);
G2L["19a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["19a"]["Name"] = [[Character_2]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.OthersText
G2L["19b"] = Instance.new("TextLabel", G2L["19a"]);
G2L["19b"]["TextWrapped"] = true;
G2L["19b"]["TextSize"] = 19;
G2L["19b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["19b"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["19b"]["BackgroundTransparency"] = 1;
G2L["19b"]["Size"] = UDim2.new(0.78111, 0, 0.1126, 0);
G2L["19b"]["Text"] = [[Some cool commands, for your tools!]];
G2L["19b"]["Name"] = [[OthersText]];
G2L["19b"]["Position"] = UDim2.new(0.11998, 0, 0.14075, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.OthersTitle
G2L["19c"] = Instance.new("TextLabel", G2L["19a"]);
G2L["19c"]["TextSize"] = 25;
G2L["19c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["19c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["19c"]["BackgroundTransparency"] = 1;
G2L["19c"]["Size"] = UDim2.new(0.52266, 0, 0.0956, 0);
G2L["19c"]["Text"] = [[Tools]];
G2L["19c"]["Name"] = [[OthersTitle]];
G2L["19c"]["Position"] = UDim2.new(0.23772, 0, 0.04828, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.Back
G2L["19d"] = Instance.new("TextButton", G2L["19a"]);
G2L["19d"]["BorderSizePixel"] = 0;
G2L["19d"]["TextSize"] = 22;
G2L["19d"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["19d"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["19d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["19d"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["19d"]["Text"] = [[Prev]];
G2L["19d"]["Name"] = [[Back]];
G2L["19d"]["Position"] = UDim2.new(0.06792, 0, 0.04393, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.Back.Character_toPAGE1_IMAGE
G2L["19e"] = Instance.new("ImageLabel", G2L["19d"]);
G2L["19e"]["BorderSizePixel"] = 0;
G2L["19e"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["19e"]["Image"] = [[http://www.roblox.com/asset/?id=1282894968]];
G2L["19e"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["19e"]["Name"] = [[Character_toPAGE1_IMAGE]];
G2L["19e"]["Position"] = UDim2.new(-0.40029, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.Next
G2L["19f"] = Instance.new("TextButton", G2L["19a"]);
G2L["19f"]["BorderSizePixel"] = 0;
G2L["19f"]["TextSize"] = 22;
G2L["19f"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["19f"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["19f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["19f"]["Size"] = UDim2.new(0.11321, 0, 0.10982, 0);
G2L["19f"]["Text"] = [[Next]];
G2L["19f"]["Name"] = [[Next]];
G2L["19f"]["Position"] = UDim2.new(0.82, 0, 0.044, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.Next.Character_toPAGE2_IMAGE
G2L["1a0"] = Instance.new("ImageLabel", G2L["19f"]);
G2L["1a0"]["BorderSizePixel"] = 0;
G2L["1a0"]["BackgroundColor3"] = Color3.fromRGB(53, 74, 94);
G2L["1a0"]["Image"] = [[http://www.roblox.com/asset/?id=1282737326]];
G2L["1a0"]["Size"] = UDim2.new(0, 25, 0, 25);
G2L["1a0"]["Name"] = [[Character_toPAGE2_IMAGE]];
G2L["1a0"]["Position"] = UDim2.new(0.90066, 0, 0, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar
G2L["1a1"] = Instance.new("Frame", G2L["19a"]);
G2L["1a1"]["BorderSizePixel"] = 0;
G2L["1a1"]["BackgroundColor3"] = Color3.fromRGB(155, 90, 183);
G2L["1a1"]["Size"] = UDim2.new(0, 83, 0, 154);
G2L["1a1"]["Position"] = UDim2.new(0.01591, 0, 0.2645, 0);
G2L["1a1"]["Name"] = [[BackGroundChar]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.ak47
G2L["1a2"] = Instance.new("TextButton", G2L["1a1"]);
G2L["1a2"]["BorderSizePixel"] = 0;
G2L["1a2"]["TextSize"] = 22;
G2L["1a2"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1a2"]["BackgroundColor3"] = Color3.fromRGB(143, 69, 173);
G2L["1a2"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1a2"]["Size"] = UDim2.new(0, 83, 0, 25);
G2L["1a2"]["Text"] = [[ak47]];
G2L["1a2"]["Name"] = [[ak47]];
G2L["1a2"]["Position"] = UDim2.new(0, 0, 0.425, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.ak47.LocalScript
G2L["1a3"] = Instance.new("LocalScript", G2L["1a2"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.shotgun
G2L["1a4"] = Instance.new("TextButton", G2L["1a1"]);
G2L["1a4"]["BorderSizePixel"] = 0;
G2L["1a4"]["TextSize"] = 20;
G2L["1a4"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1a4"]["BackgroundColor3"] = Color3.fromRGB(143, 69, 173);
G2L["1a4"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1a4"]["Size"] = UDim2.new(0, 83, 0, 25);
G2L["1a4"]["Text"] = [[shotgun]];
G2L["1a4"]["Name"] = [[shotgun]];
G2L["1a4"]["Position"] = UDim2.new(0, 0, 0.225, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.shotgun.LocalScript
G2L["1a5"] = Instance.new("LocalScript", G2L["1a4"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.sphere
G2L["1a6"] = Instance.new("TextButton", G2L["1a1"]);
G2L["1a6"]["BorderSizePixel"] = 0;
G2L["1a6"]["TextSize"] = 22;
G2L["1a6"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1a6"]["BackgroundColor3"] = Color3.fromRGB(143, 69, 173);
G2L["1a6"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1a6"]["Size"] = UDim2.new(0, 83, 0, 25);
G2L["1a6"]["Text"] = [[sphere]];
G2L["1a6"]["Name"] = [[sphere]];
G2L["1a6"]["Position"] = UDim2.new(0, 0, 0.025, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.sphere.LocalScript
G2L["1a7"] = Instance.new("LocalScript", G2L["1a6"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.BFG
G2L["1a8"] = Instance.new("TextButton", G2L["1a1"]);
G2L["1a8"]["BorderSizePixel"] = 0;
G2L["1a8"]["TextSize"] = 22;
G2L["1a8"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1a8"]["BackgroundColor3"] = Color3.fromRGB(143, 69, 173);
G2L["1a8"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1a8"]["Size"] = UDim2.new(0, 83, 0, 25);
G2L["1a8"]["Text"] = [[BFG]];
G2L["1a8"]["Name"] = [[BFG]];
G2L["1a8"]["Position"] = UDim2.new(0, 0, 0.625, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.BFG.LocalScript
G2L["1a9"] = Instance.new("LocalScript", G2L["1a8"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.handgun
G2L["1aa"] = Instance.new("TextButton", G2L["1a1"]);
G2L["1aa"]["BorderSizePixel"] = 0;
G2L["1aa"]["TextSize"] = 22;
G2L["1aa"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1aa"]["BackgroundColor3"] = Color3.fromRGB(143, 69, 173);
G2L["1aa"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1aa"]["Size"] = UDim2.new(0, 83, 0, 25);
G2L["1aa"]["Text"] = [[handgun]];
G2L["1aa"]["Name"] = [[handgun]];
G2L["1aa"]["Position"] = UDim2.new(0, 0, 0.825, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.handgun.LocalScript
G2L["1ab"] = Instance.new("LocalScript", G2L["1aa"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2
G2L["1ac"] = Instance.new("Frame", G2L["19a"]);
G2L["1ac"]["BorderSizePixel"] = 0;
G2L["1ac"]["BackgroundColor3"] = Color3.fromRGB(155, 90, 183);
G2L["1ac"]["Size"] = UDim2.new(0, 242, 0, 40);
G2L["1ac"]["Position"] = UDim2.new(0.37879, 0, 0.42644, 0);
G2L["1ac"]["Name"] = [[BackGroundChar2]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.Dupe
G2L["1ad"] = Instance.new("TextButton", G2L["1ac"]);
G2L["1ad"]["BorderSizePixel"] = 0;
G2L["1ad"]["TextSize"] = 22;
G2L["1ad"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1ad"]["BackgroundColor3"] = Color3.fromRGB(143, 69, 173);
G2L["1ad"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1ad"]["Size"] = UDim2.new(0, 100, 0, 25);
G2L["1ad"]["Text"] = [[Dupe]];
G2L["1ad"]["Name"] = [[Dupe]];
G2L["1ad"]["Position"] = UDim2.new(0.52484, 0, 0.1252, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.Dupe.LocalScript
G2L["1ae"] = Instance.new("LocalScript", G2L["1ad"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.DupeInfo
G2L["1af"] = Instance.new("TextLabel", G2L["1ac"]);
G2L["1af"]["TextWrapped"] = true;
G2L["1af"]["TextSize"] = 15;
G2L["1af"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1af"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1af"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["1af"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1af"]["BackgroundTransparency"] = 1;
G2L["1af"]["Size"] = UDim2.new(0.40641, 0, 0.33027, 0);
G2L["1af"]["Text"] = [[Items MUST:]];
G2L["1af"]["Name"] = [[DupeInfo]];
G2L["1af"]["Position"] = UDim2.new(0.02737, 0, 0.04829, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.DupeInfo
G2L["1b0"] = Instance.new("TextLabel", G2L["1ac"]);
G2L["1b0"]["TextWrapped"] = true;
G2L["1b0"]["TextSize"] = 15;
G2L["1b0"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1b0"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b0"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["1b0"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b0"]["BackgroundTransparency"] = 1;
G2L["1b0"]["Size"] = UDim2.new(0.34266, 0, 0.33027, 0);
G2L["1b0"]["Text"] = [[be droppable]];
G2L["1b0"]["Name"] = [[DupeInfo]];
G2L["1b0"]["Position"] = UDim2.new(0.02356, 0, 0.32329, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.DupeInfo
G2L["1b1"] = Instance.new("TextLabel", G2L["1ac"]);
G2L["1b1"]["TextWrapped"] = true;
G2L["1b1"]["TextSize"] = 15;
G2L["1b1"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1b1"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b1"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["1b1"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b1"]["BackgroundTransparency"] = 1;
G2L["1b1"]["Size"] = UDim2.new(0.46843, 0, 0.33027, 0);
G2L["1b1"]["Text"] = [[be in the starterpack]];
G2L["1b1"]["Name"] = [[DupeInfo]];
G2L["1b1"]["Position"] = UDim2.new(0.02356, 0, 0.57329, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.TXTBOX_Dupe
G2L["1b2"] = Instance.new("TextBox", G2L["19a"]);
G2L["1b2"]["Name"] = [[TXTBOX_Dupe]];
G2L["1b2"]["BorderSizePixel"] = 6;
G2L["1b2"]["TextWrapped"] = true;
G2L["1b2"]["TextSize"] = 14;
G2L["1b2"]["TextScaled"] = true;
G2L["1b2"]["BackgroundColor3"] = Color3.fromRGB(245, 248, 249);
G2L["1b2"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1b2"]["Size"] = UDim2.new(0.52074, 0, 0.08786, 0);
G2L["1b2"]["Position"] = UDim2.new(0.39168, 0, 0.32558, 0);
G2L["1b2"]["BorderColor3"] = Color3.fromRGB(155, 90, 183);
G2L["1b2"]["Text"] = [[]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2
G2L["1b3"] = Instance.new("Frame", G2L["19a"]);
G2L["1b3"]["BorderSizePixel"] = 0;
G2L["1b3"]["BackgroundColor3"] = Color3.fromRGB(155, 90, 183);
G2L["1b3"]["Size"] = UDim2.new(0, 242, 0, 40);
G2L["1b3"]["Position"] = UDim2.new(0.37879, 0, 0.69166, 0);
G2L["1b3"]["Name"] = [[BackGroundChar2]];


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.Grab all
G2L["1b4"] = Instance.new("TextButton", G2L["1b3"]);
G2L["1b4"]["BorderSizePixel"] = 0;
G2L["1b4"]["TextSize"] = 22;
G2L["1b4"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1b4"]["BackgroundColor3"] = Color3.fromRGB(143, 69, 173);
G2L["1b4"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1b4"]["Size"] = UDim2.new(0, 100, 0, 25);
G2L["1b4"]["Text"] = [[Grab All]];
G2L["1b4"]["Name"] = [[Grab all]];
G2L["1b4"]["Position"] = UDim2.new(0.062, 0, 0.2, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.Grab all.LocalScript
G2L["1b5"] = Instance.new("LocalScript", G2L["1b4"]);



-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.LoopGrab all
G2L["1b6"] = Instance.new("TextButton", G2L["1b3"]);
G2L["1b6"]["BorderSizePixel"] = 0;
G2L["1b6"]["TextSize"] = 22;
G2L["1b6"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1b6"]["BackgroundColor3"] = Color3.fromRGB(143, 69, 173);
G2L["1b6"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1b6"]["Size"] = UDim2.new(0, 100, 0, 25);
G2L["1b6"]["Text"] = [[LoopGrab All]];
G2L["1b6"]["Name"] = [[LoopGrab all]];
G2L["1b6"]["Position"] = UDim2.new(0.525, 0, 0.2, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.LoopGrab all.LocalScript
G2L["1b7"] = Instance.new("LocalScript", G2L["1b6"]);



-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame
G2L["1b8"] = Instance.new("Frame", G2L["5"]);
G2L["1b8"]["BorderSizePixel"] = 0;
G2L["1b8"]["BackgroundColor3"] = Color3.fromRGB(189, 196, 199);
G2L["1b8"]["Size"] = UDim2.new(0, 170, 0, 278);
G2L["1b8"]["Position"] = UDim2.new(-0.386, 0, 0.069, 0);
G2L["1b8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1b8"]["Name"] = [[MenuFrame]];


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.NameOfPlayer
G2L["1b9"] = Instance.new("TextLabel", G2L["1b8"]);
G2L["1b9"]["TextSize"] = 28;
G2L["1b9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b9"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
G2L["1b9"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1b9"]["BackgroundTransparency"] = 1;
G2L["1b9"]["Size"] = UDim2.new(0.936, 0, 0.05831, 0);
G2L["1b9"]["Text"] = [[urgay1 :joy:]];
G2L["1b9"]["Name"] = [[NameOfPlayer]];
G2L["1b9"]["Position"] = UDim2.new(0.02941, 0, 0.11826, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.NameOfPlayer.LocalScript
G2L["1ba"] = Instance.new("LocalScript", G2L["1b9"]);



-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Welcome
G2L["1bb"] = Instance.new("TextLabel", G2L["1b8"]);
G2L["1bb"]["TextWrapped"] = true;
G2L["1bb"]["TextSize"] = 14;
G2L["1bb"]["TextScaled"] = true;
G2L["1bb"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1bb"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1bb"]["TextColor3"] = Color3.fromRGB(236, 241, 241);
G2L["1bb"]["BackgroundTransparency"] = 1;
G2L["1bb"]["Size"] = UDim2.new(0.8581, 0, 0.08185, 0);
G2L["1bb"]["Text"] = [[Welcome,]];
G2L["1bb"]["Name"] = [[Welcome]];
G2L["1bb"]["Position"] = UDim2.new(0.08824, 0, 0.03133, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.PageInfo
G2L["1bc"] = Instance.new("TextButton", G2L["1b8"]);
G2L["1bc"]["BorderSizePixel"] = 0;
G2L["1bc"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1bc"]["TextSize"] = 16;
G2L["1bc"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1bc"]["BackgroundColor3"] = Color3.fromRGB(150, 166, 166);
G2L["1bc"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["1bc"]["Size"] = UDim2.new(0, 170, 0, 22);
G2L["1bc"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1bc"]["Text"] = [[Information]];
G2L["1bc"]["Name"] = [[PageInfo]];
G2L["1bc"]["Position"] = UDim2.new(0, 0, 0.23914, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.PageInfo.T_InfoImage
G2L["1bd"] = Instance.new("ImageLabel", G2L["1bc"]);
G2L["1bd"]["SizeConstraint"] = Enum.SizeConstraint.RelativeXX;
G2L["1bd"]["ZIndex"] = 2;
G2L["1bd"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1bd"]["Image"] = [[http://www.roblox.com/asset/?id=1281284684]];
G2L["1bd"]["Size"] = UDim2.new(0.18, 0, 0.18, 0);
G2L["1bd"]["BackgroundTransparency"] = 1;
G2L["1bd"]["Name"] = [[T_InfoImage]];
G2L["1bd"]["Position"] = UDim2.new(0.783, 0, -0.5, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Credits_1
G2L["1be"] = Instance.new("TextButton", G2L["1b8"]);
G2L["1be"]["BorderSizePixel"] = 0;
G2L["1be"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1be"]["TextSize"] = 16;
G2L["1be"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1be"]["BackgroundColor3"] = Color3.fromRGB(150, 166, 166);
G2L["1be"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["1be"]["ZIndex"] = 5;
G2L["1be"]["Size"] = UDim2.new(0, 170, 0, 22);
G2L["1be"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1be"]["Text"] = [[Credits]];
G2L["1be"]["Name"] = [[Credits_1]];
G2L["1be"]["Position"] = UDim2.new(0, 0, 0.715, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Credits_1.T_CreditsImage
G2L["1bf"] = Instance.new("ImageLabel", G2L["1be"]);
G2L["1bf"]["SizeConstraint"] = Enum.SizeConstraint.RelativeXX;
G2L["1bf"]["ZIndex"] = 2;
G2L["1bf"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1bf"]["ImageColor3"] = Color3.fromRGB(136, 255, 190);
G2L["1bf"]["Image"] = [[rbxassetid://1284941440]];
G2L["1bf"]["Size"] = UDim2.new(0.18, 0, 0.18, 0);
G2L["1bf"]["BackgroundTransparency"] = 1;
G2L["1bf"]["Name"] = [[T_CreditsImage]];
G2L["1bf"]["Position"] = UDim2.new(0.783, 0, -0.5, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Character_1
G2L["1c0"] = Instance.new("TextButton", G2L["1b8"]);
G2L["1c0"]["BorderSizePixel"] = 0;
G2L["1c0"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1c0"]["TextSize"] = 16;
G2L["1c0"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c0"]["BackgroundColor3"] = Color3.fromRGB(150, 166, 166);
G2L["1c0"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["1c0"]["Size"] = UDim2.new(0, 170, 0, 22);
G2L["1c0"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1c0"]["Text"] = [[Character]];
G2L["1c0"]["Name"] = [[Character_1]];
G2L["1c0"]["Position"] = UDim2.new(0, 0, 0.4, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Character_1.T_CharacterImage
G2L["1c1"] = Instance.new("ImageLabel", G2L["1c0"]);
G2L["1c1"]["SizeConstraint"] = Enum.SizeConstraint.RelativeXX;
G2L["1c1"]["ZIndex"] = 2;
G2L["1c1"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c1"]["Image"] = [[http://www.roblox.com/asset/?id=1281299598]];
G2L["1c1"]["Size"] = UDim2.new(0.18, 0, 0.18, 0);
G2L["1c1"]["BackgroundTransparency"] = 1;
G2L["1c1"]["Name"] = [[T_CharacterImage]];
G2L["1c1"]["Position"] = UDim2.new(0.783, 0, -0.5, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Animations_1
G2L["1c2"] = Instance.new("TextButton", G2L["1b8"]);
G2L["1c2"]["BorderSizePixel"] = 0;
G2L["1c2"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1c2"]["TextSize"] = 16;
G2L["1c2"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c2"]["BackgroundColor3"] = Color3.fromRGB(150, 166, 166);
G2L["1c2"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["1c2"]["ZIndex"] = 3;
G2L["1c2"]["Size"] = UDim2.new(0, 170, 0, 22);
G2L["1c2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1c2"]["Text"] = [[Animations]];
G2L["1c2"]["Name"] = [[Animations_1]];
G2L["1c2"]["Position"] = UDim2.new(0, 0, 0.61, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Animations_1.T_AnimationsImage
G2L["1c3"] = Instance.new("ImageLabel", G2L["1c2"]);
G2L["1c3"]["SizeConstraint"] = Enum.SizeConstraint.RelativeXX;
G2L["1c3"]["ZIndex"] = 2;
G2L["1c3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c3"]["Image"] = [[rbxassetid://117644623910680]];
G2L["1c3"]["Size"] = UDim2.new(0.18, 0, 0.18, 0);
G2L["1c3"]["BackgroundTransparency"] = 1;
G2L["1c3"]["Name"] = [[T_AnimationsImage]];
G2L["1c3"]["Position"] = UDim2.new(0.783, 0, -0.5, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Others_1
G2L["1c4"] = Instance.new("TextButton", G2L["1b8"]);
G2L["1c4"]["BorderSizePixel"] = 0;
G2L["1c4"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1c4"]["TextSize"] = 16;
G2L["1c4"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c4"]["BackgroundColor3"] = Color3.fromRGB(150, 166, 166);
G2L["1c4"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["1c4"]["ZIndex"] = 2;
G2L["1c4"]["Size"] = UDim2.new(0, 170, 0, 22);
G2L["1c4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1c4"]["Text"] = [[Others]];
G2L["1c4"]["Name"] = [[Others_1]];
G2L["1c4"]["Position"] = UDim2.new(0, 0, 0.505, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Others_1.T_OthersImage
G2L["1c5"] = Instance.new("ImageLabel", G2L["1c4"]);
G2L["1c5"]["SizeConstraint"] = Enum.SizeConstraint.RelativeXX;
G2L["1c5"]["ZIndex"] = 2;
G2L["1c5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c5"]["Image"] = [[rbxassetid://1281476978]];
G2L["1c5"]["Size"] = UDim2.new(0.18, 0, 0.18, 0);
G2L["1c5"]["BackgroundTransparency"] = 1;
G2L["1c5"]["Name"] = [[T_OthersImage]];
G2L["1c5"]["Position"] = UDim2.new(0.78265, 0, -0.5, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Delete
G2L["1c6"] = Instance.new("TextButton", G2L["1b8"]);
G2L["1c6"]["BorderSizePixel"] = 0;
G2L["1c6"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1c6"]["TextSize"] = 16;
G2L["1c6"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c6"]["BackgroundColor3"] = Color3.fromRGB(166, 49, 49);
G2L["1c6"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Light, Enum.FontStyle.Normal);
G2L["1c6"]["ZIndex"] = 5;
G2L["1c6"]["Size"] = UDim2.new(0, 170, 0, 22);
G2L["1c6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1c6"]["Text"] = [[Delete GUI]];
G2L["1c6"]["Name"] = [[Delete]];
G2L["1c6"]["Position"] = UDim2.new(0, 0, 0.87, 0);


-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Delete.LocalScript
G2L["1c7"] = Instance.new("LocalScript", G2L["1c6"]);



-- StarterGui.OPF:R UPDATED.Scrollup
local function C_2()
local script = G2L["2"];
	for _, v in ipairs(script.Parent:GetDescendants()) do
		if v:IsA("ScrollingFrame") then
			v.CanvasPosition = Vector2.new(0, 0)
		end
	end
end;
task.spawn(C_2);
-- StarterGui.OPF:R UPDATED.txtbox
local function C_3()
local script = G2L["3"];
	local E_SELECT = true
	
	local UIS = game:GetService("UserInputService")
	local Players = game:GetService("Players")
	
	local EHeld = false
	
	for _, v in ipairs(script.Parent:GetDescendants()) do
		if v:IsA("TextBox") and v.Name ~= "TXTBOX_Chat" and v.Name ~= "TXTBOX_Stats" and v.Name ~= "TXTBOX_Dupe" then
			v.Text = "Player"
		end
	end
	
	
	UIS.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode.E then
			EHeld = true
		end
	end)
	
	UIS.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.E then
			EHeld = false
		end
	end)
	
	
	local mouse = Players.LocalPlayer:GetMouse()
	
	mouse.Button1Down:Connect(function()
		if E_SELECT and EHeld and mouse.Target then
			local clickedPlayer = Players:GetPlayerFromCharacter(mouse.Target:FindFirstAncestorOfClass("Model"))
	
			if clickedPlayer then
				for _, v in ipairs(script.Parent:GetDescendants()) do
					if v:IsA("TextBox") and v.Name ~= "TXTBOX_Chat" and v.Name ~= "TXTBOX_Stats" and v.Name ~= "TXTBOX_Dupe" then
						v.Text = clickedPlayer.Name
					end
				end
			end
		end
	end)
end;
task.spawn(C_3);
-- StarterGui.OPF:R UPDATED.LocalScript
local function C_4()
local script = G2L["4"];
	setclipboard("discord.gg/dd4XXRMz8b")
	
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Like this script?",
			Text = "The discord has been copied!",
			Duration = 35;
		})
	end)
	
	
	task.wait(0.5)
	
	if typeof(sethiddenproperty) ~= "function" then
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "OPF:R",
			Text = "No sethiddenproperty! some features will not work.",
			Duration = 10
		})
	end
	if typeof(replicatesignal) ~= "function" then
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "OPF:R",
			Text = "No Replicatesignal! some features will not work.",
			Duration = 10
		})
	end
end;
task.spawn(C_4);
-- StarterGui.OPF:R UPDATED.MainFrame.Smooth GUI Dragging
local function C_6()
local script = G2L["6"];
	local UserInputService = game:GetService("UserInputService")
	local runService = (game:GetService("RunService"));
	
	local gui = script.Parent
	
	local dragging
	local dragInput
	local dragStart
	local startPos
	
	function Lerp(a, b, m)
		return a + (b - a) * m
	end;
	
	local lastMousePos
	local lastGoalPos
	local DRAG_SPEED = (15); -- // The speed of the UI darg.
	function Update(dt)
		if not (startPos) then return end;
		if not (dragging) and (lastGoalPos) then
			gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED))
			return 
		end;
	
		local delta = (lastMousePos - UserInputService:GetMouseLocation())
		local xGoal = (startPos.X.Offset - delta.X);
		local yGoal = (startPos.Y.Offset - delta.Y);
		lastGoalPos = UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)
		gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, xGoal, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, yGoal, dt * DRAG_SPEED))
	end;
	
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			lastMousePos = UserInputService:GetMouseLocation()
	
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	runService.Heartbeat:Connect(Update)
	
end;
task.spawn(C_6);
-- StarterGui.OPF:R UPDATED.MainFrame.Darkness.LocalScript
local function C_8()
local script = G2L["8"];
	script.Parent.MouseButton1Click:Connect(function()
		if _G.MenuBusy then return end
		_G.MenuBusy = true
	
		local MainFrame = script.Parent.Parent
		local TopBar = MainFrame.TopBar
		local MenuFrame = MainFrame.MenuFrame
		local Pages = MainFrame.Pages
	
		script.Parent.Visible = false
		MenuFrame:TweenPosition(UDim2.new(0, -170, 0.069, 0), "Out", "Sine", 0.5)
		Pages:TweenPosition(UDim2.new(0, 0, 0.218, 0), "Out", "Sine", 0.5)
		TopBar:TweenPosition(UDim2.new(0, 0, TopBar.Position.Y.Scale, TopBar.Position.Y.Offset), "Out", "Sine", 0.5)
		wait(0.5)
	
		_G.MenuBusy = false
	end)
end;
task.spawn(C_8);
-- StarterGui.OPF:R UPDATED.MainFrame.TopBar.OpenMenu.LocalScript
local function C_c()
local script = G2L["c"];
	script.Parent.MouseButton1Click:Connect(function()
		if _G.MenuBusy then return end
		_G.MenuBusy = true
	
		local MainFrame = script.Parent.Parent.Parent
		local TopBar = MainFrame.TopBar
		local MenuFrame = MainFrame.MenuFrame
		local Pages = MainFrame.Pages
		local Darkness = MainFrame.Darkness
	
		Darkness.Visible = true
		MenuFrame:TweenPosition(UDim2.new(0, 0, 0.069, 0), "Out", "Sine", 0.5)
		Pages:TweenPosition(UDim2.new(0, 170, 0.218, 0), "Out", "Sine", 0.5)
		TopBar:TweenPosition(UDim2.new(0, 170, TopBar.Position.Y.Scale, TopBar.Position.Y.Offset), "Out", "Sine", 0.5)
		wait(0.7)
	
		_G.MenuBusy = false
	end)
end;
task.spawn(C_c);
-- StarterGui.OPF:R UPDATED.MainFrame.TopBar2.minimize.LocalScript
local function C_f()
local script = G2L["f"];
	local MainFrame = script.Parent.Parent.Parent
	local Pages = MainFrame.Pages
	local TopBar = MainFrame.TopBar
	local OpenMenu = TopBar.OpenMenu
	local MenuFrame = MainFrame.MenuFrame
	local Darkness = MainFrame.Darkness
	local TweenService = game:GetService("TweenService")
	local minimized = false
	
	local function tweenSize(frame, targetSize, duration)
		TweenService:Create(frame, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = targetSize
		}):Play()
	end
	
	local function closeMenu()
		Darkness.Visible = false
		MenuFrame:TweenPosition(UDim2.new(0, -170, 0.069, 0), "Out", "Sine", 0.5)
		Pages:TweenPosition(UDim2.new(0, 0, 0.218, 0), "Out", "Sine", 0.5)
		TopBar:TweenPosition(UDim2.new(0, 0, TopBar.Position.Y.Scale, TopBar.Position.Y.Offset), "Out", "Sine", 0.5)
		wait(0.5)
	end
	
	script.Parent.MouseButton1Click:Connect(function()
		if _G.MenuBusy then return end
		_G.MenuBusy = true
	
		if Darkness.Visible then
			closeMenu()
		end
	
		if minimized then
			tweenSize(Pages, UDim2.new(0, 442, 0, 230), 0.5)
			OpenMenu:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Sine", 0.5)
			wait(0.5)
			minimized = false
		else
			tweenSize(Pages, UDim2.new(0, 442, 0, 0), 0.5)
			OpenMenu:TweenPosition(UDim2.new(-0.1, 0, 0, 0), "Out", "Sine", 0.5)
			wait(0.5)
			minimized = true
		end
	
		_G.MenuBusy = false
	end)
end;
task.spawn(C_f);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Handler
local function C_11()
local script = G2L["11"];
	
	local Pages = script.Parent
	local MainFrame = Pages.Parent
	local TopBar = MainFrame.TopBar
	local MenuFrame = MainFrame.MenuFrame
	local Darkness = MainFrame.Darkness
	
	local currentPage = "PageInfo"
	local pageHistory = {}
	
	local function closeMenu()
		Darkness.Visible = false
	
		MenuFrame:TweenPosition(UDim2.new(0, -170, 0.069, 0), "Out", "Sine", 0.5)
		Pages:TweenPosition(UDim2.new(0, 0, 0.218, 0), "Out", "Sine", 0.5)
		TopBar:TweenPosition(UDim2.new(0, 0, TopBar.Position.Y.Scale, TopBar.Position.Y.Offset), "Out", "Sine", 0.5)
	
		task.wait(0.5)
	end
	
	local function getPage(name)
		local page = Pages:FindFirstChild(name)
		if page and (page:IsA("Frame") or page:IsA("ScrollingFrame")) then
			return page
		end
	end
	
	local function getPageList()
		local list = {}
	
		for _, page in ipairs(Pages:GetChildren()) do
			if (page:IsA("Frame") or page:IsA("ScrollingFrame"))
				and page.Name ~= "Next"
				and page.Name ~= "Back" then
				table.insert(list, page)
			end
		end
	
		table.sort(list, function(a, b)
			local na = tonumber(a.Name:match("%d+$"))
			local nb = tonumber(b.Name:match("%d+$"))
	
			if na and nb and a.Name:match("^(.-)%d+$") == b.Name:match("^(.-)%d+$") then
				return na < nb
			end
	
			if na and not nb then return false end
			if nb and not na then return true end
	
			return a.Name < b.Name
		end)
	
		return list
	end
	
	local function switchPage(targetName, remember)
		if _G.MenuBusy then return end
	
		local targetPage = getPage(targetName)
		if not targetPage then
			warn("Page does not exist:", targetName)
			return
		end
	
		if currentPage == targetName then return end
	
		_G.MenuBusy = true
	
		if remember then
			table.insert(pageHistory, currentPage)
		end
	
		closeMenu()
	
		local oldPage = getPage(currentPage)
	
		if oldPage then
			oldPage:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Sine", 0.4, true, function()
				oldPage.Visible = false
			end)
		end
	
		task.wait(0.4)
	
		targetPage.Position = UDim2.new(1, 0, 0, 0)
		targetPage.Visible = true
		targetPage:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Sine", 0.4)
	
		task.wait(0.4)
	
		currentPage = targetName
		_G.MenuBusy = false
	end
	
	local function goBack()
		if #pageHistory == 0 then return end
		switchPage(table.remove(pageHistory), false)
	end
	
	for _, page in ipairs(getPageList()) do
		page.Visible = page.Name == currentPage
		page.Position = page.Name == currentPage and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 0)
	end
	
	for _, button in ipairs(MenuFrame:GetChildren()) do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			if getPage(button.Name) then
				button.MouseButton1Click:Connect(function()
					pageHistory = {}
					switchPage(button.Name, false)
				end)
			end
		end
	end
	
	for _, button in ipairs(Pages:GetDescendants()) do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			if button.Name == "Next" then
				button.MouseButton1Click:Connect(function()
					local pageList = getPageList()
					local currentIndex
	
					for i, page in ipairs(pageList) do
						if page.Name == currentPage then
							currentIndex = i
							break
						end
					end
	
					if currentIndex and pageList[currentIndex + 1] then
						switchPage(pageList[currentIndex + 1].Name, true)
					end
				end)
			elseif button.Name == "Back" then
				button.MouseButton1Click:Connect(goBack)
			end
		end
	end
	
end;
task.spawn(C_11);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar.HipHeight.LocalScript
local function C_22()
local script = G2L["22"];
	local Players = game:GetService("Players")
	
	script.Parent.MouseButton1Click:Connect(function()
		local text = script.Parent.Parent.Parent.TXTBOX_Stats.Text
		if text and text ~= "" then
			local value = tonumber(text)
			if value then
				Players.LocalPlayer.Character.Humanoid.HipHeight = value
			end
		end
	end)
end;
task.spawn(C_22);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar.JumpHeight.LocalScript
local function C_24()
local script = G2L["24"];
	local Players = game:GetService("Players")
	
	script.Parent.MouseButton1Click:Connect(function()
		local text = script.Parent.Parent.Parent.TXTBOX_Stats.Text
		if text and text ~= "" then
			local value = tonumber(text)
			if value then
				Players.LocalPlayer.Character.Humanoid.JumpPower = value
			end
		end
	end)
end;
task.spawn(C_24);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar.Speed.LocalScript
local function C_26()
local script = G2L["26"];
	local Players = game:GetService("Players")
	
	script.Parent.MouseButton1Click:Connect(function()
		local text = script.Parent.Parent.Parent.TXTBOX_Stats.Text
		if text and text ~= "" then
			local value = tonumber(text)
			if value then
				Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
			end
		end
	end)
end;
task.spawn(C_26);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar2.EditLast.LocalScript
local function C_29()
local script = G2L["29"];
	local t = game:GetService("TextChatService")
	local channel = t:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
	local player = game:GetService("Players").LocalPlayer
	local lastSentMessage
	
	channel.MessageReceived:Connect(function(message)
		if message.TextSource and message.TextSource.UserId == player.UserId then
			lastSentMessage = message
		end
	end)
	
	script.Parent.MouseButton1Click:Connect(function()
		local a = lastSentMessage
		if not a then return end
	
		local text = script.Parent.Parent.Parent.TXTBOX_Chat.Text
		local tagB = a.Metadata
		local messageId = a.MessageId
		local source = a.TextSource
	
		local sig = {
			t.ClientToServerMessageReplicateSignalV2,
			t.ClientToServerMessageReplicateSignalV3,
			t.ClientToServerMessageReplicateSignalV4
			}
	
		local attempts = {
			function() replicatesignal(sig[1], text, tagB, messageId, source, channel) end,
			function() replicatesignal(sig[2], text, tagB, messageId, source, channel, false, false) end,
			function() replicatesignal(sig[2], text, tagB, messageId, source, channel, true, false) end,
			function() replicatesignal(sig[3], text, tagB, messageId, source, channel, false, false, "", "") end,
			function() replicatesignal(sig[3], text, tagB, messageId, source, channel, true, false, "", "") end,
			function() replicatesignal(sig[3], text, "", tagB, messageId, source, channel) end,
		}
	
		for i, attempt in ipairs(attempts) do
			local ok = pcall(attempt)
			if ok then break end
		end
	end)
end;
task.spawn(C_29);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar2.FilterBypass.LocalScript
local function C_2b()
local script = G2L["2b"];
	local TextChatService = game:GetService("TextChatService")
	
	local charMap = {
		a = "丹", b = "日", c = "亡", d = "句", e = "ヨ", f = "乍",
		g = "呂", h = "廾", i = "工", j = "勹", k = "片", l = "し",
		m = "冊", n = "几", o = "回", p = "尸", q = "甲", r = "尺",
		s = "己", t = "卞", u = "凵", v = "レ", w = "山", x = "メ",
		y = "と", z = "乙"
	}
	
	script.Parent.MouseButton1Click:Connect(function()
		local text = script.Parent.Parent.Parent.TXTBOX_Chat.Text
		if not text or text == "" then return end
	
		local result = ""
		for i = 1, #text do
			local char = text:sub(i, i):lower()
			result = result .. (charMap[char] or text:sub(i, i))
		end
	
		TextChatService.TextChannels.RBXGeneral:SendAsync(result)
	end)
end;
task.spawn(C_2b);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar3.Noclip.LocalScript
local function C_2e()
local script = G2L["2e"];
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	local enabled = false
	local connection
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.BackgroundColor3 = enabled and darkerColor or defaultColor
	
		if enabled then
			connection = RunService.Stepped:Connect(function()
				for _, part in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end)
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end
			for _, part in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end)
end;
task.spawn(C_2e);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_1.BackGroundChar3.InfJump.LocalScript
local function C_30()
local script = G2L["30"];
	local UserInputService = game:GetService("UserInputService")
	local Players = game:GetService("Players")
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	local enabled = false
	local connection
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.BackgroundColor3 = enabled and darkerColor or defaultColor
	
		if enabled then
			connection = UserInputService.JumpRequest:Connect(function()
				Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end)
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
	end)
end;
task.spawn(C_30);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.Bring.LocalScript
local function C_3e()
local script = G2L["3e"];
	--TY MYWORLD :>
	
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	
	local speeding = 32
	local maxspeed = 75
	local off = CFrame.Angles(-1.5707963267948966, 0, 0)
	local bringing = false
	
	local function GetTarget()
		local targetName = script.Parent.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
		if targetName == "" then return nil end
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				return p
			end
		end
		return nil
	end
	
	button.MouseButton1Click:Connect(function()
		if bringing then
			bringing = false
			button.Text = "Bring"
			button.BackgroundColor3 = defaultColor
			return
		end
	
		local target = GetTarget()
		if not target then
			button.Text = "No Target!"
			task.delay(2, function() if button.Text == "No Target!" then button.Text = "Bring" end end)
			return
		end
	
		local c = player.Character
		local c1 = target.Character
		if not (c and c1) then return end
	
		local hrp = c:FindFirstChild("HumanoidRootPart")
		local hrp1 = c1:FindFirstChild("HumanoidRootPart")
		if not (hrp and hrp1) then return end
	
		bringing = true
		button.Text = "Bringing..."
		button.BackgroundColor3 = darkerColor
	
		local fromP = hrp1.CFrame.Position
		local toP = hrp.CFrame.Position
		local to = hrp.CFrame
		local mag = (fromP - toP).Magnitude - 3
		local lv = CFrame.new(fromP, toP).LookVector
		local vel = 0
		local pos = fromP - Vector3.new(0, 2, 0)
		toP = toP - Vector3.new(0, 2, 0)
		local lastsine = os.clock()
		local way = 0
		local reachedmaxspeed = false
	
		while bringing and c:IsDescendantOf(workspace) and c1:IsDescendantOf(workspace) do
			local sine = os.clock()
			local dt = sine - lastsine
			lastsine = sine
	
			if reachedmaxspeed then
				if mag - way < reachedmaxspeed then
					vel = vel - dt * speeding
					if vel < 0 then break end
				end
			else
				if way > mag / 2 then
					vel = vel - dt * speeding
					if vel < 0 then break end
				else
					vel = vel + dt * speeding
					if vel > maxspeed then
						reachedmaxspeed = way
						vel = maxspeed
					end
				end
			end
	
			way = way + vel * dt
	
			if not hrp:IsGrounded() then
				hrp.CFrame = CFrame.new(pos + lv * way, toP) * off
				hrp.Velocity = lv * (vel + 1)
				hrp.RotVelocity = Vector3.new()
			end
	
			task.wait()
		end
	
		hrp.CFrame = to
		hrp.Velocity = Vector3.new()
		hrp.RotVelocity = Vector3.new()
		bringing = false
		button.Text = "Bring"
		button.BackgroundColor3 = defaultColor
	end)
end;
task.spawn(C_3e);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.Fling.LocalScript
local function C_40()
local script = G2L["40"];
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local button = script.Parent
	
	local busy = false
	
	local function getTarget()
		local name = button.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
		if name == "" then return nil end
	
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player then
				local playerName = p.Name:lower()
				local displayName = (p.DisplayName or ""):lower():gsub("%s+", "")
	
				if playerName:find(name, 1, true) or displayName:find(name, 1, true) then
					return p
				end
			end
		end
	end
	
	local function getRoot(character)
		return character and character:FindFirstChild("HumanoidRootPart")
	end
	
	local function teleportLoop(target)
		local root = getRoot(player.Character)
		if not root then return end
	
		local origin = root.CFrame
		local finish = os.clock() + 1
	
		while os.clock() < finish do
			root = getRoot(player.Character)
			local targetRoot = getRoot(target.Character)
	
			if not root or not targetRoot then break end
	
			root.CFrame = targetRoot.CFrame
			root.AssemblyLinearVelocity = Vector3.new(0, 9001, 0)
			RunService.Heartbeat:Wait()
			sethiddenproperty(root,"PhysicsRepRootRef",InstanceHandle.new(targetRoot))
		end
	
		root = getRoot(player.Character)
		if root then
			root.CFrame = origin
			root.Velocity = Vector3.zero
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			sethiddenproperty(root,"PhysicsRepRootRef",nil)
		end
	end
	
	button.MouseButton1Click:Connect(function()
		if busy then return end
	
		local target = getTarget()
		if not target then
			button.Text = "No Target!"
			task.delay(2, function()
				button.Text = "Fling"
			end)
			return
		end
	
		busy = true
		button.Active = false
		button.AutoButtonColor = false
	
		pcall(teleportLoop, target)
	
		button.Active = true
		button.AutoButtonColor = true
		busy = false
	end)
end;
task.spawn(C_40);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.Weld.LocalScript
local function C_42()
local script = G2L["42"];
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local button = script.Parent
	
	local enabled = false
	local loopConnection
	local dc = script.Parent.BackgroundColor3
	local dkc = Color3.fromRGB(
		math.clamp(dc.R * 255 - 30, 0, 255),
		math.clamp(dc.G * 255 - 30, 0, 255),
		math.clamp(dc.B * 255 - 30, 0, 255)
	)
	
	local function getTarget()
		local name = button.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
		if name == "" then return nil end
	
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player then
				local playerName = p.Name:lower()
				local displayName = (p.DisplayName or ""):lower():gsub("%s+", "")
	
				if playerName:find(name, 1, true) or displayName:find(name, 1, true) then
					return p
				end
			end
		end
	end
	
	local function getRoot(character)
		return character and character:FindFirstChild("HumanoidRootPart")
	end
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
	
		if enabled then
			script.Parent.BackgroundColor3 = dkc
	
			local target = getTarget()
			if not target then
				enabled = false
				button.Parent.BackgroundColor3 = dc
				return
			end
	
			loopConnection = RunService.Heartbeat:Connect(function()
				if not enabled then return end
	
				local root = getRoot(player.Character)
				local targetRoot = getRoot(target.Character)
	
				if root and targetRoot then
					root.CFrame = targetRoot.CFrame * (CFrame.new(0, 0, 0))
					sethiddenproperty(root, "PhysicsRepRootRef", InstanceHandle.new(targetRoot))
				end
			end)
		else
			if loopConnection then
				loopConnection:Disconnect()
				loopConnection = nil
			end
	
			script.Parent.BackgroundColor3 = dc
	
			local root = getRoot(player.Character)
			if root then
				sethiddenproperty(root, "PhysicsRepRootRef", nil)
			end
		end
	end)
end;
task.spawn(C_42);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.LoopFling.LocalScript
local function C_44()
local script = G2L["44"];
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local player, button = Players.LocalPlayer, script.Parent
	local on = false
	local defaultColor = button.BackgroundColor3
	
	local function getTarget()
		local name = button.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
		if name == "" then return end
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and (p.Name:lower():find(name, 1, true) or p.DisplayName:lower():gsub("%s+", ""):find(name, 1, true)) then
				return p
			end
		end
	end
	
	local function getRoot(c)
		return c and c:FindFirstChild("HumanoidRootPart")
	end
	
	button.MouseButton1Click:Connect(function()
		on = not on
		button.BackgroundColor3 = on and Color3.new(
			math.max(0, defaultColor.R - 30/255),
			math.max(0, defaultColor.G - 30/255),
			math.max(0, defaultColor.B - 30/255)
		) or defaultColor
	
		if on then
			task.spawn(function()
				while on do
					local target = getTarget()
					local root = getRoot(player.Character)
					local targetRoot = target and getRoot(target.Character)
	
					if root and targetRoot then
						root.CFrame = targetRoot.CFrame
						root.AssemblyLinearVelocity = Vector3.new(0, 9001, 0)
						pcall(sethiddenproperty, root, "PhysicsRepRootRef", InstanceHandle.new(targetRoot))
					end
	
					RunService.Heartbeat:Wait()
				end
	
				local root = getRoot(player.Character)
				if root then
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
					pcall(sethiddenproperty, root, "PhysicsRepRootRef", nil)
				end
			end)
		end
	end)
end;
task.spawn(C_44);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.LoopTKill.LocalScript
local function C_46()
local script = G2L["46"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local button = script.Parent
	local default = button.BackgroundColor3
	local off = default
	local onColor = Color3.fromRGB(
		math.max(0, default.R * 255 - 30),
		math.max(0, default.G * 255 - 30),
		math.max(0, default.B * 255 - 30)
	)
	local enabled, conn, tool
	
	local function getTarget()
		local name = button.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
		if name == "" then return end
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and (p.Name:lower():find(name, 1, true) or p.DisplayName:lower():gsub("%s+", ""):find(name, 1, true)) then
				return p
			end
		end
	end
	
	local function toggle(state)
		enabled = state
		button.BackgroundColor3 = state and onColor or off
		if conn then conn:Disconnect() conn = nil end
		if not state then return end
	
		tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
		if not tool then
			toggle(false)
			return
		end
	
		conn = game:GetService("RunService").Heartbeat:Connect(function()
			if not enabled or tool.Parent ~= player.Character then
				toggle(false)
				return
			end
	
			local handle = tool:FindFirstChild("Handle")
			local touch = handle and handle:FindFirstChildOfClass("TouchTransmitter")
			local target = getTarget()
			local root = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	
			if touch and root then
				for _ = 1, 10 do
					firetouchinterest(handle, root, 0)
					firetouchinterest(handle, root, 1)
					firetouchinterest(handle, root, 0)
					firetouchinterest(handle, root, 1)
					firetouchinterest(handle, root, 0)
					firetouchinterest(handle, root, 1)
					firetouchinterest(handle, root, 0)
					firetouchinterest(handle, root, 1)
					firetouchinterest(handle, root, 0)
					firetouchinterest(handle, root, 1)
				end
			end
		end)
	end
	
	button.Activated:Connect(function()
		toggle(not enabled)
	end)
end;
task.spawn(C_46);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.othersBaseBackground3.ToolKill.LocalScript
local function C_48()
local script = G2L["48"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local button = script.Parent
	
	local function getTarget()
		local name = button.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
		if name == "" then return end
	
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and (p.Name:lower():find(name, 1, true) or p.DisplayName:lower():gsub("%s+", ""):find(name, 1, true)) then
				return p
			end
		end
	end
	
	button.Activated:Connect(function()
		local char = player.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		if not tool then return end
	
		local handle = tool:FindFirstChild("Handle")
		local touch = handle and handle:FindFirstChildOfClass("TouchTransmitter")
		if not touch then return end
	
		local target = getTarget()
		local root = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end
	
		for _ = 1, 10 do
			firetouchinterest(handle, root, 0)
			firetouchinterest(handle, root, 1)
			firetouchinterest(handle, root, 0)
			firetouchinterest(handle, root, 1)
			firetouchinterest(handle, root, 0)
			firetouchinterest(handle, root, 1)
			firetouchinterest(handle, root, 0)
			firetouchinterest(handle, root, 1)
			firetouchinterest(handle, root, 0)
			firetouchinterest(handle, root, 1)
		end
	end)
end;
task.spawn(C_48);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.BackGroundChar.TouchFling.LocalScript
local function C_50()
local script = G2L["50"];
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local enabled = false
	local movel = 0.1
	
	local defaultColor = script.Parent.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	
	script.Parent.MouseButton1Click:Connect(function()
		enabled = not enabled
		script.Parent.BackgroundColor3 = enabled and darkerColor or defaultColor
		if enabled then
			coroutine.wrap(function()
				while enabled do
					RunService.Heartbeat:Wait()
					local c = Players.LocalPlayer.Character
					local hrp = c and c:FindFirstChild("HumanoidRootPart")
					if hrp then
						local vel = hrp.Velocity
						hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
						RunService.RenderStepped:Wait()
						hrp.Velocity = vel
						RunService.Stepped:Wait()
						hrp.Velocity = vel + Vector3.new(0, movel, 0)
						movel = -movel
					end
				end
			end)()
		end
	end)
end;
task.spawn(C_50);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_3.BackGroundChar.ClickFling.LocalScript
local function C_52()
local script = G2L["52"];
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	local button = script.Parent
	local default = button.BackgroundColor3
	local darker = Color3.new(
		math.max(0, default.R - 30/255),
		math.max(0, default.G - 30/255),
		math.max(0, default.B - 30/255)
	)
	local enabled, tool, busy, deathConn = false
	
	local function toggle(state)
		enabled = state
		button.BackgroundColor3 = state and darker or default
		if deathConn then deathConn:Disconnect() deathConn = nil end
		if tool then tool:Destroy() tool = nil end
		if not state then return end
	
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			enabled = false
			button.BackgroundColor3 = default
			return
		end
	
		tool = Instance.new("Tool")
		tool.Name, tool.RequiresHandle, tool.CanBeDropped, tool.Parent = "ClickFling", false, false, player.Backpack
	
		deathConn = hum.Died:Connect(function() toggle(false) end)
		tool.Activated:Connect(function()
			if busy or not enabled or tool.Parent ~= char then return end
			local mouse = player:GetMouse()
			local model = mouse.Target and mouse.Target:FindFirstAncestorOfClass("Model")
			local target = model and Players:GetPlayerFromCharacter(model)
			local root = char:FindFirstChild("HumanoidRootPart")
			local other = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			if not root or not other or target == player then return end
	
			busy = true
			local origin = root.CFrame
			local endTime = os.clock() + 1
			while enabled and os.clock() < endTime and root.Parent and other.Parent do
				root.AssemblyLinearVelocity = Vector3.new(0, 90001, 0)
				root.CFrame = other.CFrame * CFrame.new(0, 0, 0)
				sethiddenproperty(root,"PhysicsRepRootRef",InstanceHandle.new(other))
				RunService.Heartbeat:Wait()
			end
			if player.Character == char and root.Parent then root.CFrame = origin end
			sethiddenproperty(root,"PhysicsRepRootRef",InstanceHandle.new(nil))
			root.Velocity = Vector3.zero
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			busy = false
		end)
	end
	
	button.Activated:Connect(function() toggle(not enabled) end)
	player.CharacterRemoving:Connect(function() if enabled then toggle(false) end end)
end;
task.spawn(C_52);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.Follow.LocalScript
local function C_61()
local script = G2L["61"];
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	local following = false
	local connection
	
	button.MouseButton1Click:Connect(function()
		following = not following
		button.BackgroundColor3 = following and darkerColor or defaultColor
	
		if following then
			local targetName = script.Parent.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
			if targetName == "" then following = false button.BackgroundColor3 = defaultColor return end
			local target = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p == player then continue end
				local name = p.Name:lower()
				local display = (p.DisplayName or ""):lower()
				if name:find(targetName) or display:find(targetName) then
					target = p
					break
				end
			end
			if not target then following = false button.BackgroundColor3 = defaultColor return end
	
			connection = RunService.Heartbeat:Connect(function()
				local character = player.Character
				local targetCharacter = target.Character
				if not character or not targetCharacter then
					following = false
					button.BackgroundColor3 = defaultColor
					connection:Disconnect()
					return
				end
				local humanoid = character:FindFirstChild("Humanoid")
				local root = character:FindFirstChild("HumanoidRootPart")
				local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
				if not humanoid or not root or not targetRoot then return end
				if humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall then
					following = false
					button.BackgroundColor3 = defaultColor
					humanoid:MoveTo(root.Position)
					connection:Disconnect()
					return
				end
				humanoid:MoveTo(targetRoot.Position)
			end)
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end
			local humanoid = player.Character:FindFirstChild("Humanoid")
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if humanoid and root then
				humanoid:MoveTo(root.Position)
			end
		end
	end)
end;
task.spawn(C_61);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.TeleportTo.LocalScript
local function C_63()
local script = G2L["63"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			local name = p.Name:lower()
			local display = (p.DisplayName or ""):lower()
			if name:find(targetName) or display:find(targetName) then
				target = p
				break
			end
		end
		if target and target.Character then
			local targetCFrame = target.Character.HumanoidRootPart.CFrame
			player.Character.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(2, 0, 0)
		end
	end)
end;
task.spawn(C_63);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.View.LocalScript
local function C_65()
local script = G2L["65"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	local enabled = false
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.BackgroundColor3 = enabled and darkerColor or defaultColor
	
		if enabled then
			local targetName = script.Parent.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
			if targetName == "" then enabled = false button.BackgroundColor3 = defaultColor return end
			local target = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p == player then continue end
				local name = p.Name:lower()
				local display = (p.DisplayName or ""):lower()
				if name:find(targetName) or display:find(targetName) then
					target = p
					break
				end
			end
			if not target or not target.Character then enabled = false button.BackgroundColor3 = defaultColor return end
			workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChild("Head")
		else
			workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
		end
	end)
end;
task.spawn(C_65);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.Orbit.LocalScript
local function C_67()
local script = G2L["67"];
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	local enabled = false
	local connection
	local savedCFrame
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.BackgroundColor3 = enabled and darkerColor or defaultColor
	
		if enabled then
			local targetName = script.Parent.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
			if targetName == "" then enabled = false button.BackgroundColor3 = defaultColor return end
			local target = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p == player then continue end
				local name = p.Name:lower()
				local display = (p.DisplayName or ""):lower()
				if name:find(targetName) or display:find(targetName) then
					target = p
					break
				end
			end
			if not target then enabled = false button.BackgroundColor3 = defaultColor return end
	
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not root then enabled = false button.BackgroundColor3 = defaultColor return end
			savedCFrame = root.CFrame
	
			local angle = 0
			local radius = 6
	
			connection = RunService.Heartbeat:Connect(function(dt)
				local targetCharacter = target.Character
				local playerCharacter = player.Character
				if not targetCharacter or not playerCharacter then return end
				local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
				local playerRoot = playerCharacter:FindFirstChild("HumanoidRootPart")
				if not targetRoot or not playerRoot then return end
				angle = angle + dt * 1.5
				local x = targetRoot.Position.X + math.cos(angle) * radius
				local z = targetRoot.Position.Z + math.sin(angle) * radius
				local y = targetRoot.Position.Y
				playerRoot.CFrame = CFrame.new(Vector3.new(x, y, z), targetRoot.Position)
			end)
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root and savedCFrame then
				root.CFrame = savedCFrame
			end
		end
	end)
end;
task.spawn(C_67);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.LookAt.LocalScript
local function C_69()
local script = G2L["69"];
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	local enabled = false
	local connection
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.BackgroundColor3 = enabled and darkerColor or defaultColor
	
		if enabled then
			local targetName = script.Parent.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
			if targetName == "" then enabled = false button.BackgroundColor3 = defaultColor return end
			local target = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p == player then continue end
				local name = p.Name:lower()
				local display = (p.DisplayName or ""):lower()
				if name:find(targetName) or display:find(targetName) then
					target = p
					break
				end
			end
			if not target then enabled = false button.BackgroundColor3 = defaultColor return end
	
			connection = RunService.Heartbeat:Connect(function()
				local camera = workspace.CurrentCamera
				local targetCharacter = target.Character
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if not targetCharacter or not root then return end
				local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
				if not targetRoot then return end
				camera.CFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position)
			end)
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
	end)
end;
task.spawn(C_69);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_1.othersBaseBackground.PathFollow.LocalScript
local function C_6b()
local script = G2L["6b"];
	local Players = game:GetService("Players")
	local PathfindingService = game:GetService("PathfindingService")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	local following = false
	
	button.MouseButton1Click:Connect(function()
		following = not following
		button.BackgroundColor3 = following and darkerColor or defaultColor
	
		if following then
			local targetName = script.Parent.Parent.Parent:WaitForChild("TXTBOX_PlrName").Text:lower():gsub("%s+", "")
			if targetName == "" then following = false button.BackgroundColor3 = defaultColor return end
			local target = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p == player then continue end
				local name = p.Name:lower()
				local display = (p.DisplayName or ""):lower()
				if name:find(targetName) or display:find(targetName) then
					target = p
					break
				end
			end
			if not target then following = false button.BackgroundColor3 = defaultColor return end
	
			coroutine.wrap(function()
				while following do
					local character = player.Character
					local targetCharacter = target.Character
					if not character or not targetCharacter then wait(0.5) continue end
					local humanoid = character:FindFirstChild("Humanoid")
					local root = character:FindFirstChild("HumanoidRootPart")
					local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
					if not humanoid or not root or not targetRoot then wait(0.5) continue end
					if humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall then
						following = false
						button.BackgroundColor3 = defaultColor
						humanoid:MoveTo(root.Position)
						break
					end
					local path = PathfindingService:CreatePath({
						AgentRadius = 2,
						AgentHeight = 5,
						AgentCanJump = true,
					})
					local success = pcall(function()
						path:ComputeAsync(root.Position, targetRoot.Position)
					end)
					if success and path.Status == Enum.PathStatus.Success then
						local waypoints = path:GetWaypoints()
						for _, waypoint in ipairs(waypoints) do
							if not following then break end
							if waypoint.Action == Enum.PathWaypointAction.Jump then
								humanoid.Jump = true
							end
							humanoid:MoveTo(waypoint.Position)
							local moved = humanoid.MoveToFinished:Wait()
							if not moved then break end
						end
					else
						humanoid:MoveTo(targetRoot.Position)
					end
					wait(0.2)
				end
			end)()
		else
			following = false
			local humanoid = player.Character:FindFirstChild("Humanoid")
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if humanoid and root then
				humanoid:MoveTo(root.Position)
			end
		end
	end)
end;
task.spawn(C_6b);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_2.WeldHandler
local function C_74()
local script = G2L["74"];
	local P=game:GetService("Players")
	local R=game:GetService("RunService")
	local p=P.LocalPlayer
	local g=script.Parent
	local tb=g:WaitForChild("TXTBOX_WeldName")
	
	local ab,ac,animConn,targetConn
	local bs={}
	local saved={}
	local targetPlayer
	local targetRoot
	
	local function gt()
		local n=tb.Text:lower():gsub("%s+","")
		if n=="" then return end
		for _,v in ipairs(P:GetPlayers()) do
			if v~=p then
				local a=v.Name:lower()
				local d=(v.DisplayName or ""):lower():gsub("%s+","")
				if a:find(n,1,true) or d:find(n,1,true) then return v end
			end
		end
	end
	
	local function pr(s)
		local x,y,z=s:match("CFrame%.Angles%s*%(%s*(.-)%s*,%s*(.-)%s*,%s*(.-)%s*%)")
		if not x then return CFrame.new() end
		local function pa(v)
			v=v:gsub("%s+","")
			local d=v:match("^math%.rad%((%-?[%d%.]+)%)$")
			if d then return math.rad(tonumber(d)) end
			return tonumber(v)
		end
		x,y,z=pa(x),pa(y),pa(z)
		if not x or not y or not z then return CFrame.new() end
		return CFrame.Angles(x,y,z)
	end
	
	local function sb(b,on)
		local d=bs[b]
		if not d then return end
		local c=d.c
		b.BackgroundColor3=on and Color3.new(
			math.max(0,c.R-30/255),
			math.max(0,c.G-30/255),
			math.max(0,c.B-30/255)
		) or c
	end
	
	local function setRootReference(root,target)
		pcall(function()
			sethiddenproperty(root,"PhysicsRepRootRef",InstanceHandle.new(target))
			sethiddenproperty(root,"PhysicsRepRootPart", target)
		end)
	end
	
	local function zeroVelocity(root)
		root.Velocity=Vector3.zero
		root.AssemblyLinearVelocity=Vector3.zero
		root.AssemblyAngularVelocity=Vector3.zero
		root.RotVelocity=Vector3.zero
	end
	
	local function stop()
		if ac then ac:Disconnect() ac=nil end
		if animConn then animConn:Disconnect() animConn=nil end
		if targetConn then targetConn:Disconnect() targetConn=nil end
	
		local char=p.Character
		local hum=char and char:FindFirstChildOfClass("Humanoid")
		local root=char and char:FindFirstChild("HumanoidRootPart")
	
		if root then
			pcall(function()
				sethiddenproperty(root,"PhysicsRepRootRef",nil)
				sethiddenproperty(root,"PhysicsRepRootPart", nil)
			end)
			zeroVelocity(root)
		end
	
		if hum then
			hum.PlatformStand=saved.PlatformStand or false
			hum.AutoRotate=saved.AutoRotate~=nil and saved.AutoRotate or true
			for state,enabled in pairs(saved.States or {}) do
				hum:SetStateEnabled(state,enabled)
			end
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	
		if ab then
			sb(ab,false)
			ab=nil
		end
	
		targetPlayer=nil
		targetRoot=nil
		saved={}
	end
	
	local function reg(b)
		local po=b:FindFirstChild("PO")
		local ro=b:FindFirstChild("RO")
		if not po or not po:IsA("Vector3Value") then return end
		if not ro or not ro:IsA("StringValue") then return end
	
		bs[b]={c=b.BackgroundColor3,po=po,ro=ro}
	
		b.Activated:Connect(function()
			if ab==b then
				stop()
				return
			end
	
			local switching=ab~=nil
	
			if switching then
				sb(ab,false)
				ab=nil
			else
				targetPlayer=gt()
				if not targetPlayer then return end
	
				local char=p.Character
				local hum=char and char:FindFirstChildOfClass("Humanoid")
				if not hum then return end
	
				saved.PlatformStand=hum.PlatformStand
				saved.AutoRotate=hum.AutoRotate
				saved.States={}
	
				for _,state in ipairs({
					Enum.HumanoidStateType.GettingUp,
					Enum.HumanoidStateType.Ragdoll,
					Enum.HumanoidStateType.FallingDown
					}) do
					saved.States[state]=hum:GetStateEnabled(state)
					hum:SetStateEnabled(state,false)
				end
	
				hum.PlatformStand=true
				hum.AutoRotate=false
	
				targetConn=targetPlayer.CharacterAdded:Connect(function(char)
					targetRoot=char:WaitForChild("HumanoidRootPart")
				end)
	
				local function stopAnims()
					local c=p.Character
					local h=c and c:FindFirstChildOfClass("Humanoid")
					if h then
						for _,track in ipairs(h:GetPlayingAnimationTracks()) do
							track:Stop(0)
						end
					end
				end
	
				animConn=R.Heartbeat:Connect(stopAnims)
			end
	
			ab=b
			sb(b,true)
	
			local tc=targetPlayer and targetPlayer.Character
			targetRoot=tc and tc:FindFirstChild("HumanoidRootPart")
	
			if not ac then
				ac=R.Heartbeat:Connect(function()
					if not ab then return end
	
					local char=p.Character
					local root=char and char:FindFirstChild("HumanoidRootPart")
					local hum=char and char:FindFirstChildOfClass("Humanoid")
					if not root or not hum then return end
	
					if not targetRoot or not targetRoot:IsDescendantOf(workspace) then
						local currentTarget=targetPlayer and targetPlayer.Character
						targetRoot=currentTarget and currentTarget:FindFirstChild("HumanoidRootPart")
						if not targetRoot then return end
					end
	
					hum.PlatformStand=true
					hum.AutoRotate=false
	
					setRootReference(root,targetRoot)
	
					local desired=targetRoot.CFrame*CFrame.new(bs[ab].po.Value)*pr(bs[ab].ro.Value)
					root.CFrame=desired
					zeroVelocity(root)
				end)
			end
		end)
	end
	
	for _,v in ipairs(g:GetDescendants()) do
		if v:IsA("TextButton") then
			reg(v)
		end
	end
	
	p.CharacterAdded:Connect(function()
		if ab then stop() end
	end)
end;
task.spawn(C_74);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon.Inspect.LocalScript
local function C_aa()
local script = G2L["aa"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
		pcall(function()
			game:GetService("GuiService"):InspectPlayerFromUserId(target.UserId)
		end)
	end)
end;
task.spawn(C_aa);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon.Age.LocalScript
local function C_ac()
local script = G2L["ac"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
		pcall(function()
			local age = target.AccountAge
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = target.Name .. "'s Account Age",
				Text = age .. " days old",
				Duration = 5,
			})
		end)
	end)
end;
task.spawn(C_ac);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon.JoinDate.LocalScript
local function C_ae()
local script = G2L["ae"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
		pcall(function()
			local age = target.AccountAge
			local joinDate = os.date("%B %d, %Y", os.time() - (age * 86400))
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = target.Name .. "'s Join Date",
				Text = joinDate,
				Duration = 5,
			})
		end)
	end)
end;
task.spawn(C_ae);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon2.CopyTools.LocalScript
local function C_b1()
local script = G2L["b1"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
	
		local function cloneTool(tool)
			pcall(function()
				local clone = tool:Clone()
				clone.Parent = player.Backpack
			end)
		end
	
		for _, tool in ipairs(target.Backpack:GetChildren()) do
			if tool:IsA("Tool") then
				cloneTool(tool)
			end
		end
	
		if target.Character then
			for _, tool in ipairs(target.Character:GetChildren()) do
				if tool:IsA("Tool") then
					cloneTool(tool)
				end
			end
		end
	
	end)
end;
task.spawn(C_b1);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon2.CopyAnims.LocalScript
local function C_b3()
local script = G2L["b3"];
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	
	local enabled = false
	local con
	local currentTrack = nil
	
	script.Parent.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.BackgroundColor3 = enabled and darkerColor or defaultColor
	
		if enabled then
			local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
			if targetName == "" then enabled = false button.BackgroundColor3 = defaultColor return end
			local target = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p == player then continue end
				if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
					target = p
					break
				end
			end
			if not target then enabled = false button.BackgroundColor3 = defaultColor return end
	
			con = RunService.Heartbeat:Connect(function()
				local tChar = target.Character
				local tHumanoid = tChar and tChar:FindFirstChild("Humanoid")
				local tAnimator = tHumanoid and tHumanoid:FindFirstChild("Animator")
				if not tAnimator then return end
	
				local myChar = player.Character
				local myHumanoid = myChar and myChar:FindFirstChild("Humanoid")
				local myAnimator = myHumanoid and myHumanoid:FindFirstChild("Animator")
				if not myHumanoid or not myAnimator then return end
	
				local playing = tAnimator:GetPlayingAnimationTracks()
				if #playing == 0 then return end
	
				local topTrack = playing[1]
				for _, t in ipairs(playing) do
					if t.Priority.Value > topTrack.Priority.Value then
						topTrack = t
					end
				end
	
				if currentTrack and currentTrack.Animation.AnimationId == topTrack.Animation.AnimationId then
					currentTrack.TimePosition = topTrack.TimePosition
					return
				end
	
				if currentTrack then
					currentTrack:Stop(0)
					currentTrack = nil
				end
	
				local anim = Instance.new("Animation")
				anim.AnimationId = topTrack.Animation.AnimationId
	
				currentTrack = myHumanoid:LoadAnimation(anim)
				currentTrack.Priority = Enum.AnimationPriority.Action4
				currentTrack:Play(0)
				currentTrack.TimePosition = topTrack.TimePosition
			end)
		else
			if con then con:Disconnect() con = nil end
			if currentTrack then currentTrack:Stop() currentTrack = nil end
		end
	end)
end;
task.spawn(C_b3);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.Colon2.CopyID.LocalScript
local function C_b5()
local script = G2L["b5"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
		pcall(function()
			local id = tostring(target.UserId)
			setclipboard(id)
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = target.Name .. "'s User ID",
				Text = "Copied to clipboard!",
				Duration = 5,
			})
		end)
	end)
end;
task.spawn(C_b5);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon4.Health.LocalScript
local function C_b8()
local script = G2L["b8"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
		local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
		if not humanoid then return end
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = target.Name .. "'s Health",
			Text = math.round(humanoid.Health) .. " / " .. math.round(humanoid.MaxHealth),
			Duration = 5,
		})
	end)
end;
task.spawn(C_b8);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon4.FullName.LocalScript
local function C_ba()
local script = G2L["ba"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
		local same = target.Name == target.DisplayName
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Name Info",
			Text = "Username: " .. target.Name .. "\nDisplay: " .. target.DisplayName .. (same and " (same)" or " (different)"),
			Duration = 5,
		})
	end)
end;
task.spawn(C_ba);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon4.SimRadius.LocalScript
local function C_bc()
local script = G2L["bc"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
		pcall(function()
			local radius = gethiddenproperty(target, "SimulationRadius")
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = target.Name .. "'s Simulation Radius",
				Text = "Radius: " .. tostring(math.round(radius)),
				Duration = 5,
			})
		end)
	end)
end;
task.spawn(C_bc);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon3.Friends.LocalScript
local function C_bf()
local script = G2L["bf"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
	
		local isFriend = player:IsFriendsWith(target.UserId)
		local mutuals = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player or p == target then continue end
			if player:IsFriendsWith(p.UserId) and target:IsFriendsWith(p.UserId) then
				table.insert(mutuals, p.Name)
			end
		end
	
		local mutualText = #mutuals > 0 and table.concat(mutuals, ", ") or "None"
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = target.Name .. " is " .. (isFriend and "Friend" or "Not Friends"),
			Text = "Mutuals: " .. mutualText,
			Duration = 8,
		})
	end)
end;
task.spawn(C_bf);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon3.Team.LocalScript
local function C_c1()
local script = G2L["c1"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
		local team = target.Team
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = target.Name .. "'s Team",
			Text = team and team.Name or "No Team",
			Duration = 5,
		})
	end)
end;
task.spawn(C_c1);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Others_4.WeldColon3.Membership.LocalScript
local function C_c3()
local script = G2L["c3"];
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	
	script.Parent.MouseButton1Click:Connect(function()
		local targetName = script.Parent.Parent.Parent.TXTBOX_PlrName.Text:lower():gsub("%s+", "")
		if targetName == "" then return end
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p == player then continue end
			if p.Name:lower():find(targetName) or (p.DisplayName or ""):lower():find(targetName) then
				target = p
				break
			end
		end
		if not target then return end
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = target.Name .. "'s Membership",
			Text = tostring(target.MembershipType),
			Duration = 5,
		})
	end)
end;
task.spawn(C_c3);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Density.Density
local function C_c9()
local script = G2L["c9"];
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	
	local enabled = false
	local savedProperties = {}
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.BackgroundColor3 = enabled and darkerColor or defaultColor
	
		local character = player.Character
		if not character then enabled = false button.BackgroundColor3 = defaultColor return end
	
		if enabled then
			savedProperties = {}
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					local cp = part.CurrentPhysicalProperties
					savedProperties[part] = {
						Friction = cp.Friction,
						Elasticity = cp.Elasticity,
						FrictionWeight = cp.FrictionWeight,
						ElasticityWeight = cp.ElasticityWeight,
						Density = cp.Density,
					}
					part.CustomPhysicalProperties = PhysicalProperties.new(
						100,
						cp.Friction,
						cp.Elasticity,
						cp.FrictionWeight,
						cp.ElasticityWeight
					)
				end
			end
		else
			for part, props in pairs(savedProperties) do
				if part and part.Parent then
					part.CustomPhysicalProperties = PhysicalProperties.new(
						props.Density,
						props.Friction,
						props.Elasticity,
						props.FrictionWeight,
						props.ElasticityWeight
					)
					part.CustomPhysicalProperties = nil
				end
			end
			savedProperties = {}
		end
	end)
end;
task.spawn(C_c9);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Trip.LocalScript
local function C_cb()
local script = G2L["cb"];
	
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	local player = game:GetService("Players").LocalPlayer
	local enabled = false
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.BackgroundColor3 = enabled and darkerColor or defaultColor
		local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
		if humanoid then humanoid.PlatformStand = enabled end
	end)
end;
task.spawn(C_cb);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.BreakJoints.LocalScript
local function C_cd()
local script = G2L["cd"];
	script.Parent.MouseButton1Click:Connect(function()
		replicatesignal(game.Players.LocalPlayer.Character:WaitForChild("Humanoid").ServerBreakJoints)
	end)
end;
task.spawn(C_cd);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.R6.LocalScript
local function C_d0()
local script = G2L["d0"];
	local plr = game:GetService("Players").LocalPlayer
	local button = script.Parent
	
	local function RunCustomAnimation(Char)
		local defaultAnimate = Char:WaitForChild("Animate")
	
		defaultAnimate.Disabled = true
	
		local Humanoid = Char:WaitForChild("Humanoid")
	
		for _, v in next, Humanoid:GetPlayingAnimationTracks() do
			v:Stop()
		end
	
		local deathConnection
		deathConnection = Humanoid.Died:Connect(function()
			for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
				track:Stop()
			end
	
			defaultAnimate.Disabled = false
	
			if deathConnection then
				deathConnection:Disconnect()
			end
		end)
	
		-- fake script
		local script = defaultAnimate
	
		local Character = Char
		local pose = "Standing"
	
		local UserGameSettings = UserSettings():GetService("UserGameSettings")
	
		local userNoUpdateOnLoopSuccess, userNoUpdateOnLoopValue =
			pcall(function()
				return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop")
			end)
	
		local userNoUpdateOnLoop =
			userNoUpdateOnLoopSuccess and userNoUpdateOnLoopValue
	
		local AnimationSpeedDampeningObject =
			script:FindFirstChild("ScaleDampeningPercent")
	
		local HumanoidHipHeight = 2
	
		local humanoidSpeed = 0
		local cachedRunningSpeed = 0
		local cachedLocalDirection = { x = 0.0, y = 0.0 }
	
		local smallButNotZero = 0.0001
		local runBlendtime = 0.2
		local lastBlendTime = 0
	
		local WALK_SPEED = 6.4
		local RUN_SPEED = 12.8
	
		local EMOTE_TRANSITION_TIME = 0.1
	
		local currentAnim = ""
		local currentAnimInstance = nil
		local currentAnimTrack = nil
		local currentAnimKeyframeHandler = nil
		local currentAnimSpeed = 1.0
	
		local PreloadedAnims = {}
	
		local animTable = {}
	
		local animNames = {
			idle = {
				{ id = "http://www.roblox.com/asset/?id=12521158637", weight = 9 },
				{ id = "http://www.roblox.com/asset/?id=12521162526", weight = 1 },
			},
	
			walk = {
				{ id = "http://www.roblox.com/asset/?id=12518152696", weight = 10 }
			},
	
			run = {
				{ id = "http://www.roblox.com/asset/?id=12518152696", weight = 10 }
			},
	
			jump = {
				{ id = "http://www.roblox.com/asset/?id=12520880485", weight = 10 }
			},
	
			fall = {
				{ id = "http://www.roblox.com/asset/?id=12520972571", weight = 10 }
			},
	
			climb = {
				{ id = "http://www.roblox.com/asset/?id=12520982150", weight = 10 }
			},
	
			sit = {
				{ id = "http://www.roblox.com/asset/?id=12520993168", weight = 10 }
			},
	
			toolnone = {
				{ id = "http://www.roblox.com/asset/?id=12520996634", weight = 10 }
			},
	
			toolslash = {
				{ id = "http://www.roblox.com/asset/?id=12520999032", weight = 10 }
			},
	
			toollunge = {
				{ id = "http://www.roblox.com/asset/?id=12521002003", weight = 10 }
			},
	
			wave = {
				{ id = "http://www.roblox.com/asset/?id=12521004586", weight = 10 }
			},
	
			point = {
				{ id = "http://www.roblox.com/asset/?id=12521007694", weight = 10 }
			},
	
			dance = {
				{ id = "http://www.roblox.com/asset/?id=12521009666", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=12521151637", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=12521015053", weight = 10 }
			},
	
			dance2 = {
				{ id = "http://www.roblox.com/asset/?id=12521169800", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=12521173533", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=12521027874", weight = 10 }
			},
	
			dance3 = {
				{ id = "http://www.roblox.com/asset/?id=12521178362", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=12521181508", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=12521184133", weight = 10 }
			},
	
			laugh = {
				{ id = "http://www.roblox.com/asset/?id=12521018724", weight = 10 }
			},
	
			cheer = {
				{ id = "http://www.roblox.com/asset/?id=12521021991", weight = 10 }
			},
		}
	
		local emoteNames = {
			wave = false,
			point = false,
			dance = true,
			dance2 = true,
			dance3 = true,
			laugh = false,
			cheer = false
		}
	
		math.randomseed(tick())
	
		local function configureAnimationSet(name, fileList)
			animTable[name] = {
				count = 0,
				totalWeight = 0
			}
	
			for idx, anim in pairs(fileList) do
				animTable[name][idx] = {}
	
				animTable[name][idx].anim = Instance.new("Animation")
				animTable[name][idx].anim.Name = name
				animTable[name][idx].anim.AnimationId = anim.id
				animTable[name][idx].weight = anim.weight
	
				animTable[name].count += 1
				animTable[name].totalWeight += anim.weight
	
				if not PreloadedAnims[anim.id] then
					Humanoid:LoadAnimation(animTable[name][idx].anim)
					PreloadedAnims[anim.id] = true
				end
			end
		end
	
		for name, fileList in pairs(animNames) do
			configureAnimationSet(name, fileList)
		end
	
		local function stopAllAnimations()
			if currentAnimKeyframeHandler then
				currentAnimKeyframeHandler:Disconnect()
			end
	
			if currentAnimTrack then
				currentAnimTrack:Stop()
				currentAnimTrack:Destroy()
				currentAnimTrack = nil
			end
	
			currentAnim = ""
		end
	
		local function setAnimationSpeed(speed)
			if currentAnimTrack and speed ~= currentAnimSpeed then
				currentAnimSpeed = speed
				currentAnimTrack:AdjustSpeed(speed)
			end
		end
	
		local function keyFrameReachedFunc(frameName)
			if frameName == "End" then
				local repeatAnim = currentAnim
	
				if emoteNames[repeatAnim] == false then
					repeatAnim = "idle"
				end
	
				local animSpeed = currentAnimSpeed
	
				playAnimation(repeatAnim, 0.15)
	
				setAnimationSpeed(animSpeed)
			end
		end
	
		local function rollAnimation(animName)
			local roll = math.random(1, animTable[animName].totalWeight)
	
			local idx = 1
	
			while roll > animTable[animName][idx].weight do
				roll -= animTable[animName][idx].weight
				idx += 1
			end
	
			return idx
		end
	
		function playAnimation(animName, transitionTime)
			local idx = rollAnimation(animName)
			local anim = animTable[animName][idx].anim
	
			if anim ~= currentAnimInstance then
				if currentAnimTrack then
					currentAnimTrack:Stop(transitionTime)
					currentAnimTrack:Destroy()
				end
	
				if currentAnimKeyframeHandler then
					currentAnimKeyframeHandler:Disconnect()
				end
	
				currentAnimSpeed = 1
				currentAnim = animName
				currentAnimInstance = anim
	
				currentAnimTrack = Humanoid:LoadAnimation(anim)
				currentAnimTrack.Priority = Enum.AnimationPriority.Core
	
				currentAnimTrack:Play(transitionTime)
	
				currentAnimKeyframeHandler =
					currentAnimTrack.KeyframeReached:Connect(keyFrameReachedFunc)
			end
		end
	
		local jumpAnimTime = 0
		local jumpAnimDuration = 0.31
	
		local function onRunning(speed)
			humanoidSpeed = speed
	
			if speed > 0.75 then
				playAnimation("walk", 0.2)
				pose = "Running"
			else
				if emoteNames[currentAnim] == nil then
					playAnimation("idle", 0.2)
					pose = "Standing"
				end
			end
		end
	
		local function onJumping()
			playAnimation("jump", 0.1)
	
			jumpAnimTime = jumpAnimDuration
			pose = "Jumping"
		end
	
		local function onClimbing(speed)
			playAnimation("climb", 0.1)
	
			setAnimationSpeed(speed / 5)
	
			pose = "Climbing"
		end
	
		local function onFreeFall()
			if jumpAnimTime <= 0 then
				playAnimation("fall", 0.2)
			end
	
			pose = "FreeFall"
		end
	
		local function onSeated()
			playAnimation("sit", 0.5)
	
			pose = "Seated"
		end
	
		local function onDied()
			pose = "Dead"
	
			stopAllAnimations()
	
			defaultAnimate.Disabled = false
		end
	
		Humanoid.Died:Connect(onDied)
		Humanoid.Running:Connect(onRunning)
		Humanoid.Jumping:Connect(onJumping)
		Humanoid.Climbing:Connect(onClimbing)
		Humanoid.FreeFalling:Connect(onFreeFall)
		Humanoid.Seated:Connect(onSeated)
	
		plr.Chatted:Connect(function(msg)
			local emote = ""
	
			if string.sub(msg, 1, 3) == "/e " then
				emote = string.sub(msg, 4)
	
			elseif string.sub(msg, 1, 7) == "/emote " then
				emote = string.sub(msg, 8)
			end
	
			if pose == "Standing" and emoteNames[emote] ~= nil then
				playAnimation(emote, EMOTE_TRANSITION_TIME)
			end
		end)
	
		playAnimation("idle", 0.1)
	
		task.spawn(function()
			while Character.Parent and Humanoid.Health > 0 do
				local _, currentGameTime = task.wait(0.1)
	
				if jumpAnimTime > 0 then
					jumpAnimTime -= 0.1
				end
			end
		end)
	end
	
	button.MouseButton1Click:Connect(function()
		local character = plr.Character or plr.CharacterAdded:Wait()
	
		RunCustomAnimation(character)
	end)
end;
task.spawn(C_d0);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Hampster.LocalScript
local function C_d3()
local script = G2L["d3"];
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local player = Players.LocalPlayer
	local button = script.Parent
	local on, ball, weld, conn, humanoid, root, oldAuto, oldRotate
	local force, attachment
	
	local function toggle()
		on = not on
		if conn then conn:Disconnect() conn = nil end
		if ball then ball:Destroy() ball = nil end
		if not on then
			if humanoid then
				humanoid.PlatformStand = false
				humanoid.AutoRotate = oldAuto
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
			return
		end
	
		local char = player.Character
		root = char and char:FindFirstChild("HumanoidRootPart")
		humanoid = char and char:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then on = false return end
	
		oldAuto, oldRotate = humanoid.AutoRotate, root.CFrame
		ball = Instance.new("Part")
		ball.Name = "HamsterBall"
		ball.Shape = Enum.PartType.Ball
		ball.Size = Vector3.new(6, 6, 6)
		ball.CFrame = root.CFrame
		ball.Material = Enum.Material.SmoothPlastic
		ball.Color = Color3.fromRGB(255, 60, 60)
		ball.Transparency = 0.3
		ball.Anchored = false
		ball.Material = Enum.Material.Marble	
		ball.CanCollide = true
		ball.Massless = false
		ball.Parent = char
	
		attachment = Instance.new("Attachment", ball)
		force = Instance.new("VectorForce", ball)
		force.Attachment0 = attachment
		force.RelativeTo = Enum.ActuatorRelativeTo.World
		force.ApplyAtCenterOfMass = true
	
		weld = Instance.new("WeldConstraint", ball)
		weld.Part0 = ball
		weld.Part1 = root
	
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true
	
		conn = RunService.RenderStepped:Connect(function()
			if not on or not ball.Parent then return end
			local camera = workspace.CurrentCamera
			local move = humanoid.MoveDirection
			local forward = camera.CFrame.LookVector
			local right = camera.CFrame.RightVector
			local direction = Vector3.new(forward.X, 0, forward.Z) * move:Dot(Vector3.new(forward.X, 0, forward.Z).Unit)
				+ Vector3.new(right.X, 0, right.Z) * move:Dot(Vector3.new(right.X, 0, right.Z).Unit)
			if direction.Magnitude > 1 then direction = direction.Unit end
			force.Force = direction * ball.AssemblyMass * 120
			root.CFrame = ball.CFrame
		end)
	end
	
	button.Activated:Connect(toggle)
end;
task.spawn(C_d3);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Freeze.LocalScript
local function C_d6()
local script = G2L["d6"];
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	local player = game:GetService("Players").LocalPlayer
	local enabled = false
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.BackgroundColor3 = enabled and darkerColor or defaultColor
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.Anchored = enabled end
	end)
end;
task.spawn(C_d6);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.No Gravity.Grav
local function C_d8()
local script = G2L["d8"];
	local button = script.Parent
	local defaultColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(
		math.clamp(defaultColor.R * 255 - 30, 0, 255),
		math.clamp(defaultColor.G * 255 - 30, 0, 255),
		math.clamp(defaultColor.B * 255 - 30, 0, 255)
	)
	local enabled = false
	local defaultGravity = workspace.Gravity
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		button.BackgroundColor3 = enabled and darkerColor or defaultColor
		workspace.Gravity = enabled and 0 or defaultGravity
	end)
end;
task.spawn(C_d8);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_3.Coolio.Dash.LocalScript
local function C_da()
local script = G2L["da"];
	script.Parent.Activated:Connect(function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,10,0)
	end)
end;
task.spawn(C_da);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_1.HANDLER
local function C_e1()
local script = G2L["e1"];
	
	local p = game.Players.LocalPlayer
	local ct, cb, bd = nil, nil, {}
	
	local function dark(c)
		return Color3.new(
			math.max(0, c.R - 30 / 255),
			math.max(0, c.G - 30 / 255),
			math.max(0, c.B - 30 / 255)
		)
	end
	
	local function stop()
		if ct then
			ct:Stop()
		end
	
		if cb then
			cb.BackgroundColor3 = bd[cb].oc
		end
	
		ct, cb = nil, nil
	end
	
	local function play(b)
		local d = bd[b]
	
		if cb == b then
			stop()
			return
		end
	
		stop()
	
		local h = p.Character:WaitForChild("Humanoid")
		local a = h:FindFirstChildOfClass("Animator")
	
		if not a then
			a = Instance.new("Animator")
			a.Parent = h
		end
	
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. d.id.Value
	
		print("Loading animation:", anim.AnimationId)
	
		local t = a:LoadAnimation(anim)
	
		t.Priority = Enum.AnimationPriority.Action4
		t:Play()
	
		if d.time then
			t.TimePosition = d.time.Value
		end
	
		if d.speed then
			t:AdjustSpeed(d.speed.Value)
		end
	
		if d.weight then
			t:AdjustWeight(d.weight.Value)
		end
	
		ct, cb = t, b
		b.BackgroundColor3 = dark(d.oc)
	end
	
	for _, b in ipairs(script.Parent:GetDescendants()) do
		if b:IsA("TextButton") then
			local id = b:FindFirstChild("ANIM")
	
			if id then
				bd[b] = {
					id = id,
					time = b:FindFirstChild("TIME"),
					speed = b:FindFirstChild("SPEED"),
					weight = b:FindFirstChild("WEIGHT"),
					oc = b.BackgroundColor3
				}
	
				b.MouseButton1Click:Connect(function()
					play(b)
				end)
			end
		end
	end
	
	
end;
task.spawn(C_e1);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Animations_2.HANDLER
local function C_13e()
local script = G2L["13e"];
	
	local p = game.Players.LocalPlayer
	local ct, cb, bd = nil, nil, {}
	
	local function dark(c)
		return Color3.new(
			math.max(0, c.R - 30 / 255),
			math.max(0, c.G - 30 / 255),
			math.max(0, c.B - 30 / 255)
		)
	end
	
	local function stop()
		if ct then
			ct:Stop()
		end
	
		if cb then
			cb.BackgroundColor3 = bd[cb].oc
		end
	
		ct, cb = nil, nil
	end
	
	local function play(b)
		local d = bd[b]
	
		if cb == b then
			stop()
			return
		end
	
		stop()
	
		local h = p.Character:WaitForChild("Humanoid")
		local a = h:FindFirstChildOfClass("Animator")
	
		if not a then
			a = Instance.new("Animator")
			a.Parent = h
		end
	
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. d.id.Value
	
		print("Loading animation:", anim.AnimationId)
	
		local t = a:LoadAnimation(anim)
	
		t.Priority = Enum.AnimationPriority.Action4
		t:Play()
	
		if d.time then
			t.TimePosition = d.time.Value
		end
	
		if d.speed then
			t:AdjustSpeed(d.speed.Value)
		end
	
		if d.weight then
			t:AdjustWeight(d.weight.Value)
		end
	
		ct, cb = t, b
		b.BackgroundColor3 = dark(d.oc)
	end
	
	for _, b in ipairs(script.Parent:GetDescendants()) do
		if b:IsA("TextButton") then
			local id = b:FindFirstChild("ANIM")
	
			if id then
				bd[b] = {
					id = id,
					time = b:FindFirstChild("TIME"),
					speed = b:FindFirstChild("SPEED"),
					weight = b:FindFirstChild("WEIGHT"),
					oc = b.BackgroundColor3
				}
	
				b.MouseButton1Click:Connect(function()
					play(b)
				end)
			end
		end
	end
	
	
end;
task.spawn(C_13e);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.ak47.LocalScript
local function C_1a3()
local script = G2L["1a3"];
	
	local button = script.Parent
	
	
	local function createGrip(x, y, z, rx, ry, rz)
		return CFrame.new(x, y, z) * CFrame.fromOrientation(math.rad(rx), math.rad(ry), math.rad(rz))
	end
	
	local gripPoses = {
		createGrip(0.517, 0.058, 0.000, -21.4, 90.0, -0.0),
		createGrip(0.941, 0.058, 0.000, -21.4, 90.0, -0.0),
		createGrip(0.315, 1.267, -0.000, -36.0, 90.0, -0.0),
		createGrip(0.680, 1.267, -0.000, -36.0, 90.0, -0.0),
		createGrip(0.238, 1.768, -0.000, -47.8, 90.0, -0.0),
		createGrip(0.168, 1.676, -0.000, -39.9, 90.0, -0.0),
		createGrip(-0.802, -1.296, 0.000, 87.3, 90.0, 0.0),
		createGrip(-1.232, -1.296, 0.000, 87.3, 90.0, 0.0),
		createGrip(-1.232, -2.567, 0.000, 87.3, 90.0, 0.0),
		createGrip(-0.838, -2.567, 0.000, 87.3, 90.0, 0.0),
		createGrip(-0.838, -3.876, 0.000, 87.3, 90.0, 0.0),
		createGrip(-0.838, -5.173, 0.000, 87.3, 90.0, 0.0),
		createGrip(-0.838, -6.539, 0.000, 87.3, 90.0, 0.0),
		createGrip(-1.583, -3.641, 0.000, 85.3, -90.0, 180.0),
		createGrip(-1.583, -4.978, 0.000, 85.3, -90.0, 180.0),
		createGrip(-1.210, 0.033, 0.000, 87.8, 90.0, 0.0),
		createGrip(-0.821, 0.033, 0.000, 87.8, 90.0, 0.0),
		createGrip(-0.821, 1.348, 0.000, 87.8, 90.0, 0.0),
		createGrip(-1.322, 1.024, 0.000, 74.7, 90.0, 0.0),
		createGrip(-1.322, 2.361, 0.000, 74.7, 90.0, 0.0),
		createGrip(-1.322, 3.690, 0.000, 74.7, 90.0, 0.0),
		createGrip(-1.322, 4.322, 0.031, 74.7, 90.0, 0.0),
		createGrip(-1.240, 4.516, 0.031, 82.0, 90.0, 0.0),
		createGrip(-0.859, 3.324, 0.031, 87.1, 90.0, 0.0),
		createGrip(-0.859, 2.055, 0.031, 87.1, 90.0, 0.0),
		createGrip(-1.339, -0.130, 0.031, 26.1, 90.0, 0.0),
		createGrip(-1.403, 0.700, 0.031, 21.3, 90.0, 0.0),
	}
	
	button.MouseButton1Click:Connect(function()
		local localPlayer = game.Players.LocalPlayer
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	
		if not character or not humanoid or not backpack then return end
	
		humanoid:UnequipTools()
	
		local tools = {}
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(tools, item)
			end
		end
	
		table.sort(tools, function(toolA, toolB)
			return toolA.Name:lower() < toolB.Name:lower()
		end)
	
		local toolsToProcess = math.min(#gripPoses, #tools)
		for i = 1, toolsToProcess do
			local tool = tools[i]
			tool.Grip = gripPoses[i]
			tool.Parent = character
		end
	end)
	
end;
task.spawn(C_1a3);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.shotgun.LocalScript
local function C_1a5()
local script = G2L["1a5"];
	
	local button = script.Parent
	
	
	local function createGrip(x, y, z, rx, ry, rz)
		return CFrame.new(x, y, z) * CFrame.fromOrientation(math.rad(rx), math.rad(ry), math.rad(rz))
	end
	
	local gripPoses = {
		createGrip(3.600, -2.939, 0.000, -66.3, -90.0, 0.0), 
		createGrip(3.829, -2.078, 0.000, -66.3, -90.0, 0.0), 
		createGrip(1.040, -2.939, 0.000, -66.3, -90.0, 0.0), 
		createGrip(1.238, -2.078, 0.000, -66.3, -90.0, 0.0), 
		createGrip(1.231, -2.109, 0.000, -0.2, -90.0, 0.0), 
		createGrip(3.462, 0.889, 0.000, 52.4, -90.0, 0.0), 
		createGrip(3.047, -3.539, 0.000, -0.9, -90.0, 0.0), 
		createGrip(1.993, -4.507, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-0.651, -4.507, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-3.272, -4.507, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-1.478, -2.146, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-4.111, -2.146, 0.000, -0.9, -90.0, 0.0), 
		createGrip(0.352, -3.338, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-2.139, -3.338, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-4.702, -3.338, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-6.741, -2.144, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-9.300, -2.144, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-11.899, -2.144, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-14.613, -2.144, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-17.318, -2.144, 0.000, -0.9, -90.0, 0.0), 
		createGrip(-16.634, 4.554, 0.000, -22.6, -90.0, 0.0), 
		createGrip(-8.647, -5.675, 0.000, 21.6, -90.0, 0.0), 
		createGrip(-12.119, -1.801, -0.033, 0.2, -90.0, 0.0), 
		createGrip(-14.763, -1.801, -0.033, 0.2, -90.0, 0.0), 
		createGrip(8.663, 3.666, -0.033, -0.2, 90.0, 180.0), 
		createGrip(11.351, 3.666, -0.033, -0.2, 90.0, 180.0), 
		createGrip(13.998, 3.666, -0.033, -0.2, 90.0, 180.0), 
		createGrip(16.688, 3.666, -0.033, -0.2, 90.0, 180.0), 
		createGrip(18.704, 3.666, -0.033, -0.2, 90.0, 180.0), 
		createGrip(-6.674, -3.465, -0.033, 0.2, -90.0, 0.0), 
		createGrip(5.333, 4.709, -0.033, -8.3, 90.0, 180.0), 
		createGrip(-1.779, 0.449, -0.033, -45.4, -90.0, 0.0), 
		createGrip(0.288, -0.040, -0.033, 1.4, -90.0, 0.0), 
	}
	
	button.MouseButton1Click:Connect(function()
		local localPlayer = game.Players.LocalPlayer
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		
		if not character or not humanoid or not backpack then return end
	
		humanoid:UnequipTools()
	
		local tools = {}
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(tools, item)
			end
		end
	
		table.sort(tools, function(toolA, toolB)
			return toolA.Name:lower() < toolB.Name:lower()
		end)
	
		local toolsToProcess = math.min(#gripPoses, #tools)
		for i = 1, toolsToProcess do
			local tool = tools[i]
			tool.Grip = gripPoses[i]
			tool.Parent = character
		end
	end)
	
end;
task.spawn(C_1a5);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.sphere.LocalScript
local function C_1a7()
local script = G2L["1a7"];
	local button = script.Parent
	
	local function generateSpherePositions(n, radius)
		local positions = {}
		local phi = math.pi * (3 - math.sqrt(5))
	
		for i = 0, n - 1 do
			local y = 1 - (i / (n - 1)) * 2
			local r = math.sqrt(1 - y * y)
			local theta = phi * i
	
			local x = math.cos(theta) * r
			local z = math.sin(theta) * r
	
			table.insert(positions, Vector3.new(x, y, z) * radius)
		end
	
		return positions
	end
	
	button.MouseButton1Click:Connect(function()
		local localPlayer = game.Players.LocalPlayer
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	
		if not character or not humanoid or not backpack then return end
	
		humanoid:UnequipTools()
	
		local tools = {}
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(tools, item)
			end
		end
	
		table.sort(tools, function(toolA, toolB)
			return toolA.Name:lower() < toolB.Name:lower()
		end)
	
		local baseRadius = 0
		local radius = baseRadius + (#tools / 50) * 10
	
		local torsoOffset = Vector3.new(-2, 0, 2)
		local offsets = generateSpherePositions(#tools, radius)
	
		for i = 1, #tools do
			local tool = tools[i]
			local offset = offsets[i] or Vector3.new(0, 0, 0)
	
			local lookCFrame = CFrame.lookAt(offset, Vector3.new(0, 0, 0))
			local alignedCFrame = lookCFrame * CFrame.Angles(math.rad(-90), math.rad(180), 0)
	
			tool.Grip = (alignedCFrame + offset + torsoOffset):Inverse()
			tool.Parent = character
		end
	end)
	
end;
task.spawn(C_1a7);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.BFG.LocalScript
local function C_1a9()
local script = G2L["1a9"];
	
	local button = script.Parent
	
	
	local function createGrip(x, y, z, rx, ry, rz)
		return CFrame.new(x, y, z) * CFrame.fromOrientation(math.rad(rx), math.rad(ry), math.rad(rz))
	end
	
	
	local gripPoses = {
		createGrip(-5.112, 6.242, 0.000, 17.4, 90.0, 0.0),
		createGrip(-4.491, 6.242, 0.000, 17.4, 90.0, 0.0),
		createGrip(-3.836, 6.242, 0.000, 17.4, 90.0, 0.0),
		createGrip(-3.276, 6.242, 0.000, 17.4, 90.0, 0.0),
		createGrip(-1.995, 5.507, 0.000, 29.7, 90.0, 0.0),
		createGrip(-2.635, 5.507, 0.000, 29.7, 90.0, 0.0),
		createGrip(-3.144, 5.507, 0.000, 29.7, 90.0, 0.0),
		createGrip(-3.620, 5.507, 0.000, 29.7, 90.0, 0.0),
		createGrip(-3.620, 4.136, 0.000, 29.7, 90.0, 0.0),
		createGrip(-3.620, 2.846, 0.000, 29.7, 90.0, 0.0),
		createGrip(-3.620, 1.530, 0.000, 29.7, 90.0, 0.0),
		createGrip(-3.186, 4.168, 0.000, 29.7, 90.0, 0.0),
		createGrip(-3.186, 2.831, 0.000, 29.7, 90.0, 0.0),
		createGrip(-3.186, 1.525, 0.000, 29.7, 90.0, 0.0),
		createGrip(-2.619, 4.164, 0.000, 29.7, 90.0, 0.0),
		createGrip(-2.619, 2.848, 0.000, 29.7, 90.0, 0.0),
		createGrip(-2.619, 1.529, 0.000, 29.7, 90.0, 0.0),
		createGrip(-2.011, 1.529, 0.000, 29.7, 90.0, 0.0),
		createGrip(-2.012, 2.816, 0.000, 29.7, 90.0, 0.0),
		createGrip(-1.997, 4.128, 0.000, 29.7, 90.0, 0.0),
		createGrip(-2.011, 0.222, 0.000, 29.7, 90.0, 0.0),
		createGrip(-1.494, 0.650, 0.000, 79.8, 90.0, 0.0),
		createGrip(-1.483, -0.475, 0.000, 88.6, 90.0, 0.0),
		createGrip(-1.717, -0.503, 0.000, 54.2, -90.0, 180.0),
		createGrip(2.043, 0.122, 0.000, -8.2, 90.0, -0.0),
		createGrip(2.707, 0.122, 0.000, -8.2, 90.0, -0.0),
		createGrip(3.325, 0.122, 0.000, -8.2, 90.0, -0.0),
		createGrip(3.988, 0.122, 0.000, -8.2, 90.0, -0.0),
		createGrip(4.652, 0.122, 0.000, -8.2, 90.0, -0.0),
		createGrip(5.241, 0.122, 0.000, -8.2, 90.0, -0.0),
		createGrip(5.527, -0.758, -0.000, 0.8, 90.0, 0.0),
		createGrip(5.527, -2.083, -0.000, 0.8, 90.0, 0.0),
		createGrip(2.303, -6.422, -0.000, 43.9, 90.0, 0.0),
		createGrip(6.471, -3.917, -0.000, -0.7, 90.0, -0.0),
		createGrip(6.471, -5.237, -0.000, -0.7, 90.0, -0.0),
		createGrip(8.276, 1.908, -0.000, -60.2, 90.0, -0.0),
		createGrip(-2.590, -3.488, -0.000, -31.0, 90.0, -0.0),
		createGrip(-0.322, -5.433, -0.000, -60.4, 90.0, -0.0),
		createGrip(-5.396, -3.441, -0.000, -1.8, 90.0, -0.0),
		createGrip(-5.396, -4.788, -0.000, -1.8, 90.0, -0.0),
		createGrip(-7.499, -2.012, -0.000, 33.2, 90.0, 0.0),
		createGrip(-6.781, 2.262, 0.000, 89.3, -90.0, 180.0),
		createGrip(-6.781, 0.920, 0.000, 89.3, -90.0, 180.0),
		createGrip(-6.781, -0.372, 0.000, 89.3, -90.0, 180.0),
		createGrip(-6.781, -1.673, 0.000, 89.3, -90.0, 180.0),
		createGrip(-6.781, -2.996, 0.000, 89.3, -90.0, 180.0),
		createGrip(-6.898, -4.048, -0.000, 86.8, -90.0, 180.0),
		createGrip(-7.713, -3.231, -0.000, 72.9, -90.0, 180.0),
		createGrip(-7.727, 0.817, -0.000, 62.8, 90.0, 0.0),
		createGrip(-7.103, 2.337, -0.000, 83.6, 90.0, 0.0),
		createGrip(-3.410, -7.684, -0.000, 0.2, 90.0, 0.0),
		createGrip(-2.798, -7.684, -0.000, 0.2, 90.0, 0.0),
		createGrip(-2.179, -7.684, -0.000, 0.2, 90.0, 0.0),
		createGrip(-1.669, -7.684, -0.000, 0.2, 90.0, 0.0),
		createGrip(-1.669, -8.798, -0.000, 0.2, 90.0, 0.0),
		createGrip(-2.190, -8.798, -0.000, 0.2, 90.0, 0.0),
		createGrip(-2.788, -8.798, -0.000, 0.2, 90.0, 0.0),
		createGrip(-5.653, -7.387, -0.000, 16.8, 90.0, 0.0),
		createGrip(-5.653, -6.106, -0.000, 16.8, 90.0, 0.0),
		createGrip(-9.049, 1.706, -0.000, 83.1, -90.0, 180.0),
		createGrip(-8.739, 0.365, -0.000, 88.0, 90.0, 0.0),
		createGrip(-8.739, -0.987, -0.000, 88.0, 90.0, 0.0),
		createGrip(-8.739, -2.277, -0.000, 88.0, 90.0, 0.0),
		createGrip(-8.739, -3.659, -0.000, 88.0, 90.0, 0.0),
		createGrip(-9.009, -4.255, -0.000, 87.3, -90.0, 180.0),
		createGrip(-9.641, 2.524, -0.000, 40.5, -90.0, 180.0),
		createGrip(-6.608, 6.542, -0.000, 5.1, -90.0, 180.0),
		createGrip(-8.127, 3.415, -0.000, 22.2, -90.0, 180.0),
		createGrip(-0.927, 8.704, -0.000, -32.6, -90.0, -180.0),
		createGrip(4.892, -1.969, -0.000, 0.0, 90.0, 0.0),
		createGrip(4.307, -1.969, -0.000, 0.0, 90.0, 0.0),
		createGrip(3.692, -1.965, -0.000, 0.0, 90.0, 0.0),
		createGrip(3.056, -1.965, -0.000, 0.0, 90.0, 0.0),
		createGrip(2.508, -1.965, -0.000, 0.0, 90.0, 0.0),
		createGrip(1.911, -1.965, -0.000, 0.0, 90.0, 0.0),
		createGrip(1.911, -3.279, -0.000, 0.0, 90.0, 0.0),
		createGrip(1.911, -4.576, -0.000, 0.0, 90.0, 0.0),
		createGrip(1.911, -5.488, -0.000, 0.0, 90.0, 0.0),
		createGrip(1.911, -6.274, -0.000, 0.0, 90.0, 0.0),
		createGrip(2.499, -3.269, -0.000, 0.0, 90.0, 0.0),
		createGrip(2.499, -4.543, -0.000, 0.0, 90.0, 0.0),
		createGrip(2.499, -5.921, -0.000, 0.0, 90.0, 0.0),
		createGrip(3.037, -3.287, -0.000, 0.0, 90.0, 0.0),
		createGrip(3.037, -4.598, -0.000, 0.0, 90.0, 0.0),
		createGrip(3.037, -5.921, -0.000, 0.0, 90.0, 0.0),
		createGrip(3.695, -3.243, -0.000, 0.0, 90.0, 0.0),
		createGrip(3.695, -4.564, -0.000, 0.0, 90.0, 0.0),
		createGrip(3.695, -5.892, -0.000, 0.0, 90.0, 0.0),
		createGrip(4.279, -3.267, -0.000, 0.0, 90.0, 0.0),
		createGrip(4.278, -4.557, -0.000, 0.0, 90.0, 0.0),
		createGrip(4.278, -5.899, -0.000, 0.0, 90.0, 0.0),
		createGrip(4.872, -5.899, -0.000, 0.0, 90.0, 0.0),
		createGrip(4.872, -4.604, -0.000, 0.0, 90.0, 0.0),
		createGrip(4.872, -3.308, -0.000, 0.0, 90.0, 0.0),
		createGrip(5.421, -3.308, -0.000, 0.0, 90.0, 0.0),
		createGrip(5.421, -4.636, -0.000, 0.0, 90.0, 0.0),
		createGrip(5.421, -5.997, -0.000, 0.0, 90.0, 0.0),
		createGrip(5.998, -5.997, -0.000, 0.0, 90.0, 0.0),
		createGrip(5.998, -4.675, -0.000, 0.0, 90.0, 0.0),
		createGrip(5.998, -3.765, -0.000, 0.0, 90.0, 0.0),
		createGrip(1.307, -2.124, -0.000, 0.0, 90.0, 0.0),
		createGrip(1.307, -3.431, -0.000, 0.0, 90.0, 0.0),
		createGrip(1.307, -4.684, -0.000, 0.0, 90.0, 0.0),
		createGrip(1.307, -5.976, -0.000, 0.0, 90.0, 0.0),
		createGrip(0.652, -2.510, -0.000, 0.0, 90.0, 0.0),
		createGrip(0.011, -2.510, -0.000, 0.0, 90.0, 0.0),
		createGrip(-0.649, -2.510, -0.000, 0.0, 90.0, 0.0),
		createGrip(-1.209, -2.510, -0.000, 0.0, 90.0, 0.0),
		createGrip(0.643, -3.830, -0.000, 0.0, 90.0, 0.0),
		createGrip(0.643, -5.167, -0.000, 0.0, 90.0, 0.0),
		createGrip(0.643, -6.125, 0.028, 0.0, 90.0, 0.0),
		createGrip(1.914, -5.535, -0.005, 0.0, 90.0, 0.0),
		createGrip(0.004, -3.839, -0.005, 0.0, 90.0, 0.0),
		createGrip(0.004, -5.113, -0.005, 0.0, 90.0, 0.0),
		createGrip(4.738, -4.378, -0.005, -47.1, 90.0, -0.0),
		createGrip(4.291, -4.490, -0.005, -47.1, 90.0, -0.0),
		createGrip(-0.625, -3.789, -0.005, 0.0, 90.0, 0.0),
		createGrip(-0.625, -5.120, -0.005, 0.0, 90.0, 0.0),
		createGrip(-1.238, -3.866, -0.005, 0.0, 90.0, 0.0),
		createGrip(-1.238, -5.187, -0.005, 0.0, 90.0, 0.0),
		createGrip(4.672, -4.129, -0.005, -58.5, 90.0, -0.0),
		createGrip(4.268, -4.648, -0.005, -58.5, 90.0, -0.0),
		createGrip(3.834, -6.280, -0.005, -58.5, 90.0, -0.0),
		createGrip(3.834, -4.968, -0.005, -58.5, 90.0, -0.0),
		createGrip(-1.924, -2.065, -0.005, 0.0, 90.0, 0.0),
		createGrip(-2.421, -1.388, -0.005, 0.0, 90.0, 0.0),
		createGrip(-3.002, -1.388, -0.005, 0.0, 90.0, 0.0),
		createGrip(-3.518, -1.832, -0.005, 0.0, 90.0, 0.0),
		createGrip(-4.068, -2.760, -0.005, 0.0, 90.0, 0.0),
		createGrip(-4.563, -3.139, -0.005, 0.0, 90.0, 0.0),
		createGrip(-4.983, -3.417, -0.005, 0.0, 90.0, 0.0),
		createGrip(-4.983, -4.719, -0.005, 0.0, 90.0, 0.0),
		createGrip(-4.576, -4.490, -0.005, 0.0, 90.0, 0.0),
		createGrip(-4.075, -4.091, -0.005, 0.0, 90.0, 0.0),
		createGrip(-4.075, -5.421, -0.005, 0.0, 90.0, 0.0),
		createGrip(-3.509, -3.152, -0.005, 0.0, 90.0, 0.0),
		createGrip(-3.509, -4.470, -0.005, 0.0, 90.0, 0.0),
		createGrip(-3.509, -5.781, -0.005, 0.0, 90.0, 0.0),
		createGrip(-2.991, -2.683, -0.005, 0.0, 90.0, 0.0),
		createGrip(-2.991, -4.022, -0.005, 0.0, 90.0, 0.0),
		createGrip(-2.991, -5.310, -0.005, 0.0, 90.0, 0.0),
		createGrip(-2.435, -2.714, -0.005, 0.0, 90.0, 0.0),
		createGrip(-2.435, -4.042, -0.005, 0.0, 90.0, 0.0),
		createGrip(-2.435, -5.364, -0.005, 0.0, 90.0, 0.0),
		createGrip(-1.892, -3.403, -0.005, 0.0, 90.0, 0.0),
		createGrip(-1.892, -4.697, -0.005, 0.0, 90.0, 0.0),
		createGrip(-6.853, -2.804, -0.005, 28.5, 90.0, 0.0),
		createGrip(3.850, -6.531, 0.000, -90.0, 90.0, 0.0),
		createGrip(5.153, -6.531, 0.000, -90.0, 90.0, 0.0),
		createGrip(5.153, -7.859, 0.000, -90.0, 90.0, 0.0),
		createGrip(5.153, -9.243, 0.000, -90.0, 90.0, 0.0),
		createGrip(5.153, -10.577, 0.000, -90.0, 90.0, 0.0),
		createGrip(5.153, -11.934, 0.000, -90.0, 90.0, 0.0),
		createGrip(5.153, -13.214, 0.000, -90.0, 90.0, 0.0),
		createGrip(5.153, -14.533, 0.000, -90.0, 90.0, 0.0),
		createGrip(5.153, -15.841, 0.000, -90.0, 90.0, 0.0),
		createGrip(-5.153, 16.577, 0.000, 90.0, 90.0, 0.0),
		createGrip(4.464, -6.572, 0.000, -90.0, 90.0, 0.0),
		createGrip(4.464, -7.920, 0.000, -90.0, 90.0, 0.0),
		createGrip(4.464, -9.222, 0.000, -90.0, 90.0, 0.0),
		createGrip(4.464, -10.569, 0.000, -90.0, 90.0, 0.0),
		createGrip(4.464, -11.907, 0.000, -90.0, 90.0, 0.0),
		createGrip(4.464, -13.182, 0.000, -90.0, 90.0, 0.0),
		createGrip(4.464, -14.549, 0.000, -90.0, 90.0, 0.0),
		createGrip(4.464, -15.861, 0.000, -90.0, 90.0, 0.0),
		createGrip(-4.661, 16.494, 0.000, 89.3, 90.0, 0.0),
		createGrip(3.815, -7.934, 0.000, -89.8, 90.0, -0.0),
		createGrip(3.815, -9.249, 0.000, -89.8, 90.0, -0.0),
		createGrip(3.815, -10.576, 0.000, -89.8, 90.0, -0.0),
		createGrip(3.815, -11.897, 0.000, -89.8, 90.0, -0.0),
		createGrip(3.815, -13.257, 0.000, -89.8, 90.0, -0.0),
		createGrip(3.815, -14.562, 0.000, -89.8, 90.0, -0.0),
		createGrip(3.815, -15.864, 0.000, -89.8, 90.0, -0.0),
		createGrip(-3.815, 16.554, 0.000, 89.8, -90.0, 180.0),
		createGrip(-4.763, 16.115, -0.000, 85.0, 90.0, 0.0),
		createGrip(-4.239, 16.115, -0.000, 85.0, 90.0, 0.0),
		createGrip(-3.807, 16.115, -0.000, 85.0, 90.0, 0.0),
		createGrip(-3.333, 16.115, -0.000, 85.0, 90.0, 0.0),
		createGrip(-2.911, 16.115, -0.000, 85.0, 90.0, 0.0),
		createGrip(-2.432, 16.115, -0.000, 85.0, 90.0, 0.0),
		createGrip(-1.900, 16.115, -0.000, 85.0, 90.0, 0.0),
		createGrip(-1.295, 16.115, -0.000, 85.0, 90.0, 0.0),
		createGrip(-0.792, 16.115, -0.000, 85.0, 90.0, 0.0),
		createGrip(-0.361, 16.115, -0.000, 85.0, 90.0, 0.0),
		createGrip(-11.383, 11.831, -0.000, 38.5, 90.0, 0.0),
		createGrip(-11.383, 10.452, -0.000, 38.5, 90.0, 0.0),
		createGrip(-16.622, 0.971, -0.000, -1.9, 90.0, -0.0),
		createGrip(-11.332, 9.156, -0.000, 38.9, 90.0, 0.0),
		createGrip(-8.458, 10.033, -0.000, 50.0, 90.0, 0.0),
		createGrip(-8.458, 8.782, -0.000, 50.0, 90.0, 0.0),
		createGrip(-1.667, 10.966, -0.000, 87.8, 90.0, 0.0),
		createGrip(-1.667, 9.679, -0.000, 87.8, 90.0, 0.0),
		createGrip(-9.291, -1.097, -0.000, 4.7, 90.0, 0.0),
		createGrip(10.644, 8.904, -0.000, 39.2, -90.0, 180.0),
		createGrip(-0.427, 14.916, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.014, 14.916, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.014, 13.577, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.014, 12.231, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.510, 14.936, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.510, 13.619, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.510, 12.305, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.510, 10.961, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.510, 9.818, 0.016, 90.0, 90.0, 0.0),
		createGrip(-1.913, 15.028, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.913, 13.719, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.913, 12.406, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.913, 11.117, -0.000, 90.0, 90.0, 0.0),
		createGrip(-1.913, 9.833, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.364, 15.060, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.364, 13.723, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.364, 12.428, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.364, 11.144, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.364, 9.813, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.792, 15.092, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.792, 13.763, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.792, 12.442, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.792, 11.164, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.792, 9.842, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.329, 15.154, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.329, 13.774, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.329, 12.434, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.329, 11.084, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.329, 9.793, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.329, 8.444, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.827, 8.444, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.490, -7.131, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.120, -7.131, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.721, -7.131, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.384, -7.131, -0.000, 90.0, 90.0, 0.0),
		createGrip(-6.018, -7.131, -0.000, 90.0, 90.0, 0.0),
		createGrip(6.404, 8.448, -0.000, -90.0, 90.0, 0.0),
		createGrip(5.775, 8.448, -0.000, -90.0, 90.0, 0.0),
		createGrip(5.251, 8.448, -0.000, -90.0, 90.0, 0.0),
		createGrip(4.726, 8.448, -0.000, -90.0, 90.0, 0.0),
		createGrip(4.179, 8.448, -0.000, -90.0, 90.0, 0.0),
		createGrip(3.646, 8.448, -0.000, -90.0, 90.0, 0.0),
		createGrip(3.168, 8.448, -0.000, -90.0, 90.0, 0.0),
		createGrip(2.752, 8.448, -0.000, -90.0, 90.0, 0.0),
		createGrip(-2.752, -10.164, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.246, -10.164, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.740, -10.164, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.314, -10.164, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.810, -10.164, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.335, -10.164, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.764, -10.164, -0.000, 90.0, 90.0, 0.0),
		createGrip(-6.317, -10.164, -0.000, 90.0, 90.0, 0.0),
		createGrip(-6.317, -11.466, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.825, -11.489, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.272, -11.489, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.795, -11.542, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.285, -11.542, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.713, -11.542, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.297, -11.542, -0.000, 90.0, 90.0, 0.0),
		createGrip(-2.943, -11.542, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.062, -12.903, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.062, -14.223, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.062, -15.531, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.697, -12.856, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.697, -14.172, -0.000, 90.0, 90.0, 0.0),
		createGrip(-3.697, -15.486, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.369, -12.859, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.369, -14.203, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.369, -15.516, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.369, -16.834, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.768, -12.831, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.768, -14.143, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.768, -15.486, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.768, -16.795, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.318, -12.828, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.318, -14.160, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.318, -15.419, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.318, -16.744, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.876, -12.787, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.876, -14.118, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.876, -15.404, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.876, -16.678, -0.000, 90.0, 90.0, 0.0),
		createGrip(-6.279, -12.818, -0.000, 90.0, 90.0, 0.0),
		createGrip(-6.279, -14.073, -0.000, 90.0, 90.0, 0.0),
		createGrip(-6.279, -15.455, -0.000, 90.0, 90.0, 0.0),
		createGrip(10.629, -13.943, -0.000, 41.7, 90.0, 0.0),
		createGrip(10.033, -13.748, -0.000, 41.7, 90.0, 0.0),
		createGrip(9.515, -13.745, -0.000, 41.7, 90.0, 0.0),
		createGrip(-4.620, -18.109, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.159, -18.126, -0.000, 90.0, 90.0, 0.0),
		createGrip(-5.208, -18.126, -0.000, 90.0, 90.0, 0.0),
		createGrip(-11.020, -15.293, -0.000, 71.3, -90.0, 180.0),
		createGrip(-11.020, -13.899, -0.000, 71.3, -90.0, 180.0),
		createGrip(-6.108, -19.036, -0.000, 86.9, -90.0, 180.0),
		createGrip(-0.931, -19.826, -0.000, 80.3, 90.0, -0.0),
		createGrip(-4.621, -19.583, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.621, -20.938, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.621, -22.203, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.621, -23.578, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.621, -24.813, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.621, -26.110, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.621, -27.467, -0.000, 90.0, 90.0, 0.0),
		createGrip(-4.912, -29.010, -0.000, 88.9, -90.0, 180.0),
		createGrip(-4.912, -28.217, -0.000, 88.9, -90.0, 180.0),
		createGrip(-5.326, -28.217, -0.000, 88.9, -90.0, 180.0),
		createGrip(-5.326, -29.075, -0.000, 88.9, -90.0, 180.0),
		createGrip(-2.146, -0.257, 0.065, 1.8, -90.0, 180.0),
		createGrip(-2.641, -0.257, 0.065, 1.8, -90.0, 180.0),
		createGrip(-3.156, -0.257, 0.065, 1.8, -90.0, 180.0),
		createGrip(-3.771, -0.143, 0.065, 1.8, -90.0, 180.0),
		createGrip(-4.402, -0.018, 0.065, 1.8, -90.0, 180.0),
		createGrip(-5.105, 0.275, 0.065, -1.5, -90.0, -180.0),
		createGrip(4.961, 1.743, 0.003, -7.3, 90.0, -0.0),
		createGrip(4.453, 1.743, 0.003, -7.3, 90.0, -0.0),
		createGrip(3.858, 1.743, 0.003, -7.3, 90.0, -0.0),
		createGrip(3.280, 1.743, 0.003, -7.3, 90.0, -0.0),
		createGrip(2.775, 1.743, 0.003, -7.3, 90.0, -0.0),
		createGrip(2.248, 1.743, 0.003, -7.3, 90.0, -0.0),
		createGrip(1.968, 1.743, 0.003, -7.3, 90.0, -0.0),
		createGrip(1.968, 3.098, 0.003, -7.3, 90.0, -0.0),
		createGrip(2.444, 3.098, 0.003, -7.3, 90.0, -0.0),
		createGrip(2.928, 3.098, 0.003, -7.3, 90.0, -0.0),
		createGrip(3.250, 3.098, 0.003, -7.3, 90.0, -0.0),
		createGrip(3.847, 3.098, 0.003, -7.3, 90.0, -0.0),
		createGrip(4.362, 3.098, 0.003, -7.3, 90.0, -0.0),
		createGrip(4.904, 3.098, 0.003, -7.3, 90.0, -0.0),
		createGrip(3.293, 8.413, 0.003, -21.2, 90.0, -0.0),
		createGrip(2.587, 8.413, 0.003, -21.2, 90.0, -0.0),
		createGrip(2.587, 8.413, 0.003, -21.2, 90.0, -0.0),
		createGrip(2.029, 8.413, 0.003, -21.2, 90.0, -0.0),
		createGrip(1.421, 8.413, 0.003, -21.2, 90.0, -0.0),
		createGrip(0.799, 8.413, 0.003, -21.2, 90.0, -0.0),
		createGrip(0.293, 8.402, 0.003, -21.2, 90.0, -0.0),
		createGrip(1.112, 6.919, 0.003, -14.9, 90.0, -0.0),
		createGrip(1.681, 6.919, 0.003, -14.9, 90.0, -0.0),
		createGrip(2.237, 6.919, 0.003, -14.9, 90.0, -0.0),
		createGrip(2.871, 6.919, 0.003, -14.9, 90.0, -0.0),
		createGrip(3.353, 6.919, 0.003, -14.9, 90.0, -0.0),
		createGrip(4.037, 6.760, 0.003, -14.9, 90.0, -0.0),
		createGrip(5.033, 4.929, 0.003, -5.0, 90.0, -0.0),
		createGrip(4.463, 4.986, 0.003, -5.0, 90.0, -0.0),
		createGrip(4.039, 4.986, 0.003, -5.0, 90.0, -0.0),
		createGrip(3.529, 5.099, 0.003, -5.0, 90.0, -0.0),
		createGrip(2.977, 5.233, 0.003, -5.0, 90.0, -0.0),
		createGrip(2.454, 5.419, 0.003, -5.0, 90.0, -0.0),
		createGrip(2.193, 5.421, 0.003, -5.0, 90.0, -0.0),
		createGrip(2.193, 4.066, 0.003, -5.0, 90.0, -0.0),
		createGrip(2.820, 3.899, 0.003, -5.0, 90.0, -0.0),
		createGrip(3.481, 3.867, 0.003, -5.0, 90.0, -0.0),
		createGrip(4.039, 3.705, 0.003, -5.0, 90.0, -0.0),
		createGrip(4.416, 3.705, 0.003, -5.0, 90.0, -0.0),
		createGrip(4.987, 3.705, 0.003, -5.0, 90.0, -0.0),
		createGrip(12.238, -14.741, 0.003, 30.3, 90.0, 0.0),
		createGrip(12.238, -15.949, 0.003, 30.3, 90.0, 0.0),
		createGrip(12.238, -17.123, 0.003, 30.3, 90.0, 0.0),
		createGrip(19.809, -8.621, 0.003, 0.7, 90.0, 0.0),
		createGrip(19.809, -7.340, 0.003, 0.7, 90.0, 0.0),
		createGrip(19.809, -6.158, 0.003, 0.7, 90.0, 0.0),
		createGrip(0.908, 1.809, 0.003, 89.9, -90.0, 180.0),
		createGrip(0.908, 0.548, 0.003, 89.9, -90.0, 180.0),
		createGrip(0.908, -0.743, 0.003, 89.9, -90.0, 180.0),
		createGrip(1.480, -0.857, 0.003, 44.9, 90.0, 0.0),
		createGrip(-1.062, -0.672, 0.003, 37.2, 90.0, 0.0),
		createGrip(-0.470, -0.674, 0.003, -24.4, 90.0, -0.0),
	}
	
	button.MouseButton1Click:Connect(function()
		local localPlayer = game.Players.LocalPlayer
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	
		if not character or not humanoid or not backpack then return end
	
		humanoid:UnequipTools()
	
		local tools = {}
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(tools, item)
			end
		end
	
		table.sort(tools, function(toolA, toolB)
			return toolA.Name:lower() < toolB.Name:lower()
		end)
	
		local toolsToProcess = math.min(#gripPoses, #tools)
		for i = 1, toolsToProcess do
			local tool = tools[i]
			tool.Grip = gripPoses[i]
			tool.Parent = character
		end
	end)
	
end;
task.spawn(C_1a9);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar.handgun.LocalScript
local function C_1ab()
local script = G2L["1ab"];
	
	local button = script.Parent
	
	
	local function createGrip(x, y, z, rx, ry, rz)
		return CFrame.new(x, y, z) * CFrame.fromOrientation(math.rad(rx), math.rad(ry), math.rad(rz))
	end
	
	local gripPoses = {
		createGrip(-0.129, 0.139, -0.000, 9.1, 90.0, 0.0),
		createGrip(-0.632, 0.139, -0.000, 9.1, 90.0, 0.0),
		createGrip(-0.632, -1.004, -0.000, 9.1, 90.0, 0.0),
		createGrip(-0.140, -1.208, -0.000, 9.1, 90.0, 0.0),
		createGrip(-1.730, -0.277, -0.000, 89.7, 90.0, 0.0),
		createGrip(-1.553, -0.942, 0.000, 89.7, 90.0, 0.0),
		createGrip(-1.553, -2.252, 0.000, 89.7, 90.0, 0.0),
		createGrip(-1.703, -1.580, 0.000, 89.7, 90.0, 0.0),
		createGrip(-1.512, -3.039, 0.000, 85.0, 90.0, 0.0),
		createGrip(-1.581, -3.082, 0.000, 89.7, 90.0, 0.0),
		createGrip(-1.766, -3.422, 0.000, 89.2, 90.0, 0.0),
		createGrip(1.534, 0.126, -0.000, -69.7, -90.0, -180.0),
		createGrip(-0.001, -0.849, 0.443, 86.5, -179.5, 2.9),
		createGrip(-0.001, -1.682, -0.815, 25.9, -180.0, 2.4),
	}
	
	button.MouseButton1Click:Connect(function()
		local localPlayer = game.Players.LocalPlayer
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	
		if not character or not humanoid or not backpack then return end
	
		humanoid:UnequipTools()
	
		local tools = {}
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(tools, item)
			end
		end
	
		table.sort(tools, function(toolA, toolB)
			return toolA.Name:lower() < toolB.Name:lower()
		end)
	
		local toolsToProcess = math.min(#gripPoses, #tools)
		for i = 1, toolsToProcess do
			local tool = tools[i]
			tool.Grip = gripPoses[i]
			tool.Parent = character
		end
	end)
	
end;
task.spawn(C_1ab);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.Dupe.LocalScript
local function C_1ae()
local script = G2L["1ae"];
	script.Parent.MouseButton1Click:Connect(function()
		local player = game.Players.LocalPlayer
		local startCFrame = player.Character.HumanoidRootPart.CFrame
	
		for i = 1, tonumber(script.Parent.Parent.Parent.TXTBOX_Dupe.Text) do
			local char = player.Character or player.CharacterAdded:Wait()
			task.wait(0.01)
			char:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(0, 10000000000, 0)
			task.wait(0.5)
	
			for _, tool in ipairs(player.Backpack:GetChildren()) do
				tool.Parent = char
				task.wait(0)
				tool.Parent = workspace
			end
	
			char:WaitForChild("Humanoid").Health = 0
			player.CharacterAdded:Wait()
		end
	
		local finalChar = player.Character or player.CharacterAdded:Wait()
		local finalRoot = finalChar:WaitForChild("HumanoidRootPart")
	
		finalRoot.CFrame = startCFrame
		task.wait(0.5)
		finalRoot.Anchored = true
		task.wait(0.1)
	
		for _, tool in ipairs(workspace:GetChildren()) do
			if tool:IsA("Tool") then
				for _, desc in ipairs(tool:GetDescendants()) do
					if desc:IsA("BasePart") then
						desc.CanCollide = false
					end
				end
				if tool:FindFirstChild("Handle") then
					tool.Handle.CFrame = finalRoot.CFrame
				end
			end
		end
	
		finalRoot.Anchored = false
	end)
	
end;
task.spawn(C_1ae);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.Grab all.LocalScript
local function C_1b5()
local script = G2L["1b5"];
	local button = script.Parent
	local player = game.Players.LocalPlayer
	
	button.MouseButton1Click:Connect(function()
		local character = player.Character or player.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart")
	
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Tool") and not (obj.Parent and obj.Parent:FindFirstChildOfClass("Humanoid")) then
				local handle = obj:FindFirstChild("Handle")
	
				if handle and handle:IsA("BasePart") and not handle.Anchored then
					handle.CFrame = root.CFrame
				end
			end
		end
	end)
end;
task.spawn(C_1b5);
-- StarterGui.OPF:R UPDATED.MainFrame.Pages.Character_2.BackGroundChar2.LoopGrab all.LocalScript
local function C_1b7()
local script = G2L["1b7"];
	local button = script.Parent
	local player = game.Players.LocalPlayer
	
	local enabled = false
	local normalColor = button.BackgroundColor3
	local darkerColor = Color3.fromRGB(102, 38, 142)
	
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
	
		button.BackgroundColor3 = enabled and darkerColor or normalColor
	
		if enabled then
			task.spawn(function()
				while enabled do
					local character = player.Character
					local root = character and character:FindFirstChild("HumanoidRootPart")
	
					if root then
						for _, obj in ipairs(workspace:GetDescendants()) do
							if obj:IsA("Tool") and not (obj.Parent and obj.Parent:FindFirstChildOfClass("Humanoid")) then
								local handle = obj:FindFirstChild("Handle")
								if handle and handle:IsA("BasePart")
									and not handle.Anchored then
									handle.CFrame = root.CFrame
								end
							end
						end
					end
	
					task.wait(1)
				end
			end)
		end
	end)
end;
task.spawn(C_1b7);
-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.NameOfPlayer.LocalScript
local function C_1ba()
local script = G2L["1ba"];
	script.Parent.Text = game.Players.LocalPlayer.Name
end;
task.spawn(C_1ba);
-- StarterGui.OPF:R UPDATED.MainFrame.MenuFrame.Delete.LocalScript
local function C_1c7()
local script = G2L["1c7"];
	script.Parent.MouseButton1Click:Connect(function()
	script.Parent.Parent.Parent.Parent:Destroy()
	end)
end;
task.spawn(C_1c7);


-- MODERN UI PATCH: responsive sizing, dark glass palette, readable controls.
do
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local GuiService = game:GetService("GuiService")
	local player = Players.LocalPlayer
	local gui = G2L["1"]
	local main = G2L["5"]

	gui.DisplayOrder = 50
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false

	local C = {
		bg = Color3.fromRGB(15, 18, 27),
		panel = Color3.fromRGB(23, 28, 40),
		panel2 = Color3.fromRGB(30, 37, 53),
		top = Color3.fromRGB(20, 25, 38),
		cyan = Color3.fromRGB(0, 220, 235),
		purple = Color3.fromRGB(145, 85, 255),
		text = Color3.fromRGB(240, 245, 255),
		muted = Color3.fromRGB(165, 176, 198),
		warn = Color3.fromRGB(245, 177, 66),
		red = Color3.fromRGB(239, 83, 99),
	}
	local function corner(obj, radius)
		if obj and obj:IsA("GuiObject") and not obj:FindFirstChildOfClass("UICorner") then
			local u = Instance.new("UICorner")
			u.CornerRadius = UDim.new(0, radius or 9)
			u.Parent = obj
		end
	end
	local function stroke(obj, color, thickness, transparency)
		if obj and obj:IsA("GuiObject") and not obj:FindFirstChildOfClass("UIStroke") then
			local u = Instance.new("UIStroke")
			u.Color = color or C.cyan
			u.Thickness = thickness or 1
			u.Transparency = transparency or 0.45
			u.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			u.Parent = obj
		end
	end

	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.Size = UDim2.fromOffset(442, 293)
	main.BackgroundTransparency = 0
	main.BackgroundColor3 = C.bg
	main.ClipsDescendants = true
	corner(main, 13)
	stroke(main, C.purple, 1.25, 0.2)

	local scaler = main:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	scaler.Parent = main
	local function resize()
		local camera = workspace.CurrentCamera
		if not camera then return end
		local v = camera.ViewportSize
		local safe = GuiService:GetGuiInset()
		local availableX = math.max(260, v.X - 24)
		local availableY = math.max(220, v.Y - safe.Y - safe.Y - 24)
		scaler.Scale = math.clamp(math.min(availableX / 442, availableY / 293, 1), 0.62, 1)
	end
	resize()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
	end

	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("Frame") then
			obj.BorderSizePixel = 0
			if obj.Name == "TopBar" then
				obj.BackgroundColor3 = C.top
				corner(obj, 10)
			elseif obj.Name == "TopBar2" then
				obj.BackgroundColor3 = C.panel
			elseif obj.Name == "Pages" or obj.Name:find("Page") then
				obj.BackgroundColor3 = C.panel
			elseif obj.Name:find("BackGround") or obj.Name:find("Background") then
				obj.BackgroundColor3 = C.panel2
				corner(obj, 8)
			elseif obj.Name:find("Warning") or obj.Name:find("Warn") then
				obj.BackgroundColor3 = C.warn
				corner(obj, 7)
			elseif obj.Name:find("Info") then
				obj.BackgroundColor3 = C.panel2
				corner(obj, 7)
			elseif obj.BackgroundTransparency < 1 then
				obj.BackgroundColor3 = C.panel
			end
		elseif obj:IsA("TextButton") then
			obj.AutoButtonColor = true
			obj.BorderSizePixel = 0
			obj.BackgroundColor3 = C.panel2
			obj.TextColor3 = C.text
			obj.Font = Enum.Font.GothamMedium
			obj.TextSize = math.clamp(obj.TextSize, 12, 17)
			obj.TextWrapped = true
			corner(obj, 7)
			stroke(obj, C.cyan, 1, 0.72)
		elseif obj:IsA("ImageButton") then
			obj.AutoButtonColor = true
			obj.BorderSizePixel = 0
			if obj.Name ~= "OpenMenu" then
				corner(obj, 8)
			end
		elseif obj:IsA("TextLabel") then
			obj.Font = Enum.Font.Gotham
			obj.TextColor3 = C.text
			if obj.Name == "Title" then
				obj.Font = Enum.Font.GothamBold
				obj.TextColor3 = C.cyan
				obj.TextSize = 23
			elseif obj.Name:find("Description") or obj.Name:find("Warning") then
				obj.TextColor3 = C.muted
				obj.TextSize = math.clamp(obj.TextSize, 12, 16)
			else
				obj.TextSize = math.clamp(obj.TextSize, 12, 20)
			end
		elseif obj:IsA("TextBox") then
			obj.BackgroundColor3 = C.bg
			obj.TextColor3 = C.text
			obj.PlaceholderColor3 = C.muted
			obj.Font = Enum.Font.Gotham
			obj.TextSize = 14
			obj.BorderSizePixel = 0
			corner(obj, 7)
			stroke(obj, C.purple, 1, 0.55)
		elseif obj:IsA("ScrollingFrame") then
			obj.ScrollBarThickness = 4
			obj.ScrollBarImageColor3 = C.cyan
			obj.BackgroundColor3 = C.panel
			obj.BorderSizePixel = 0
		end
	end

	-- Accent strips remain visible but use the new cyan/purple palette.
	for _, name in ipairs({"Info_Bar", "Warning_Bar"}) do
		local obj = gui:FindFirstChild(name, true)
		if obj and obj:IsA("GuiObject") then
			obj.BackgroundColor3 = name == "Info_Bar" and C.cyan or C.warn
		end
	end
	local title = gui:FindFirstChild("Title", true)
	if title and title:IsA("TextLabel") then
		title.Text = "OPFINALITY / REVIVED"
	end

	-- Keep the interface inside the screen when opened on narrow phones.
	-- Dragging remains handled by the original drag controller.
	if UserInputService.TouchEnabled then
		main.Active = true
		main.Selectable = true
	end
end


return G2L["1"], require;
