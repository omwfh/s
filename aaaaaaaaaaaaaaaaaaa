local webhookcheck =
	is_sirhurt_closure and "[Sirhurt](" .. "https://sirhurt.net/" .. ")" or pebc_execute and "[ProtoSmasher](" .. "https://dailypcapp.com/protosmasher-download/" .. ")" or syn and "[Synapse X](" .. "https://x.synapse.to/" .. ")" or
	secure_load and "[Sentinel](" .. "https://v3rmillion.net/showthread.php?tid=944783" .. ")" or
	KRNL_LOADED and "[Krnl](" .. "https://krnl.ca/" .. ")" or
	SONA_LOADED and "Sona" or
	"Kid with shit exploit"

-- Encoder

local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding

function encode(data)
	return ((data:gsub('.', function(x) 
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

-- Time

local TIME_ZONE = 17
local date = os.date("!*t")
local hour = (date.hour + TIME_ZONE) % 24
local ampm = hour < 12 and "AM" or "PM"
local timestamp = string.format("%02i:%02i %s", ((hour - 1) % 12) + 1, date.min, ampm)
local date = ((os.date("!*t", os.time())).year .. "/" .. (os.date("!*t", os.time())).month .. "/" .. (os.date("!*t", os.time())).day)

local Player = game.Players.LocalPlayer
local url = _G.Config.Webhook.Url

local data = {
   ["username"] = Player.Name,
   ["avatar_url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=".. tostring(Player.UserId) .."&width=420&height=420&format=png",
   ["content"] = "",
   ["embeds"] = {
       {
           ["title"] = Player.Name .. "'s Arsenal Stats",
           
		   ["description"] = "Username: **" .. game.Players.LocalPlayer.Name.."** executed with **"..webhookcheck.."**",
          	
		   ["type"] = _G.Config.Webhook.Type,
			
		    ["color"] = _G.Config.Webhook.Color,
			
			["fields"] = {
				{
					["name"] = "Kills",
					["value"] = game.Players.LocalPlayer.CareerStatsCache.Kills.Value,
					["inlines"] = true
				},
				{
					["name"] = "Level",
					["value"] = game.Players.LocalPlayer.CareerStatsCache.Level.Value,
					["inlines"] = true,
				},
				{
					["name"] = "Deaths",
					["value"] = game.Players.LocalPlayer.Data.KD.WOs.Value,
					["inlines"] = true,
				},
				{
					["name"] = "Skin Equipped",
					["value"] = game.Players.LocalPlayer.Data.Skin.Value,
					["inlines"] = true,
				},
				{
					["name"] = "Melee Equipped",
					["value"] = game.Players.LocalPlayer.Data.Melee.Value,
					["inlines"] = true,
				},
				{
					["name"] = "Bucks",
					["value"] = "$" .. game.Players.LocalPlayer.PlayerGui.Menew.ShopButtons.Bucks.Bucks.Text,
					["inlines"] = true
				}
			},

            ["thumbnail"] = {
				["url"] = "http://www.roblox.com/Thumbs/Avatar.ashx?x=150&y=150&Format=Png&username=" .. tostring(Player.Name)
			},
			
			["footer"] = {
				["text"] = "Time: " .. tostring(date) .. " at " .. tostring(timestamp)
			},
      	}
	}
}
local newdata = game:GetService("HttpService"):JSONEncode(data)

local headers = {
   ["content-type"] = "application/json"
}

request = http_request or request or HttpPost or syn.request

local abcdef = {Url = url, Body = newdata, Method = "POST", Headers = headers}

request(abcdef)
