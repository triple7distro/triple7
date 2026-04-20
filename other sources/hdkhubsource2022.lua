_G.hdkVer = "2 BETATESTING"
_G.hdkMem = {}

print("hdkhub version ".. _G.hdkVer)

if not isfile("HDKHub") then
	makefolder("HDKHub")
end

local loaders = {
    ["2862098693"] = function()
			--// variabs

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local UniversalTables = require(ReplicatedStorage.Modules:WaitForChild("UniversalTables"));
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/EpicDev2232/MaterialLua/master/Module.lua"))()

local camera = workspace.CurrentCamera

local mt = getrawmetatable(game)
setreadonly(mt, false)

local updateTick = 0

-- break anticheat 

local badremote = game.ReplicatedStorage.Remotes:WaitForChild("\208\149rrrorLog")
badremote:Destroy()

-- preset folder

if not isfile("HDKHub/ProjectDelta") then
	makefolder("HDKHub/ProjectDelta")
end

function getPresets(includePath)
	local presets = {}

	for _, preset in pairs(listfiles("HDKHub/ProjectDelta")) do
		local charTable = string.split(string.split(string.split(preset, "HDKHub/ProjectDelta")[2], ".txt")[1], "")
		local name = ""

		for index, char in pairs(charTable) do
			if index > 1 then
				name = name.. char
			end
		end

        print(name)

		if includePath then
			presets[name] = preset
		else
			table.insert(presets, name)
		end
	end

	return presets
end

-- modules

local modules = {
	ESP = (function()
		local ESP = {}
		
		function ESP:CreateNametag()
			local text = Instance.new("TextLabel")
			text.Size = UDim2.new(1,0,0.2,0)
			text.FontFace = Font.fromName("Jura", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			text.TextColor3 = Color3.new(1,1,1)
			text.TextStrokeColor3 = Color3.new(0,0,0)
			text.TextStrokeTransparency = 0
			text.BackgroundTransparency = 1
			
			return text
		end
		
		function ESP:CreateBar()
			local bg = Instance.new("Frame")
			bg.Size = UDim2.new(1,0,0.05,0)
			bg.BackgroundColor3 = Color3.new(0.168627, 0.168627, 0.168627)
			bg.BorderSizePixel = 0
			
			local bar = Instance.new("Frame")
			bar.Parent = bg
			bar.Size = UDim2.new(0.5, 0, 1, 0)
			bar.BorderSizePixel = 0
			bar.BackgroundColor3 = Color3.new(1,1,1)
			
			bar = nil
			
			return bg
		end
		
		function ESP:Update()
			local playerTable = Players:GetPlayers()

			for index, espPlayer in pairs(playerTable) do
				playerTable[index] = espPlayer.Character
			end

			local playerTables = {
				["Players"] = playerTable;
				["Corpses"] = workspace:FindFirstChild("DroppedItems"):GetChildren();
				["AIs"] = workspace:FindFirstChild("AiZones"):GetDescendants();
			}

			for ESPindex, ESPtable in pairs(playerTables) do
				for _, char in pairs(ESPtable) do
					coroutine.wrap(function()
						local humanoid = char:FindFirstChildOfClass("Humanoid")
			
						if humanoid and char ~= player.Character then
							local espInfo = char:FindFirstChild("HDKInfo")
							
							if not espInfo then
								espInfo = Instance.new("BillboardGui")
								espInfo.Size = UDim2.new(4, 20, 5, 25)
								espInfo.LightInfluence = 0
								espInfo.AlwaysOnTop = true
								espInfo.Parent = char
								espInfo.Name = "HDKInfo"
							else
								espInfo.Enabled = true
							end
							
							local highlight = char:FindFirstChild("HighlightHDK")
							
							local nametag = espInfo:FindFirstChild("NametagHDK")
							local distance = espInfo:FindFirstChild("DistanceHDK")
							local healthbar = espInfo:FindFirstChild("HealthbarHDK")
			
							if _G.hdkMem.ESPEnabledToggle == true and (ESPindex == "Players" or (ESPindex == "Corpses" and _G.hdkMem.IncludeCorpsesOnESP == true) or (ESPindex == "AIs" and _G.hdkMem.IncludeAIsOnESP == true)) then
								-- ESP Nametags
								if _G.hdkMem.ShowESPNametagsToggle == true then
									if not nametag then
										nametag = ESP:CreateNametag()
										nametag.Parent = espInfo
										nametag.Text = char.Name
										nametag.Name = "NametagHDK"
										nametag.Position = UDim2.new(0, 0, -0.18, 0)
									else
										nametag.Text = char.Name
									end
								else
									if nametag then
										nametag:Destroy()
									end
								end
								
								-- ESP distance
								if _G.hdkMem.ShowESPDistanceToggle == true then
									if not distance then
										distance = ESP:CreateNametag()
										distance.Parent = espInfo
										distance.Text = math.round((player.Character:GetPivot().Position - char:GetPivot().Position).Magnitude)
										distance.Name = "DistanceHDK"
										distance.Position = UDim2.new(0, 0, 0.8, 0)
									else
										distance.Text = math.round((player.Character:GetPivot().Position - char:GetPivot().Position).Magnitude)
									end
								else
									if distance then
										distance:Destroy()
									end
								end
								
								-- ESP healthbar
								if _G.hdkMem.ShowESPHealthbarToggle == true then
									if not healthbar then
										healthbar = ESP:CreateBar()
										healthbar.Parent = espInfo
										healthbar.Frame.Size = UDim2.new(humanoid.Health / 100, 0, 1, 0)
										healthbar.Name = "HealthbarHDK"
										healthbar.Position = UDim2.new(0,0,0.08,0)
									else
										healthbar.Frame.Size = UDim2.new(humanoid.Health / 100, 0, 1, 0)
									end
								else
									if healthbar then
										healthbar:Destroy()
									end
								end
			
								-- ESP Highlights
								if _G.hdkMem.ShowESPHighlightsToggle then
									if not highlight then
										highlight = Instance.new("Highlight")
										highlight.Parent = char
										highlight.Name = "HighlightHDK"
									else
										highlight.Enabled = true
			
										if _G.hdkMem.ESPHighlightColor then
											highlight.FillColor = _G.hdkMem.ESPHighlightColor
											highlight.OutlineColor = _G.hdkMem.ESPHighlightColor
										end
									end
								else
									if highlight then
										highlight:Destroy()
									end
								end
							else -- remove esp components
								if highlight then highlight:Destroy() end
								if nametag then nametag:Destroy() end
								if distance then distance:Destroy() end
								if healthbar then healthbar:Destroy() end
							end
							
							-- nulling to save peoples RAM
							highlight = nil
							nametag = nil
							distance = nil
							healthbar = nil
							espInfo = nil
						end
						
						humanoid = nil
					end)()
				end
			end
		end
		
		return ESP
	end)();







	HideVisor = (function()
		local HideVisor = {}

		function HideVisor:CreateIsToggledInfo(name)
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(0, 75, 0, 75)
				frame.Position = UDim2.new(0.8, 0, 0.8, 0)
				frame.BackgroundColor3 = Color3.fromRGB(135, 255, 135)
				frame.Parent = CoreGui.HDKHub

				local text = Instance.new("TextLabel")
				text.BackgroundTransparency = 1
				text.Size = UDim2.new(1,0,1,0)
				text.FontFace = Font.fromName("Michroma")
				text.TextColor3 = Color3.new(1,1,1)
				text.TextStrokeTransparency = 0
				text.TextSize = 25
				text.Parent = frame
				text.Text = name

				return frame
			end

		function HideVisor:Update()
			-- visor down gui
			local hideVisorGui = CoreGui.HDKHub:FindFirstChild("IsVisorToggled")
			
			if _G.hdkMem.HideVisorToggle == true then
				if not hideVisorGui then
					hideVisorGui = HideVisor:CreateIsToggledInfo("Visor Down")
					hideVisorGui.Name = "IsVisorToggled"
				end
			else
				if hideVisorGui then
					hideVisorGui:Destroy()
				end
			end
			
			-- find visor path
			local screenEffects
			local mainGui = playerGui:FindFirstChild("MainGui")
			
			if mainGui then
				local mainFrame = mainGui:FindFirstChild("MainFrame")

				if mainFrame then
					screenEffects = mainFrame:FindFirstChild("ScreenEffects")
				end
				
				mainFrame = nil
			end
			
			-- update visors
			if screenEffects then
				local visorDown = false

				for _, guiContainer in pairs({screenEffects.Visor, screenEffects.Mask, screenEffects.HelmetMask}) do
					if _G.hdkMem.HideVisorToggle == true then
						guiContainer.Visible = false
					else
						guiContainer.Visible = true
					end

					for _, visorGui in pairs(guiContainer:GetChildren()) do
						if visorGui.Visible == true then
							visorDown = true

							break
						end
					end
				end

				if hideVisorGui then
					if visorDown == true then
						hideVisorGui.BackgroundColor3 = Color3.fromRGB(135, 255, 135)
						hideVisorGui.TextLabel.Text = "Visor Down"
					else
						hideVisorGui.BackgroundColor3 = Color3.fromRGB(255, 124, 124)
						hideVisorGui.TextLabel.Text = "Visor Up"
					end
				end
				
				visorDown = nil
			end
			
			screenEffects = nil
			mainGui = nil
			hideVisorGui = nil
		end

		return HideVisor
	end)();







	FOV = (function()
		local FOV = {}

		local rayParams = RaycastParams.new()

		function FOV:TracePath(startBtn, endBtn, Line)
			local startX, startY = startBtn.X, startBtn.Y
			local endX, endY = endBtn.X, endBtn.Y
			Line.AnchorPoint = Vector2.new(0.5, 0.5)
			Line.Size = UDim2.new(0, ((endX - startX) ^ 2 + (endY - startY) ^ 2) ^ 0.5, 0, 2) -- Get the size using the distance formula
			Line.Position = UDim2.new(0, (startX + endX) / 2, 0, (startY + endY) / 2) -- Get the position using the midpoint formula
			Line.Rotation = math.atan2(endY - startY, endX - startX) * (180 / math.pi) -- Get the rotation using atan2, convert radians to degrees
			Line.Parent = CoreGui.HDKHub
			
			endX = nil
			endY = nil
			startX = nil
			startY = nil
		end

		function FOV:Update()
			local FOVCircle = CoreGui.HDKHub:FindFirstChild("FOVCircle")

			-- FOV circle
			if _G.hdkMem.FOVWidth and _G.hdkMem.FOVWidth > 0 then
				if not FOVCircle then
					FOVCircle = Instance.new("ImageLabel")
					FOVCircle.Parent = CoreGui.HDKHub
					FOVCircle.Name = "FOVCircle"
					FOVCircle.BackgroundTransparency = 1
					FOVCircle.ZIndex = -9999
					FOVCircle.ImageTransparency = 1

					local corner = Instance.new("UICorner")
					corner.Parent = FOVCircle
					corner.CornerRadius = UDim.new(1,0)

					local stroke = Instance.new("UIStroke")
					stroke.Parent = FOVCircle
					stroke.Color = Color3.new(1,1,1)
					
					corner = nil
					stroke = nil
				end

				FOVCircle.Size = UDim2.new((_G.hdkMem.FOVWidth / camera.ViewportSize.X) * 10, 0, (_G.hdkMem.FOVWidth / camera.ViewportSize.Y) * 10, 0)
				FOVCircle.Position = UDim2.new(0, (camera.ViewportSize.X - FOVCircle.AbsoluteSize.X) * 0.5, 0, (camera.ViewportSize.Y - FOVCircle.AbsoluteSize.Y) * 0.5)

				if _G.hdkMem.FOVVisible ~= nil then
					FOVCircle.Visible = _G.hdkMem.FOVVisible
				else
					FOVCircle.Visible = true
				end
			else
				if FOVCircle then
					FOVCircle:Destroy()
				end
				
				for _, tracer in pairs(CoreGui.HDKHub:GetChildren()) do
					if string.match(tracer.Name, "FOVTracer") then
						tracer:Destroy()
					end
				end
			end

			-- Find closest person within FOV
			
			if not _G.hdkMem.FOVWidth then
				_G.hdkMem.FOVWidth = 0
			end
			
			local closest = nil
			local last = _G.hdkMem.FOVWidth * 5
			if FOVCircle then last = FOVCircle.AbsoluteSize.X * 0.5 end
			local position = nil

			-- establish playertable

			local playerTable = Players:GetPlayers()

			for index, espPlayer in pairs(playerTable) do
				playerTable[index] = espPlayer.Character
			end

			local playerTables = {
				["Players"] = playerTable;
				["AIs"] = workspace:FindFirstChild("AiZones"):GetDescendants();
			}

			for FOVindex, FOVTable in pairs(playerTables) do
				for _, char in pairs(FOVTable) do
					local humanoid = char:FindFirstChildOfClass("Humanoid")
					
					if humanoid and char ~= player.Character and (FOVindex == "Players" or (FOVindex == "AIs" and _G.hdkMem.IncludeAIsOnFOV == true)) then
						local raycast = true

						local lookPart = char:FindFirstChild("Head")

						if lookPart then
							lookPart = lookPart.Position
						else
							lookPart = char:GetPivot().Position
						end

						if _G.hdkMem.FOVCheckVisible == true then
							rayParams.FilterDescendantsInstances = {player.Character}
							raycast = workspace:Raycast(camera.CFrame.Position, lookPart - camera.CFrame.Position, rayParams)

							if raycast then
								if raycast.Instance:FindFirstAncestor(char.Name) then
									raycast = true
								else
									raycast = false
								end
							end
						end
						
						if raycast == true then
							local screenPosition, onScreen = camera:WorldToViewportPoint(lookPart)

							if onScreen then
								screenPosition = Vector2.new(screenPosition.X, screenPosition.Y)

								local dist = (screenPosition - camera.ViewportSize * 0.5).Magnitude

								if dist <= last then
									last = dist
									closest = char
									position = screenPosition
								end
							end

							onScreen = nil
							screenPosition = nil
						end
						
						raycast = nil
					end

					humanoid = nil
				end
			end
			
			_G.hdkMem.ClosestPlayerInFOV = closest

			-- Update tracers
			if position and closest then
				local tracer = CoreGui.HDKHub:FindFirstChild("FOVTracer"..closest.Name)

				if not tracer then
					tracer = Instance.new("Frame")
					tracer.Name = "FOVTracer"..closest.Name
					tracer.Parent = CoreGui.HDKHub
					tracer.BorderSizePixel = 0
					tracer.BackgroundColor3 = Color3.new(1,1,1)

					FOV:TracePath(camera.ViewportSize * 0.5, position, tracer)
				else
					FOV:TracePath(camera.ViewportSize * 0.5, position, tracer)
				end
				
				tracer = nil
			end

			for _, tracer in pairs(CoreGui.HDKHub:GetChildren()) do
				if string.match(tracer.Name, "FOVTracer") then
					if closest ~= nil and position ~= nil then
						if not string.match(tracer.Name, closest.Name) then
							tracer:Destroy()
						end
					else
						tracer:Destroy()
					end
				end
			end
			
			closest = nil
			last = nil
			position = nil
			FOVCircle = nil
		end

		return FOV
	end)();
	






	PlayerInfo = (function()
		local PlayerInfo = {}

		local rayParams = RaycastParams.new()

		function PlayerInfo:Update()
			local playerInfoGui = CoreGui.HDKHub:FindFirstChild("PlayerInfoGui")
			
			if _G.hdkMem.PlayerInfoEnabled == true then
				-- Info GUI
				if _G.hdkMem.ClosestPlayerInFOV then
					if not playerInfoGui then
						playerInfoGui = Instance.new("TextLabel")
						playerInfoGui.Parent = CoreGui.HDKHub
						playerInfoGui.Name = "PlayerInfoGui"
						playerInfoGui.BackgroundColor3 = Color3.fromRGB(40,40,40)
						playerInfoGui.BorderSizePixel = 0
						playerInfoGui.Position = UDim2.new(0.012, 0,0.305, 0)
						
						playerInfoGui.FontFace = Font.fromName("Gotham")
						playerInfoGui.TextColor3 = Color3.new(1,1,1)
						playerInfoGui.TextYAlignment = Enum.TextYAlignment.Top
						playerInfoGui.TextXAlignment = Enum.TextXAlignment.Left
						playerInfoGui.TextSize = 14
						playerInfoGui.RichText = true
					end
					
					-- player name
					local infoText = "Name: ".. _G.hdkMem.ClosestPlayerInFOV.Name
					local lines = 1

					-- Show Visible
					if _G.hdkMem.FOVChipset["Show Visible"] == true then
						rayParams.FilterDescendantsInstances = {player.Character}
						local raycast = workspace:Raycast(camera.CFrame.Position, (_G.hdkMem.ClosestPlayerInFOV:GetPivot().Position - camera.CFrame.Position) * 2, rayParams)

						if raycast then
							if raycast.Instance:FindFirstAncestor(_G.hdkMem.ClosestPlayerInFOV.Name) then
								infoText = infoText.. "<br/>Visible: true"
							else
								infoText = infoText.. "<br/>Visible: false"
							end
						else
							infoText = infoText.. "<br/>Visible: false"
						end

						lines = lines + 1
					end
					
					-- show inventory
					local playerStatsFolder = ReplicatedStorage:FindFirstChild("Players")
					
					if playerStatsFolder then
						local playerFolder = playerStatsFolder:FindFirstChild(_G.hdkMem.ClosestPlayerInFOV.Name)
						
						if playerFolder and _G.hdkMem.FOVChipset["Show Inventory"] == true then
							infoText = infoText.. "<br/>Inventory:<br/>"
							lines = lines + 1
							
							-- display hotbar
							infoText = infoText.. "      Hotbar:<br/>"
							lines = lines + 1
							
							for _, item in pairs(playerFolder.Inventory:GetChildren()) do
								infoText = infoText.. "          ".. item.Name.. "<br/>"
								lines = lines + 1
							end
							
							-- display clothing
							for _, clothing in pairs(playerFolder.Clothing:GetChildren()) do
								infoText = infoText.. "      ".. clothing.Name
								
								local inventory = clothing:FindFirstChild("Inventory")
								
								if inventory then
									infoText = infoText.. ":<br/>"
									
									-- show items in clothing
									for _, item in pairs(inventory:GetChildren()) do
										infoText = infoText.. "          ".. item.Name.. "<br/>"
										lines = lines + 1
									end
								else
									infoText = infoText.. "<br/>"
								end
								
								lines = lines + 1
								inventory = nil
							end
						end
						
						playerFolder = nil
					end

					lines = lines + 1

					-- Show Distance
					if _G.hdkMem.FOVChipset["Show Distance"] == true then
						infoText = infoText.. "<br/>Distance: ".. tostring(math.round((_G.hdkMem.ClosestPlayerInFOV:GetPivot().Position - camera.CFrame.Position).Magnitude))

						lines = lines + 1
					end
					
					playerInfoGui.Text = infoText
					playerInfoGui.Size = UDim2.new(0.137, 0, 0, lines * playerInfoGui.TextSize)
					
					playerStatsFolder = nil
					infoText = nil
					lines = nil
				else
					if playerInfoGui then playerInfoGui:Destroy() end
				end
			else
				if playerInfoGui then playerInfoGui:Destroy() end
			end
			
			playerInfoGui = nil
		end

		return PlayerInfo
	end)();
	






	SilentAim = (function()
		local SilentAim = {}
		
		-- thank you, synapse
		
		local oldHook = nil
		
		oldHook = hookfunction(require(game.ReplicatedStorage.Modules.FPS.Bullet).CreateBullet, function(...)
			local args = {...}

			if _G.hdkMem.SilentAimEnabled == true and _G.hdkMem.ClosestPlayerInFOV then
				local head = _G.hdkMem.ClosestPlayerInFOV:FindFirstChild("Head")
		
				if not head then
					head = _G.hdkMem.ClosestPlayerInFOV:GetPivot().Position
				else
					head = head.Position
				end

				args[9] = {CFrame = CFrame.lookAt(
					player.Character.HumanoidRootPart.Position + Vector3.new(
						0, UniversalTables.UniversalTable.GameSettings.RootScanHeight, 0
					),
					head
				)}
			end

			return oldHook(table.unpack(args))
		end)
		
		return SilentAim
	end)();
	






	Movehack = (function()
		local Movehack = {}

		local lastHum = nil

		function Movehack:Update()
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				for _, connectTable in pairs({
					getconnections(humanoid.StateChanged);
					getconnections(humanoid:GetPropertyChangedSignal("WalkSpeed"));
					getconnections(humanoid:GetPropertyChangedSignal("JumpHeight"))
				}) do
					for _, event in pairs(connectTable) do
						event:Disable()
					end
				end

				if _G.hdkMem.SpeedhackEnabledToggle == true and humanoid then
					humanoid.WalkSpeed = _G.hdkMem.SpeedValueOverride
				end

				if _G.hdkMem.JumphackEnabledToggle == true and humanoid then
					humanoid.JumpHeight = _G.hdkMem.JumpValueOverride
				end
			end

			lastHum = humanoid
			humanoid = nil
		end

		return Movehack
	end)();







	GunMods = (function()
		local GunMods = {}

		local mt = getrawmetatable(game)
		setreadonly(mt, false)
		
		local oldRecoil = nil
		
		oldRecoil = hookfunction(require(game.ReplicatedStorage.Modules.VFX).RecoilCamera, function(...)
			if _G.hdkMem.RecoilRemoveEnabled == true then
				return nil
			end
		
			return oldRecoil(...)
		end)

		local oldFiremodes = nil
		
		oldFiremodes = hookfunction(require(game.ReplicatedStorage.Modules.FPS).fireMode, function(...)
			local args = {...}

			if _G.hdkMem.UnlockFiremodesEnabled == true then
				args[1].FireModes = {
					"Auto";
					"Semi"
				}
			end

			return oldFiremodes(table.unpack(args))
		end)
		
		return GunMods
	end)();
	






	Visuals = (function()
		local Visuals = {}

		local mt = getrawmetatable(game)
		setreadonly(mt, false)

		-- remove recoil

		local cameraHook = nil

		cameraHook = hookfunction(require(game.ReplicatedStorage.Modules.spring).update, function(...)
			if _G.hdkMem.RemoveCameraTiltEnabled == true then
				return nil
			end
			
			return cameraHook(...)
		end)

		-- custom fov

		local fovHook = nil

		fovHook = hookfunction(require(game.ReplicatedStorage.Modules.FPS).fovUpdate, function(...)
			local args = {...}

			if _G.hdkMem.FOVOverride and _G.hdkMem.FOVOverride > 0 then
				args[1].baseFov = _G.hdkMem.FOVOverride
			end

			return fovHook(table.unpack(args))
		end)

		function Visuals:Update()
			if _G.hdkMem.FOVOverride and _G.hdkMem.FOVOverride > 0 then
				camera.FieldOfView = _G.hdkMem.FOVOverride
			end
		end

		return Visuals
	end)();
}

--// UI CONTROLS

local HDKUi = Material.Load(
	{
		Title = "HDKHub v".._G.hdkVer;
		Style = 2;
		SizeX = 400,
		SizeY = 550,
		Theme = "Dark"
	}
)

-- mouse unlock

local mouseUnlock = Instance.new("TextButton")
mouseUnlock.BackgroundTransparency = 1
mouseUnlock.TextTransparency = 1
mouseUnlock.Modal = true
mouseUnlock.Size = UDim2.new(1,0,1,0)
mouseUnlock.ZIndex = -1000
mouseUnlock.Parent = CoreGui.HDKHub

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.End then
		mouseUnlock.Visible = not mouseUnlock.Visible
		UserInputService.MouseIconEnabled = mouseUnlock.Visible
	end
end)

--// UI

local Visuals = HDKUi.New({Title = "Visuals"})
local FOV = HDKUi.New({Title = "FOV"})
local Movement = HDKUi.New({Title = "Movement"})
local Combat = HDKUi.New({Title = "Combat"})
local Miscellaneous = HDKUi.New({Title = "Misc"})
local Settings = HDKUi.New({Title = "Settings"})

local UIElements = {
-- Visuals UI

VisualsMiscDivider = Visuals.Label({
	Text = "--// MISC //--";
	Menu = {
		Information = function()
			HDKUi.Banner("Miscellaneous: Misc visual features to spice up the looks of your game!")
		end
	}
});

HideVisor = Visuals.Toggle({
	Text = "Hide Visor";
	Callback = function(value)
		_G.hdkMem.HideVisorToggle = value
	end,
});

Fullbright = Visuals.Toggle({ -- fullbright
	Text = "Fullbright";
	Callback = function(value)
		if value == true then
			Lighting.Ambient = Color3.new(1,1,1)
			Lighting.OutdoorAmbient = Color3.new(1,1,1)
			Lighting.GlobalShadows = false
			Lighting.Brightness = 3
		else
			if _G.hdkMem.LastLightingOptions then
				Lighting.Ambient = _G.hdkMem.LastLightingOptions.Ambient
				Lighting.OutdoorAmbient = _G.hdkMem.LastLightingOptions.OutdoorAmbient
				Lighting.GlobalShadows = _G.hdkMem.LastLightingOptions.GlobalShadows
				Lighting.Brightness = _G.hdkMem.LastLightingOptions.Brightness
			end
			
			_G.hdkMem.LastLightingOptions = {
				Ambient = Lighting.Ambient;
				OutdoorAmbient = Lighting.OutdoorAmbient;
				GlobalShadows = Lighting.GlobalShadows;
				Brightness = Lighting.Brightness;
			}
		end
	end,
});

RemoveCameraTilt = Visuals.Toggle({
	Text = "Remove Camera Sway";
	Callback = function(value)
		_G.hdkMem.RemoveCameraTiltEnabled = value
	end
});

FOVOverride = Visuals.Slider({
	Text = "FOV Override (0 to disable)";
	Callback = function(value)
		_G.hdkMem.FOVOverride = value
	end;
	Min = 0;
	Max = 120;
	Def = 0;
});

RemoveWeatherEffects = Visuals.Toggle({
	Text = "Remove Weather Effects";
	Callback = function(value)
		if value == true then
			local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

			if atmosphere then
				atmosphere.Parent = player
			end
		else
			local atmosphere = player:FindFirstChildOfClass("Atmosphere")

			if atmosphere then
				atmosphere.Parent = Lighting
			end
		end
	end
});

VisualsViewmodelsDivider = Visuals.Label({
	Text = "--// VIEWMODELS //--";
	Menu = {
		Information = function()
			HDKUi.Banner("Viewmodel offsets: Change your on-screen location of the viewmodel (SET ALL TO 0 FOR DEFAULT)")
		end
	}
});

ViewmodelOffsetX = Visuals.Slider({
	Text = "Viewmodel Offset X";
	Callback = function(value)
		_G.hdkMem.ViewmodelOffsetX = value
	end;
	Min = -300,
	Max = 300,
	Def = 0
});

ViewmodelOffsetY = Visuals.Slider({
	Text = "Viewmodel Offset Y";
	Callback = function(value)
		_G.hdkMem.ViewmodelOffsetY = value
	end;
	Min = -300,
	Max = 300,
	Def = 0
});

ViewmodelOffsetZ = Visuals.Slider({
	Text = "Viewmodel Offset Z";
	Callback = function(value)
		_G.hdkMem.ViewmodelOffsetZ = value
	end;
	Min = -300,
	Max = 300,
	Def = 0
});

-- ESP UI

ESPDivider = Visuals.Label({
	Text = "--// ESP //--";
	Menu = {
		Information = function()
			HDKUi.Banner("ESP: Shows you the positions / outlines of players behind obstructions such as walls.")
		end
	}
});

ESPEnabled = Visuals.Toggle({
	Text = "ESP";
	Callback = function(value)
		_G.hdkMem.ESPEnabledToggle = value
	end
});

ESPChipSet = Visuals.ChipSet({
	Text = "ESP Settings";
	Callback = function(chipset)
		_G.hdkMem.ShowESPNametagsToggle = chipset.Nametags
		_G.hdkMem.ShowESPDistanceToggle = chipset.Distances
		_G.hdkMem.ShowESPHealthbarToggle = chipset.Healthbars
		_G.hdkMem.ShowESPHighlightsToggle = chipset.Highlights
		_G.hdkMem.IncludeCorpsesOnESP = chipset["Include Corpses"]
		_G.hdkMem.IncludeAIsOnESP = chipset["Include AIs"]
	end,
	Options = {
		Nametags = false;
		Distances = false;
		Healthbars = false;
		Highlights = false;
		["Include Corpses"] = false;
		["Include AIs"] = false;
	}
});

ESPHighlightColor = Visuals.ColorPicker({
	Text = "Highlight Color";
	Callback = function(value)
		_G.hdkMem.ESPHighlightColor = value
	end
});

-- FOV UI

FOVSlider = FOV.Slider({
	Text = "FOV Angle (0 to disable)";
	Callback = function(value)
		_G.hdkMem.FOVWidth = value
	end,
	Min = 0;
	Max = 150;
	Def = 0;
});

FOVEnabled = FOV.Toggle({
	Text = "FOV Visible Toggle";
	Callback = function(value)
		_G.hdkMem.FOVVisible = value
	end,
	Enabled = true
});

FOVCheckVisible = FOV.Toggle({
	Text = "Check Visibility";
	Callback = function(value)
		_G.hdkMem.FOVCheckVisible = value
	end,
});

FOVShowPlayerInfo = FOV.Toggle({
	Text = "Show Player Info";
	Callback = function(value)
		_G.hdkMem.PlayerInfoEnabled = value
	end
});

FOVPlayerInfoChipset = FOV.ChipSet({
	Text = "Player Info";
	Callback = function(chipset)
		_G.hdkMem.FOVChipset = chipset
	end,
	Options = {
		["Show Inventory"] = false;
		["Show Distance"] = false;
		["Show Visible"] = false;
	}
});

FOVIncludeAIs = FOV.Toggle({
	Text = "Include AIs";
	Callback = function(value)
		_G.hdkMem.IncludeAIsOnFOV = value
	end
});

--// Movement UI

SpeedhackEnabled = Movement.Toggle({
	Text = "Speedhack Enabled";
	Callback = function(value)
		_G.hdkMem.SpeedhackEnabledToggle = value
	end
});

SpeedhackSlider = Movement.Slider({
	Text = "Speed Override";
	Callback = function(value)
		_G.hdkMem.SpeedValueOverride = value
	end;
	Min = 0;
	Max = 50;
	Def = 0;
});

JumphackEnabled = Movement.Toggle({
	Text = "Jumphack Enabled";
	Callback = function(value)
		_G.hdkMem.JumphackEnabledToggle = value
	end
});

JumphackSlider = Movement.Slider({
	Text = "Jumphack Override";
	Callback = function(value)
		_G.hdkMem.JumpValueOverride = value
	end;
	Min = 0;
	Max = 8;
	Def = 0;
});


--// combat

CombatSilentAimDivider = Combat.Label({
	Text = "--// SILENT AIM //--";
	Menu = {
		Information = function()
			HDKUi.Banner("Silent Aim: Directs the bullets towards the closest enemy in your FOV circle")
		end
	}
});

SilentAimEnabled = Combat.Toggle({
	Text = "Silent Aim";
	Callback = function(value)
		_G.hdkMem.SilentAimEnabled = value
	end
});

CombatGunModsDivider = Combat.Label({
	Text = "--// GUN MODIFICATIONS //--";
	Menu = {
		Information = function()
			HDKUi.Banner("Gun Mods: Modify the way your weapon behaves!")
		end
	}
});

RemoveRecoilEnabled = Combat.Toggle({
	Text = "Remove Recoil";
	Callback = function(value)
		_G.hdkMem.RecoilRemoveEnabled = value
	end
});

UnlockFiremodesEnabled = Combat.Toggle({
	Text = "Unlock Firemodes";
	Callback = function(value)
		_G.hdkMem.UnlockFiremodesEnabled = value
	end
});

UnlockFireRate = Combat.Slider({
	Text = "Unlock Firerate (0 to disable)";
	Callback = function(value)
		_G.hdkMem.CustomFireRate = value
	end;
	Min = 0;
	Max = 1000;
	Def = 0
});

RemoveBloomEnabled = Combat.Toggle({
	Text = "Remove Spread";
	Callback = function(value)
		_G.hdkMem.RemoveSpreadEnabled = value
	end
});

--// MISC UI

OpenClosestDoor = Miscellaneous.Button({
	Text = "Open Closest Door";
	Callback = function()
		local last = 5
		local closest = nil

		for _, door in pairs(workspace:GetChildren()) do
			if door:IsA("Model") then
				if door:GetAttribute("KeyDoor") and door:FindFirstChild("Main") then
					if (door:GetPivot().Position - player.Character:GetPivot().Position).Magnitude <= last then
						last = (door:GetPivot().Position - player.Character:GetPivot().Position).Magnitude
						closest = door
					end
				end
			end
		end

		if closest then
			local unit = (closest.Main.Position - player.Character.HumanoidRootPart.Position).Unit

			for i = 1,20 do
				player.Character.HumanoidRootPart.CFrame = CFrame.new(closest.Main.Position + unit * 3)
				game.ReplicatedStorage.Remotes.Door:FireServer(closest, 1, closest:GetPivot().Position);
				task.wait(0.05)
			end
		end
	end
});

PresetDivider = Settings.Label({
	Text = "--// PRESETS //--";
	Menu = {
		Information = function()
			HDKUi.Banner("Presets: Save presets to use for later! (CHIPSETS DO NOT SAVE AS OF NOW)")
		end
	}
});

PresetName = Settings.TextField({
	Text = "";
	Type = "Default";
	Callback = function(value)
		_G.hdkMem.SaveCurrentPresetName = value
	end
});

PresetDropdown = Settings.Dropdown({
	Text = "Presets";
	Callback = function(value)
		_G.hdkMem.SaveCurrentPresetName = value
		setPresetButtonText(value)
	end;
	Options = getPresets()
});

SavePreset = Settings.Button({
	Text = "Save Preset";
	Callback = function()
		SavePreset(_G.hdkMem.SaveCurrentPresetName)
	end
});

LoadPreset = Settings.Button({
	Text = "Load Preset";
	Callback = function()
		LoadPreset(_G.hdkMem.SaveCurrentPresetName)
	end
})
}

--// Preset Functions

function stringToBool(content)
	local convert = {["true"] = true; ["false"] = false; ["nil"] = nil}
	return convert[content]
end

function boolToString(content)
	if content == true then
		return "true"
	elseif content == false then
		return "false"
	else
		return "nil"
	end
end

function stringToBool(content)
	local convert = {["true"] = true; ["false"] = false; ["nil"] = nil}
	return convert[content]
end

function stringToTable(content)
	local result = {}

	local split = string.split(content, ",")

	for i, element in pairs(split) do
		if i ~= #split then
			if i == 1 then
				element = string.split(element, "{")[2]
			end

			local splitValue = string.split(element, "=")

			local value = splitValue[2]
			local index = string.split(string.split(splitValue[1], "[")[2], "]")[1]

			-- convert index
			if tonumber(index) ~= nil then
				index = tonumber(index)
			end

			-- convert value
			if tonumber(value) ~= nil then
				value = tonumber(value)
			elseif stringToBool(value) ~= nil then
				value = stringToBool(value)
			elseif stringToCol3(value) ~= nil then
				value = stringToCol3(value)
			end

			result[index] = value
		end
	end

	return result
end

function stringToCol3(content)
	split = string.split(content, ",")
	
	local r = tonumber(string.split(split[1], "col3(")[2])
	local g = tonumber(split[2])
	local b = tonumber(string.split(split[3], ")")[1])

	if r ~= nil then r = r * 255 end
	if g ~= nil then g = g * 255 end
	if b ~= nil then b = b * 255 end

	return Color3.fromRGB(r,g,b)
end

function setPresetButtonText(text) UIElements.PresetName:SetText(text) end

function SavePreset(name)
	if name then
		local saved = ""

		for ElementName, UIElement in pairs(UIElements) do
			if ElementName ~= "PresetName" and ElementName ~= "PresetDropdown" then
				local toSave = nil
				local uiType

				local success, err = pcall(function()
					uiType = UIElement:GetType()
				end)

				if success then
					if uiType then
						local switchCase = {
							["Slider"] = function()
								toSave = UIElement:GetValue()
							end;

							["Toggle"] = function()
								toSave = UIElement:GetState()
							end;

							["TextField"] = function()
								toSave = UIElement:GetText()
							end;

							["ChipSet"] = function()
								toSave = UIElement:GetOptions()
							end;

							["Dropdown"] = function()
								toSave = UIElement:GetOptions()
							end;

							["ColorPicker"] = function()
								toSave = UIElement:GetColor()
							end;
						}

						local success, err = pcall(function() switchCase[uiType]() end)

						if success then
							if typeof(toSave) == "table" then
								saveContent = "{"

								for index, content in pairs(toSave) do
									local toSaveContent = content

									if typeof(content) == "boolean" then
										toSaveContent = boolToString(content)
									end

									saveContent = saveContent.."["..tostring(index).."]="..toSaveContent..","
								end

								saveContent = saveContent.. "}"
							elseif typeof(toSave) == "Color3" then
								saveContent = "col3("..tostring(toSave.R)..","..tostring(toSave.G)..","..tostring(toSave.B)..")"
							elseif typeof(toSave) == "boolean" then
								saveContent = boolToString(toSave)
							else
								saveContent = tostring(toSave)
							end

							saved = saved.. saveContent..";"..ElementName..";"..uiType.."/"
						end
					end
				end
			end
		end

		writefile("HDKHub/ProjectDelta/"..name..".txt", saved)

		HDKUi.Banner({Text = "Saved preset '".. name.. "'"})
		UIElements.PresetDropdown:SetOptions(getPresets())
	end
end

function LoadPreset(name)
	if name then
		local preset = readfile(getPresets(true)[name])

		if preset then
			local components = string.split(preset, "/")

			for _, stringComponent in pairs(components) do
				local tableComponent = string.split(stringComponent, ";")

				if #tableComponent == 3 then
					local switchCase = {
						["Slider"] = function()
							UIElements[tableComponent[2]]:SetValue(tonumber(tableComponent[1]))
						end;
						["Toggle"] = function()
							UIElements[tableComponent[2]]:SetState(stringToBool(tableComponent[1]))
						end;
						["TextField"] = function()
							UIElements[tableComponent[2]]:SetText(tableComponent[1])
						end;
						["ChipSet"] = function()
							local tab = stringToTable(tableComponent[1])
							UIElements[tableComponent[2]]:SetOptions(tab)
						end;
						["Dropdown"] = function()
							local tab = stringToTable(tableComponent[1])
							UIElements[tableComponent[2]]:SetOptions(tab)
						end;
						["ColorPicker"] = function()
							UIElements[tableComponent[2]]:SetColor(stringToCol3(tableComponent[1]))
						end;
					}

					switchCase[tableComponent[3]]()
				end
			end
		end
	end
end

--// RenderStepped

RunService.RenderStepped:Connect(function()
	updateTick = updateTick + 1

	if updateTick >= 2 then
		updateTick = 0

		--// FOV (for silent aim, player info, etc.)
		modules.FOV:Update()
		
		--// Player info
		modules.PlayerInfo:Update()

		--// Visuals
		modules.Visuals:Update()
	elseif updateTick == 1 then
		--// ESP
		modules.ESP:Update()
		
		--// Hide Visor
		modules.HideVisor:Update()
		
		--// Speedhack / Jumphack
		modules.Movehack:Update()
	end
end)

--// namecall hooks

local oldNamecalls = nil

oldNamecalls = hookmetamethod(game, "__namecall", function(inst, ...)
	local args = {...}
	local method = getnamecallmethod()
	local caller = getcallingscript()  


	if not checkcaller() then
		if inst.Parent == ReplicatedStorage.AmmoTypes and method == "GetAttribute" then
			if args[1] == "AccuracyDeviation" and _G.hdkMem.RemoveSpreadEnabled == true then
				return 0
			end
		end
	end

	return oldNamecalls(inst, ...)
end)

--// function hooks

local updClient = nil

updClient = hookfunction(require(game.ReplicatedStorage.Modules.FPS).updateClient, function(...)
	local args = {...}

	-- viewmodel offset
	if not _G.hdkMem.ViewmodelOffsetX then _G.hdkMem.ViewmodelOffsetX = 0 end
	if not _G.hdkMem.ViewmodelOffsetY then _G.hdkMem.ViewmodelOffsetY = 0 end
	if not _G.hdkMem.ViewmodelOffsetZ then _G.hdkMem.ViewmodelOffsetZ = 0 end

	if args[1].TempCFrame and (_G.hdkMem.ViewmodelOffsetX ~= 0 or _G.hdkMem.ViewmodelOffsetY ~= 0 or _G.hdkMem.ViewmodelOffsetZ ~= 0) then
		args[1].TempCFrame.Value = CFrame.new(_G.hdkMem.ViewmodelOffsetX * 0.01, _G.hdkMem.ViewmodelOffsetY * 0.01, _G.hdkMem.ViewmodelOffsetZ * 0.01)
	end

	-- unlock FireRate
	if _G.hdkMem.CustomFireRate and _G.hdkMem.CustomFireRate > 0 then
		args[1].FireRate = (1000 - _G.hdkMem.CustomFireRate) * 0.001
	end

	return updClient(table.unpack(args))
end)

end
}

