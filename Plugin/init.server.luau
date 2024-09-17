--[[
	Created by Rawblocky
--]]

-- ==========================
--> SERVICES
-- ==========================
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
-- <-

-- ==========================
--> CONFIGURATION
-- ==========================
local spriteSheets = {
	"rbxassetid://85041127659272",
	"rbxassetid://134677518949894",
	"rbxassetid://127654379341229",
	"rbxassetid://79652421170538",
	"rbxassetid://139900244308816",
	"rbxassetid://91374783271321",
	"rbxassetid://125972508282020",
	"rbxassetid://114698596607716",
	"rbxassetid://121821204835243",
	"rbxassetid://77586120923428",
	"rbxassetid://93155589577048",
	"rbxassetid://106656168492821",
	"rbxassetid://115069371932988",
	"rbxassetid://125229681126604",
}
local framesPerSec = 4
local playbackSpeed = 2
local spriteSize = Vector2.new(102.4, 192)
local spriteSheetSize = Vector2.new(1024, 960)
local totalFrames = 660

local pluginGuiId = "Rawblocky-SubwaySurf"
local scaleTypeKey = pluginGuiId .. "-ScaleType"
local scaleType = {
	Enum.ScaleType.Stretch,
	Enum.ScaleType.Fit,
	Enum.ScaleType.Crop,
}

local defaultSize = Vector2.new(100, 190) * 2
local minimumSize = Vector2.new(100, 190)
local widgetInfo = DockWidgetPluginGuiInfo.new(
	RunService:IsEdit() and Enum.InitialDockState.Float or Enum.InitialDockState.Left,
	true,
	false,
	defaultSize.X,
	defaultSize.Y,
	minimumSize.X,
	minimumSize.Y
)
-- <-

local toolbar = plugin:CreateToolbar("Subway Surfers")
local button = toolbar:CreateButton("Subway Surfers", "Subway Surfers", "rbxassetid://90302369520844")
button.ClickableWhenViewportHidden = true

local pluginGui = plugin:CreateDockWidgetPluginGui(pluginGuiId, widgetInfo)
pluginGui.Name = pluginGuiId
pluginGui.Title = "Subway Surfers"
button:SetActive(pluginGui.Enabled)

button.Click:Connect(function()
	pluginGui.Enabled = not pluginGui.Enabled
	button:SetActive(pluginGui.Enabled)
end)

local mainImage = Instance.new("ImageLabel")
mainImage.BackgroundTransparency = 1
mainImage.ImageRectSize = spriteSize
mainImage.Name = "MainVideo"
mainImage.ResampleMode = Enum.ResamplerMode.Default
mainImage.Size = UDim2.fromScale(1, 1)
mainImage.ZIndex = 2
mainImage.Parent = pluginGui

local preloadImage = Instance.new("ImageButton")
preloadImage.BackgroundTransparency = 1
preloadImage.ImageRectSize = spriteSize
preloadImage.ImageTransparency = 0.9
preloadImage.Name = "PreloadSpritesheet"
preloadImage.Size = UDim2.new(1, 1, 1, 1)
preloadImage.ZIndex = 1
preloadImage.Parent = pluginGui

local scaleTypeIndex = tonumber(plugin:GetSetting(scaleTypeKey) or 1) or 1
local function updateScaleType(offset: number)
	if offset then
		scaleTypeIndex = ((scaleTypeIndex + offset - 1) % #scaleType) + 1
		plugin:SetSetting(scaleTypeKey, scaleTypeIndex)
	end
	scaleTypeIndex = math.clamp(scaleTypeIndex, 1, #scaleType)

	mainImage.ScaleType = scaleType[scaleTypeIndex]
	preloadImage.ScaleType = scaleType[scaleTypeIndex]
end
preloadImage.MouseButton1Click:Connect(function()
	updateScaleType(1)
end)
updateScaleType()

local currentFrame = 1

local framesPerSpritesheet = math.ceil((spriteSheetSize.X / spriteSize.X) * (spriteSheetSize.Y / spriteSize.Y))

local function setToFrame(frameNumber: number)
	if frameNumber == currentFrame then
		return
	end
	local spriteSheetIndex = math.clamp(math.ceil(frameNumber / framesPerSpritesheet), 1, #spriteSheets)
	local upcomingSpriteSheetIndex = (spriteSheetIndex % #spriteSheets) + 1

	local spriteSheetId = spriteSheets[spriteSheetIndex] or ""
	local upcomingSpriteSheetId = spriteSheets[upcomingSpriteSheetIndex] or ""
	local frameInSpritesheet = (frameNumber - 1) % framesPerSpritesheet
	local positionX = (frameInSpritesheet % (spriteSheetSize.X / spriteSize.X)) * spriteSize.X
	local positionY = math.floor(frameInSpritesheet / (spriteSheetSize.X / spriteSize.X)) * spriteSize.Y

	mainImage.Image = spriteSheetId
	mainImage.ImageRectOffset = Vector2.new(positionX, positionY)

	preloadImage.Image = upcomingSpriteSheetId

	currentFrame = frameNumber
end

local function updateFrames()
	local currentTime = os.clock()
	local frameNumber = math.floor(currentTime * framesPerSec * playbackSpeed) % totalFrames

	setToFrame(frameNumber)
end

-- Only play when the PluginGui is enabled
local playbackId
local function pluginGuiToggled()
	local isEnabled = pluginGui.Enabled
	if not pluginGui.Enabled then
		playbackId = nil
		return
	end
	local currentPlaybackId = HttpService:GenerateGUID(false)
	playbackId = currentPlaybackId
	local waitTime = 1 / (framesPerSec * playbackSpeed * 1.5)

	while currentPlaybackId == playbackId and pluginGui.Enabled do
		updateFrames()
		task.wait(waitTime)
	end
end

pluginGui:GetPropertyChangedSignal("Enabled"):Connect(pluginGuiToggled)
pluginGuiToggled()
