-- ## server ## --


local data = game:GetService("DataStoreService")
local json = game:GetService("HttpService")
local jddata = data:GetDataStore("JdXomNomStuff")

-- so you know the parent
script.Parent = workspace

local val = owner:FindFirstChild'VALUE' or Instance.new("ObjectValue",owner)
val.Name = "VALUE"
val.Value = script

local tag = owner.UserId
script.Name = 'deez'
local event = Instance.new("RemoteEvent", owner)
event.Name = 'event'
local sound = Instance.new("Sound", owner.Character.Head)
sound.SoundId = "rbxassetid://9119119619"
local parts = {}
local tbl = {}

local soundsave = tag.."SavedSounds"


local ids = {}
function refreshids()
	local work,err = pcall(function()
		return jddata:GetAsync(soundsave)
	end)
	ids = (work and err or {})
	print(ids)
	if not work or ids == nil then
		warn("ERROR LOADING ID(S): "..tostring(err))
		ids = {}
	end
end
refreshids()

function saveid(name,id)
	refreshids()
	ids[name] = id
	local work,err = pcall(function()
		jddata:SetAsync(soundsave,ids)
	end)
	if not work then
		warn("ERROR SAVING IDS: "..err)
	end
end

function getsavedid(name)
	local id = false
	local work,err = pcall(function()
		id = jddata:GetAsync(soundsave)[name]
	end)
	if id then
		return id
	else
		warn("ERROR LOADING ID IS: "..err)
		return 0
	end
end

local len = 6;
local pos = owner.Character.HumanoidRootPart.CFrame
local folder = Instance.new("Folder", script)
folder.Name = 'deezFolder'

local function gen()
	sound.Parent = script
	folder:ClearAllChildren()
	for i=1,len,1 do
		parts[i] = Instance.new("Part", folder)
		parts[i].Name = 'deez' .. i
		parts[i].Anchored = true
		parts[i].CFrame = pos * CFrame.new(0,15,i * 3 - ((len / 2) * 3))
		parts[i].Material = "Neon"
		parts[i].CanCollide = false
		parts[i].Transparency = 0.3
	end
	sound.Parent = parts[math.round(len/2)]
end
gen()

local function load(id)
	sound.SoundId = 'rbxassetid://' .. ids[id]
end



sound.Parent = parts[1]
sound.Name = 'deez'
sound.Looped = true

local r = 0;
local g = 10;
local b = 0;

event.OnServerEvent:Connect(function(p, l)
	tbl[1] = math.clamp(l / 10, 0, 60)
	for i=len,2,-1 do
		tbl[i] = tbl[i - 1]
	end
	for i,v in ipairs(tbl) do
		parts[i].Size = Vector3.new(1,tbl[i] / 2,2)
		parts[i].Color = Color3.fromRGB(tbl[i] * r,tbl[i] * g,tbl[i] * b)
	end
end)

function message(p)
	local args = string.split(p, "/")
	if args[1] == '#color' then
		if tonumber(args[2]) then
			r = tonumber(args[2])
		end
		if tonumber(args[3]) then
			g = tonumber(args[3])
		end
		if tonumber(args[4]) then
			b = tonumber(args[4])
		end
	elseif args[1] == '#id' then
		sound.SoundId = 'rbxassetid://' .. args[2]
	elseif args[1] == '#len' then
		if tonumber(args[2]) then
			len = math.clamp(tonumber(args[2]),1,50) 
			gen()
		end
	elseif args[1] == '#play' then
		sound:Play()
	elseif args[1] == '#stop' then
		sound:Stop()
	elseif args[1] == '#save' then
		if tonumber(args[3]) then
			saveid(args[2],args[3])
		end
	elseif args[1] == '#load' then
		load(args[2])
	elseif args[1] == '#volume' then
		if tonumber(args[2]) then
			sound.Volume = math.clamp(tonumber(args[2]), 0, 100) / 10
		end
	elseif args[1] == '#list' then
		table.foreach(ids,print)
	end
end

owner.Chatted:Connect(function(c)
	if c:sub(1,3) == "/e " then
		message(c:sub(4))
	else
		message(c)
	end
end)

sound:Play()

-- ## client ## --

NLS([[
local event = owner.event
local sound = owner.VALUE.Value.deezFolder.deez1.deez

game:service'RunService'.Heartbeat:Connect(function()
	event:FireServer(sound.PlaybackLoudness)
end)
]], owner.PlayerGui)
