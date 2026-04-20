if not LPH_OBFUSCATED and not LPH_JIT_ULTRA then
	LPH_JIT_ULTRA = function(f) return f end
	LPH_JIT_MAX = function(f) return f end
	LPH_JIT = function(f) return f end
	LPH_ENCSTR = function(s) return s end
	LPH_STRENC = function(s) return s end
	LPH_CRASH = function() while true do end return end
end

--[Setup Table]
local executedTimer = tick()
repeat task.wait() until game:IsLoaded()

local InGameCheaters = {}
local InGameStaff = {}

table.insert(InGameCheaters, game:GetService("Players").LocalPlayer.UserId)
function CheckCheaterTable(UserID)
    for i, v in pairs(InGameCheaters) do
        if v == UserID then
            print("Cheater Found")
            return true
        end
    end
    return false
end

function CheckStaffTable(UserID)
    for i, v in pairs(InGameStaff) do
        if v == UserID then
            print("Staff Found")
            return true
        end
    end
    return false
end

function CheckCheaterTable2(UserID)
    print("Cheater Table: " .. InGameCheaters)
    for i, v in pairs(InGameCheaters) do
        print(i, v)
        if v == UserID then
            return false
        end
    end
    return true
end

function CheckStaffTable2(UserID)
    print("Staff Table: " .. InGameStaff)
    for i, v in pairs(InGameStaff) do
        print(i, v)
        if v == UserID then
            return false
        end
    end
    return true
end

local script_version_number = "Beta v3.3"
local last_updated = "30/11/2022"
local serverLabel

--[Main Variables]
local plrs       = game["Players"]
local ws         = game["Workspace"]
local Workspace  = game["Workspace"]
local uis        = game["UserInputService"]
local rs         = game["RunService"]
local hs         = game["HttpService"]
local cgui       = game["CoreGui"]
local lighting   = game["Lighting"]
local GuiService = game["GuiService"]
local repStorage = game["ReplicatedStorage"]
 
local Terrain    = ws:FindFirstChildOfClass("Terrain")
local plr        = plrs.LocalPlayer
local mouse      = plr:GetMouse()
local dwPlayers  = game.Players:GetPlayers()
local Camera     = ws.CurrentCamera
local VFXModule  = require(repStorage.Modules.VFX)
local ReplicatedPlayers = repStorage:FindFirstChild("Players")
local worldToViewportPoint = Camera.worldToViewportPoint


-- Aimbot
loadstring(game:HttpGet("https://www.octohook.xyz/infinity/aimbot2.lua"))()

local OrionLib  = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local library   = loadstring(game:HttpGet("https://raw.githubusercontent.com/Callumgm/Roblox-Scripts/main/ui.lua"))()
local watermark = library:Watermark("1NF1N17Y | 60 fps | 60ms | " .. script_version_number .. " | Paid")


local ESP, ESP_RenderStepped, Framework = loadstring(game:HttpGet("https://www.octohook.xyz/infinity/ESP.lua"))()
repeat task.wait() until ReplicatedPlayers

local Loaded, Running = false, true
local Keybinds = {
    Aimbot = "MouseButton2",
    Walkspeed = "Z",
    CameraZoom =  "X",
    FakeLag = "C",
}
local r15Parts = {'Head', 'LeftUpperArm', 'LeftLowerArm', 'LeftHand', 'RightUpperArm', 'RightLowerArm', 'RightHand', 'LeftUpperLeg', 'LeftLowerLeg', 'LeftFoot', 'RightUpperLeg', 'RightLowerLeg', 'RightFoot', 'UpperTorso', 'LowerTorso'};

KeybindViewer = {
    Size = Vector2.new(300, 14), 
    
    Main = Framework:Draw("Square", {Thickness = 0, Size = Vector2.new(175, 185), Filled = true, Position = Vector2.new(0, Camera.ViewportSize.Y / 2), Color = library.flags["Tab Background"], Visible = false}),
    Border = Framework:Draw("Square", {Thickness = 2, Size = Vector2.new(175, 185), Filled = false, Position = Vector2.new(0, Camera.ViewportSize.Y / 2), Color = library.flags["Window Background"], Visible = false}),
    TopBorder = Framework:Draw("Square", {Thickness = 1, Size = Vector2.new(169, 3), Filled = true, Position = Vector2.new(2, Camera.ViewportSize.Y / 2 + 2), Color = library.flags["Accent"], Visible = false}),
    
    Texts = {}
}
local Title = Framework:Draw("Text", {
    Text = "Keybinds", 
    Font = 3, 
    Size = 18, 
    Position = Vector2.new(KeybindViewer.Main.Position.X + 7, KeybindViewer.Main.Position.Y + 5), 
    Color = Color3.fromRGB(255,255,255),
    Visible = false, 
    Outline = true
})
table.insert(KeybindViewer.Texts, Title)
local WalkspeedKeybindOld = Framework:Draw("Text", {
    Text = "Walk Speed   [C]", 
    Font = 3, 
    Size = 16, 
    Position = Vector2.new(KeybindViewer.Main.Position.X + 30, KeybindViewer.Main.Position.Y + 40), 
    Color = Color3.fromRGB(255,255,255), 
    Visible = false, 
    Outline = true
})
table.insert(KeybindViewer.Texts, WalkspeedKeybindOld)
local WalkspeedKeybind = Framework:Draw("Text", {
    Text = "Camera Speed [V]", 
    Font = 3, 
    Size = 16, 
    Position = Vector2.new(KeybindViewer.Main.Position.X + 30, KeybindViewer.Main.Position.Y + 60), 
    Color = Color3.fromRGB(255,255,255), 
    Visible = false, 
    Outline = true
})
table.insert(KeybindViewer.Texts, WalkspeedKeybind)
local CameraZoomKeybind = Framework:Draw("Text", {
    Text = "Camera Zoom  [X]", 
    Font = 3, 
    Size = 16, 
    Position = Vector2.new(KeybindViewer.Main.Position.X + 30, KeybindViewer.Main.Position.Y + 80), 
    Color = Color3.fromRGB(255,255,255), 
    Visible = false, 
    Outline = true
})
table.insert(KeybindViewer.Texts, CameraZoomKeybind)
local ThirdPersonKeybind = Framework:Draw("Text", {
    Text = "Third Person [N]", 
    Font = 3, 
    Size = 16, 
    Position = Vector2.new(KeybindViewer.Main.Position.X + 30, KeybindViewer.Main.Position.Y + 100), 
    Color = Color3.fromRGB(255,255,255), 
    Visible = false, 
    Outline = true
})
table.insert(KeybindViewer.Texts, ThirdPersonKeybind)
local HipHeightKeybind = Framework:Draw("Text", {
    Text = "Hip Height   [L]", 
    Font = 3, 
    Size = 16, 
    Position = Vector2.new(KeybindViewer.Main.Position.X + 30, KeybindViewer.Main.Position.Y + 120), 
    Color = Color3.fromRGB(255,255,255), 
    Visible = false, 
    Outline = true
})
table.insert(KeybindViewer.Texts, HipHeightKeybind)
local UnlockDoorKeybind = Framework:Draw("Text", {
    Text = "Unlock Door  [O]", 
    Font = 3, 
    Size = 16, 
    Position = Vector2.new(KeybindViewer.Main.Position.X + 30, KeybindViewer.Main.Position.Y + 140), 
    Color = Color3.fromRGB(255,255,255), 
    Visible = false, 
    Outline = true
})
table.insert(KeybindViewer.Texts, UnlockDoorKeybind)
local AiAimbotKeybind = Framework:Draw("Text", {
    Text = "AI Aimbot    [I]", 
    Font = 3, 
    Size = 16, 
    Position = Vector2.new(KeybindViewer.Main.Position.X + 30, KeybindViewer.Main.Position.Y + 160), 
    Color = Color3.fromRGB(255,255,255), 
    Visible = false, 
    Outline = true
})
table.insert(KeybindViewer.Texts, AiAimbotKeybind)

 
--[Setup Table]

