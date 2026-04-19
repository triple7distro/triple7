-- Triple7 Save Manager
-- Handles configuration saving and loading across sessions

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local SaveManager = {
    Library = nil,
    Folder = "Triple7_Configs",
    Configs = {},
    CurrentConfig = nil,
    AutoSave = false,
    AutoSaveInterval = 60
}

function SaveManager:SetLibrary(library)
    self.Library = library
    return self
end

function SaveManager:SetFolder(folder)
    self.Folder = folder
    return self
end

function SaveManager:BuildFolderPath()
    return self.Folder
end

function SaveManager:CreateFolder()
    if not isfolder then return end
    
    local path = self:BuildFolderPath()
    if not isfolder(path) then
        makefolder(path)
    end
end

function SaveManager:GetConfigs()
    if not isfolder or not listfiles then return {} end
    
    self:CreateFolder()
    local path = self:BuildFolderPath()
    
    if not isfolder(path) then return {} end
    
    local configs = {}
    for _, file in ipairs(listfiles(path)) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(configs, name)
            end
        end
    end
    
    self.Configs = configs
    return configs
end

function SaveManager:Save(name)
    if not self.Library or not writefile then return false end
    
    self:CreateFolder()
    local path = self:BuildFolderPath() .. "/" .. name .. ".json"
    
    local config = {}
    for flag, value in pairs(self.Library.Flags) do
        if typeof(value) == "Color3" then
            config[flag] = {
                Type = "Color3",
                R = value.R,
                G = value.G,
                B = value.B
            }
        elseif typeof(value) == "EnumItem" then
            config[flag] = {
                Type = "Enum",
                Value = tostring(value),
                EnumType = tostring(value.EnumType)
            }
        elseif typeof(value) == "table" then
            config[flag] = {
                Type = "Table",
                Value = value
            }
        else
            config[flag] = value
        end
    end
    
    local success, result = pcall(function()
        writefile(path, HttpService:JSONEncode(config))
    end)
    
    if success then
        self.CurrentConfig = name
        return true
    else
        warn("[Triple7] Failed to save config:", result)
        return false
    end
end

function SaveManager:Load(name)
    if not self.Library or not readfile then return false end
    
    local path = self:BuildFolderPath() .. "/" .. name .. ".json"
    
    if not isfile or not isfile(path) then
        warn("[Triple7] Config not found:", name)
        return false
    end
    
    local success, content = pcall(function()
        return readfile(path)
    end)
    
    if not success then
        warn("[Triple7] Failed to read config:", content)
        return false
    end
    
    local decodeSuccess, config = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    
    if not decodeSuccess then
        warn("[Triple7] Failed to decode config:", config)
        return false
    end
    
    for flag, value in pairs(config) do
        local option = self.Library.Options[flag]
        if option then
            if type(value) == "table" and value.Type then
                if value.Type == "Color3" then
                    option:SetValue(Color3.new(value.R, value.G, value.B))
                elseif value.Type == "Enum" then
                    -- Handle enum loading
                    local enumType = value.EnumType:gsub("Enum\\.", "")
                    local enumValue = value.Value:gsub("Enum\\." .. enumType .. "\\.", "")
                    option:SetValue(Enum[enumType][enumValue])
                elseif value.Type == "Table" then
                    option:SetValue(value.Value)
                end
            else
                option:SetValue(value)
            end
        end
    end
    
    self.CurrentConfig = name
    return true
end

function SaveManager:Delete(name)
    if not delfile then return false end
    
    local path = self:BuildFolderPath() .. "/" .. name .. ".json"
    
    if not isfile or not isfile(path) then
        return false
    end
    
    local success = pcall(function()
        delfile(path)
    end)
    
    return success
end

function SaveManager:AutoSaveLoop()
    if not self.AutoSave then return end
    
    task.spawn(function()
        while self.AutoSave do
            task.wait(self.AutoSaveInterval)
            if self.CurrentConfig then
                self:Save(self.CurrentConfig)
            end
        end
    end)
end

function SaveManager:ImportFromString(name, jsonString)
    if not self.Library or not writefile then return false end
    
    self:CreateFolder()
    local path = self:BuildFolderPath() .. "/" .. name .. ".json"
    
    local success, result = pcall(function()
        writefile(path, jsonString)
    end)
    
    return success
end

function SaveManager:ExportToString(name)
    if not readfile then return nil end
    
    local path = self:BuildFolderPath() .. "/" .. name .. ".json"
    
    if not isfile or not isfile(path) then
        return nil
    end
    
    local success, content = pcall(function()
        return readfile(path)
    end)
    
    if success then
        return content
    else
        return nil
    end
end

function SaveManager:CreateConfigSection(tab, side)
    if not self.Library then return end
    
    local section = tab:CreateSection({Name = "Configuration", Side = side or "Left"})
    
    local configName = ""
    
    -- Config Name Input
    local nameInput = section:AddTextBox({
        Name = "Config Name",
        Placeholder = "Enter config name...",
        Callback = function(value)
            configName = value
        end
    })
    
    -- Save Button
    section:AddButton({
        Name = "Save Config",
        Callback = function()
            if configName ~= "" then
                local success = self:Save(configName)
                if success then
                    if self.Library.Notify then
                        self.Library:Notify({
                            Title = "Config Saved",
                            Content = "Successfully saved config: " .. configName,
                            Type = "Success",
                            Duration = 3
                        })
                    end
                end
            end
        end
    })
    
    -- Load Dropdown
    local configs = self:GetConfigs()
    section:AddDropdown({
        Name = "Load Config",
        Values = configs,
        Callback = function(value)
            local success = self:Load(value)
            if success and self.Library.Notify then
                self.Library:Notify({
                    Title = "Config Loaded",
                    Content = "Successfully loaded config: " .. value,
                    Type = "Success",
                    Duration = 3
                })
            end
        end
    })
    
    -- Delete Dropdown
    section:AddDropdown({
        Name = "Delete Config",
        Values = configs,
        Callback = function(value)
            local success = self:Delete(value)
            if success and self.Library.Notify then
                self.Library:Notify({
                    Title = "Config Deleted",
                    Content = "Successfully deleted config: " .. value,
                    Type = "Success",
                    Duration = 3
                })
            end
        end
    })
    
    -- Auto Save Toggle
    section:AddToggle({
        Name = "Auto Save",
        Default = false,
        Callback = function(value)
            self.AutoSave = value
            if value then
                self:AutoSaveLoop()
            end
        end
    })
    
    -- Refresh Button
    section:AddButton({
        Name = "Refresh Configs",
        Callback = function()
            self:GetConfigs()
        end
    })
    
    return section
end

-- Legacy config converter
function SaveManager:ImportFromTable(name, configTable)
    if not writefile then return false end
    
    self:CreateFolder()
    local path = self:BuildFolderPath() .. "/" .. name .. ".json"
    
    local success = pcall(function()
        writefile(path, HttpService:JSONEncode(configTable))
    end)
    
    return success
end

return SaveManager
