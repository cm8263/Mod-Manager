local Json = require("json.lua")

local jsonFiles = nil

Mod_Manager_Load = function()
  -- Load list of JSON files in Archives directory
  if jsonFiles == nil then
    OverlayShow("ui_loadingIcon", true)
    jsonFiles = {}

    local cdHandle = io.popen("cd")
    local archivesDirectory = cdHandle:read():gsub("\\", "/") .. "/Archives"

    cdHandle.close()

    local dirHandle = io.popen((string.format)("dir \"%s\" /b", archivesDirectory))
    
    for line in dirHandle:lines() do
      if #line > 5 and line:sub(-5) == ".json" and line ~= "modinfo_Mod Manager.json" then
        table.insert(jsonFiles, (string.format)("%s/%s", archivesDirectory, line))
      end
    end

    dirHandle:close()

    OverlayShow("ui_loadingIcon", false)
  end
  
  -- Create Menu
  local menu = Menu_Create(ListMenu, "Mod Manager Menu")
  menu.align = "left"
  menu.background = {}
  menu.capacity = 10
  menu.showArrows = true

  menu.Show = function(self, direction)
    if direction and direction > 0 then
      Menu_Main_SetIdle("env_clementineHouse400_developerCommentary")
      ChorePlayAndWait("env_clementineHouse400_mainMenuToDeveloperCommentary")
      ChorePlay("ui_alphaGradient_show")
    end

    (Menu.Show)(self)
  end

  menu.Hide = function(self, direction)
    (Menu.Hide)(self)

    if direction and direction < 0 then
      ChorePlay("ui_alphaGradient_hide")
      ChorePlayAndWait("env_clementineHouse400_developerCommentaryToMainMenu")
    end
  end

  menu.Populate = function(self)
    Menu_Add(Header, nil, "Mod Manager Menu")

    for index, file in pairs(jsonFiles) do
      local jsonFile = Mod_Manager_Load_JSON(file)
      Menu_Add(ListButtonLite, "modManagerMod" .. index, jsonFile and jsonFile.ModDisplayName or "Unknown Mod #" .. index, (string.format)("Mod_Manager_Mod_View(%s)", index))
    end
    
    local legendWidget = Menu_Add(Legend)
    legendWidget.Place = function(self)
      self:AnchorToAgent(menu.agent, "left", "bottom")
    end

    Legend_Add("faceButtonDown", "legend_select")
    Legend_Add("faceButtonRight", "legend_previousMenu", "Menu_Pop()")
    local legendButton = Menu_Add(LegendButtonBack, nil, "Menu_Pop()", "legendButton_back")
    legendButton.Place = function(self)
      self:AnchorToAgent(menu.agent, "left", "bottom")
    end
  end

  Menu_Push(menu)
end

Mod_Manager_Mod_View = function(index)
  local jsonFile = Mod_Manager_Load_JSON(jsonFiles[index])

  -- Create Menu
  local menu = Menu_Create(JumpScrollList, "Mod: " .. (jsonFile and jsonFile.ModDisplayName or "Unknown Mod #" .. fileIndex))
  menu.align = "left"
  menu.fileIndex = index
  
  menu.Populate = function(self)
    if not jsonFile or not jsonFile.ModDisplayName then
      Menu_Add(ListButtonLite, "modManagerMod" .. self.fileIndex .. "Error", "Could not load Mod Info!")
    else
      Menu_Add(Header, nil, "Mod: " .. (jsonFile and jsonFile.ModDisplayName or "Unknown Mod #" .. fileIndex))

      require(jsonFile.ModEntryPoint)

      Menu_Add(ListButtonLite, "modManagerMod" .. self.fileIndex .. "Name", (string.format)("Name: %s", jsonFile.ModDisplayName))
      Menu_Add(ListButtonLite, "modManagerMod" .. self.fileIndex .. "Version", (string.format)("Version: %s", jsonFile.ModVersion))
      Menu_Add(ListButtonLite, "modManagerMod" .. self.fileIndex .. "Author", (string.format)("Author: %s", jsonFile.ModAuthor))

      if jsonFile.ModEntryPoint then
        Menu_Add(ListButtonLite, "modManagerMod" .. self.fileIndex .. "EntryPoint", (string.format)("Entry Point: %s", jsonFile.ModEntryPoint))

        if jsonFile.ModEntryPointFunction then
          Menu_Add(ListButtonLite, "modManagerModSpacer", "")
          Menu_Add(ListButtonLite, "modManagerMod" .. self.fileIndex .. "EntryPointFunction", "Launch Mod", (string.format)("%s", jsonFile.ModEntryPointFunction))
        end
      end
    end
    
    local legendWidget = Menu_Add(Legend)
    legendWidget.Place = function(self)
      self:AnchorToAgent(menu.agent, "left", "bottom")
    end

    Legend_Add("faceButtonDown", "legend_select")
    Legend_Add("faceButtonRight", "legend_previousMenu", "Menu_Pop()")
    local legendButton = Menu_Add(LegendButtonBack, nil, "Menu_Pop()", "legendButton_back")
    legendButton.Place = function(self)
      self:AnchorToAgent(menu.agent, "left", "bottom")
    end
  end

  Menu_Push(menu)
end

-- https://gist.github.com/jasonbradley/4291520
Mod_Manager_Load_JSON = function(fileName)
    local contents = ""
    local myTable = {}
    local file = io.open(fileName, "r")

    if not file then return nil end

    local contents = file:read("*a")
    
    myTable = Json.decode(contents);
    io.close(file)

    return myTable
end