--- ==== OnAir ====
---
--- Turn a Kasa plug on and off (presumably powering a light) to indicate when you are on a call.
---
--- Possible example of using it with the MeetingDetector spoon:
--- ```
--- hs.loadSpoon("MeetingDetector")
--- spoon.MeetingDetector:start()
---
--- hs.loadSpoon("OnAir")
--- spoon.OnAir:start("10.10.10.10")
---
--- meetingWatcher = hs.watchable.watch("MeetingDetector", "meeting_in_progress",
--- 	function(_watcher, _path, _key, meetingWasInProgress, meetingInProgressNow)
--- 		if meetingInProgressNow ~= meetingWasInProgress then -- there's been a change
--- 			if meetingInProgressNow then
--- 				spoon.OnAir.on()
--- 			else
--- 				spoon.OnAir.off()
--- 			end
--- 		end
--- 	end
--- )
--- ```

local M = {}
M.__index = M

-- Metadata
M.name = "OnAir"
M.version = "1.0"
M.author = "Robb Kidd <robb@thekidds.org>"
M.license = "MIT - https://opensource.org/licenses/MIT"

local logger = hs.logger.new("OnAir")
local lightmenu = nil
local plug_command = nil

local function lightboxReachable()
	local output, status, type, rc = hs.execute(plug_command .. ' status', true)
	return rc == 0
end

local function lightboxSet(lit)
	if not lightboxReachable() then
		logger.d("NO-OP: The ON AIR light isn't available.")
		return nil
	end

	if lit then
		cmd = plug_command .. " on"
		logger.d(cmd)
		local output, status, type, rc = hs.execute(cmd, true)
		logger.d(output)
		lightmenu:setTitle("ON AIR")
		lightmenu:setTooltip("The light is lit.")
		logger.i("turn on the light")
	else
		cmd = plug_command .. " off"
		logger.d(cmd)
		local output, status, type, rc = hs.execute(cmd, true)
		logger.d(output)
		lightmenu:setTitle("OFF AIR")
		lightmenu:setTooltip("The light is off.")
		logger.i("turn off the light")
	end
end

local function lightboxGet()
	local output, status, type, rc = hs.execute(plug_command .. ' status | grep On', true)
	return rc == 0
end

local function lightboxToggle()
	local current = lightboxGet()
	if (current == nil) then
			return nil
	end
	lightboxSet(not current)
	return lightboxGet()
end

function M:init()
	lightmenu = hs.menubar.new()
	lightmenu:setTooltip("On Air")
	lightmenu:setTitle("❓")
	lightmenu:setClickCallback(lightboxToggle)
end

--- OnAir:start(plug_ip)
--- Method
--- Start the OnAir spoon to turn a Kasa plug on and off.
---
--- Parameters:
---  * plug_ip - [string] IP address for the Kasa plug to toggle on/off
---
--- Returns:
---  * None
function M:start(plug_ip)
	plug_ip = plug_ip or "nope"
	plug_command = "~/bin/kasa-plug --plug " .. plug_ip

	if lightboxReachable() then
		lightmenu:returnToMenuBar()
		lightboxSet(lightboxGet())
	else
		lightmenu:removeFromMenuBar()
	end
end

function M:stop()
	lightmenu:removeFromMenuBar()
end

function M.on()
	lightboxSet(true)
end

function M.off()
	lightboxSet(false)
end

function M.toggle()
	lightboxToggle()
end

return M
