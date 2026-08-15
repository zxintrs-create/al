local Window=Rayfield:CreateWindow({
	Name="🪽FunScripts🪽",Icon=0,LoadingTitle="🪽FunScripts🪽",LoadingSubtitle="by Benjamin",Theme="Default",
	DisableRayfieldPrompts=false,DisableBuildWarnings=false,
	ConfigurationSaving={Enabled=true,FolderName=nil,FileName="FunscriptsGuiFF1"},
	Discord={Enabled=false,Invite="noinvitelink",RememberJoins=true}
})

local MainTab=Window:CreateTab("🏡 Home 🏡",nil)
local MainSection=MainTab:CreateSection("Fun Stuff")

Rayfield:Notify({Title="Welcome!",Content="Enjoy!",Duration=6.5,Image=nil})

MainTab:CreateButton({
	Name="Jump Forever",
	Callback=function()
		local InfiniteJumpEnabled=true
		game:GetService("UserInputService").JumpRequest:Connect(function()
			if InfiniteJumpEnabled then
				game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
			end
		end)
	end
})

MainTab:CreateSlider({
	Name="Walkspeed",
	Range={0,500},
	Increment=1,
	Suffix="Speed",
	CurrentValue=16,
	Flag="Slider1",
	Callback=function(Value)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed=Value
	end
})
