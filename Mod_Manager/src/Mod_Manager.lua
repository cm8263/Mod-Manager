local Json = require("json.lua")

local jsonFiles = nil

Mod_Manager_Load = function()
  -- Load list of JSON files in Archives directory
  if jsonFiles == nil then
    OverlayShow("ui_loadingProgress", true)
    jsonFiles = {}

    local cdHandle = io.popen("cd")
    local archivesDirectory = cdHandle:read():gsub("\\", "/") .. "/Archives"

    cdHandle.close()

    local dirHandle = io.popen((string.format)("dir \"%s\" /b", archivesDirectory))
    
    for line in dirHandle:lines() do
      if #line > 5 and line:sub(-5) == ".json" then
        table.insert(jsonFiles, (string.format)("%s/%s", archivesDirectory, line))
      end
    end

    dirHandle:close()

    OverlayShow("ui_loadingProgress", false)
  end
  
  -- Create Menu
  local menu = Menu_Create(JumpScrollList, "Mod Manager")
  menu.align = "left"
  menu.background = {}
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
    Menu_Add(Header, nil, "Mod Manager")
    for i, file in pairs(jsonFiles) do
      local jsonFile = Mod_Manager_Load_JSON(file)
      Menu_Add(ListButtonLite, "modManagerTest" .. i, jsonFile ~= nil and jsonFile.ModDisplayName or "Unknown Mod #" .. i, (string.format)("DialogBox_Okay(\"%s\")", file))
    end
    
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

    if file == nil then return nil end

    local contents = file:read("*a")
    
    myTable = Json.decode(contents);
    io.close(file)

    return myTable
end