local activeLoader = loaders[tostring(game.GameId)]

if activeLoader then
    coroutine.wrap(activeLoader)()
end

local hdkhub = Instance.new("ScreenGui")
hdkhub.Parent = game:GetService("CoreGui")
hdkhub.IgnoreGuiInset = true
hdkhub.Name = "HDKHub"
hdkhub.ResetOnSpawn = false
hdkhub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local tip = Instance.new("TextLabel")
tip.BackgroundTransparency = 1
tip.Size = UDim2.new(1,0,1,0)
tip.TextSize = 50
tip.FontFace = Font.fromName("Michroma")
tip.RichText = true
tip.TextColor3 = Color3.new(1,1,1)
tip.Parent = hdkhub

if activeLoader then
    tip.Text = '<u>Welcome to HDKHub! v'.. _G.hdkVer..'</u> <br/> <font size="30">This is a completely free exploit.<br/>Press END to lock / unlock your mouse cursor.</font>'
else
    tip.Text = '<u>Welcome to HDKHub! v'.. _G.hdkVer..'</u> <br/> <font size="30">The game you are playing is unsupported by HDKHub.</font>'
end

local tipHighlight = tip:Clone()
tipHighlight.Parent = hdkhub
tipHighlight.Position = UDim2.new(0,2,0,2)
tipHighlight.TextColor3 = Color3.fromRGB(85, 85, 85)
tipHighlight.ZIndex = 0

task.wait(5)

tip:Destroy()
tipHighlight:Destroy()