local Old_Gravity = workspace.Gravity
local Old_Decoration = gethiddenproperty(Terrain, "Decoration")
local Default_Walkspeed = plr.Character.Humanoid.WalkSpeed
local Old_FOV = Camera.FieldOfView
local Old_Lighting = {
    Ambient = lighting.Ambient,
    Brightness = lighting.Brightness,
    ColorShift_Bottom = lighting.ColorShift_Bottom,
    ColorShift_Top = lighting.ColorShift_Top,
    EnvironmentDiffuseScale = lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = lighting.EnvironmentSpecularScale,
    GlobalShadows = lighting.GlobalShadows,
    OutdoorAmbient = lighting.OutdoorAmbient,
    Technology = gethiddenproperty(lighting, "Technology"),
    ClockTime = lighting.ClockTime,
    TimeOfDay = lighting.TimeOfDay,
    ExposureCompensation = lighting.ExposureCompensation
}
local Old_Ammo = {
	["762x54AP"] = {
		["Drop"]  = repStorage.AmmoTypes["762x54AP"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["762x54AP"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["762x54AP"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["762x54AP"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["762x54AP"]:GetAttribute("ArmorPen")
	},
	["9x18AP"] = {
		["Drop"]  = repStorage.AmmoTypes["9x18AP"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["9x18AP"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["9x18AP"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["9x18AP"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["9x18AP"]:GetAttribute("ArmorPen")
	},
	["762x39AP"] = {
		["Drop"]  = repStorage.AmmoTypes["762x39AP"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["762x39AP"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["762x39AP"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["762x39AP"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["762x39AP"]:GetAttribute("ArmorPen")
	},
	["9x18Z"] = {
		["Drop"]  = repStorage.AmmoTypes["9x18Z"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["9x18Z"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["9x18Z"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["9x18Z"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["9x18Z"]:GetAttribute("ArmorPen")
	},
	["762x25Tracer"] = {
		["Drop"]  = repStorage.AmmoTypes["762x25Tracer"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["762x25Tracer"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["762x25Tracer"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["762x25Tracer"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["762x25Tracer"]:GetAttribute("ArmorPen")
	},
	["556x45Tracer"] = {
		["Drop"]  = repStorage.AmmoTypes["556x45Tracer"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["556x45Tracer"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["556x45Tracer"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["556x45Tracer"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["556x45Tracer"]:GetAttribute("ArmorPen")
	},
	["762x25AP"] = {
		["Drop"]  = repStorage.AmmoTypes["762x25AP"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["762x25AP"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["762x25AP"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["762x25AP"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["762x25AP"]:GetAttribute("ArmorPen")
	},
	["762x39Tracer"] = {
		["Drop"]  = repStorage.AmmoTypes["762x39Tracer"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["762x39Tracer"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["762x39Tracer"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["762x39Tracer"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["762x39Tracer"]:GetAttribute("ArmorPen")
	},
	["762x54Tracer"] = {
		["Drop"]  = repStorage.AmmoTypes["762x54Tracer"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["762x54Tracer"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["762x54Tracer"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["762x54Tracer"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["762x54Tracer"]:GetAttribute("ArmorPen")
	},
	["9x19Tracer"] = {
		["Drop"]  = repStorage.AmmoTypes["9x19Tracer"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["9x19Tracer"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["9x19Tracer"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["9x19Tracer"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["9x19Tracer"]:GetAttribute("ArmorPen")
	},
	["9x18Tracer"] = {
		["Drop"]  = repStorage.AmmoTypes["9x18Tracer"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["9x18Tracer"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["9x18Tracer"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["9x18Tracer"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["9x18Tracer"]:GetAttribute("ArmorPen")
	},
	["9x19AP"] = {
		["Drop"]  = repStorage.AmmoTypes["9x19AP"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["9x19AP"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["9x19AP"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["9x19AP"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["9x19AP"]:GetAttribute("ArmorPen")
	},
	["556x45AP"] = {
		["Drop"]  = repStorage.AmmoTypes["556x45AP"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["556x45AP"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["556x45AP"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["556x45AP"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["556x45AP"]:GetAttribute("ArmorPen")
	},
	["9x39Z"] = {
		["Drop"]  = repStorage.AmmoTypes["9x39Z"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["9x39Z"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["9x39Z"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["9x39Z"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["9x39Z"]:GetAttribute("ArmorPen")
	},
	["9x39AP"] = {
		["Drop"]  = repStorage.AmmoTypes["9x39AP"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["9x39AP"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["9x39AP"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["9x39AP"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["9x39AP"]:GetAttribute("ArmorPen")
	},
	["12gaSlug"] = {
		["Drop"]  = repStorage.AmmoTypes["12gaSlug"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["12gaSlug"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["12gaSlug"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["12gaSlug"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["12gaSlug"]:GetAttribute("ArmorPen"),
        ["Spread"] = repStorage.AmmoTypes["12gaSlug"]:GetAttribute("AccuracyDeviation")
	},
	["12gaBuckshot"] = {
		["Drop"] = repStorage.AmmoTypes["12gaBuckshot"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["12gaBuckshot"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["12gaBuckshot"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["12gaBuckshot"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["12gaBuckshot"]:GetAttribute("ArmorPen"),
        ["Spread"] = repStorage.AmmoTypes["12gaBuckshot"]:GetAttribute("AccuracyDeviation")
	},
	["12gaFlechette"] = {
		["Drop"] = repStorage.AmmoTypes["12gaFlechette"]:GetAttribute("ProjectileDrop"),
		["Speed"] = repStorage.AmmoTypes["12gaFlechette"]:GetAttribute("MuzzleVelocity"),
        ["Damage"] = repStorage.AmmoTypes["12gaFlechette"]:GetAttribute("Damage"),
        ["Pellets"] = repStorage.AmmoTypes["12gaFlechette"]:GetAttribute("Pellets"),
        ["ArmorPen"] = repStorage.AmmoTypes["12gaFlechette"]:GetAttribute("ArmorPen"),
        ["Spread"] = repStorage.AmmoTypes["12gaFlechette"]:GetAttribute("AccuracyDeviation")
	}
}
local esp = {
    players = {},
    objects = {},
    otherObjects = {},
    enabled = false,
    teamcheck = false,
    fontsize = 13,
    rainbowmode = false,
    rainbowcolor = Color3.fromHSV(0, 1, 1),
    font = 3,
    settings = {
        name = {enabled = false, outline = false, displaynames = false, color = Color3.fromRGB(255, 255, 255)},
        box = {enabled = false, outline = false, color = Color3.fromRGB(255, 255, 255)},
        tool = {enabled = false, outline = false, color = Color3.fromRGB(255, 255, 255)},
        healthbar = {enabled = false, outline = false},
        healthtext = {enabled = false, outline = false, color = Color3.fromRGB(255, 255, 255)},
        distance = {enabled = false, outline = false, color = Color3.fromRGB(255, 255, 255)},
        viewangle = {enabled = false, color = Color3.fromRGB(255, 255, 255)},
        tracers = {enabled = false, color = Color3.fromRGB(255, 255, 255)},
        skeleton = {enabled = false, color = Color3.fromRGB(255, 255, 255)},
        chams = {enabled = false, color = Color3.fromRGB(255, 255, 255)},
        chamsOutline = {enabled = false, color = Color3.fromRGB(255, 255, 255)},
    }
}

local function IsDown(EnumItem)
	return (EnumItem.EnumType == Enum.KeyCode and UserInputService:IsKeyDown(EnumItem)) or (EnumItem.EnumType == Enum.UserInputType and UserInputService:IsMouseButtonPressed(EnumItem))
end

local ThirdPersonToggled
local BanRemote
local Character = plr.Character
if Character then
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        for _, connection in pairs(getconnections(Humanoid.StateChanged)) do
            local Function = connection.Function
            local Constants = getconstants(Function)
            if table.find(Constants, "FireServer") then
                connection:Disable()
                local Upvalues = getupvalues(Function)
                for i, v in pairs(Upvalues) do
                    if typeof(v) == "Instance" and v:IsA("RemoteEvent") then
                        BanRemote = v
                    end
                end
            end
        end
    end
end
local LocalPlayerName = game:GetService("Players").LocalPlayer.Name
LPH_JIT_ULTRA(function()
	local emptyFunction = function() end
	__newindex = hookmetamethod(game, "__newindex", function(i, v, n_v)
		--if not Running or checkcaller() or not Loaded then return __newindex(i, v, n_v) end

		if i == Camera and v == "CFrame" then
			LastCameraCFrame = n_v
            if library.flags["thirdpersonEnabled"] and ThirdPersonToggled then
                return __newindex(i, v, n_v + Camera.CFrame.LookVector * - library.flags["thirdpersonValue"])
            end
			if library.flags["nocamerabobEnabled"] then
				local Script = getcallingscript()
				if tostring(Script) == "CharacterController" then
					return __newindex(i, v, Camera.CFrame)
				end
			end
		end
		return __newindex(i, v, n_v)
	end)
	__namecall = hookmetamethod(game, "__namecall", function(self, ...)
		local args = {...}
        
        -- Anti Error
		if getnamecallmethod() == "FireServer" and tostring(self) == "ErrorLog" then
			return
		end

        -- Anti Kick
		if getnamecallmethod() == "FireServer" and tostring(self) == "Kick" then
			return
		end
        
        -- Anti Drown
		if getnamecallmethod() == "FireServer" and tostring(self) == "Drowning" then
			if library.flags["antidrownEnabled"] then
				return
			end
		end
	
		return __namecall(self, ...)
	end)
end)()

function Bypass_Client()
	for i, v in pairs(getgc(true)) do
		if type(v) == "table" and rawget(v, "A1Sent") ~= nil then 
			rawset(v, "A1Sent", true)
		end
	end
end

local FPS = nil
for i, v in next, getgc(true) do
	if type(v) == "table" and rawget(v, "updateClient") then
		FPS = v
	end
end

local Visor
local Utility
Bypass_Client()
local FPS_new = FPS.new
FPS.new = function(...)
	local Call = FPS_new(...)
	Bypass_Client()
    for i, v in pairs(plr.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") then
            if v.Text:find("| Server") or v.Text:find(game.JobId:lower()) or v.Text:find(plr.UserId) or v.Text:find("Development") then
                serverLabel = v
            end
        end
    end
    if serverLabel then
        serverLabel:GetPropertyChangedSignal("Text"):Connect(LPH_JIT_ULTRA(function()
            if library.flags["noserverinfoEnabled"] then
                serverLabel.Text = ""
            end
        end))
    end
	task.spawn(function()
		local MainGui = plr.PlayerGui:WaitForChild("MainGui")
		if MainGui then 
			local MainFrame = MainGui:WaitForChild("MainFrame")
			if MainFrame then 
				local ScreenEffects = MainFrame:WaitForChild("ScreenEffects")
				Visor = ScreenEffects:WaitForChild("Visor")
				if Visor then
					Visor:GetPropertyChangedSignal("Visible"):Connect(function()
						if library.flags["novisorEnabled"] then
							Visor.Visible = false
						else
							Visor.Visible = true
						end
					end)
				end
			end
		end
	end)
	return Call
end
LPH_JIT_ULTRA(function()
    local function hookfunc(a,b)
        local old
        old = hookfunction(a,function(...)
            return old(b({...}))
        end)
    end
    do
        function a(...)
            if library.flags["norecoilEnabled"] then
                return 0
            end
            return unpack({...})
        end
        
        local old
        old = hookfunction(VFXModule.RecoilCamera, function(...)
            return old(a(...));
        end)
    end
end)()

local main = library:Load{
    Name = "1NF1N17Y - " .. script_version_number .. " - Paid - Last Updated: " .. last_updated,
    SizeX = 600,
    SizeY = 650,
    Theme = "Midnight",
    Extension = "json", 
    Folder = "1NF1N17Y Configs" 
}

--* Tabs *--
local Tabs = {
    Combat = main:Tab("Combat"),
    Visuals = main:Tab("Visuals"),
    Misc = main:Tab("Misc"),
    Credits = main:Tab("Credits"),
}

--* Sections *--
local Sections = {
    Combat = {
        Aimbot = Tabs.Combat:Section{Name = "Aimbot", Side = "Left"},
        FOVCircle = Tabs.Combat:Section{Name = "FOVCircle", Side = "Right"},
        WeaponMods = Tabs.Combat:Section{Name = "Weapon Mods", Side = "Right"},
    },
    Visuals = {
        ESP = Tabs.Visuals:Section{Name = "ESP", Side = "Left"},
        Objects = Tabs.Visuals:Section{Name = "Objects", Side = "Left"},
        InventoryScanner = Tabs.Visuals:Section{Name = "Inventory Viewer", Side = "Right"},
        FreeCamera = Tabs.Visuals:Section{Name = "Free Camera", Side = "Right"},
        RainbowSettings = Tabs.Visuals:Section{Name = "Rainbow ESP", Side = "Right"},
    },
    Misc = {
        Lighting = Tabs.Misc:Section{Name = "Lighting", Side = "Left"},
        Removals = Tabs.Misc:Section{Name = "Removals", Side = "Right"},
        LocalPlayer = Tabs.Misc:Section{Name = "Local Player", Side = "Left"},
        Misc = Tabs.Misc:Section{Name = "Misc", Side = "Right"},
        ChatSpammer = Tabs.Misc:Section{Name = "Misc", Side = "Left"},
    },
    Credits = {
        Changelog = Tabs.Credits:Section{Name = "Changelog", Side = "Left"},
        Credits = Tabs.Credits:Section{Name = "Credits", Side = "Right"},
    },
}

--* Aimbot *--
local AimbotToggle = Sections.Combat.Aimbot:Toggle{
    Name = "Enabled",
    Flag = "aimbotEnabled",
    Default = false,
    Callback  = function(bool)
        getgenv().Aimbot.Settings.Enabled = bool
    end
}

AimbotToggle:Keybind{
    Default = Enum.UserInputType.MouseButton2,
    Blacklist = {Enum.UserInputType.MouseButton1},
    Flag = "aimbotKeybind",
    Mode = "nil", -- mode to nil if u dont want it to toggle the toggle
    Callback = function(key, fromsetting)
        local key = tostring(key):gsub("Enum.UserInputType.", "")
        getgenv().Aimbot.Settings.TriggerKey = key
    end
}

local SilentAim = Sections.Combat.Aimbot:Toggle{
    Name = "Silent Aim",
    Flag = "silentaimEnabled",
    -- Default = false,
    Callback  = function(bool)
        getgenv().Aimbot.Settings.SilentAimEnabled = bool
    end
}
SilentAim:Slider{
    Text = "Misschance: [value]/100",
    Default = 0,
    Min = 0,
    Max = 100,
    Float = 1,
    Flag = "silentaimMisschance",
    Callback = function(value)
        getgenv().Aimbot.Settings.SilentAimMisschance = value
    end
}

local AiAimbotToggled = false
local AIAimbot = Sections.Combat.Aimbot:Toggle{
    Name = "AI Aimbot",
    Flag = "aiaimbotEnabled",
    -- Default = false,
    Callback  = function(bool)
        getgenv().Aimbot.Settings.AiAimbotEnabled = bool
    end
}
AIAimbot:Keybind{
    Default = Enum.KeyCode.I,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3},
    Flag = "cameraFOVZoomKeybind",
    Mode = "nill", -- mode to nil if u dont want it to toggle the toggle
    Callback = function(key, fromsetting)
        if library.flags["aiaimbotEnabled"] then
            local key = tostring(key):gsub("Enum.KeyCode.", "")
            AiAimbotKeybind.Text = "AI Aimbot    [" .. key .. "]"
        end
        if not fromsetting then
            AiAimbotToggled = not AiAimbotToggled
            if AiAimbotToggled then
                AiAimbotKeybind.Color = Color3.fromRGB(0, 255, 0)
                getgenv().Aimbot.Settings.AiAimbotEnabled = true
                AIAimbot:Toggle(true)
            else
                AiAimbotKeybind.Color = Color3.fromRGB(255, 255, 255)
                getgenv().Aimbot.Settings.AiAimbotEnabled = false
                AIAimbot:Toggle(false)
            end
        end
    end
}

Sections.Combat.Aimbot:Toggle{
    Name = "Friend Check",
    Flag = "aimbotfriendcheckEnabled",
    -- Default = false,
    Callback  = function(bool)
        getgenv().Aimbot.Settings.TeamCheck = bool
    end
}

Sections.Combat.Aimbot:Toggle{
    Name = "Wall Bang Check",
    Flag = "aimbotallbangcheckEnabled",
    -- Default = false,
    Callback = function(bool)
        getgenv().Aimbot.Settings.WallBang = bool
    end
}
Sections.Combat.Aimbot:Toggle{
    Name = "Visible Check",
    Flag = "visiblecheckEnabled",
    -- Default = false,
    Callback = function(bool)
        getgenv().Aimbot.Settings.WallCheck = bool
    end
}
local aimbotSnaplines = Sections.Combat.Aimbot:Toggle{
    Name = "Snap Lines",
    Flag = "snaplinesEnabled",
    -- Default = false,
    Callback = function(bool)
        getgenv().Aimbot.Settings.SnapLines = bool
    end
}
aimbotSnaplines:ColorPicker{
    Default = Color3.fromRGB(255, 0, 0), 
    Flag = "snaplinesColor",
    Callback = function(color)
        getgenv().Aimbot.Settings.SnapLineColor = string.format("%s, %s, %s", math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255))
    end
}

local aimbotPrediction = Sections.Combat.Aimbot:Toggle{
    Name = "Prediction",
    Flag = "predictionEnabled",
    -- Default = false,
    Callback = function(bool)
        getgenv().Aimbot.Settings.Prediction = bool
    end
}
aimbotPrediction:Slider{
    Text = "Strength: [value]/25",
    Default = 5,
    Min = 0,
    Max = 25,
    Float = 0.05,
    Flag = "predictionMultiplier",
    Callback = function(value)
        getgenv().Aimbot.Settings.PredictionMultiplier = value
    end
}

Sections.Combat.Aimbot:Separator("Aimbot Settings")

Sections.Combat.Aimbot:Dropdown{
    Name = "Walls To Check",
    Default = {"Wood", "WoodPlanks", "Fabric"},
    Max = 5, -- makes it multi
    Content = {"Wood", "WoodPlanks", "Fabric", "CorrodedMetal", "Plastic"},
    Flag = "aimbotallbangcheckDropdown",
    Callback = function(option)
        local Walls = {}
        for i,v in pairs(library.flags["aimbotallbangcheckDropdown"]) do
            table.insert(Walls, v)
            print(v)
        end
        for i,v in pairs(Walls) do
            print(v)
        end
        getgenv().Aimbot.Settings.WallTypes = Walls
    end
}

Sections.Combat.Aimbot:Dropdown{
    Name = "Snap Part",
    Default = "Head",
    Content = {
        "Head",
        "FaceHitBox",
        "UpperTorso",
        "LowerTorso",
    },
    Flag = "aimbotSnapPart",
    Callback = function(option)
        getgenv().Aimbot.Settings.LockPart = tostring(option)
    end
}

Sections.Combat.Aimbot:Slider{
    Name = "Sensitivity",
    Text = "[value] ms",
    Default = 0,
    Min = 0,
    Max = 1,
    Float = 0.01,
    Flag = "aimbotSensitivity",
    Callback = function(value)
        getgenv().Aimbot.Settings.Sensitivity = value
    end
}

Sections.Combat.Aimbot:Slider{
    Name = "Max Aim Distance",
    Text = "[value] m",
    Default = 1000,
    Min = 0,
    Max = 5000,
    Float = 1,
    Flag = "aimbotMaxDistance",
    Callback = function(value)
        getgenv().Aimbot.Settings.MaxDistance = value
    end
}


--* FOV Circle *--
local fovCircle = Sections.Combat.FOVCircle:Toggle{
    Name = "Enabled",
    Flag = "fovcircleEnabled",
    -- Default = false,
    Callback = function(bool)
        getgenv().Aimbot.FOVSettings.Enabled = bool
    end
}
fovCircle:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "fovcircleColor",
    Callback = function(color)
        getgenv().Aimbot.FOVSettings.Color = string.format("%s, %s, %s", math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255))
    end
}

Sections.Combat.FOVCircle:Slider{
    Name = "Size",
    Text = "[value]",
    Default = 90,
    Min = 1,
    Max = Camera.ViewportSize.X / 2 + 200,
    Float = 1,
    Flag = "fovcircleSize",
    Callback = function(value)
        getgenv().Aimbot.FOVSettings.Amount = value
    end
}

Sections.Combat.FOVCircle:Slider{
    Name = "Sides",
    Text = "[value]",
    Default = 50,
    Min = 1,
    Max = 65,
    Float = 1,
    Flag = "fovcircleSides",
    Callback = function(value)
        getgenv().Aimbot.FOVSettings.Sides = value
    end
}
getgenv().Aimbot.FOVSettings.Thickness = 1
Sections.Combat.FOVCircle:Slider{
    Name = "Thickness",
    Text = "[value]",
    Default = 1,
    Min = 1,
    Max = 10,
    Float = 1,
    Flag = "fovcircleThickness",
    Callback = function(value)
        getgenv().Aimbot.FOVSettings.Thickness = value
    end
}

--* Weapon Mods *--
local OldWeaponMods_QuickReload = {}
local OldWeaponMods_QuickAim    = {}
local OldWeaponMods_Sway        = {}
local OldWeaponMods_NoRecoil    = {}
Sections.Combat.WeaponMods:Toggle{
    Name = "Quicker Reload",
    Flag = "quickerreloadEnabled",
    -- Default = false,
    Callback = function(bool)
        if bool then
            OldWeaponMods_QuickReload = {}
            for i,v in next, game.ReplicatedStorage.Players[game.Players.LocalPlayer.Name].Inventory:GetChildren() do
                local module = require(v.SettingsModule)

                table.insert(OldWeaponMods_QuickReload, module.ReloadFadeIn)
                table.insert(OldWeaponMods_QuickReload, module.ReloadFadeOut)
                table.insert(OldWeaponMods_QuickReload, module.ReloadFadeInTimePos)
                table.insert(OldWeaponMods_QuickReload, module.ReloadFadeOutTimePos)

                module.ReloadFadeIn = 0
                module.ReloadFadeOut = 0
                module.ReloadFadeInTimePos = 0
                module.ReloadFadeOutTimePos = 0
            end
        else
            for i,v in next, game.ReplicatedStorage.Players[game.Players.LocalPlayer.Name].Inventory:GetChildren() do
                local module = require(v.SettingsModule)
                
                for i2,v2 in next, OldWeaponMods_QuickReload do
                    module.ReloadFadeIn = v2
                    module.ReloadFadeOut = v2
                    module.ReloadFadeInTimePos = v2
                    module.ReloadFadeOutTimePos = v2
                end
            end
        end
    end
}
Sections.Combat.WeaponMods:Toggle{
    Name = "Quick Aim",
    Flag = "quickaimEnabled",
    -- Default = false,
    Callback = function(bool)
        if bool then
            OldWeaponMods_QuickAim = {}
            for i,v in next, game.ReplicatedStorage.Players[game.Players.LocalPlayer.Name].Inventory:GetChildren() do
                local module = require(v.SettingsModule)

                table.insert(OldWeaponMods_QuickAim, module.AimInSpeed)
                table.insert(OldWeaponMods_QuickAim, module.AimOutSpeed)

                module.AimInSpeed = 0
                module.AimOutSpeed = 0
            end
        else
            for i,v in next, game.ReplicatedStorage.Players[game.Players.LocalPlayer.Name].Inventory:GetChildren() do
                local module = require(v.SettingsModule)

                for i2,v2 in next, OldWeaponMods_QuickAim do
                    module.AimInSpeed = v2
                    module.AimOutSpeed = v2
                end
            end
        end
    end
}
Sections.Combat.WeaponMods:Toggle{
    Name = "No Recoil",
    Flag = "norecoilEnabled",
    -- Default = false,
    Callback = function(bool)
        if bool then
            OldWeaponMods_NoRecoil = {}
            for i,v in next, game.ReplicatedStorage.Players[game.Players.LocalPlayer.Name].Inventory:GetChildren() do
                local module = require(v.SettingsModule)

                table.insert(OldWeaponMods_Sway, module.MaxRecoil)
                table.insert(OldWeaponMods_Sway, module.RecoilTValueMax)
                table.insert(OldWeaponMods_Sway, module.RecoilReductionMax)

                module.MaxRecoil = 0
                module.RecoilTValueMax = 0
                module.RecoilReductionMax = 0
            end
        else
            for i,v in next, game.ReplicatedStorage.Players[game.Players.LocalPlayer.Name].Inventory:GetChildren() do
                local module = require(v.SettingsModule)

                for i2,v2 in next, OldWeaponMods_NoRecoil do
                    module.MaxRecoil = v2
                    module.RecoilTValueMax = v2
                    module.RecoilReductionMax = v2
                end
            end
        end
    end
}
Sections.Combat.WeaponMods:Toggle{
    Name = "No Bullet Drop",
    Flag = "nobulletdropEnabled",
    -- Default = false,
    Callback = function(bool)
        for _, Item in pairs(repStorage.AmmoTypes:GetChildren()) do
            if bool then
                Item:SetAttribute("ProjectileDrop", 0)
            else
                Item:SetAttribute("ProjectileDrop", Old_Ammo[Item.Name]["Drop"])
            end
        end
    end
}
Sections.Combat.WeaponMods:Toggle{
    Name = "No Shotgun Spread",
    Flag = "noshotgunspreadEnabled",
    -- Default = false,
    Callback = function(bool)
        for _, Item in pairs(repStorage.AmmoTypes:GetChildren()) do
            if bool and Item:GetAttribute("AccuracyDeviation") ~= nil then
                Item:SetAttribute("AccuracyDeviation", 0)
            elseif Item:GetAttribute("AccuracyDeviation") ~= nil and not bool then
                Item:SetAttribute("AccuracyDeviation", Old_Ammo[Item.Name]["Spread"])
            end
        end
    end
}
Sections.Combat.WeaponMods:Toggle{
    Name = "No Muzzle Flash",
    Flag = "nomuzzleflashEnabled",
    -- Default = false,
    Callback = function(bool)
        for i,v in pairs(repStorage.RangedWeapons:GetChildren()) do
            v:SetAttribute("MuzzleEffect", not bool)
        end
    end
}
Sections.Combat.WeaponMods:Toggle{
    Name = "Hard Damage Bullets",
    Flag = "hardbulletsEnabled",
    -- Default = false,
    Callback = function(bool)
        for _, Item in pairs(repStorage.AmmoTypes:GetChildren()) do
            if bool then
                Item:SetAttribute("ArmorPen", Old_Ammo[Item.Name]["ArmorPen"] * 3)
                Item:SetAttribute("Damage", Old_Ammo[Item.Name]["Damage"] * 3)
            else
                Item:SetAttribute("ArmorPen", Old_Ammo[Item.Name]["ArmorPen"])
                Item:SetAttribute("Damage", Old_Ammo[Item.Name]["Damage"])
            end
        end
    end
}
Sections.Combat.WeaponMods:Toggle{
    Name = "Double Bullet",
    Flag = "doublebulletEnabled",
    -- Default = false,
    Callback = function(bool)
        for _, Item in pairs(repStorage.AmmoTypes:GetChildren()) do
            if bool and Item:GetAttribute("Pellets") ~= nil then
                Item:SetAttribute("Pellets", Old_Ammo[Item.Name]["Pellets"] * 2)
            elseif not bool and Item:GetAttribute("Pellets") ~= nil then
                Item:SetAttribute("Pellets", Old_Ammo[Item.Name]["Pellets"])
            end
        end
    end
}
-- local rapidfireEnabledd = false
-- local FireRate = Sections.Combat.WeaponMods:Toggle{
--     Name = "Fire Rate",
--     Flag = "rapidfireEnabled",
--     -- Default = false,
--     Callback = function(bool)
--         if bool and not rapidfireEnabledd then
--             rapidfireEnabledd = true
--             for i,v in next, game.ReplicatedStorage.Players[game.Players.LocalPlayer.Name].Inventory:GetChildren() do
--                 local module = require(v.SettingsModule)

--                 module.FireRate = library.flags["firerateValue"]
--                 module.FireModes = { "Semi", "Auto" }
--                 module.FireMode = 'Auto'
--             end
--         end
--     end
-- }
-- FireRate:Slider{
--     Text = "[value] ms",
--     Default = 0,
--     Min = 0,
--     Max = 1,
--     Float = 0.0001,
--     Flag = "firerateValue",
--     Callback = function(value)
        
--     end
-- }

-- * ESP * --
Sections.Visuals.ESP:Toggle{
    Name = "Enabled",
    Flag = "espEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.enabled = bool
    end
}
local espFriendCheck = Sections.Visuals.ESP:Toggle{
    Name = "Friend Check",
    Flag = "friendcheckEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
espFriendCheck:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "friendcheckColor",
    Callback = function(color)
        
    end
}
local espName = Sections.Visuals.ESP:Toggle{
    Name = "Name",
    Flag = "espnameEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.settings.name.enabled = bool
    end
}
espName:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "espnameColor",
    Callback = function(color)
        esp.settings.name.color = color
    end
}
local espBox = Sections.Visuals.ESP:Toggle{
    Name = "Box",
    Flag = "espboxEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.settings.box.enabled = bool
    end
}
espBox:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "espboxColor",
    Callback = function(color)
        esp.settings.box.color = color
    end
}
local espTool = Sections.Visuals.ESP:Toggle{
    Name = "Tool",
    Flag = "esptoolEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.settings.tool.enabled = bool
    end
}
espTool:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "esptoolColor",
    Callback = function(color)
        esp.settings.tool.color = color
    end
}
Sections.Visuals.ESP:Toggle{
    Name = "Health Bar",
    Flag = "esphealthbarEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.settings.healthbar.enabled = bool
    end
}
local espHealthText = Sections.Visuals.ESP:Toggle{
    Name = "Health Text",
    Flag = "esphealthtextEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.settings.healthtext.enabled = bool
    end
}
espHealthText:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "esphealthtextColor",
    Callback = function(color)
        esp.settings.healthtext.color = color
    end
}
local espDistance = Sections.Visuals.ESP:Toggle{
    Name = "Distance",
    Flag = "espdistanceEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.settings.distance.enabled = bool
    end
}
espDistance:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "espdistanceColor",
    Callback = function(color)
        esp.settings.distance.color = color
    end
}
local espViewAngle = Sections.Visuals.ESP:Toggle{
    Name = "View Angle",
    Flag = "espviewangleEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.settings.viewangle.enabled = bool
    end
}
espViewAngle:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "espviewangleColor",
    Callback = function(color)
        esp.settings.viewangle.color = color
    end
}
local espTracers = Sections.Visuals.ESP:Toggle{
    Name = "Tracers",
    Flag = "esptracersEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.settings.tracers.enabled = bool
    end
}
espTracers:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "esptracersColor",
    Callback = function(color)
        esp.settings.tracers.color = color
    end
}
local espSkeleton = Sections.Visuals.ESP:Toggle{
    Name = "Skeleton",
    Flag = "espskeletonEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.settings.skeleton.enabled = bool
    end
}
espSkeleton:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "espskeletonColor",
    Callback = function(color)
        esp.settings.skeleton.color = color
    end
}
local espChams = Sections.Visuals.ESP:Toggle{
    Name = "Chams",
    Flag = "espchamsEnabled",
    -- Default = false,
    Callback = function(bool)   
        esp.settings.chams.enabled = bool
    end
}
espChams:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "espchamsColor",
    Callback = function(color)
        esp.settings.chams.color = color
    end
}
local espChamsOutline = Sections.Visuals.ESP:Toggle{
    Name = "Chams Outline",
    Flag = "espchamsoutlineEnabled",
    -- Default = false,
    Callback = function(bool)   
        esp.settings.chamsOutline.enabled = bool
    end
}
espChamsOutline:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "espchamsoutlineColor",
    Callback = function(color)
        esp.settings.chamsOutline.color = color
    end
}
Sections.Visuals.ESP:Separator("ESP Settings")
Sections.Visuals.ESP:Dropdown{
    Name = "Tracer Location",
    Default = "Bottom",
    Content = {
        "Bottom",
        "Middle",
    },
    Flag = "tracerFromLocation",
    Callback = function(option)
        
    end
}
Sections.Visuals.ESP:Slider{
    Name = "Max Distance",
    Text = "[value] m",
    Default = 1000,
    Min = 1,
    Max = 8000,
    Float = 1,
    Flag = "espMaxDistance",
    Callback = function(value)
    end
}
Sections.Visuals.ESP:Slider{
    Name = "Font Size",
    Text = "[value]/13",
    Default = 13,
    Min = 5,
    Max = 30,
    Float = 0.01,
    Flag = "espFontSize",
    Callback = function(value)
        esp.fontsize = value
    end
}


--* Object Visuals *--
LPH_JIT_MAX(function()
    local objectConnections = {}
    Sections.Visuals.Objects:Toggle{
        Name = "Enabled",
        Flag = "espobjectsEnabled",
        -- Default = false,
        Callback = function(bool)
            ESP:Toggle(bool)
            ESP.Settings.Objects_Enabled = bool
        end
    }
    local AiZones = Workspace:FindFirstChild("AiZones")
    if AiZones then
        for _, Zone in pairs(AiZones:GetChildren()) do
            Zone.ChildAdded:Connect(function(Child)
                if Child:IsA("Model") then
                    if Child.PrimaryPart and library.flags["espobjectsEnabled"] and library.flags["espobjectsaientitiesEnabled"] then
                        ESP:Object(Child, {
                            Type = "Bandit",
                            Color = library.flags["espobjectsaientitiesColor"]
                        })
                    end
                    if objectConnections[Child] == nil then
                        objectConnections[Child] = Child:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
                            if Child.PrimaryPart == nil then
                                local Object = ESP:GetObject(Child)
                                if Object then
                                    Object:Destroy()
                                end
                            elseif library.flags["espobjectsEnabled"] and library.flags["espobjectsaientitiesEnabled"] then
                                ESP:Object(Child, {
                                    Type = "Bandit",
                                    Color = library.flags["espobjectsaientitiesColor"]
                                })
                            end
                        end)
                    end
                end
            end)
            Zone.ChildRemoved:Connect(function(Child)
                if Child:IsA("Model") then
                    local Object = ESP:GetObject(Child)
                    if Object then
                        Object:Destroy()
                    end
                end
            end)
        end
        local espobjectsAiEntities = Sections.Visuals.Objects:Toggle{
            Name = "AI Entities",
            Flag = "espobjectsaientitiesEnabled",
            -- Default = false,
            Callback = function(bool)
                if bool then
                    for _, Zone in pairs(AiZones:GetChildren()) do
                        for _, Item in pairs(Zone:GetChildren()) do
                            ESP:Object(Item, {
                                Type = "Bandit",
                                Color = library.flags["espobjectsaientitiesColor"]
                            })
                            if objectConnections[Item] == nil then
                                objectConnections[Item] = Item:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
                                    if Item.PrimaryPart == nil then
                                        local Object = ESP:GetObject(Item)
                                        if Object then
                                            Object:Destroy()
                                        end
                                    elseif library.flags["espobjectsEnabled"] and library.flags["espobjectsaientitiesEnabled"] then
                                        ESP:Object(Item, {
                                            Type = "Bandit",
                                            Color = library.flags["espobjectsaientitiesColor"]
                                        })
                                    end
                                end)
                            end
                        end
                    end
                else
                    for _, Object in pairs(ESP.Objects) do
                        if Object.Type == "Bandit" then
                            Object:Destroy()
                        end
                    end
                end
            end
        }
        espobjectsAiEntities:ColorPicker{
            Default = Color3.fromRGB(255, 255, 255), 
            Flag = "espobjectsaientitiesColor",
            Callback = function(color)
                for _, Object in pairs(ESP.Objects) do
                    if Object.Type == "Bandit" then
                        for _, Drawing in pairs(Object.Components) do
                            Drawing.Color = color
                        end
                    end
                end
            end
        }
    end
    local DroppedItems = Workspace:FindFirstChild("DroppedItems")
    if DroppedItems then
        DroppedItems.ChildAdded:Connect(function(Child)
            if Child:IsA("Model") then
                if Child.PrimaryPart and library.flags["espobjectsEnabled"] and library.flags["espobjectsdroppeditemsEnabled"] then
                    ESP:Object(Child, {
                        Type = "Dropped",
                        Color = library.flags["espobjectsdroppeditemsColor"]
                    })
                end
                if objectConnections[Child] == nil then
                    objectConnections[Child] = Child:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
                        if Child.PrimaryPart == nil then
                            local Object = ESP:GetObject(Child)
                            if Object then
                                Object:Destroy()
                            end
                        elseif library.flags["espobjectsEnabled"] and library.flags["espobjectsdroppeditemsEnabled"] then
                            ESP:Object(Child, {
                                Type = "Dropped",
                                Color = library.flags["espobjectsdroppeditemsColor"]
                            })
                        end
                    end)
                end
            end
        end)
        DroppedItems.ChildRemoved:Connect(function(Child)
            if Child:IsA("Model") then
                local Object = ESP:GetObject(Child)
                if Object then
                    Object:Destroy()
                end
            end
        end)
        local espobjectsDroppedItems = Sections.Visuals.Objects:Toggle{
            Name = "Dropped Items",
            Flag = "espobjectsdroppeditemsEnabled",
            -- Default = false,
            Callback = function(bool)
                if bool then
                    for _, Item in pairs(DroppedItems:GetChildren()) do
                        ESP:Object(Item, {
                            Type = "Dropped",
                            Color = library.flags["espobjectsdroppeditemsColor"]
                        })
                        if objectConnections[Item] == nil then
                            objectConnections[Item] = Item:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
                                if Item.PrimaryPart == nil then
                                    local Object = ESP:GetObject(Item)
                                    if Object then
                                        Object:Destroy()
                                    end
                                elseif library.flags["espobjectsEnabled"] and library.flags["espobjectsdroppeditemsEnabled"] then
                                    ESP:Object(Item, {
                                        Type = "Dropped",
                                        Color = library.flags["espobjectsdroppeditemsColor"]
                                    })
                                end
                            end)
                        end
                    end
                else
                    for _, Object in pairs(ESP.Objects) do
                        if Object.Type == "Dropped" then
                            Object:Destroy()
                        end
                    end
                end
            end
        }
        espobjectsDroppedItems:ColorPicker{
            Default = Color3.fromRGB(255, 255, 255), 
            Flag = "espobjectsdroppeditemsColor",
            Callback = function(color)
                for _, Object in pairs(ESP.Objects) do
                    if Object.Type == "Dropped" then
                        for _, Drawing in pairs(Object.Components) do
                            Drawing.Color = color
                        end
                    end
                end
            end
        }
    end
    local NoCollision = Workspace:FindFirstChild("NoCollision")
    if NoCollision then
        local ExitLocations = NoCollision:FindFirstChild("ExitLocations")
        if ExitLocations then
            ExitLocations.ChildAdded:Connect(function(Child)
                if Child:IsA("BasePart") then
                    if library.flags["espobjectsEnabled"] and library.flags["espobjectsextractsEnabled"] then
                        ESP:Object(Child, {
                            Type = "Exit",
                            Color = library.flags["espobjectsextractsColor"]
                        })
                    end
                end
            end)
            ExitLocations.ChildRemoved:Connect(function(Child)
                if Child:IsA("BasePart") then
                    local Object = ESP:GetObject(Child)
                    if Object then
                        Object:Destroy()
                    end
                end
            end)
            local espobjectsExtracts = Sections.Visuals.Objects:Toggle{
                Name = "Extracts",
                Flag = "espobjectsextractsEnabled",
                -- Default = false,
                Callback = function(bool)
                    if bool then
                        for _, Item in pairs(ExitLocations:GetChildren()) do
                            if Item:IsA("BasePart") then
                                ESP:Object(Item, {
                                    Type = "Exit",
                                    Color = library.flags["espobjectsextractsColor"]
                                })
                            end
                        end
                    else
                        for _, Object in pairs(ESP.Objects) do
                            if Object.Type == "Exit" then
                                Object:Destroy()
                            end
                        end
                    end
                end
            }
            espobjectsExtracts:ColorPicker{
                Default = Color3.fromRGB(255, 255, 255), 
                Flag = "espobjectsextractsColor",
                Callback = function(color)
                    for _, Object in pairs(ESP.Objects) do
                        if Object.Type == "Exit" then
                            for _, Drawing in pairs(Object.Components) do
                                Drawing.Color = color
                            end
                        end
                    end
                end
            }
        end
    end
    local LockedDoors = Workspace:FindFirstChild("Door")
    if LockedDoors then
        LockedDoors.ChildAdded:Connect(function(Child)
            if Child.Name == "Hinge" then
                if v:FindFirstChild("Unlock") then
                    if library.flags["espobjectsEnabled"] and library.flags["espobjectslockeddoorsEnabled"] then
                        ESP:Object(Child, {
                            Name = "Locked Door",
                            Type = "Locked Door",
                            Color = library.flags["espobjectslockeddoorsColor"]
                        })
                    end
                end
            end
        end)
        LockedDoors.ChildRemoved:Connect(function(Child)
            if Child:IsA("BasePart") then
                local Object = ESP:GetObject(Child)
                if Object then
                    Object:Destroy()
                end
            end
        end)
        local espobjectsLockedDoors = Sections.Visuals.Objects:Toggle{
            Name = "Locked Doors",
            Flag = "espobjectslockeddoorsEnabled",
            -- Default = false,
            Callback = function(bool)
                if bool then
                    for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
                        if v.Name == "Hinge" then
                            if v:FindFirstChild("Unlock") then
                                ESP:Object(v, {
                                    Name = "Locked Door",
                                    Type = "Locked Door",
                                    Color = library.flags["espobjectslockeddoorsColor"]
                                })
                            end
                        end
                    end
                else
                    for _, Object in pairs(ESP.Objects) do
                        if Object.Type == "Locked Door" then
                            Object:Destroy()
                        end
                    end
                end
            end
        }
        espobjectsLockedDoors:ColorPicker{
            Default = Color3.fromRGB(255, 255, 255), 
            Flag = "espobjectslockeddoorsColor",
            Callback = function(color)
                for _, Object in pairs(ESP.Objects) do
                    if Object.Type == "Locked Door" then
                        for _, Drawing in pairs(Object.Components) do
                            Drawing.Color = color
                        end
                    end
                end
            end
        }
    end
    local VehiclesUAZ = Workspace:FindFirstChild("Vehicles")
    if VehiclesUAZ then
        VehiclesUAZ.ChildAdded:Connect(function(Child)
            if Child.Name == "UAZ" then
                if v:FindFirstChild("Body") then
                    if library.flags["espobjectsEnabled"] and library.flags["espobjectsvehiclesEnabled"] then
                        ESP:Object(Child.Body, {
                            Name = "Vehicle",
                            Type = "Vehicle",
                            Color = library.flags["espobjectsvehiclesColor"]
                        })
                    end
                end
            end
        end)
        VehiclesUAZ.ChildRemoved:Connect(function(Child)
            if Child:IsA("BasePart") then
                local Object = ESP:GetObject(Child)
                if Object then
                    Object:Destroy()
                end
            end
        end)
        local espobjectsVehicles = Sections.Visuals.Objects:Toggle{
            Name = "Vehicles",
            Flag = "espobjectsvehiclesEnabled",
            -- Default = false,
            Callback = function(bool)
                if bool then
                    for _, v in pairs(game:GetService("Workspace").Vehicles:GetDescendants()) do
                        if v.Name == "UAZ" then
                            if v:FindFirstChild("Body") then
                                ESP:Object(v.Body, {
                                    Name = "Vehicle",
                                    Type = "Vehicle",
                                    Color = library.flags["espobjectsvehiclesColor"]
                                })
                            end
                        end
                    end
                else
                    for _, Object in pairs(ESP.Objects) do
                        if Object.Type == "Vehicle" then
                            Object:Destroy()
                        end
                    end
                end
            end
        }
        espobjectsVehicles:ColorPicker{
            Default = Color3.fromRGB(255, 255, 255), 
            Flag = "espobjectsvehiclesColor",
            Callback = function(color)
                for _, Object in pairs(ESP.Objects) do
                    if Object.Type == "Vehicle" then
                        for _, Drawing in pairs(Object.Components) do
                            Drawing.Color = color
                        end
                    end
                end
            end
        }
    end

    Sections.Visuals.Objects:Slider{
        Name = "Max Distance",
        Text = "[value] m",
        Default = 1000,
        Min = 1,
        Max = 8000,
        Float = 1,
        Flag = "espobjectMaxDistance",
        Callback = function(value)
            ESP.Settings.Object_Maximal_Distance = value
        end
    }
end)()

--* Inventory Viewer *--
InventoryViewer = {
    Size = Vector2.new(300, 14), 
    
    Main = Framework:Draw("Square", {Thickness = 0, Size = Vector2.new(300, 14), Filled = true, Position = Vector2.new(100, 100), Transparency = 0.4}),
    Border = Framework:Draw("Square", {Thickness = 1, Size = Vector2.new(300, 14), Filled = false, Position = Vector2.new(100, 100), Color = Color3.fromRGB(102,0,204)}),
    Texts = {}
}
LPH_JIT_ULTRA(function()
    function InventoryViewer:Clear()
        for i, v in pairs(self.Texts) do
            v:Remove()
            self.Texts[i] = nil
            self.Main.Size = self.Size
        end
    end
    function InventoryViewer:AddText(Text, Tabulated, Main_Text)
        local Main = self.Main
        local Border = self.Border
        local Drawing = Framework:Draw("Text", {Text = Text, Color = Color3.new(1, 1, 1), Transparency = 1, Size = 13, Font = 2, Outline = true, Visible = true})
        table.insert(self.Texts, Drawing)
        table.insert(self.Texts, Seperator)
        local Drawings = #self.Texts
        Main.Size = Vector2.new(self.Size.X, 14 * Drawings)
        Border.Size = Main.Size + Vector2.new(4, 4)
        Drawing.Position = Main.Position + Vector2.new(5, (Drawings - 1) * 14)
        if Main_Text then
            if Text == "[HOTBAR]" then
                Drawing.Color = Color3.fromRGB(102,0,204)
                Drawing.Center = true
                Drawing.Position = Main.Position + Vector2.new(Main.Size.X / 2, (Drawings - 1) * 14)
            else
                Drawing.Color = Color3.fromRGB(0,235,0)
                Drawing.Center = true
                Drawing.Position = Main.Position + Vector2.new(Main.Size.X / 2, 3)
            end
        end
        if Tabulated then
            Drawing.Position = Main.Position + Vector2.new(20, (Drawings - 1) * 14)
        end
        return Drawing
    end
    function InventoryViewer:Update()
        self.Size = Vector2.new(300, 14)
        local Scan, Containers, _Players = {}, table.find({library.flags["inventoryscannerInventoryToScan"]}, "Containers") , table.find({library.flags["inventoryscannerInventoryToScan"]}, "Players")
        if Containers then
            for i, v in pairs(Workspace.Containers:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("Inventory") then
                    table.insert(Scan, v)
                end
            end
        end
        if _Players then
            for i, v in pairs(plrs:GetPlayers()) do
                if v ~= plr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChildOfClass("Humanoid") then
                    table.insert(Scan, v.Character)
                end
            end
        end
        local Target, Magnitude, lowMagnitude = nil, math.huge, math.huge
        for i, v in pairs(Scan) do
            local PrimaryPart = v.PrimaryPart
            if PrimaryPart then
                local Vector, onScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)
                if onScreen then
                    local Magnitude = (Camera.ViewportSize / 2 - Framework:V3_To_V2(Vector)).Magnitude
                    if Magnitude < lowMagnitude then
                        lowMagnitude = Magnitude
                        Target = v
                    end
                end
            end
        end
        if not Target then
            self:Clear()
            self:AddText("Inventory Viewer", false, true)
            return
        end
        local Humanoid = Target:FindFirstChildOfClass("Humanoid")
        self:Clear()
        local MainText = self:AddText(Target.Name, false, true)
        local sep = self:AddText("------------------------------------------", false, false)
        sep.Color = Color3.fromRGB(102,0,204)
        Scan = {}
        local Maximal_X = 0
        if Humanoid then
            local Folder = repStorage:FindFirstChild("Players")[Target.Name]
            table.insert(Scan, Folder.Inventory)
            table.insert(Scan, Folder.Clothing)
            for i, v in pairs(Scan) do
                local Name = v.Name
                if Name == "Inventory" then
                    self:AddText("[HOTBAR]", false, true)
                    self:AddText("", false, false)
                    for _, Item in pairs(v:GetChildren()) do
                        local ItemProperties = Item:FindFirstChild("ItemProperties")
                        if ItemProperties then
                            local ammoString = ""
                            local isGun = false
                            local ItemType = ItemProperties:GetAttribute("ItemType")
                            if ItemType and ItemType == "RangedWeapon" then
                                isGun = true
                                local Attachments = Item:FindFirstChild("Attachments")
                                if Attachments then
                                    local Magazine = Attachments:FindFirstChild("Magazine")
                                    if Magazine then
                                        Magazine = Magazine:FindFirstChildOfClass("StringValue")
                                        if Magazine then
                                            local MagazineProperties = Magazine:FindFirstChild("ItemProperties")
                                            if MagazineProperties then
                                                local LoadedAmmo = MagazineProperties:FindFirstChild("LoadedAmmo")
                                                if LoadedAmmo then
                                                    for _, Slot in pairs(LoadedAmmo:GetChildren()) do
                                                        local Amount = Slot:GetAttribute("Amount")
                                                        if tonumber(Amount) > 0 then
                                                            ammoString = ammoString .. Amount
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if ammoString == "" and isGun == false then
                                self:AddText(Item.Name)
                            elseif ammoString == "" then
                                local HotbarDrawing = self:AddText(Item.Name .. " [OUT OF AMMO]")
                                local textBoundsX = HotbarDrawing.TextBounds.X
                                if textBoundsX > Maximal_X then
                                    Maximal_X = textBoundsX
                                end
                                if Maximal_X > self.Size.X then
                                    self.Size = Vector2.new(Maximal_X + 10, self.Main.Size.Y)
                                    self.Main.Size = self.Size
                                    MainText.Position = self.Main.Position + Vector2.new(self.Main.Size.X / 2, 0)
                                end
                            else
                                ammoString = ammoString:sub(0, ammoString:len() - 2)
                                local HotbarDrawing = self:AddText(Item.Name .. " ["..ammoString.."]")
                                local textBoundsX = HotbarDrawing.TextBounds.X
                                if textBoundsX > Maximal_X then
                                    Maximal_X = textBoundsX
                                end
                                if Maximal_X > self.Size.X then
                                    self.Size = Vector2.new(Maximal_X + 10, self.Main.Size.Y)
                                    self.Main.Size = self.Size
                                    MainText.Position = self.Main.Position + Vector2.new(self.Main.Size.X / 2, 0)
                                end
                            end
                        else
                            self:AddText(Item.Name)
                        end
                    end
                    local sep = self:AddText("------------------------------------------", false, false)
                    sep.Color = Color3.fromRGB(102,0,204)
                elseif Name == "Clothing" then
                    for _, Clothing in pairs(v:GetChildren()) do
                        -- Clothing
                        local Attachments = Clothing:FindFirstChild("Attachments")
                        local attachmentString = ""
                        if Attachments then
                            for _, Slot in pairs(Attachments:GetChildren()) do
                                local Attachment = Slot:FindFirstChildOfClass("StringValue")
                                if Attachment then
                                    attachmentString = attachmentString .. Attachment.Name .. "; "
                                end
                            end
                        end
                        attachmentString = attachmentString:sub(0, attachmentString:len() - 2)
                        if attachmentString == "" then
                            local ClothingDrawing = self:AddText(Clothing.Name)
                            ClothingDrawing.Color = Color3.fromRGB(255, 153, 51)
                        else
                            local ClothingDrawing = self:AddText(Clothing.Name .. " [".. attachmentString .."]")
                            ClothingDrawing.Color = Color3.fromRGB(255, 153, 51)
                            local textBoundsX = ClothingDrawing.TextBounds.X
                            if textBoundsX > Maximal_X then
                                Maximal_X = textBoundsX
                            end
                            if Maximal_X > self.Size.X then
                                self.Size = Vector2.new(Maximal_X + 10, self.Main.Size.Y)
                                self.Main.Size = self.Size
                                MainText.Position = self.Main.Position + Vector2.new(self.Main.Size.X / 2, 0)
                            end
                        end

                        -- Clothing Inventory
                        local Inventory = Clothing:FindFirstChild("Inventory")
                        if Inventory then
                            for _, Item in pairs(Inventory:GetChildren()) do
                                local ItemProperties = Item:FindFirstChild("ItemProperties")
                                
                                if ItemProperties then
                                    local Amount = ItemProperties:GetAttribute("Amount")
                                    if Amount then
                                        if Amount > 1 then
                                            if Item.Name == "Rubles" then
                                                local RublesDrawing = self:AddText(Item.Name .. " [" .. tostring(Amount) .. "]", true)
                                                RublesDrawing.Color = Color3.fromRGB(0, 255, 0)
                                            else
                                                local Rags = "Rags"
                                                local Goldbar = "Gold50g"
                                                local GoldenDV2 = "GoldenDV2"
                                                local PlasmaNinjato = "PlasmaNinjato"
                                                local AA2 = "AA2"
                                                local DV2 = "DV2"
                                                local Beans = "Beans"
                                                local FlareGun = "FlareGun"
                                                local M84 = "M84"
                                                local RGO = "RGO"
                                                local Lighter = "Lighter"
                                                local RGD5 = "RGD5"
                                                local AI2 = "AI2"
                                                local Bandage = "Bandage"
                                                local MaxEnergy = "MaxEnergy"
                                                local BloxyCola = "BloxyCola"
                                                local ResKola = "ResKola"
                                                local CatfrogSoda = "CatfrogSoda"
                                                local AnarchyTomahawk = "AnarchyTomahawk"
                                                local FrontSVD = "FrontSVD"
                                                local ImprStockAKM = "ImprStockAKM"
                                                local ImprFrontAKM = "ImprFrontAKM"
                                                local ImprHandleAKM = "ImprHandleAKM"
                                                local FlashHiderAKM = "FlashHiderAKM"
                                                local FlashHiderSVD = "FlashHiderSVD"
                                                local HoloSight = "HoloSight"
                                                local LaserPointer = "LaserPointer"
                                                local Flashlight = "Flashlight"
                                                local MuzzleBrakeAKM = "MuzzleBrakeAKM"
                                                local T1Sight = "T1Sight"
                                                local GP5Filter = "GP5Filter"
                                                local PN6K5 = "PN6K5"
                                                local PolymerStockAKMN = "PolymerStockAKMN"
                                                local TacticalFrontAKMN = "TacticalFrontAKMN"
                                                local FrontM4 = "FrontM4"
                                                local ACOG = "ACOG"
                                                local HandleM4 = "HandleM4"
                                                local SOCOM556 = "SOCOM556"
                                                local FlashHiderM4 = "FlashHiderM4"
                                                local QuadNVG = "QuadNVG"
                                                local FrontAsVal = "FrontAsVal"
                                                local HandleRK3AKMN = "HandleRK3AKMN"
                                                local StockIZh81 = "StockIZh81"
                                                local StockPT1AKMN = "StockPT1AKMN"
                                                local TitanShield = "TitanShield"
                                                local F1 = "F1"
                                                local Hammer = "Hammer"
                                                local FlatScrewdriver = "FlatScrewdriver"
                                                local PH2Screwdriver = "PH2Screwdriver"
                                                local Wrench = "Wrench"
                                                local AABattery = "AABattery"
                                                local CopperCoil = "CopperCoil"
                                                local SuperGlue = "SuperGlue"
                                                local RepairKit = "RepairKit"
                                                local DuctTape = "DuctTape"
                                                local Gold50g = "Gold50g"
                                                local SolterStatue = "SolterStatue"
                                                local Pathfinder = "Pathfinder"
                                                if Item.Name == Rags or Item.Name == Goldbar or Item.Name == GoldenDV2 or Item.Name == PlasmaNinjato or Item.Name == AA2 or Item.Name == DV2 or Item.Name == Beans or Item.Name == FlareGun or Item.Name == M84 or Item.Name == RGO or Item.Name == Lighter or Item.Name == RGD5 or Item.Name == AI2 or Item.Name == Bandage or Item.Name == MaxEnergy or Item.Name == BloxyCola or Item.Name == ResKola or Item.Name == CatfrogSoda or Item.Name == AnarchyTomahawk or Item.Name == FrontSVD or Item.Name == ImprStockAKM or Item.Name == ImprFrontAKM or Item.Name == ImprHandleAKM or Item.Name == FlashHiderAKM or Item.Name == FlashHiderSVD or Item.Name == HoloSight or Item.Name == LaserPointer or Item.Name == Flashlight or Item.Name == MuzzleBrakeAKM or Item.Name == T1Sight or Item.Name == GP5Filter or Item.Name == PN6K5 or Item.Name == PolymerStockAKMN or Item.Name == TacticalFrontAKMN or Item.Name == FrontM4 or Item.Name == ACOG or Item.Name == HandleM4 or Item.Name == SOCOM556 or Item.Name == FlashHiderM4 or Item.Name == QuadNVG or Item.Name == FrontAsVal or Item.Name == HandleRK3AKMN or Item.Name == StockIZh81 or Item.Name == StockPT1AKMN or Item.Name == TitanShield or Item.Name == F1 or Item.Name == Hammer or Item.Name == FlatScrewdriver or Item.Name == PH2Screwdriver or Item.Name == Wrench or Item.Name == AABattery or Item.Name == CopperCoil or Item.Name == SuperGlue or Item.Name == RepairKit or Item.Name == DuctTape or Item.Name == Gold50g or Item.Name == SolterStatue or Item.Name == Pathfinder then
                                                    local MiscDrawing = self:AddText(Item.Name .. " [" .. tostring(Amount) .. "]", true)
                                                    MiscDrawing.Color = Color3.fromRGB(255, 255, 255)
                                                else
                                                    local Ammo_762x39AP = "762x39AP"
                                                    local Ammo_762x39Tracer = "762x39Tracer"
                                                    local Ammo_762x54Tracer = "762x54Tracer"
                                                    local Ammo_762x54AP = "762x54AP"
                                                    local Ammo_762x25AP = "762x25AP"
                                                    local Ammo_762x25Tracer = "762x25Tracer"
                                                    local Ammo_556x45AP = "556x45AP"
                                                    local Ammo_9x39AP = "9x39AP"
                                                    local Ammo_9x39Z = "9x39Z"
                                                    local Ammo_9x19Tracer = "9x19Tracer"
                                                    local Ammo_9x19AP = "9x19AP"
                                                    local Ammo_12gaSlug = "12gaSlug"
                                                    local Ammo_12gaBuckshot = "12gaBuckshot"
                                                    local Ammo_12gaFlechette = "12gaFlechette"
                                                    local Ammo_9x18Z = "9x18Z"

                                                    if Item.Name == Ammo_762x39AP or Item.Name == Ammo_762x39Tracer or Item.Name == Ammo_762x54Tracer or Item.Name == Ammo_762x54AP or Item.Name == Ammo_762x25AP or Item.Name == Ammo_762x25Tracer or Item.Name == Ammo_556x45AP or Item.Name == Ammo_9x39AP or Item.Name == Ammo_9x39Z or Item.Name == Ammo_9x19Tracer or Item.Name == Ammo_9x19AP or Item.Name == Ammo_12gaSlug or Item.Name == Ammo_12gaBuckshot or Item.Name == Ammo_12gaFlechette or Item.Name == Ammo_9x18Z then
                                                        local AmmoDrawing = self:AddText(Item.Name .. " [" .. tostring(Amount) .. "]", true)
                                                        AmmoDrawing.Color = Color3.fromRGB(255, 255, 255)
                                                    else
                                                        self:AddText(Item.Name .. " [" .. tostring(Amount) .. "]", true)
                                                    end
                                                end
                                            end
                                        else
                                            self:AddText(Item.Name, true)
                                        end
                                    else
                                        local AsVal = "AsVal"
                                        local M4 = "M4"
                                        local Attak5 = "Attak5"
                                        local GoldBar = "Gold50g"
                                        local FlareGun = "FlareGun"
                                        local FastMT = "FastMT"
                                        local JPC = "JPC"
                                        local FastVisor = "FastVisor"
                                        local AltynVisor = "AltynVisor"
                                        local Altyn = "Altyn"
                                        local FuelingStationKey = "FuelingStationKey"
                                        local LightHouseKey     = "LighthouseKey"
                                        local VillageKey        = "VillageKey"
                                        local CraneKey          = "CraneKey"
                                        local FactoryGarageKey  = "FactoryGarageKey"

                                        if Item.Name == AsVal or Item.Name == M4 or Item.Name == Attak5 or Item.Name == GoldBar or Item.Name == FlareGun or Item.Name == FastMT or Item.Name == JPC or Item.Name == FastVisor or Item.Name == AltynVisor or Item.Name == Altyn or Item.Name == FuelingStationKey or Item.Name == LightHouseKey or Item.Name == VillageKey or Item.Name == CraneKey or Item.Name == FactoryGarageKey then
                                            local KeysDrawing = self:AddText(Item.Name, true)
                                            KeysDrawing.Color = Color3.fromRGB(0, 255, 0)
                                        else
                                            local AsVal = "AsVal"
                                            local M4 = "M4"
                                            local TFZ0 = "TFZ0"
                                            local MP443 = "MP443"
                                            local PPSH41 = "PPSH41"
                                            local SVD = "SVD"
                                            local AKMN = "AKMN"
                                            local Mosin = "Mosin"
                                            local Makarov = "Makarov"
                                            local AKM = "AKM"
                                            local TT33 = "TT33"
                                            local IZh81 = "IZh81"
                                            local MP5SD = "MP5SD"

                                            if Item.Name == AsVal or Item.Name == M4 or Item.Name == TFZ0 or Item.Name == MP443 or Item.Name == PPSH41 or Item.Name == SVD or Item.Name == AKMN or Item.Name == Mosin or Item.Name == Makarov or Item.Name == AKM or Item.Name == TT33 or Item.Name == IZh81 or Item.Name == MP5SD then
                                                local WeaponsDrawing = self:AddText(Item.Name, true)
                                                WeaponsDrawing.Color = Color3.fromRGB(255, 255, 255)
                                            else
                                                local WastelandPants = "WastelandPants"
                                                local WastelandShirt = "WastelandShirt"
                                                local WastelandBackpack = "WastelandBackpack"
                                                local Lynx = "Lynx"
                                                local Attak5 = "Attak5"
                                                local KneePads = "KneePads"
                                                local GhillieLegs = "GhillieLegs"
                                                local GhillieHood = "GhillieHood"
                                                local GhillieTorso = "GhillieTorso"
                                                local Balaclava = "Balaclava"
                                                local SpecopsBackpack = "SpecopsBackpack"
                                                local MotorcycleHelmet = "MotorcycleHelmet"
                                                local Smersh = "Smersh"
                                                local HandWraps = "HandWraps"
                                                local CivilianShirt = "CivilianShirt"
                                                local CivilianPants = "CivilianPants"
                                                local CamoShirt = "CamoShirt"
                                                local CamoPants = "CamoPants"
                                                local CombatGloves = "CombatGloves"
                                                local Tortilla = "Tortilla"
                                                local MotorcycleHelmetVisor = "MotorcycleHelmetVisor"

                                                if Item.Name == WastelandPants or Item.Name == WastelandShirt or Item.Name == WastelandBackpack or Item.Name == Lynx or Item.Name == Attak5 or Item.Name == KneePads or Item.Name == GhillieLegs or Item.Name == GhillieHood or Item.Name == GhillieTorso or Item.Name == Balaclava or Item.Name == SpecopsBackpack or Item.Name == MotorcycleHelmet or Item.Name == Smersh or Item.Name == HandWraps or Item.Name == CivilianShirt or Item.Name == CivilianPants or Item.Name == CamoShirt or Item.Name == CamoPants or Item.Name == CombatGloves or Item.Name == Tortilla or Item.Name == MotorcycleHelmetVisor then
                                                    local ClothingDrawing = self:AddText(Item.Name, true)
                                                    ClothingDrawing.Color = Color3.fromRGB(255, 255, 255)
                                                else
                                                    local FastMT = "FastMT"
                                                    local JPC = "JPC"
                                                    local Zsh = "Zsh"
                                                    local Amour_6B27 = "6B27"
                                                    local Amour_6B43 = "6B43"
                                                    local Amour_6B23 = "6B23"
                                                    local Amour_6B2 = "6B2"
                                                    local Amour_6B5 = "6B5"
                                                    local SSH68 = "SSH68"
                                                    local Altyn = "Altyn"
                                                    local Bandoiler = "Bandoiler"
                                                    local ZShVisor = "ZShVisor"
                                                    local FastVisor = "FastVisor"
                                                    local AltynVisor = "AltynVisor"

                                                    if Item.Name == FastMT or Item.Name == JPC or Item.Name == Zsh or Item.Name == Amour_6B27 or Item.Name == Amour_6B43 or Item.Name == Amour_6B23 or Item.Name == Amour_6B2 or Item.Name == Amour_6B5 or Item.Name == SSH68 or Item.Name == Altyn or Item.Name == Bandoiler or Item.Name == ZShVisor or Item.Name == FastVisor or Item.Name == AltynVisor then
                                                        local ArmourDrawing = self:AddText(Item.Name, true)
                                                        ArmourDrawing.Color = Color3.fromRGB(255, 255, 255)
                                                    else
                                                        self:AddText(Item.Name, true)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                else
                                    self:AddText(Item.Name, true)
                                end
                            end
                        end
                    end
                end
            end
        else
            local Inventory = Target:FindFirstChild("Inventory")
            if Inventory then
                for _, Item in pairs(Inventory:GetChildren()) do
                    local ItemProperties = Item:FindFirstChild("ItemProperties")
                    if ItemProperties then
                        local Amount = ItemProperties:GetAttribute("Amount")
                        if Amount then
                            if Amount > 1 then
                                self:AddText(Item.Name .. " [" .. tostring(Amount) .. "]")
                            else
                                self:AddText(Item.Name)
                            end
                        else
                            self:AddText(Item.Name)
                        end
                    else
                        self:AddText(Item.Name)
                    end
                end
            end
        end
    end
    InventoryViewer.__index = InventoryViewer

    local invViewer, canUpdate = nil, true
    Sections.Visuals.InventoryScanner:Toggle{
        Name = "Enabled",
        Flag = "inventoryscannerEnabled",
        -- Default = false,
        Callback = function(bool)
            if bool then
                if invViewer ~= nil then
                    invViewer:Disconnect()
                end
                invViewer = rs.Heartbeat:Connect(function()
                    if not canUpdate then return end
                    canUpdate = false
                    InventoryViewer:Update()
                    task.wait(library.flags["inventoryscannerUpdateRate"])
                    canUpdate = true
                end)
                InventoryViewer.Main.Visible = true
                InventoryViewer.Border.Visible = true
            else
                if invViewer ~= nil then
                    invViewer:Disconnect()
                end
                InventoryViewer.Main.Visible = false
                InventoryViewer.Border.Visible = false
                task.spawn(function()
                    task.wait()
                    InventoryViewer:Clear()
                end)
            end
        end
    }
    Sections.Visuals.InventoryScanner:Slider{
        Name = "Update Rate",
        Text = "[value] s",
        Default = 1,
        Min = 0,
        Max = 3,
        Float = 0.01,
        Flag = "inventoryscannerUpdateRate",
        Callback = function(value)
            
        end
    }
    Sections.Visuals.InventoryScanner:Slider{
        Name = "Frame X Pos",
        Text = "X Position: [value]",
        Default = 100,
        Min = 0,
        Max = Camera.ViewportSize.X - 300,
        Float = 1,
        Flag = "inventoryscannerFrameXPos",
        Callback = function(value)
            InventoryViewer.Main.Position = Vector2.new(value, InventoryViewer.Main.Position.Y)
	        InventoryViewer.Border.Position = Vector2.new(value, InventoryViewer.Border.Position.Y)
        end
    }
    Sections.Visuals.InventoryScanner:Slider{
        Name = "Frame Y Pos",
        Text = "Y Position: [value]",
        Default = 100,
        Min = 0,
        Max = Camera.ViewportSize.Y,
        Float = 1,
        Flag = "inventoryscannerFrameYPos",
        Callback = function(value)
            InventoryViewer.Main.Position = Vector2.new(InventoryViewer.Main.Position.X, value)
	        InventoryViewer.Border.Position = Vector2.new(InventoryViewer.Border.Position.X, value)
        end
    }
    Sections.Visuals.InventoryScanner:Dropdown{
        Name = "Inventory To Scan",
        Default = "Players",
        Content = {
            "Players",
            "Containers",
        },
        Flag = "inventoryscannerInventoryToScan",
        Callback = function(option)
            
        end
    }
end)()

--* Free Camera *--
Sections.Visuals.FreeCamera:Button{
    Name = "Enabled - Shift + P",
    Callback  = function()
        loadstring(game:HttpGet("https://www.octohook.xyz/infinity/freecam.lua"))()
    end
}

-- * Lighting * --
Sections.Misc.Lighting:Toggle{
    Name = "Full Bright",
    Flag = "fullbrightEnabled",
    -- Default = false,
    Callback = function(bool)
        if bool then
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.Brightness = 1
            lighting.FogEnd = 1e10
            lighting.ClockTime = 12
            for i, v in pairs(lighting:GetDescendants()) do
                if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                end
            end
        else
            lighting.Ambient = Old_Lighting.Ambient
            lighting.Brightness = Old_Lighting.Brightness
            lighting.FogEnd = Old_Lighting.FogEnd
            lighting.ClockTime = Old_Lighting.ClockTime
        end
    end
}
lighting.Changed:Connect(function()
    if library.flags["fullbrightEnabled"] then
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 1
        lighting.FogEnd = 1e10
    end
end)
task.spawn(function()
    while task.wait() do
        while library.flags["fullbrightEnabled"] do
            local character = plr.Character
            repeat wait() until character ~= nil
            if not character.HumanoidRootPart:FindFirstChildWhichIsA("PointLight") and library.flags["fullbrightEnabled"] then
                local headlight = Instance.new("PointLight", character.HumanoidRootPart)
                headlight.Brightness = 1
                headlight.Range = 60
            else
                if character.HumanoidRootPart:FindFirstChildWhichIsA("PointLight") and not library.flags["fullbrightEnabled"] then
                    character.HumanoidRootPart:FindFirstChildWhichIsA("PointLight"):Destroy()
                end
            end
        end
    end
end)
local AmbientLighting = Sections.Misc.Lighting:Toggle{
    Name = "Ambient",
    Flag = "ambientlightingEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
AmbientLighting:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "ambientlightingColor",
    Callback = function(color)
        if library.flags["ambientlightingEnabled"] then
            lighting.Ambient = string.format("%s, %s, %s", math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255))
        else
            lighting.Ambient = Old_Lighting.Ambient
        end
    end
}
Sections.Misc.Lighting:Slider{
    Name = "Brightness",
    Text = "[value]/10",
    Default = 3,
    Min = 1,
    Max = 10,
    Float = 0.1,
    Flag = "brightnessValue",
    Callback = function(value)
        lighting.Brightness = value
    end
}

-- * Removals * --
Sections.Misc.Removals:Toggle{
    Name = "Ambient Sounds",
    Flag = "noambientsoundsEnabled",
    Callback  = function(bool)
        for i, v in pairs(game:GetService("Workspace").AmbientSounds:GetDescendants()) do
            if v:IsA("Sound") then
                if bool then
                    v.Volume = 0
                else
                    v.Volume = 2
                end
            end
        end
    end
}
Sections.Misc.Removals:Toggle{
    Name = "Anti Drown",
    Flag = "antidrownEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
Sections.Misc.Removals:Toggle{
    Name = "Camera Bob",
    Flag = "nocamerabobEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local MainGui = plr.PlayerGui:FindFirstChild("MainGui")
if MainGui then 
	local MainFrame = MainGui:FindFirstChild("MainFrame")
	if MainFrame then 
		ScreenEffects = MainFrame:FindFirstChild("ScreenEffects")
		Visor = ScreenEffects:FindFirstChild("Visor")
		if Visor then
            Sections.Misc.Removals:Toggle{
                Name = "Visor",
                Flag = "novisorEnabled",
                -- Default = false,
                Callback = function(bool)
                    if Visor.Visible and bool then
                        Visor.Visible = false
                    else
                        Visor.Visible = true
                    end
                end
            }
		end
	end
end
local MainGui = plr.PlayerGui:FindFirstChild("MainGui")
if MainGui then 
	local MainFrame = MainGui:FindFirstChild("MainFrame")
	if MainFrame then 
		ScreenEffects = MainFrame:FindFirstChild("ScreenEffects")
        FlashBang = ScreenEffects:FindFirstChild("Flashbang")
        if FlashBang then
            Sections.Misc.Removals:Toggle{
                Name = "Anti Flashbang",
                Flag = "antiflashbangEnabled",
                -- Default = false,
                Callback = function(bool)
                    if bool then
                        repStorage.SFX.Explosions.Flashbang.Volume = 0
                        ScreenEffects.Flashbang.Size = UDim2.new(0, 0, 0, 0)
                    else
                        repStorage.SFX.Explosions.Flashbang.Volume = 10
                        ScreenEffects.Flashbang.Size = UDim2.new(1, 0, 1, 0)
                    end
                end
            }
        end
	end
end
for i, v in pairs(plr.PlayerGui:GetDescendants()) do
    if v:IsA("TextLabel") then
        if v.Text:find("| Server") or v.Text:find(game.JobId:lower()) or v.Text:find(plr.UserId) then
            serverLabel = v
        end
    end
end
if serverLabel then
    Sections.Misc.Removals:Toggle{
        Name = "Server Information",
        Flag = "noserverinfoEnabled",
        -- Default = false,
        Callback = function(bool)
            task.spawn(function()
                task.wait()
                if bool then
                    serverLabel.Text = ""
                end
            end)
        end
    }
    serverLabel:GetPropertyChangedSignal("Text"):Connect(LPH_JIT_ULTRA(function()
        if library.flags["noserverinfoEnabled"] then
            serverLabel.Text = ""
        end
    end))
end
Sections.Misc.Removals:Separator("World")
local waterBlur = lighting:WaitForChild("WaterBlur")
Sections.Misc.Removals:Toggle{
    Name = "Water Blur",
    Flag = "nowaterblurEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local Atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
if Atmosphere then
    Sections.Misc.Removals:Toggle{
        Name = "Atmosphere",
        Flag = "noatmosphereEnabled",
        -- Default = false,
        Callback = function(bool)
            if library.flags["fullbrightEnabled"] then
                Atmosphere.Parent = bool and cgui or lighting
            end
        end
    }
end
Sections.Misc.Removals:Toggle{
    Name = "Grass",
    Flag = "nograssEnabled",
    -- Default = false,
    Callback = function(bool)
        sethiddenproperty(Terrain, "Decoration", not bool)
    end
}
local Clouds = Terrain:FindFirstChildOfClass("Clouds")
if Clouds then
    Sections.Misc.Removals:Toggle{
        Name = "Clouds",
        Flag = "nocloudsEnabled",
        -- Default = false,
        Callback = function(bool)
            Clouds.Parent = bool and cgui or Terrain
        end
    }
end
local leafTable = {}
Sections.Misc.Removals:Toggle{
    Name = "Foliage",
    Flag = "nofoliageEnabled",
    -- Default = false,
    Callback = function(bool)
        if bool then
            for i, v in next, game:GetService("Workspace").SpawnerZones.Foliage:GetDescendants() do
                if v:IsA("MeshPart") and v.TextureID == "" then
                    leafTable[i] = {
                        Part = v,
                        Old = v.Parent
                    }
                    v.Parent = cgui
                end
            end
        else
            pcall(function()
                for i, v in pairs(leafTable) do
                    v.Part.Parent = v.Old
                end
                leafTable = {}
            end)
        end
    end
}

--* Misc *--
local UnlockDoorToggled = false
Sections.Misc.Misc:Button{
    Name = "Unlock Closest Door",
    Callback = function()
        local last = 5
		local closest = nil
		for _, door in pairs(ws:GetChildren()) do
			if door:IsA("Model") then
				if door:GetAttribute("KeyDoor") and door:FindFirstChild("Main") then
					if (door:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude <= last then
						last = (door:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude
						closest = door
					end
				end
			end
		end
		if closest then
			local unit = (closest.Main.Position - plr.Character.HumanoidRootPart.Position).Unit

			for i = 1,20 do
				plr.Character.HumanoidRootPart.CFrame = CFrame.new(closest.Main.Position + unit * 3)
				game.ReplicatedStorage.Remotes.Door:FireServer(closest, 1, closest:GetPivot().Position);
				task.wait(0.05)
			end
		end
    end
}
local dwUnlockDoor = Sections.Misc.Misc:Toggle{
    Name = "Unlock Closest Door Keybind",
    Flag = "unlockdoorEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
dwUnlockDoor:Keybind{
    Default = Enum.KeyCode.O,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3},
    Flag = "unlockdoorKeybind",
    Mode = "nill", -- mode to nil if u dont want it to toggle the toggle
    Callback = function(key, fromsetting)
        if library.flags["unlockdoorEnabled"] then
            local key = tostring(key):gsub("Enum.KeyCode.", "")
            UnlockDoorKeybind.Text = "Unlock Door  [" .. key .. "]"
        end
        if not fromsetting then
            UnlockDoorToggled = not UnlockDoorToggled
            if UnlockDoorToggled and library.flags["unlockdoorEnabled"] then
                UnlockDoorKeybind.Color = Color3.fromRGB(0, 255, 0)
                local last = 5
                local closest = nil
                for _, door in pairs(ws:GetChildren()) do
                    if door:IsA("Model") then
                        if door:GetAttribute("KeyDoor") and door:FindFirstChild("Main") then
                            if (door:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude <= last then
                                last = (door:GetPivot().Position - plr.Character:GetPivot().Position).Magnitude
                                closest = door
                            end
                        end
                    end
                end
                if closest then
                    local unit = (closest.Main.Position - plr.Character.HumanoidRootPart.Position).Unit

                    for i = 1,20 do
                        plr.Character.HumanoidRootPart.CFrame = CFrame.new(closest.Main.Position + unit * 3)
                        game.ReplicatedStorage.Remotes.Door:FireServer(closest, 1, closest:GetPivot().Position);
                        task.wait(0.05)
                    end

                    UnlockDoorKeybind.Color = Color3.fromRGB(255, 255, 255)
                    UnlockDoorToggled = false
                end
            else
                UnlockDoorKeybind.Color = Color3.fromRGB(255, 255, 255)
            end
        end
    end
}

--* Chat Spammer *--
Sections.Misc.ChatSpammer:Toggle{
    Name = "Chat Spammer Enabled",
    Flag = "chatmessageEnabled",
    Callback = function(bool) 
        
    end
}
local Chatmessage = Sections.Misc.ChatSpammer:Box{
    Name = "Message",
    Placeholder = "Enter Message Here",
    Flag = "chatMessage",
}
Sections.Misc.ChatSpammer:Slider{
    Name = "Delay",
    Text = "[value] s",
    Default = 2,
    Min = 2,
    Max = 10,
    Float = 0.1,
    Flag = "chatmessageDelay",
    Callback = function(value)
        
    end
}
task.spawn(function()
    while task.wait(library.flags["chatmessageDelay"]) do
        if library.flags["chatmessageEnabled"] then
            local args = {
                [1] = tostring(library.flags["chatMessage"]),
                [2] = "Global"
            }
            repStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
        end
    end
end)



-- * Local Player Mods * --
local WalkSpeedKeybindToggledOld = false
local HipHeightToggled = false
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldindex = gmt.__index
gmt.__index = newcclosure(function(self,b)
    if b == "WalkSpeed" and library.flags["walkspeedEnabledOld"] and WalkSpeedKeybindToggledOld then 
        game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = library.flags["walkspeedValueOld"]
        return 10
    end 
    if b == "HipHeight" and library.flags["hipheightEnabled"] and HipHeightToggled then
        game:GetService("Players").LocalPlayer.Character.Humanoid.HipHeight = library.flags["hipheightValue"]
        return 2
    end

    return oldindex(self, b)
end)
Sections.Misc.LocalPlayer:Toggle{
    Name = "Bhop",
    Flag = "bhopEnabled",
    -- Default = false,
    Callback = function(bool)
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, connectTable in pairs({
                getconnections(humanoid.StateChanged);
                getconnections(humanoid:GetPropertyChangedSignal("WalkSpeed"));
                getconnections(humanoid:GetPropertyChangedSignal("JumpHeight"))
            }) do
                for _, event in pairs(connectTable) do
                    if bool then
                        event:Disable()
                    else
                        event:Enable()
                    end
                end
            end
        end
    end
}
local dwHipHeight = Sections.Misc.LocalPlayer:Toggle{
    Name = "Hip Height",
    Flag = "hipheightEnabled",
    -- Default = false,
    Callback = function(bool)
        if not bool then
            game:GetService("Players").LocalPlayer.Character.Humanoid.HipHeight = 2
        end
    end
}
dwHipHeight:Keybind{
    Default = Enum.KeyCode.L,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3},
    Flag = "hipheightKeybinded",
    Mode = "nill", -- mode to nil if u dont want it to toggle the toggle
    Callback = function(key, fromsetting)
        if library.flags["thirdpersonEnabled"] then
            local key = tostring(key):gsub("Enum.KeyCode.", "")
            HipHeightKeybind.Text = "Hip Height   [" .. key .. "]"
        end
        if not fromsetting then
            HipHeightToggled = not HipHeightToggled
            if HipHeightToggled and library.flags["hipheightEnabled"] then
                HipHeightKeybind.Color = Color3.fromRGB(0, 255, 0)
                game:GetService("Players").LocalPlayer.Character.Humanoid.HipHeight = library.flags["hipheightValue"]
            else
                HipHeightKeybind.Color = Color3.fromRGB(255, 255, 255)
                game:GetService("Players").LocalPlayer.Character.Humanoid.HipHeight = 2
            end
        end
    end
}
dwHipHeight:Slider{
    Text = "Height: [value]/7.5",
    Default = 2,
    Min = 2,
    Max = 7.5,
    Float = 0.001,
    Flag = "hipheightValue",
    Callback = function(value)
    end
}
local dwWalkSpeed = Sections.Misc.LocalPlayer:Toggle{
    Name = "Player Speed",
    Flag = "walkspeedEnabledOld",
    -- Default = false,
    Callback = function(bool)
        if not bool then
            game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = Default_Walkspeed
        end
    end
}
dwWalkSpeed:Keybind{
    Default = Enum.KeyCode.C,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3},
    Flag = "walkspeedKeybindOld",
    Mode = "nill", -- mode to nil if u dont want it to toggle the toggle
    Callback = function(key, fromsetting)
        if library.flags["walkspeedEnabledOld"] then
            local key = tostring(key):gsub("Enum.KeyCode.", "")
            WalkspeedKeybindOld.Text = "Walk Speed   [" .. key .. "]"
        end
        if not fromsetting then
            WalkSpeedKeybindToggledOld = not WalkSpeedKeybindToggledOld
            if WalkSpeedKeybindToggledOld and library.flags["walkspeedEnabledOld"] then
                WalkspeedKeybindOld.Color = Color3.fromRGB(0, 255, 0)
            else
                WalkspeedKeybindOld.Color = Color3.fromRGB(255, 255, 255)
            end
        end
    end
}
dwWalkSpeed:Slider{
    Text = "Speed: [value]/50",
    Default = 10,
    Min = 10,
    Max = 50,
    Float = 0.5,
    Flag = "walkspeedValueOld",
    Callback = function(value)
    end
}
local WalkSpeedKeybindToggled = false
local dwWalkSpeed = Sections.Misc.LocalPlayer:Toggle{
    Name = "Camera Speed",
    Flag = "walkspeedEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
dwWalkSpeed:Keybind{
    Default = Enum.KeyCode.V,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3},
    Flag = "walkspeedKeybind",
    Mode = "nill", -- mode to nil if u dont want it to toggle the toggle
    Callback = function(key, fromsetting)
        if library.flags["walkspeedEnabled"] then
            local key = tostring(key):gsub("Enum.KeyCode.", "")
            WalkspeedKeybind.Text = "Camera Speed [" .. key .. "]"
        end
        if not fromsetting then
            WalkSpeedKeybindToggled = not WalkSpeedKeybindToggled
            if WalkSpeedKeybindToggled and library.flags["walkspeedEnabled"] then
                WalkspeedKeybind.Color = Color3.fromRGB(0, 255, 0)
            else
                WalkspeedKeybind.Color = Color3.fromRGB(255, 255, 255)
            end
        end
    end
}
dwWalkSpeed:Slider{
    Text = "Speed: [value]/0.5",
    Default = 0,
    Min = 0,
    Max = 0.5,
    Float = 0.00001,
    Flag = "walkspeedValue",
    Callback = function(value)
        
    end
}
ThirdPersonToggled = false
local dwThirdPerson = Sections.Misc.LocalPlayer:Toggle{
    Name = "Third Person",
    Flag = "thirdpersonEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
dwThirdPerson:Keybind{
    Default = Enum.KeyCode.N,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3},
    Flag = "thirdpersonKeybinded",
    Mode = "nill", -- mode to nil if u dont want it to toggle the toggle
    Callback = function(key, fromsetting)
        if library.flags["thirdpersonEnabled"] then
            local key = tostring(key):gsub("Enum.KeyCode.", "")
            ThirdPersonKeybind.Text = "Third Person [" .. key .. "]"
        end
        if not fromsetting then
            ThirdPersonToggled = not ThirdPersonToggled
            if ThirdPersonToggled and library.flags["thirdpersonEnabled"] then
                ThirdPersonKeybind.Color = Color3.fromRGB(0, 255, 0)
                local Checkkkk = game:GetService("Workspace").Camera:FindFirstChild("ViewModel")
                if Checkkkk then
                    for i,v in pairs(game:GetService("Workspace").Camera.ViewModel:GetChildren()) do
                        if v.ClassName == "MeshPart" then
                            if v.Parent.Name == "WastelandShirt" or v.Parent.Name == "GhillieTorso" or v.Parent.Name == "CivilianPants" or v.Parent.Name == "CamoShirt" or v.Parent.Name == "HandWraps" or v.Parent.Name == "CombatGloves" then
                                v.Transparency = 1
                            end
                        end
                        if v.ClassName == "MeshPart" then
                            if v.Name == "LeftHand" or v.Name == "LeftLowerArm" or v.Name == "LeftUpperArm" or v.Name == "RightHand" or v.Name == "RightLowerArm" or v.Name == "RightUpperArm" then
                                v.Transparency = 1
                            end
                        end
                        if v.ClassName == "Part" then
                            if v.Name == "AimPartCanted" or v.Name == "AimPart" then
                                v.Transparency = 1
                            end
                        end
                    end
                    for i,v in pairs(game:GetService("Workspace").Camera.ViewModel.Item:GetDescendants()) do
                        if v.ClassName == "MeshPart" or v.ClassName == "Part" then
                            v.Transparency = 1
                        end
                    end
                end
            else
                local Checkkkk = game:GetService("Workspace").Camera:FindFirstChild("ViewModel")
                if Checkkkk then
                    for i,v in pairs(game:GetService("Workspace").Camera.ViewModel:GetChildren()) do
                        if v.ClassName == "MeshPart" then
                            if v.Parent.Name == "WastelandShirt" or v.Parent.Name == "GhillieTorso" or v.Parent.Name == "CivilianPants" or v.Parent.Name == "CamoShirt" or v.Parent.Name == "HandWraps" or v.Parent.Name == "CombatGloves" then
                                v.Transparency = 0
                            end
                        end
                        if v.ClassName == "MeshPart" then
                            if v.Name == "LeftHand" or v.Name == "LeftLowerArm" or v.Name == "LeftUpperArm" or v.Name == "RightHand" or v.Name == "RightLowerArm" or v.Name == "RightUpperArm" then
                                v.Transparency = 0
                            end
                        end
                        if v.ClassName == "Part" then
                            if v.Name == "AimPartCanted" or v.Name == "AimPart" then
                                v.Transparency = 0
                            end
                        end
                    end
                    for i,v in pairs(game:GetService("Workspace").Camera.ViewModel.Item:GetDescendants()) do
                        if v.ClassName == "MeshPart" or v.ClassName == "Part" then
                            v.Transparency = 0
                        end
                    end
                end
                ThirdPersonKeybind.Color = Color3.fromRGB(255, 255, 255)
            end
        end
    end
}
dwThirdPerson:Slider{
    Text = "Distance: [value]/20",
    Default = 5,
    Min = 0,
    Max = 20,
    Float = 0.001,
    Flag = "thirdpersonValue",
    Callback = function(value)
        
    end
}
Sections.Misc.LocalPlayer:Separator("Camera Settings")
local FovZoomEnabled = false
local dwFOVZoom = Sections.Misc.LocalPlayer:Toggle{
    Name = "Camera FOV Zoom",
    Flag = "cameraFOVZoomEnabled",
    -- Default = false,
    Callback = function(bool)
        if not bool then
            if Camera.FieldOfView ~= Old_FOV then
                Camera.FieldOfView = Old_FOV
                FovZoomEnabled = false
            end
        end
    end
}
dwFOVZoom:Keybind{
    Default = Enum.KeyCode.X,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3},
    Flag = "cameraFOVZoomKeybind",
    Mode = "nill", -- mode to nil if u dont want it to toggle the toggle
    Callback = function(key, fromsetting)
        if library.flags["cameraFOVZoomEnabled"] then
            local key = tostring(key):gsub("Enum.KeyCode.", "")
            CameraZoomKeybind.Text = "Camera Zoom  [" .. key .. "]"
        end
        if not fromsetting then
            FovZoomEnabled = not FovZoomEnabled
            if library.flags["cameraFOVZoomEnabled"] and FovZoomEnabled then
                CameraZoomKeybind.Color = Color3.fromRGB(0, 255, 0)
                Camera.FieldOfView = library.flags["cameraFOVZoomValue"]
            else
                CameraZoomKeybind.Color = Color3.fromRGB(255, 255, 255)
                Camera.FieldOfView = Old_FOV
            end
        end
    end
}
dwFOVZoom:Slider{
    Text = "Distance: [value]/120",
    Default = 15,
    Min = 1,
    Max = 120,
    Float = 1,
    Flag = "cameraFOVZoomValue",
    Callback = function(value)
    end
}
local dwFOV = Sections.Misc.LocalPlayer:Toggle{
    Name = "Camera FOV",
    Flag = "cameraFOVEnabled",
    -- Default = false,
    Callback = function(bool)
        if not bool then
            Camera.FieldOfView = Old_FOV
        end
    end
}
dwFOV:Slider{
    Text = "Distance: [value]/120",
    Default = 90,
    Min = 1,
    Max = 120,
    Float = 1,
    Flag = "cameraFOVValue",
    Callback = function(value)
        if library.flags["cameraFOVEnabled"] then
            Camera.FieldOfView = value
        end
    end
}
local FakeLagEnabled = false
local NetworkClient = game:GetService("NetworkClient")
local VisualizeLagFolder
Sections.Misc.LocalPlayer:Separator("Fake Lag")
local dwVisualizeFakeLag = Sections.Misc.LocalPlayer:Toggle{
    Name = "Visualize Fake Lag",
    Flag = "visualizefakelagEnabled",
    -- Default = false,
    Callback = function(bool)
        if not bool then
            task.spawn(function()
                task.wait()
                VisualizeLagFolder:ClearAllChildren()
            end)
        end
    end
}
dwVisualizeFakeLag:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "visualizefakelagColor",
    Callback = function(color)
        
    end
}
VisualizeLagFolder = Framework:Instance("Folder", {Parent = Camera})
local dwFakeLag = Sections.Misc.LocalPlayer:Toggle{
    Name = "Fake Lag",
    Flag = "fakelagEnabled",
    -- Default = false,
    Callback = function(bool)
        if not bool then
            task.spawn(function()
                task.wait()
                NetworkClient:SetOutgoingKBPSLimit(math.huge)
                VisualizeLagFolder:ClearAllChildren()
            end)
        end
    end
}
dwFakeLag:Keybind{
    Default = Enum.KeyCode.C,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3},
    Flag = "fakelagKeybind",
    Mode = "nill", -- mode to nil if u dont want it to toggle the toggle
    Callback = function(key, fromsetting)
        if not fromsetting then
            FakeLagEnabled = not FakeLagEnabled
        end
    end
}
dwFakeLag:Slider{
    Text = "Ticks: [value]/100",
    Default = 0,
    Min = 0,
    Max = 100,
    Float = 1,
    Flag = "fakelagLimit",
    Callback = function(value)
    end
}
local Tick = 0
local sec = nil
local FPS = {}
sec = tick()
local RunService_Crosshair = game:GetService("RunService")
local ViewportSize_ = Camera.ViewportSize / 2
local Axis_X, Axis_Y = ViewportSize_.X, ViewportSize_.Y
local HorizontalLine = Drawing.new("Line")
local VerticalLine   = Drawing.new("Line")  
task.spawn(function()
    while task.wait() do
        if library.flags["walkspeedEnabled"] and WalkSpeedKeybindToggled then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + game.Players.LocalPlayer.Character.Humanoid.MoveDirection * library.flags["walkspeedValue"]
            game:GetService("RunService").Stepped:wait()
        end
    end
end)
Camera:GetPropertyChangedSignal("FieldOfView"):Connect(LPH_JIT_ULTRA(function()
    if library.flags["cameraFOVZoomEnabled"] and FovZoomEnabled then
        Camera.FieldOfView = library.flags["cameraFOVZoomValue"]
        return
    end
    if library.flags["cameraFOVEnabled"] then
        Camera.FieldOfView = library.flags["cameraFOVValue"]
    end
end))

Sections.Misc.Misc:Separator("LocalPlayer Chams")

--* LocalPlayer Chams *--
local LocalPlayerChamsToggle = Sections.Misc.Misc:Toggle{
    Name = "Enabled",
    Flag = "localchamsEnabled",
    --Default = false,
    Callback = function(bool)
        
    end
}
LocalPlayerChamsToggle:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "localplayerchamsColor",
    Callback = function(color)
        
    end
}
Sections.Misc.Misc:Dropdown{
    Name = "Player Material",
    Default = "ForceField",
    Content = {"ForceField", "Neon", "SmoothPlastic", "Glass"},
    Flag = "localplayerchamsMaterial",
    Callback = function(option)
    end
}
Sections.Misc.Misc:Dropdown{
    Name = "Gun Material",
    Default = "ForceField",
    Content = {"ForceField", "Neon", "SmoothPlastic", "Glass", "Metal"},
    Flag = "localgunchamsMaterial",
    Callback = function(option)
    end
}

--* Enemy Radar *--
local Players = game:service("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = game:service("Workspace").CurrentCamera
local RS = game:service("RunService")
local UIS = game:service("UserInputService")
local LerpColorModule = loadstring(game:HttpGet("https://www.octohook.xyz/infinity/lerpcolor.lua"))()
local HealthBarLerp = LerpColorModule:Lerp(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0))

local function NewCircle(Transparency, Color, Radius, Filled, Thickness)
    local c = Drawing.new("Circle")
    c.Transparency = Transparency
    c.Color = Color
    c.Visible = false
    c.Thickness = Thickness
    c.Position = Vector2.new(0, 0)
    c.Radius = Radius
    c.NumSides = math.clamp(Radius*55/100, 10, 75)
    c.Filled = Filled
    return c
end

local RadarInfo = {
    Position = Vector2.new(200, 200),
    Radius = 100,
    Scale = 1,
    RadarBack = Color3.fromRGB(10, 10, 10),
    RadarBorder = Color3.fromRGB(75, 75, 75),
    LocalPlayerDot = Color3.fromRGB(255, 255, 255),
    PlayerDot = Color3.fromRGB(60, 170, 255),
    Team = Color3.fromRGB(0, 255, 0),
    Enemy = Color3.fromRGB(255, 0, 0),
    Health_Color = false,
    Team_Check = false
}

local RadarBackground = NewCircle(0.9, RadarInfo.RadarBack, RadarInfo.Radius, true, 1)
RadarBackground.Visible = true
RadarBackground.Position = RadarInfo.Position

local RadarBorder = NewCircle(0.75, RadarInfo.RadarBorder, RadarInfo.Radius, false, 3)
RadarBorder.Visible = true
RadarBorder.Position = RadarInfo.Position

local function GetRelative(pos)
    local char = Player.Character
    if char ~= nil and char.PrimaryPart ~= nil then
        local pmpart = char.PrimaryPart
        local camerapos = Vector3.new(Camera.CFrame.Position.X, pmpart.Position.Y, Camera.CFrame.Position.Z)
        local newcf = CFrame.new(pmpart.Position, camerapos)
        local r = newcf:PointToObjectSpace(pos)
        return r.X, r.Z
    else
        return 0, 0
    end
end

local function PlaceDot(plr)
    local PlayerDot = NewCircle(1, RadarInfo.PlayerDot, 3, true, 1)

    local function Update()
        local c 
        c = game:service("RunService").RenderStepped:Connect(function()
            if library.flags["enemyradarEnabled"] then
                local char = plr.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char.PrimaryPart ~= nil and char:FindFirstChildOfClass("Humanoid").Health > 0 and library.flags["enemyradarEnabled"] then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local scale = RadarInfo.Scale
                    local relx, rely = GetRelative(char.PrimaryPart.Position)
                    local newpos = RadarInfo.Position - Vector2.new(relx * scale, rely * scale) 
                    
                    if (newpos - RadarInfo.Position).magnitude < RadarInfo.Radius-2 then 
                        PlayerDot.Radius = 3   
                        PlayerDot.Position = newpos
                        PlayerDot.Visible = true
                    else 
                        local dist = (RadarInfo.Position - newpos).magnitude
                        local calc = (RadarInfo.Position - newpos).unit * (dist - RadarInfo.Radius)
                        local inside = Vector2.new(newpos.X + calc.X, newpos.Y + calc.Y)
                        PlayerDot.Radius = 2
                        PlayerDot.Position = inside
                        PlayerDot.Visible = true
                    end

                    PlayerDot.Color = RadarInfo.Enemy

                    if RadarInfo.Health_Color then
                        PlayerDot.Color = HealthBarLerp(hum.Health / hum.MaxHealth)
                    end
                else 
                    PlayerDot.Visible = false
                    if Players:FindFirstChild(plr.Name) == nil then
                        PlayerDot:Remove()
                        c:Disconnect()
                    end
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

for _,v in pairs(Players:GetChildren()) do
    if v.Name ~= Player.Name then
        PlaceDot(v)
    end
end

local function NewLocalDot()
    local d = Drawing.new("Triangle")
    d.Visible = true
    d.Thickness = 1
    d.Filled = true
    d.Color  = RadarInfo.LocalPlayerDot
    d.PointA = RadarInfo.Position + Vector2.new(0, -6)
    d.PointB = RadarInfo.Position + Vector2.new(-3, 6)
    d.PointC = RadarInfo.Position + Vector2.new(3, 6)
    return d
end

local LocalPlayerDot = NewLocalDot()

Players.PlayerAdded:Connect(function(v)
    if library.flags["enemyradarEnabled"] then
        if v.Name ~= Player.Name then
            PlaceDot(v)
        end
        LocalPlayerDot:Remove()
        LocalPlayerDot = NewLocalDot()
    end
end)

-- Draggable
local inset = game:service("GuiService"):GetGuiInset()

local dragging = false
local offset = Vector2.new(0, 0)
UIS.InputBegan:Connect(function(input)
    if library.flags["enemyradarEnabled"] then
        if input.UserInputType == Enum.UserInputType.MouseButton1 and (Vector2.new(Mouse.X, Mouse.Y + inset.Y) - RadarInfo.Position).magnitude < RadarInfo.Radius then
            offset = RadarInfo.Position - Vector2.new(Mouse.X, Mouse.Y)
            dragging = true
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if library.flags["enemyradarEnabled"] then
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end
end)
local dot = NewCircle(1, Color3.fromRGB(255, 255, 255), 3, true, 1)

Sections.Misc.Misc:Separator("Enemy Radar")
local EnemyRadarToggle = Sections.Misc.Misc:Toggle{
    Name = "Enabled",
    Flag = "enemyradarEnabled",
    --Default = false,
    Callback = function(bool)
        
    end
}
EnemyRadarToggle:Slider{
    Text = "Size: [value]/250",
    Default = 100,
    Min = 25,
    Max = 250,
    Float = 1,
    Flag = "enemyradarSize",
    Callback = function(value)
        RadarInfo.Radius = value
    end
}
Sections.Misc.Misc:Toggle{
    Name = "Health Color",
    Flag = "enemyradarhealthcolorEnabled",
    --Default = false,
    Callback = function(bool)
        RadarInfo.Health_Color = bool
    end
}


--* ESP Functions *--
esp.NewDrawing = function(type, properties)
    local newD = Drawing.new(type)
    for i,v in next, properties or {} do
        local s,e = pcall(function()
            newD[i] = v
        end)
 
        if not s then
            warn(e)
        end
    end
    return newD
end
esp.HasCharacter = function(v)
    local pass = false
    if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
        pass = true
    end
 
    if s then return pass; end; return pass;
end
esp.TeamCheck = function(v)
    local pass = true
    if plr.TeamColor == v.TeamColor then
        pass = false
    end
 
    if s then return pass; end; return pass;
end --[true = Same Team | false = Same Team]
esp.NewPlayer = function(v)
    esp.players[v] = {
        name = esp.NewDrawing("Text", {Color = Color3.fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 2}),
        boxOutline = esp.NewDrawing("Square", {Color = Color3.fromRGB(0, 255, 0), Thickness = 3}),
        box = esp.NewDrawing("Square", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Filled = false}),
        tool = esp.NewDrawing("Text", {Color = Color3.fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 2}),
        healthBarOutline = esp.NewDrawing("Line", {Color = Color3.fromRGB(0, 0, 0), Thickness = 3}),
        healthBar = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
        healthText = esp.NewDrawing("Text", {Color = Color3.fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 2}),
        distance = esp.NewDrawing("Text", {Color = Color3.fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 2}),
        viewAngle = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
        tracers = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
        chams = Instance.new("Highlight"),
        skeleton = {
            Head = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            LeftHand = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            RightHand = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            LeftLowerArm = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            RightLowerArm = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            LeftUpperArm = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            RightUpperArm = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            LeftFoot = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            LeftLowerLeg = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            UpperTorso = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            LeftUpperLeg = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            RightFoot = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            RightLowerLeg = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            LowerTorso = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1}),
            RightUpperLeg = esp.NewDrawing("Line", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1})
        }
    }
end
for _,v in ipairs(plrs:GetPlayers()) do
	if v ~= plr then
    	esp.NewPlayer(v)
	end
end
plrs.PlayerAdded:Connect(esp.NewPlayer)
local Plr_Target
local Plr_Target_Predicted

--* Rainbow Function *--
local rcurrent = 255
local gcurrent = 0
local bcurrent = 0

local redtime = true
local bluetime2 = false
local greentime = false

local function ResetRainbow()
    redtime = true
    bluetime2 = false
    greentime = false
end

local function getRandomColor()
    local rnum = 0
    local bnum = 0
    local gnum = 0

    if rcurrent == 255 and gcurrent == 0 and bcurrent == 0 then
        ResetRainbow()
        rcurrent = 255
        gcurrent = 0
        bcurrent = 0
    end

    if gcurrent < 255 and not greentime then
        gnum = gcurrent + 15
        gcurrent = gnum

    elseif gcurrent == 255 and rcurrent > 0 and redtime and rcurrent ~= 0 then
        rnum = rcurrent - 15
        rcurrent = rnum

    elseif bcurrent < 255 and gcurrent == 255 and rcurrent == 0 and not bluetime2 then
        bnum = bcurrent + 15
        bcurrent = bnum

    elseif gcurrent > 0 and gcurrent ~= 0 and bcurrent == 255 and rcurrent == 0 and not bluetime2 then
        greentime = true
        gnum = gcurrent - 15
        gcurrent = gnum

    elseif bcurrent == 255 and gcurrent == 0 and rcurrent < 255 then
        redtime = false
        rnum = rcurrent + 15
        rcurrent = rnum

    elseif bcurrent > 0 and bcurrent ~= 0 and gcurrent == 0 and rcurrent == 255 then
        bluetime2 = true
        bnum = bcurrent - 15
        bcurrent = bnum
    end
    return Color3.fromRGB(rcurrent, gcurrent, bcurrent)
end

local rainbowespmode = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Rainbow Mode",
    Flag = "rainbowmodeEnabled",
    -- Default = false,
    Callback = function(bool)
        esp.rainbowmode = bool
    end
}
rainbowespmode:Slider{
    Text = "[value] ms",
    Default = 0,
    Min = 0,
    Max = 0.5,
    Float = 0.0001,
    Flag = "rainbowmodeSpeed",
    Callback = function(value)
    end
}
local RainbowESPNames = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Names Rainbow",
    Flag = "rainbownamesEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local RainbowESPBoxes = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Boxes Rainbow",
    Flag = "rainbowboxesEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local RainbowESPTool = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Tool Rainbow",
    Flag = "rainbowtoolEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local RainbowESPHealthText = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Health Text Rainbow",
    Flag = "rainbowhealthtextEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local RainbowESPDistance = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Distance Rainbow",
    Flag = "rainbowdistanceEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local RainbowESPViewAngle = Sections.Visuals.RainbowSettings:Toggle{
    Name = "View Angle Rainbow",
    Flag = "rainbowviewangleEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local RainbowESPTracers = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Tracers Rainbow",
    Flag = "rainbowtracersEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local RainbowESPSkeleton = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Skeleton Rainbow",
    Flag = "rainbowskeletonEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local RainbowESPChams = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Chams Rainbow",
    Flag = "rainbowchamsEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local RainbowESPChamsOutline = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Chams Outline Rainbow",
    Flag = "rainbowchamsoutlineEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
local RainbowESPLocalPlayerChams = Sections.Visuals.RainbowSettings:Toggle{
    Name = "Local Chams Rainbow",
    Flag = "rainbowlocalchamsEnabled",
    -- Default = false,
    Callback = function(bool)
        
    end
}
Sections.Visuals.RainbowSettings:Toggle{
    Name = "Enable All",
    Flag = "rainbowmodeEnableAll",
    -- Default = false,
    Callback = function(bool)
        RainbowESPNames:Toggle(bool)
        RainbowESPBoxes:Toggle(bool)
        RainbowESPTool:Toggle(bool)
        RainbowESPHealthText:Toggle(bool)
        RainbowESPDistance:Toggle(bool)
        RainbowESPViewAngle:Toggle(bool)
        RainbowESPTracers:Toggle(bool)
        RainbowESPSkeleton:Toggle(bool)
        RainbowESPChams:Toggle(bool)
        RainbowESPChamsOutline:Toggle(bool)
        RainbowESPLocalPlayerChams:Toggle(bool)
    end
}
task.spawn(function()
    while task.wait(library.flags["rainbowmodeSpeed"]) do
        --* Rainbow Mode *--
        if esp.rainbowmode then
            local rand = getRandomColor()
            esp.rainbowcolor = rand
            for i,v in pairs(esp.players) do
                
                if library.flags["rainbownamesEnabled"] then
                    v.name.Color = esp.rainbowcolor
                end
                if library.flags["rainbowboxesEnabled"] then
                    v.box.Color = esp.rainbowcolor
                end
                if library.flags["rainbowtoolEnabled"] then
                    v.tool.Color = esp.rainbowcolor
                end
                if library.flags["rainbowhealthtextEnabled"] then
                    v.healthText.Color = esp.rainbowcolor
                end
                if library.flags["rainbowdistanceEnabled"] then
                    v.distance.Color = esp.rainbowcolor
                end
                if library.flags["rainbowviewangleEnabled"] then
                    v.viewAngle.Color = esp.rainbowcolor
                end
                if library.flags["rainbowtracersEnabled"] then
                    v.tracers.Color = esp.rainbowcolor
                end
                if library.flags["rainbowskeletonEnabled"] then
                    v.skeleton.Head.Color = esp.rainbowcolor
                    v.skeleton.LeftHand.Color = esp.rainbowcolor
                    v.skeleton.RightHand.Color = esp.rainbowcolor
                    v.skeleton.LeftLowerArm.Color = esp.rainbowcolor
                    v.skeleton.RightLowerArm.Color = esp.rainbowcolor
                    v.skeleton.LeftUpperArm.Color = esp.rainbowcolor
                    v.skeleton.RightUpperArm.Color = esp.rainbowcolor
                    v.skeleton.LeftFoot.Color = esp.rainbowcolor
                    v.skeleton.LeftLowerLeg.Color = esp.rainbowcolor
                    v.skeleton.UpperTorso.Color = esp.rainbowcolor
                    v.skeleton.LeftUpperLeg.Color = esp.rainbowcolor
                    v.skeleton.RightFoot.Color = esp.rainbowcolor
                    v.skeleton.RightLowerLeg.Color = esp.rainbowcolor
                    v.skeleton.LowerTorso.Color = esp.rainbowcolor
                    v.skeleton.RightUpperLeg.Color = esp.rainbowcolor
                end
                if library.flags["rainbowlocalchamsEnabled"] then
                    library.flags["localplayerchamsColor"] = esp.rainbowcolor
                end
                if library.flags["rainbowchamsEnabled"] then
                    v.chams.FillColor = esp.rainbowcolor
                end
                if library.flags["rainbowchamsoutlineEnabled"] then
                    v.chams.OutlineColor = esp.rainbowcolor
                end
            end
        end
    end
end)



local mainLoop = game:GetService("RunService").RenderStepped:Connect(function()

    --* Enemy Radar *--
    if library.flags["enemyradarEnabled"] then
        if LocalPlayerDot ~= nil then
            LocalPlayerDot.Visible = true
            LocalPlayerDot.Color = RadarInfo.LocalPlayerDot
            LocalPlayerDot.PointA = RadarInfo.Position + Vector2.new(0, -6)
            LocalPlayerDot.PointB = RadarInfo.Position + Vector2.new(-3, 6)
            LocalPlayerDot.PointC = RadarInfo.Position + Vector2.new(3, 6)
        end
        RadarBackground.Position = RadarInfo.Position
        RadarBackground.Radius = RadarInfo.Radius
        RadarBackground.Color = RadarInfo.RadarBack

        RadarBorder.Position = RadarInfo.Position
        RadarBorder.Radius = RadarInfo.Radius
        RadarBorder.Color = RadarInfo.RadarBorder
        RadarBorder.Visible = true
        RadarBackground.Visible = true

        if (Vector2.new(Mouse.X, Mouse.Y + inset.Y) - RadarInfo.Position).magnitude < RadarInfo.Radius then
            dot.Position = Vector2.new(Mouse.X, Mouse.Y + inset.Y)
            dot.Visible = true
        else 
            dot.Visible = false
        end
        if dragging then
            RadarInfo.Position = Vector2.new(Mouse.X, Mouse.Y) + offset
        end
    else
        RadarBorder.Visible = false
        RadarBackground.Visible = false
        LocalPlayerDot.Visible = false
        dot.Visible = false
    end

    --* Third Person *--
    if library.flags["thirdpersonEnabled"] and ThirdPersonToggled then
        if library.flags["cameraFOVEnabled"] then
            workspace.CurrentCamera.FieldOfView = Old_FOV
        end
        local Checkkkk = game:GetService("Workspace").Camera:FindFirstChild("ViewModel")
        if Checkkkk then
            for i,v in pairs(game:GetService("Workspace").Camera.ViewModel:GetDescendants()) do
                if v.ClassName == "MeshPart" then
                    if v.Parent.Name == "WastelandShirt" or v.Parent.Name == "GhillieTorso" or v.Parent.Name == "CivilianPants" or v.Parent.Name == "CamoShirt" or v.Parent.Name == "HandWraps" or v.Parent.Name == "CombatGloves" then
                        v.Transparency = 1
                    end
                end
                if v.ClassName == "MeshPart" then
                    if v.Name == "LeftHand" or v.Name == "LeftLowerArm" or v.Name == "LeftUpperArm" or v.Name == "RightHand" or v.Name == "RightLowerArm" or v.Name == "RightUpperArm" then
                        v.Transparency = 1
                    end
                end
                if v.ClassName == "Part" then
                    if v.Name == "AimPartCanted" or v.Name == "AimPart" then
                        v.Transparency = 1
                    end
                end
            end
            for i,v in pairs(game:GetService("Workspace").Camera.ViewModel.Item:GetDescendants()) do
                if v.ClassName == "MeshPart" or v.ClassName == "Part" then
                    v.Transparency = 1
                end
            end
        end
    end

    --* LocalPlayer Chams *--
    local Checkkkk = game:GetService("Workspace").Camera:FindFirstChild("ViewModel")
    if library.flags["localchamsEnabled"] and Checkkkk ~= nil then
        for i,v in pairs(game:GetService("Workspace").Camera.ViewModel:GetDescendants()) do
            if v.ClassName == "MeshPart" then
                if v.Parent.Name == "WastelandShirt" or v.Parent.Name == "GhillieTorso" or v.Parent.Name == "CivilianPants" or v.Parent.Name == "CamoShirt" or v.Parent.Name == "HandWraps" or v.Parent.Name == "CombatGloves" then
                    v.Transparency = 1
                end
            end
            if v.ClassName == "MeshPart" then
                if v.Name == "LeftHand" or v.Name == "LeftLowerArm" or v.Name == "LeftUpperArm" or v.Name == "RightHand" or v.Name == "RightLowerArm" or v.Name == "RightUpperArm" then
                    v.Material = (library.flags["localplayerchamsMaterial"])
                    v.Color = (library.flags["localplayerchamsColor"])
                end
            end
            if v.ClassName == "Part" then
                if v.Name == "AimPartCanted" or v.Name == "AimPart" then
                    v.Size = Vector3.new(0, 0, 0)
                    v.Transparency = 1
                end
            end
        end
        for i,v in pairs(game:GetService("Workspace")[LocalPlayerName]:GetChildren()) do
            if v.ClassName == "MeshPart" then
                v.Material = (library.flags["localplayerchamsMaterial"])
                v.Color = (library.flags["localplayerchamsColor"])
            end
        end
        --game:GetService("Workspace").Camera.ViewModel.Item.ItemRoot.Material = (library.flags["localplayerchamsMaterial"])
        --game:GetService("Workspace").Camera.ViewModel.Item game:GetService("Workspace").Camera.ViewModel.Item.SlideModel.SurfaceAppearance
        for i,v in pairs(game:GetService("Workspace").Camera.ViewModel.Item:GetDescendants()) do
            if v.ClassName == "MeshPart" or v.ClassName == "Part" then
                v.Material = (library.flags["localgunchamsMaterial"])
                v.Color = (library.flags["localplayerchamsColor"])
            end
            if v:FindFirstChild("SurfaceAppearance") then
                v.SurfaceAppearance:Destroy()
            end
        end
    end

    --* No Water Blur *--
    if library.flags["nowaterblurEnabled"] then
        waterBlur.Enabled = false
    end

    --* Rapid Fire *--
    if library.flags["rapidfireEnabled"] then
        for i,v in next, game.ReplicatedStorage.Players[game.Players.LocalPlayer.Name].Inventory:GetChildren() do
            local module = require(v.SettingsModule)
            module.FireRate = library.flags["firerateValue"]
        end
    end

    -- * CrossHair * --
    local Real_Size = library.flags["crosshairSize"] / 2
    HorizontalLine.Color        = library.flags["crosshairColor"]
    HorizontalLine.Thickness    = library.flags["crosshairThickness"]
    HorizontalLine.Visible      = library.flags["crosshairEnabled"]
    VerticalLine.Color          = library.flags["crosshairColor"]
    VerticalLine.Thickness      = library.flags["crosshairThickness"]
    VerticalLine.Visible        = library.flags["crosshairEnabled"]
    HorizontalLine.From         = Vector2.new(Axis_X - Real_Size, Axis_Y)
    HorizontalLine.To           = Vector2.new(Axis_X + Real_Size, Axis_Y)
    VerticalLine.From           = Vector2.new(Axis_X, Axis_Y - Real_Size)
    VerticalLine.To             = Vector2.new(Axis_X, Axis_Y + Real_Size)

    --* Watermark *--

    -- FPS maths
    local fr = tick()
    for index = #FPS,1,-1 do
        FPS[index + 1] = (FPS[index] >= fr - 1) and FPS[index] or nil
    end
    FPS[1] = fr
    local fps = (tick() - sec >= 1 and #FPS) or (#FPS / (tick() - sec))
    fps = math.floor(fps)

    -- Ping maths
    local ping = tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue())
    ping = math.floor(ping)

    watermark:Set("1NF1N17Y | " .. fps .. " fps | " .. ping .. "ms | " .. script_version_number .. " | Paid")

    --* Fake Lag *--
    if library.flags["fakelagEnabled"] and FakeLagEnabled then
        Tick = Tick + 1
        local Character = plr.Character
        if Character then
            local Head, HumanoidRootPart, Humanoid = Character:FindFirstChild("Head"), Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
            if Head and HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
                if Tick >= library.flags["fakelagLimit"] then
                    Tick = 0
                    NetworkClient:SetOutgoingKBPSLimit(math.huge)
                    print("Fake Lag")
                    if library.flags["visualizefakelagEnabled"] and FakeLagEnabled then
                        VisualizeLagFolder:ClearAllChildren()
                        Character.Archivable = true
                        local Clone = Character:Clone()
                        Character.Archivable = false
                        for _, Child in pairs(Clone:GetDescendants()) do
                            if Child:IsA("SurfaceAppearance") or Child:IsA("Humanoid") or Child:IsA("BillboardGui") or Child:IsA("Decal") or Child.Name == "HumanoidRootPart" then
                                Child:Destroy()
                                continue
                            end
                            if Child:IsA("BasePart") then
                                Child.CanCollide = false
                                Child.Anchored = true
                                Child.Material = Enum.Material.ForceField
                                Child.Color = library.flags["visualizefakelagColor"] 
                                Child.Size = Child.Size + Vector3.new(0.025, 0.025, 0.025)
                            end
                        end
                        Clone.Parent = VisualizeLagFolder
                    else
                        VisualizeLagFolder:ClearAllChildren()
                    end
                else
                    NetworkClient:SetOutgoingKBPSLimit(1)
                end
            end
        end
    else
        VisualizeLagFolder:ClearAllChildren()
    end

    -- Loop through all the players in the esp table
    for i,v in pairs(esp.players) do
        if esp.HasCharacter(i) then
            local hum = i.Character.Humanoid
            local hrp = i.Character.HumanoidRootPart
            local head = i.Character.Head

            local Vector, onScreen = Camera:WorldToViewportPoint(i.Character.HumanoidRootPart.Position)

            local Size = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.6, 0)).Y) / 2
            local BoxSize = Vector2.new(math.floor(Size * 1.5), math.floor(Size * 1.9))
            local BoxPos = Vector2.new(math.floor(Vector.X - Size * 1.5 / 2), math.floor(Vector.Y - Size * 1.6 / 2))

            local BottomOffset = BoxSize.Y + BoxPos.Y + 1
            local DistanceFromPlayer = math.floor((plr.Character.Head.Position - hrp.Position).Magnitude + 0.5)

            if onScreen and esp.enabled and DistanceFromPlayer < library.flags["espMaxDistance"] then
                if esp.settings.name.enabled then
                    v.name.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BoxPos.Y - 16)
                    v.name.Outline = esp.settings.name.outline

                    if not library.flags["rainbownamesEnabled"] or not esp.rainbowmode then 
                        v.name.Color = esp.settings.name.color
                    elseif library.flags["showcheatersEnabled"] and CheckCheaterTable(i.UserId) then 
                        v.name.Color = library.flags["showcheatersColor"]
                    elseif plr:GetFriendStatus(i) == Enum.FriendStatus.Friend and library.flags["friendcheckEnabled"] then 
                        v.name.Color = library.flags["friendcheckColor"]
                    -- elseif library.flags["showstaffEnabled"] and CheckStaffTable(i.UserId) then 
                    --     v.name.Color = library.flags["showstaffColor"]
                    end

                    v.name.Font = esp.font
                    v.name.Size = esp.fontsize

                    if esp.settings.name.displaynames then
                        v.name.Text = tostring(i.DisplayName)
                    else
                        v.name.Text = tostring(i.Name)
                    end

                    v.name.Visible = true
                else
                    v.name.Visible = false
                end

                if esp.settings.distance.enabled then
                    v.distance.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BottomOffset)
                    v.distance.Outline = esp.settings.distance.outline
                    v.distance.Text = "[" .. math.floor((hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                    
                    if not library.flags["rainbowdistanceEnabled"] or not esp.rainbowmode then 
                        v.distance.Color = esp.settings.distance.color
                    elseif library.flags["showcheatersEnabled"] and CheckCheaterTable(i.UserId) then 
                        v.distance.Color = library.flags["showcheatersColor"]
                    elseif plr:GetFriendStatus(i) == Enum.FriendStatus.Friend and library.flags["friendcheckEnabled"] then 
                        v.distance.Color = library.flags["friendcheckColor"]
                    -- elseif library.flags["showstaffEnabled"] and CheckStaffTable(i.UserId) then 
                    --     v.distance.Color = library.flags["showstaffColor"]
                    end


                    BottomOffset = BottomOffset + 15

                    v.distance.Font = esp.font
                    v.distance.Size = esp.fontsize

                    v.distance.Visible = true
                else
                    v.distance.Visible = false
                end

                if esp.settings.tool.enabled then
                    v.tool.Position = Vector2.new((BoxPos.X + BoxSize.X + 20), (BoxPos.Y + BoxSize.Y - 1 * BoxSize.Y) -1)
                    v.tool.Outline = esp.settings.tool.outline

                    local Tool = ReplicatedPlayers[i.Name].Status.GameplayVariables.EquippedTool
                    local toolObject = Tool.Value
                    local FoundTool = toolObject ~= nil and toolObject.Name or "None"
                    v.tool.Text = tostring(FoundTool)
                    
                    if not library.flags["rainbowtoolEnabled"] or not esp.rainbowmode then 
                        v.tool.Color = esp.settings.tool.color
                    elseif library.flags["showcheatersEnabled"] and CheckCheaterTable(i.UserId) then 
                        v.tool.Color = library.flags["showcheatersColor"]
                    elseif plr:GetFriendStatus(i) == Enum.FriendStatus.Friend and library.flags["friendcheckEnabled"] then 
                        v.tool.Color = library.flags["friendcheckColor"]
                    -- elseif library.flags["showstaffEnabled"] and CheckStaffTable(i.UserId) then 
                    --     v.distance.Color = library.flags["showstaffColor"]
                    end

                    v.tool.Font = esp.font
                    v.tool.Size = esp.fontsize

                    v.tool.Visible = true
                else
                    v.tool.Visible = false
                end

                if esp.settings.box.enabled then
                    v.boxOutline.Size = BoxSize
                    v.boxOutline.Position = BoxPos
                    v.boxOutline.Visible = esp.settings.box.outline

                    v.box.Size = BoxSize
                    v.box.Position = BoxPos

                    if not library.flags["rainbowboxesEnabled"] or not esp.rainbowmode then 
                        v.box.Color = esp.settings.box.color
                    elseif library.flags["showcheatersEnabled"] and CheckCheaterTable(i.UserId) then 
                        v.box.Color = library.flags["showcheatersColor"]
                    elseif plr:GetFriendStatus(i) == Enum.FriendStatus.Friend and library.flags["friendcheckEnabled"] then 
                        v.box.Color = library.flags["friendcheckColor"]
                    -- elseif library.flags["showstaffEnabled"] and CheckStaffTable(i.UserId) then 
                    --     v.box.Color = library.flags["showstaffColor"]
                    end

                    v.box.Filled = false
                    v.box.Visible = true
                else
                    v.boxOutline.Visible = false
                    v.box.Visible = false
                end

                if esp.settings.healthbar.enabled then
                    v.healthBar.From = Vector2.new((BoxPos.X - 5), BoxPos.Y + BoxSize.Y)
                    v.healthBar.To = Vector2.new(v.healthBar.From.X, v.healthBar.From.Y - (hum.Health / hum.MaxHealth) * BoxSize.Y)
                    v.healthBar.Color = Color3.fromRGB(255 - 255 / (hum["MaxHealth"] / hum["Health"]), 255 / (hum["MaxHealth"] / hum["Health"]), 0)
                    v.healthBar.Visible = true

                    v.healthBarOutline.From = Vector2.new(v.healthBar.From.X, BoxPos.Y + BoxSize.Y + 1)
                    v.healthBarOutline.To = Vector2.new(v.healthBar.From.X, (v.healthBar.From.Y - 1 * BoxSize.Y) -1)
                    v.healthBarOutline.Visible = esp.settings.healthbar.outline
                else
                    v.healthBarOutline.Visible = false
                    v.healthBar.Visible = false
                end

                if esp.settings.healthtext.enabled then
                    v.healthText.Text = tostring(math.floor((hum.Health / hum.MaxHealth) * 100 + 0.5))
                    v.healthText.Position = Vector2.new((BoxPos.X - 20), (BoxPos.Y + BoxSize.Y - 1 * BoxSize.Y) -1)

                    if not library.flags["rainbowhealthtextEnabled"] or not esp.rainbowmode then 
                        v.healthText.Color = esp.settings.healthtext.color 
                    elseif library.flags["showcheatersEnabled"] and CheckCheaterTable(i.UserId) then 
                        v.healthText.Color = library.flags["showcheatersColor"] 
                    elseif plr:GetFriendStatus(i) == Enum.FriendStatus.Friend and library.flags["friendcheckEnabled"] then 
                        v.healthText.Color = library.flags["friendcheckColor"] 
                    -- elseif library.flags["showstaffEnabled"] and CheckStaffTable(i.UserId) then 
                    --     v.healthText.Color = library.flags["showstaffColor"] 
                    end

                    v.healthText.Outline = esp.settings.healthtext.outline

                    v.healthText.Font = esp.font
                    v.healthText.Size = esp.fontsize

                    v.healthText.Visible = true
                else
                    v.healthText.Visible = false
                end

                if esp.settings.viewangle.enabled then
                    local fromHead = Camera:worldToViewportPoint(head.CFrame.p)
                    local toPoint = Camera:worldToViewportPoint((head.CFrame + (head.CFrame.lookVector * 10)).p)
                    
                    v.viewAngle.From = Vector2.new(fromHead.X, fromHead.Y)
                    v.viewAngle.To = Vector2.new(toPoint.X, toPoint.Y)

                    if not library.flags["rainbowviewangleEnabled"] or not esp.rainbowmode then 
                        v.viewAngle.Color = esp.settings.viewangle.color 
                    elseif library.flags["showcheatersEnabled"] and CheckCheaterTable(i.UserId) then 
                        v.viewAngle.Color = library.flags["showcheatersColor"]
                    elseif plr:GetFriendStatus(i) == Enum.FriendStatus.Friend and library.flags["friendcheckEnabled"] then 
                        v.viewAngle.Color = library.flags["friendcheckColor"] 
                    -- elseif library.flags["showstaffEnabled"] and CheckStaffTable(i.UserId) then 
                    --     v.viewAngle.Color = library.flags["showstaffColor"] 
                    end

                    v.viewAngle.Visible = true
                else
                    v.viewAngle.Visible = false
                end

                if esp.settings.skeleton.enabled then
                    local Head = i.Character.Head
                    local LeftHand = i.Character.LeftHand
                    local RightHand = i.Character.RightHand
                    local LeftLowerArm = i.Character.LeftLowerArm
                    local RightLowerArm = i.Character.RightLowerArm
                    local LeftUpperArm = i.Character.LeftUpperArm
                    local RightUpperArm = i.Character.RightUpperArm
                    local LeftFoot = i.Character.LeftFoot
                    local LeftLowerLeg = i.Character.LeftLowerLeg
                    local UpperTorso = i.Character.UpperTorso
                    local LeftUpperLeg = i.Character.LeftUpperLeg
                    local RightFoot = i.Character.RightFoot
                    local RightLowerLeg = i.Character.RightLowerLeg
                    local LowerTorso = i.Character.LowerTorso
                    local RightUpperLeg = i.Character.RightUpperLeg

                    local HeadPos = Camera:WorldToViewportPoint(Head.Position)
                    local LeftHandPos = Camera:WorldToViewportPoint(LeftHand.Position)
                    local RightHandPos = Camera:WorldToViewportPoint(RightHand.Position)
                    local LeftLowerArmPos = Camera:WorldToViewportPoint(LeftLowerArm.Position)
                    local RightLowerArmPos = Camera:WorldToViewportPoint(RightLowerArm.Position)
                    local LeftUpperArmPos = Camera:WorldToViewportPoint(LeftUpperArm.Position)
                    local RightUpperArmPos = Camera:WorldToViewportPoint(RightUpperArm.Position)
                    local LeftFootPos = Camera:WorldToViewportPoint(LeftFoot.Position)
                    local LeftLowerLegPos = Camera:WorldToViewportPoint(LeftLowerLeg.Position)
                    local UpperTorsoPos = Camera:WorldToViewportPoint(UpperTorso.Position)
                    local LeftUpperLegPos = Camera:WorldToViewportPoint(LeftUpperLeg.Position)
                    local RightFootPos = Camera:WorldToViewportPoint(RightFoot.Position)
                    local RightLowerLegPos = Camera:WorldToViewportPoint(RightLowerLeg.Position)
                    local LowerTorsoPos = Camera:WorldToViewportPoint(LowerTorso.Position)
                    local RightUpperLegPos = Camera:WorldToViewportPoint(RightUpperLeg.Position)

                    local function CheckFriend()
                        -- if library.flags["showstaffEnabled"] and CheckStaffTable(i.UserId) then 
                        --     return library.flags["showstaffColor"] 
                        -- end
                        if plr:GetFriendStatus(i) == Enum.FriendStatus.Friend and library.flags["friendcheckEnabled"] then 
                            return library.flags["friendcheckColor"] 
                        end
                        if library.flags["showcheatersEnabled"] and CheckCheaterTable(i.UserId) then 
                            return library.flags["showcheatersColor"] 
                        end
                        if not library.flags["rainbowskeletonEnabled"] or not esp.rainbowmode then 
                            return esp.settings.skeleton.color 
                        end

                        return esp.rainbowcolor
                    end

                    if HeadPos and UpperTorsoPos then
                        v.skeleton.Head.From = Vector2.new(HeadPos.X, HeadPos.Y)
                        v.skeleton.Head.To = Vector2.new(UpperTorsoPos.X, UpperTorsoPos.Y)
                        v.skeleton.Head.Color = CheckFriend()
                        v.skeleton.Head.Visible = true

                        v.skeleton.LeftHand.From = Vector2.new(LeftHandPos.X, LeftHandPos.Y)
                        v.skeleton.LeftHand.To = Vector2.new(LeftLowerArmPos.X, LeftLowerArmPos.Y)
                        v.skeleton.LeftHand.Color = CheckFriend()
                        v.skeleton.LeftHand.Visible = true

                        v.skeleton.RightHand.From = Vector2.new(RightHandPos.X, RightHandPos.Y)
                        v.skeleton.RightHand.To = Vector2.new(RightLowerArmPos.X, RightLowerArmPos.Y)
                        v.skeleton.RightHand.Color = CheckFriend()
                        v.skeleton.RightHand.Visible = true

                        v.skeleton.LeftLowerArm.From = Vector2.new(LeftLowerArmPos.X, LeftLowerArmPos.Y)
                        v.skeleton.LeftLowerArm.To = Vector2.new(LeftUpperArmPos.X, LeftUpperArmPos.Y)
                        v.skeleton.LeftLowerArm.Color = CheckFriend()
                        v.skeleton.LeftLowerArm.Visible = true

                        v.skeleton.RightLowerArm.From = Vector2.new(RightLowerArmPos.X, RightLowerArmPos.Y)
                        v.skeleton.RightLowerArm.To = Vector2.new(RightUpperArmPos.X, RightUpperArmPos.Y)
                        v.skeleton.RightLowerArm.Color = CheckFriend()
                        v.skeleton.RightLowerArm.Visible = true

                        v.skeleton.LeftUpperArm.From = Vector2.new(LeftUpperArmPos.X, LeftUpperArmPos.Y)
                        v.skeleton.LeftUpperArm.To = Vector2.new(UpperTorsoPos.X, UpperTorsoPos.Y)
                        v.skeleton.LeftUpperArm.Color = CheckFriend()
                        v.skeleton.LeftUpperArm.Visible = true

                        v.skeleton.RightUpperArm.From = Vector2.new(RightUpperArmPos.X, RightUpperArmPos.Y)
                        v.skeleton.RightUpperArm.To = Vector2.new(UpperTorsoPos.X, UpperTorsoPos.Y)
                        v.skeleton.RightUpperArm.Color = CheckFriend()
                        v.skeleton.RightUpperArm.Visible = true

                        v.skeleton.LeftFoot.From = Vector2.new(LeftFootPos.X, LeftFootPos.Y)
                        v.skeleton.LeftFoot.To = Vector2.new(LeftLowerLegPos.X, LeftLowerLegPos.Y)
                        v.skeleton.LeftFoot.Color = CheckFriend()
                        v.skeleton.LeftFoot.Visible = true

                        v.skeleton.LeftLowerLeg.From = Vector2.new(LeftLowerLegPos.X, LeftLowerLegPos.Y)
                        v.skeleton.LeftLowerLeg.To = Vector2.new(LeftUpperLegPos.X, LeftUpperLegPos.Y)
                        v.skeleton.LeftLowerLeg.Color = CheckFriend()
                        v.skeleton.LeftLowerLeg.Visible = true

                        v.skeleton.UpperTorso.From = Vector2.new(UpperTorsoPos.X, UpperTorsoPos.Y)
                        v.skeleton.UpperTorso.To = Vector2.new(LowerTorsoPos.X, LowerTorsoPos.Y)
                        v.skeleton.UpperTorso.Color = CheckFriend()
                        v.skeleton.UpperTorso.Visible = true

                        v.skeleton.LeftUpperLeg.From = Vector2.new(LeftUpperLegPos.X, LeftUpperLegPos.Y)
                        v.skeleton.LeftUpperLeg.To = Vector2.new(LowerTorsoPos.X, LowerTorsoPos.Y)
                        v.skeleton.LeftUpperLeg.Color = CheckFriend()
                        v.skeleton.LeftUpperLeg.Visible = true

                        v.skeleton.RightFoot.From = Vector2.new(RightFootPos.X, RightFootPos.Y)
                        v.skeleton.RightFoot.To = Vector2.new(RightLowerLegPos.X, RightLowerLegPos.Y)
                        v.skeleton.RightFoot.Color = CheckFriend()
                        v.skeleton.RightFoot.Visible = true

                        v.skeleton.RightLowerLeg.From = Vector2.new(RightLowerLegPos.X, RightLowerLegPos.Y)
                        v.skeleton.RightLowerLeg.To = Vector2.new(RightUpperLegPos.X, RightUpperLegPos.Y)
                        v.skeleton.RightLowerLeg.Color = CheckFriend()
                        v.skeleton.RightLowerLeg.Visible = true

                        v.skeleton.LowerTorso.From = Vector2.new(LowerTorsoPos.X, LowerTorsoPos.Y)
                        v.skeleton.LowerTorso.To = Vector2.new(RightUpperLegPos.X, RightUpperLegPos.Y)
                        v.skeleton.LowerTorso.Color = CheckFriend()
                        v.skeleton.LowerTorso.Visible = true

                        v.skeleton.RightUpperLeg.From = Vector2.new(RightUpperLegPos.X, RightUpperLegPos.Y)
                        v.skeleton.RightUpperLeg.To = Vector2.new(LowerTorsoPos.X, LowerTorsoPos.Y)
                        v.skeleton.RightUpperLeg.Color = CheckFriend()
                        v.skeleton.RightUpperLeg.Visible = true
                    end
                else
                    v.skeleton.Head.Visible = false
                    v.skeleton.LeftHand.Visible = false
                    v.skeleton.RightHand.Visible = false
                    v.skeleton.LeftLowerArm.Visible = false
                    v.skeleton.RightLowerArm.Visible = false
                    v.skeleton.LeftUpperArm.Visible = false
                    v.skeleton.RightUpperArm.Visible = false
                    v.skeleton.LeftFoot.Visible = false
                    v.skeleton.LeftLowerLeg.Visible = false
                    v.skeleton.UpperTorso.Visible = false
                    v.skeleton.LeftUpperLeg.Visible = false
                    v.skeleton.RightFoot.Visible = false
                    v.skeleton.RightLowerLeg.Visible = false
                    v.skeleton.LowerTorso.Visible = false
                    v.skeleton.RightUpperLeg.Visible = false
                end

                if esp.settings.tracers.enabled then
                    local headPos = Camera:WorldToViewportPoint(head.CFrame.p)

                    if library.flags["tracerFromLocation"] == "Bottom" then
                        v.tracers.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    elseif library.flags["tracerFromLocation"] == "Middle" then
                        v.tracers.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    end
                    v.tracers.To = Vector2.new(headPos.X, headPos.Y)
                    
                    if not library.flags["rainbowtracersEnabled"] or not esp.rainbowmode then 
                        v.tracers.Color = esp.settings.tracers.color
                    elseif library.flags["showcheatersEnabled"] and CheckCheaterTable(i.UserId) then 
                        v.tracers.Color = library.flags["showcheatersColor"] 
                    elseif plr:GetFriendStatus(i) == Enum.FriendStatus.Friend and library.flags["friendcheckEnabled"] then 
                        v.tracers.Color = library.flags["friendcheckColor"]
                    -- elseif library.flags["showstaffEnabled"] and CheckStaffTable(i.UserId) then 
                    --     v.tracers.Color = library.flags["showstaffColor"] 
                    end

                    v.tracers.Visible = true
                else
                    v.tracers.Visible = false
                end

                if esp.settings.chams.enabled then
                    -- Check if chams highlight is found
                    if not i.Character:FindFirstChild("Highlight") then
                        v.chams = Instance.new("Highlight") -- Create a new highlight instance if it doesn't exist
                    end

                    v.chams.FillTransparency = 0
                    if esp.settings.chamsOutline.enabled then
                        v.chams.OutlineTransparency = 0
                    else
                        v.chams.OutlineTransparency = 1
                    end
                    v.chams.Parent = i.Character

                    if not library.flags["rainbowchamsoutlineEnabled"] or not esp.rainbowmode then 
                        v.chams.OutlineColor = esp.settings.chamsOutline.color
                    elseif not library.flags["rainbowchamsEnabled"] or not esp.rainbowmode then 
                        v.chams.FillColor = esp.settings.chams.color
                    elseif not library.flags["rainbowchamsEnabled"] and not library.flags["rainbowchamsoutlineEnabled"] or not esp.rainbowmode then 
                        v.chams.FillColor = esp.settings.chams.color
                        v.chams.OutlineColor = esp.settings.chamsOutline.color
                    elseif library.flags["showcheatersEnabled"] and CheckCheaterTable(i.UserId) then 
                        v.chams.FillColor = library.flags["showcheatersColor"] 
                        v.chams.OutlineColor = library.flags["showcheatersColor"] 
                    elseif plr:GetFriendStatus(i) == Enum.FriendStatus.Friend and library.flags["friendcheckEnabled"] then 
                        v.chams.FillColor = library.flags["friendcheckColor"]
                        v.chams.OutlineColor = library.flags["friendcheckColor"]
                    -- elseif library.flags["showstaffEnabled"] and CheckStaffTable(i.UserId) then 
                    --     v.tracers.Color = library.flags["showstaffColor"] 
                    end

                else
                    v.chams.FillTransparency = 1
                    v.chams.OutlineTransparency = 1
                end

            else
                -- Disable ESP if player is off screen or out of Max render distance
                v.name.Visible = false
                v.boxOutline.Visible = false
                v.box.Visible = false
                v.tool.Visible = false
                v.healthBarOutline.Visible = false
                v.healthBar.Visible = false
                v.healthText.Visible = false
                v.distance.Visible = false
                v.viewAngle.Visible = false
                v.tracers.Visible = false

                v.chams.FillTransparency = 1
                v.chams.OutlineTransparency = 1

                v.skeleton.Head.Visible = false
                v.skeleton.LeftHand.Visible = false
                v.skeleton.RightHand.Visible = false
                v.skeleton.LeftLowerArm.Visible = false
                v.skeleton.RightLowerArm.Visible = false
                v.skeleton.LeftUpperArm.Visible = false
                v.skeleton.RightUpperArm.Visible = false
                v.skeleton.LeftFoot.Visible = false
                v.skeleton.LeftLowerLeg.Visible = false
                v.skeleton.UpperTorso.Visible = false
                v.skeleton.LeftUpperLeg.Visible = false
                v.skeleton.RightFoot.Visible = false
                v.skeleton.RightLowerLeg.Visible = false
                v.skeleton.LowerTorso.Visible = false
                v.skeleton.RightUpperLeg.Visible = false
            end
        else
            -- Disable ESP if player has no character
            v.name.Visible = false
            v.boxOutline.Visible = false
            v.box.Visible = false
            v.tool.Visible = false
            v.healthBarOutline.Visible = false
            v.healthBar.Visible = false
            v.healthText.Visible = false
            v.distance.Visible = false
            v.viewAngle.Visible = false
            v.tracers.Visible = false

            v.chams.FillTransparency = 1
            v.chams.OutlineTransparency = 1
            
            v.skeleton.Head.Visible = false
            v.skeleton.LeftHand.Visible = false
            v.skeleton.RightHand.Visible = false
            v.skeleton.LeftLowerArm.Visible = false
            v.skeleton.RightLowerArm.Visible = false
            v.skeleton.LeftUpperArm.Visible = false
            v.skeleton.RightUpperArm.Visible = false
            v.skeleton.LeftFoot.Visible = false
            v.skeleton.LeftLowerLeg.Visible = false
            v.skeleton.UpperTorso.Visible = false
            v.skeleton.LeftUpperLeg.Visible = false
            v.skeleton.RightFoot.Visible = false
            v.skeleton.RightLowerLeg.Visible = false
            v.skeleton.LowerTorso.Visible = false
            v.skeleton.RightUpperLeg.Visible = false
        end
    end

end)


--* Configurations TAB *--
local configs = main:Tab("Configuration")
local themes = configs:Section{Name = "Settings", Side = "Left"}
themes:Button{
    Name = "Unhook",
    Callback  = function()
        Running = false

        getgenv().Aimbot.Settings.Enabled = false
        getgenv().Aimbot.FOVSettings.Enabled = false

        
        ESP:Toggle(false)
        ESP.Settings.Objects_Enabled = false

        gethiddenproperty(Terrain, "Decoration", Old_Decoration)

        KeybindViewer.Main:Remove()
        KeybindViewer.Border:Remove()
        KeybindViewer.TopBorder:Remove()
        for i, v in pairs(KeybindViewer.Texts) do
            v:Remove()
        end

        lighting.Ambient = Old_Lighting.Ambient
	    lighting.Brightness = Old_Lighting.Brightness

        library:Unload()
    end
}
themes:Button{
    Name = "Rejoin Server",
    Callback  = function()
        local Rejoin = coroutine.create(function()
            local Success, ErrorMessage = pcall(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
            end)

            if ErrorMessage and not Success then
                warn(ErrorMessage)
            end
        end)

        coroutine.resume(Rejoin)
    end
}
themes:Keybind{
    Name = "UI Toggle",
    Flag = "UI Toggle",
    Default = Enum.KeyCode.RightShift,
    Blacklist = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3},
    Callback = function(_, fromsetting)
        if not fromsetting then
            library:Close()
        end
    end
}

themes:Separator("Player Scanner")

--* Cheater Scanner *--
local ShowCheatersToggle = themes:Toggle{
    Name = "Show Cheaters",
    Flag = "showcheatersEnabled",
    -- Default = false,
    Callback = function(bool)
        if not bool then
            InGameCheaters = {}
        end
    end
}
ShowCheatersToggle:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "showcheatersColor",
    Callback = function(color)
        
    end
}
local addcheaterName = themes:Box{
    Name = "Cheaters Name",
    Placeholder = "Cheaters Name",
    Flag = "addcheaterName",
}
local CheaterFound = false
themes:Button{
    Name = "Add Cheater",
    Callback = function()
        if library.flags["addcheaterName"] then
            -- for each player
            for i, v in pairs(game.Players:GetPlayers()) do
                if v.Name == library.flags["addcheaterName"] or v.DisplayName == library.flags["addcheaterName"] then
                    if addRobloxUsername(v.UserId) then
                        OrionLib:MakeNotification({
                            Name = "Notification",
                            Content = "Successfully added cheater to database",
                            Image = "rbxassetid://4483345998",
                            Time = 5
                        })
                        CheaterFound = true
                        break
                    else
                        OrionLib:MakeNotification({
                            Name = "Notification",
                            Content = "Failed to add cheater to database",
                            Image = "rbxassetid://4483345998",
                            Time = 5
                        })
                        CheaterFound = true
                        break
                    end
                end
            end

            if not CheaterFound then
                OrionLib:MakeNotification({
                    Name = "Notification",
                    Content = "No cheater found with that name",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
            end
        end
    end
}

--* Staff Scanner *--
local ShowStaffToggle = themes:Toggle{
    Name = "Show Staff",
    Flag = "showstaffEnabled",
    -- Default = false,
    Callback = function(bool)
        if not bool then
            InGameStaff = {}
        end
    end
}
ShowStaffToggle:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "showstaffColor",
    Callback = function(color)
        
    end
}
local addstaffName = themes:Box{
    Name = "Staff Name",
    Placeholder = "Staff Name",
    Flag = "addstaffName",
}
local StaffFound = false
themes:Button{
    Name = "Add Staff",
    Callback = function()
        if library.flags["addstaffName"] then
            -- for each player
            for i, v in pairs(game.Players:GetPlayers()) do
                if v.Name == library.flags["addstaffName"] or v.DisplayName == library.flags["addstaffName"] then
                    if addRobloxUsernameStaff(v.UserId) then
                        OrionLib:MakeNotification({
                            Name = "Notification",
                            Content = "Successfully added staff to database",
                            Image = "rbxassetid://4483345998",
                            Time = 5
                        })
                        StaffFound = true
                        break
                    else
                        OrionLib:MakeNotification({
                            Name = "Notification",
                            Content = "Failed to add staff to database",
                            Image = "rbxassetid://4483345998",
                            Time = 5
                        })
                        StaffFound = true
                        break
                    end
                end
            end

            if not StaffFound then
                OrionLib:MakeNotification({
                    Name = "Notification",
                    Content = "No staff found with that name",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
            end
        end
    end
}

--* Player Scanner Funtions *--
task.spawn(function()
    -- repeat task
    while task.wait(5) do
        if library.flags["showcheatersEnabled"] then
            for i, Player in pairs(plrs:GetPlayers()) do
                if Player ~= plr then
                    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                        if Player.Character.Humanoid.Health > 0 and library.flags["showcheatersEnabled"] then
                            if checkRobloxUsername(Player.UserId) and not CheckCheaterTable2(Player.UserId) then
                                print("Found cheater")
                                table.insert(InGameCheaters, Player.UserId)
                            elseif Player.Character.Humanoid.Health > 100 and not CheckCheaterTable2(Player.UserId) then
                                print("Found cheater")
                                table.insert(InGameCheaters, Player.UserId)
                            elseif Player.Character.Humanoid.WalkSpeed > 11 and not CheckCheaterTable2(Player.UserId) then
                                print("Found cheater")
                                table.insert(InGameCheaters, Player.UserId)
                            elseif Player.Character.Humanoid.JumpPower > 50 and not CheckCheaterTable2(Player.UserId) then
                                print("Found cheater")
                                table.insert(InGameCheaters, Player.UserId)
                            -- elseif checkRobloxUsernameStaff(Player.UserId) and not CheckStaffTable2(Player.UserId) then
                            --     print("Found staff")
                            --     table.insert(InGameStaff, Player.UserId)
                            -- elseif Player.Name == "DaRealOneTabo" or Player.Name == "yeetussaintcletus" or Player.Name == "adsqwe0DD" or Player.Name == "comdinationisLEHbest" or Player.Name == "walter0456" or Player.Name == "ZanderEL" or Player.Name == "hujhufbslkjgbskg" or Player.Name == "Skillful" or Player.Name == "Dan64210" or Player.Name == "Skillh" or Player.Name == "nite_mare654" or Player.Name == "MrDude94" or Player.Name == "xtg12221gtx" or Player.Name == "ismpforvic" then
                            --     if not CheckStaffTable2(Player.UserId) then
                            --         print("Found staff")
                            --         table.insert(InGameStaff, Player.UserId)
                            --     end
                            end
                        else
                            InGameStaff = {}
                            InGameCheaters = {}
                        end
                    end
                end
            end
        end
    end
end)

local themepickers = {}

local themelist = themes:Dropdown{
    Name = "Theme",
    Default = library.currenttheme,
    Content = library:GetThemes(),
    Flag = "Theme Dropdown",
    Callback = function(option)
        if option then
            library:SetTheme(option)

            for option, picker in next, themepickers do
                picker:Set(library.theme[option])
            end
        end
    end
}

library:ConfigIgnore("Theme Dropdown")

local namebox = themes:Box{
    Name = "Custom Theme Name",
    Placeholder = "Custom Theme",
    Flag = "Custom Theme"
}

library:ConfigIgnore("Custom Theme")

themes:Button{
    Name = "Save Custom Theme",
    Callback = function()
        if library:SaveCustomTheme(library.flags["Custom Theme"]) then
            themelist:Refresh(library:GetThemes())
            themelist:Set(library.flags["Custom Theme"])
            namebox:Set("")
        end
    end
}


local customtheme = configs:Section{Name = "", Side = "Right"}

themepickers["Accent"] = customtheme:ColorPicker{
    Name = "Accent",
    Default = library.theme["Accent"],
    Flag = "Accent",
    Callback = function(color)
        library:ChangeThemeOption("Accent", color)
        KeybindViewer.TopBorder.Color = color
    end
}

library:ConfigIgnore("Accent")

themepickers["Window Background"] = customtheme:ColorPicker{
    Name = "Window Background",
    Default = library.theme["Window Background"],
    Flag = "Window Background",
    Callback = function(color)
        library:ChangeThemeOption("Window Background", color)
        KeybindViewer.Border.Color = color
    end
}

library:ConfigIgnore("Window Background")

themepickers["Window Border"] = customtheme:ColorPicker{
    Name = "Window Border",
    Default = library.theme["Window Border"],
    Flag = "Window Border",
    Callback = function(color)
        library:ChangeThemeOption("Window Border", color)
    end
}

library:ConfigIgnore("Window Border")

themepickers["Tab Background"] = customtheme:ColorPicker{
    Name = "Tab Background",
    Default = library.theme["Tab Background"],
    Flag = "Tab Background",
    Callback = function(color)
        library:ChangeThemeOption("Tab Background", color)
        KeybindViewer.Main.Color = color
    end
}

library:ConfigIgnore("Tab Background")

themepickers["Tab Border"] = customtheme:ColorPicker{
    Name = "Tab Border",
    Default = library.theme["Tab Border"],
    Flag = "Tab Border",
    Callback = function(color)
        library:ChangeThemeOption("Tab Border", color)
    end
}

library:ConfigIgnore("Tab Border")

themepickers["Tab Toggle Background"] = customtheme:ColorPicker{
    Name = "Tab Toggle Background",
    Default = library.theme["Tab Toggle Background"],
    Flag = "Tab Toggle Background",
    Callback = function(color)
        library:ChangeThemeOption("Tab Toggle Background", color)
    end
}

library:ConfigIgnore("Tab Toggle Background")

themepickers["Section Background"] = customtheme:ColorPicker{
    Name = "Section Background",
    Default = library.theme["Section Background"],
    Flag = "Section Background",
    Callback = function(color)
        library:ChangeThemeOption("Section Background", color)
    end
}

library:ConfigIgnore("Section Background")

themepickers["Section Border"] = customtheme:ColorPicker{
    Name = "Section Border",
    Default = library.theme["Section Border"],
    Flag = "Section Border",
    Callback = function(color)
        library:ChangeThemeOption("Section Border", color)
    end
}

library:ConfigIgnore("Section Border")

themepickers["Text"] = customtheme:ColorPicker{
    Name = "Text",
    Default = library.theme["Text"],
    Flag = "Text",
    Callback = function(color)
        library:ChangeThemeOption("Text", color)
    end
}

library:ConfigIgnore("Text")

themepickers["Disabled Text"] = customtheme:ColorPicker{
    Name = "Disabled Text",
    Default = library.theme["Disabled Text"],
    Flag = "Disabled Text",
    Callback = function(color)
        library:ChangeThemeOption("Disabled Text", color)
    end
}

library:ConfigIgnore("Disabled Text")

themepickers["Object Background"] = customtheme:ColorPicker{
    Name = "Object Background",
    Default = library.theme["Object Background"],
    Flag = "Object Background",
    Callback = function(color)
        library:ChangeThemeOption("Object Background", color)
    end
}

library:ConfigIgnore("Object Background")

themepickers["Object Border"] = customtheme:ColorPicker{
    Name = "Object Border",
    Default = library.theme["Object Border"],
    Flag = "Object Border",
    Callback = function(color)
        library:ChangeThemeOption("Object Border", color)
    end
}

library:ConfigIgnore("Object Border")

themepickers["Dropdown Option Background"] = customtheme:ColorPicker{
    Name = "Dropdown Option Background",
    Default = library.theme["Dropdown Option Background"],
    Flag = "Dropdown Option Background",
    Callback = function(color)
        library:ChangeThemeOption("Dropdown Option Background", color)
    end
}

library:ConfigIgnore("Dropdown Option Background")


local CrossHair = configs:Section{Name = "", Side = "Right"}

--* Cross Hair *--
local CrossHairEnabled = CrossHair:Toggle{
    Name = "Show Crosshair",
    Flag = "crosshairEnabled",
    -- Default = false,
    Callback = function(bool)
    end
}
CrossHairEnabled:ColorPicker{
    Default = Color3.fromRGB(255, 255, 255), 
    Flag = "crosshairColor",
    Callback = function(color)
        
    end
}
CrossHair:Slider{
    Name = "Size",
    Text = "[value]/100",
    Default = 45,
    Min = 1,
    Max = 100,
    Float = 1,
    Flag = "crosshairSize",
    Callback = function(value)
        
    end
}
CrossHair:Slider{
    Name = "Thickness",
    Text = "[value]/10",
    Default = 3,
    Min = 1,
    Max = 10,
    Float = 0.1,
    Flag = "crosshairThickness",
    Callback = function(value)
        
    end
}

local keybind_viewer = configs:Section{Name = "", Side = "Right"}

local KeybindviewerToggle = keybind_viewer:Toggle{
    Name = "Show Keybind Viewer",
    Flag = "showkeybindsEnabled",
    -- Default = false,
    Callback = function(bool)
        KeybindViewer.Main.Visible = bool
        KeybindViewer.Border.Visible = bool
        KeybindViewer.TopBorder.Visible = bool

        Title.Visible = bool
        WalkspeedKeybindOld.Visible = bool
        WalkspeedKeybind.Visible = bool
        CameraZoomKeybind.Visible = bool
        ThirdPersonKeybind.Visible = bool
        HipHeightKeybind.Visible = bool
        UnlockDoorKeybind.Visible = bool
        AiAimbotKeybind.Visible = bool
    end
}
keybind_viewer:Slider{
    Name = "Frame X Pos",
    Text = "X Position: [value]",
    Default = 0,
    Min = 0,
    Max = Camera.ViewportSize.X - 175,
    Float = 1,
    Flag = "keybindFrameXPos",
    Callback = function(value)
        KeybindViewer.Main.Position = Vector2.new(value, KeybindViewer.Main.Position.Y)
        KeybindViewer.Border.Position = Vector2.new(value, KeybindViewer.Border.Position.Y)
        KeybindViewer.TopBorder.Position = Vector2.new(value + 2, KeybindViewer.TopBorder.Position.Y)
        Title.Position = Vector2.new(value + 7, Title.Position.Y)
        WalkspeedKeybindOld.Position = Vector2.new(value + 10, WalkspeedKeybindOld.Position.Y)
        WalkspeedKeybind.Position = Vector2.new(value + 10, WalkspeedKeybind.Position.Y)
        CameraZoomKeybind.Position = Vector2.new(value + 10, CameraZoomKeybind.Position.Y)
        ThirdPersonKeybind.Position = Vector2.new(value + 10, ThirdPersonKeybind.Position.Y)
        HipHeightKeybind.Position = Vector2.new(value + 10, HipHeightKeybind.Position.Y)
        UnlockDoorKeybind.Position = Vector2.new(value + 10, UnlockDoorKeybind.Position.Y)
        AiAimbotKeybind.Position = Vector2.new(value + 10, AiAimbotKeybind.Position.Y)
    end
}
keybind_viewer:Slider{
    Name = "Frame Y Pos",
    Text = "Y Position: [value]",
    Default = Camera.ViewportSize.Y / 2,
    Min = 0,
    Max = Camera.ViewportSize.Y - 145,
    Float = 1,
    Flag = "keybindFrameYPos",
    Callback = function(value)
        KeybindViewer.Main.Position = Vector2.new(KeybindViewer.Main.Position.X, value)
        KeybindViewer.Border.Position = Vector2.new(KeybindViewer.Border.Position.X, value)
        KeybindViewer.TopBorder.Position = Vector2.new(KeybindViewer.TopBorder.Position.X, value + 2)
        Title.Position = Vector2.new(Title.Position.X, value + 5)
        WalkspeedKeybindOld.Position = Vector2.new(WalkspeedKeybindOld.Position.X, value + 40)
        WalkspeedKeybind.Position = Vector2.new(WalkspeedKeybind.Position.X, value + 60)
        CameraZoomKeybind.Position = Vector2.new(CameraZoomKeybind.Position.X, value + 80)
        ThirdPersonKeybind.Position = Vector2.new(ThirdPersonKeybind.Position.X, value + 100)
        HipHeightKeybind.Position = Vector2.new(HipHeightKeybind.Position.X, value + 120)
        UnlockDoorKeybind.Position = Vector2.new(UnlockDoorKeybind.Position.X, value + 140)
        AiAimbotKeybind.Position = Vector2.new(AiAimbotKeybind.Position.X, value + 160)
    end
}


local configsection = configs:Section{Name = "Configs", Side = "Left"}

local configlist = configsection:Dropdown{
    Name = "Available Configs",
    Content = library:GetConfigs(), -- GetConfigs(true) if you want universal configs
    Flag = "Config Dropdown"
}

library:ConfigIgnore("Config Dropdown")

local loadconfig = configsection:Button{
    Name = "Load Config",
    Callback = function()
        library:LoadConfig(library.flags["Config Dropdown"]) -- LoadConfig(library.flags["Config Dropdown"], true)  if you want universal configs
        library:LoadConfig(library.flags["Config Dropdown"])
        library:LoadConfig(library.flags["Config Dropdown"])
    end
}

local delconfig = configsection:Button{
    Name = "Delete Config",
    Callback = function()
        library:DeleteConfig(library.flags["Config Dropdown"]) -- DeleteConfig(library.flags["Config Dropdown"], true)  if you want universal configs
        configlist:Refresh(library:GetConfigs())
    end
}


local configbox = configsection:Box{
    Name = "Config Name",
    Placeholder = "Enter Config Name Here",
    Flag = "Config Name"
}

library:ConfigIgnore("Config Name")

local save = configsection:Button{
    Name = "Save Config",
    Callback = function()
        library:SaveConfig(library.flags["Config Dropdown"] or library.flags["Config Name"]) -- SaveConfig(library.flags["Config Name"], true) if you want universal configs
        configlist:Refresh(library:GetConfigs())
    end
}

Sections.Credits.Changelog:Label(script_version_number .. " - " .. last_updated)
Sections.Credits.Changelog:Label(" - Fixed fps issues")
Sections.Credits.Changelog:Label(" - Fixed silent aim not working with ai aimbot")
Sections.Credits.Changelog:Label(" - Added hip height keybind")
Sections.Credits.Changelog:Label(" - Added unlock door keybind")
Sections.Credits.Changelog:Label(" - Added ai aimbot enabled keybind")

Sections.Credits.Credits:Label("Made by: 黑客先生#8957")
Sections.Credits.Credits:Label("Discord: .gg/cookiesservices")