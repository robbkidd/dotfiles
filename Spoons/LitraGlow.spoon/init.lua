--- === Litra Glow ===
---
--- Control the Litra Glow light from the menubar.

local M = {}
M.__index = M

-- Metadata
M.name = "LitraGlow"
M.version = "1.0"
M.author = "Robb Kidd <robb@thekidds.org>"
M.license = "MIT - https://opensource.org/licenses/MIT"

local logger = hs.logger.new("litraglow")
local enabled = nil
local litramenu = nil
local usbWatcher = nil
-- cribbed from https://ultracrepidarian.phfactor.net/tag/mac/
local vidpid = "046D/C900" -- vidpid in hex
local vendor_product_id = "1133:51456" -- vidpid in decimal
local hidCommand = "~/bin/hidapitester"
local hidCommandRepo = "https://github.com/todbot/hidapitester"

local function checkCommandIsAvailable()
	executable = hs.fs.attributes(hidCommand, "mode")
	if executable == "file" then
		return true
	else
		logger.w(
			hidCommand .. " does not appear to be available; unable to manage light." ..
			" See " .. hidCommandRepo .. " for more information."
		)
		return false
	end
end

local litraCodes = {
	["on"] = "0x11,0xff,0x04,0x1c,0x01",
	["off"] = "0x11,0xff,0x04,0x1c",
	-- brightness
	["glow"] = "0x11,0xff,0x04,0x4c,0x00,20",
	["dim"] = "0x11,0xff,0x04,0x4c,0x00,50",
	["normal"] = "0x11,0xff,0x04,0x4c,0x00,70",
	["medium"] = "0x11,0xff,0x04,0x4c,0x00,100",
	["bright"] = "0x11,0xff,0x04,0x4c,0x00,204",
	-- warmth
	["warmest"] = "0x11,0xff,0x04,0x9c,10,140",
	["warm"] = "0x11,0xff,0x04,0x9c,12,128",
	["coldest"] = "0x11,0xff,0x04,0x9c,25,100"
}

local function litraDo(data)
	code = litraCodes[data] or data
	output, success, _, _ = hs.execute(
		hidCommand ..
		" --vidpid " .. vidpid ..
		" --open" ..
		" --length 20" ..
		" --send-output " .. code ..
		" --close"
	)

	if not success then
		logger.e(output)
	end

	return output
end

local function turnOn()
	litraDo("on")
end

local function turnOff()
	litraDo("off")
end

local function menuItems()
	return {
		{ title = "on",      fn = turnOn },
		{ title = "off",     fn = turnOff },
		{ title = "---" },
		{ title = "glow",    fn = function() litraDo("glow")    end, tooltip = "~10%" },
		{ title = "dim",     fn = function() litraDo("dim")     end, tooltip = "~20%" },
		{ title = "normal",  fn = function() litraDo("normal")  end, tooltip = "~40%" },
		{ title = "medium",  fn = function() litraDo("medium")  end, tooltip = "~50%" },
		{ title = "bright",  fn = function() litraDo("bright")  end, tooltip = "~90%" },
		{ title = "---" },
		{ title = "warmest", fn = function() litraDo("warmest") end, tooltip = "2700K" },
		{ title = "warm",    fn = function() litraDo("warm")    end, tooltip = "3200K" },
		{ title = "coldest", fn = function() litraDo("coldest") end, tooltip = "6500K" }
	}
end

local function isLitraDevice(vendorID, productID)
	return vendorID .. ':' .. productID == vendor_product_id
end

local function isPluggedIn()
	for _, dev in ipairs(hs.usb.attachedDevices()) do
		if isLitraDevice(dev["vendorID"], dev["productID"]) then
			return true
		end
	end

	return false
end

local function usbDeviceCallback(data)
	if isLitraDevice(data["vendorID"], data["productID"]) then
		if data["eventType"] == "added" then
			logger.i("Litra Glow just plugged in. Turning off the light.")
			litramenu:returnToMenuBar()
			turnOff()
		elseif data["eventType"] == "removed" then
			logger.i("Litra Glow unplugged. Removing menubar icon.")
			litramenu:removeFromMenuBar()
		end
	end
end

function M:init()
	if not checkCommandIsAvailable() then
		enabled = false
		return
	end

	enabled = true
	usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
	litramenu = hs.menubar.new()
	litramenu:setTooltip("Litra Glow")
	litramenu:setTitle("💡")
	litramenu:setMenu(menuItems())
end

function M:start()
	if not enabled then
		return
	end

	usbWatcher:start()
	if isPluggedIn() then
		litramenu:returnToMenuBar()
	else
		litramenu:removeFromMenuBar()
	end
end

function M:stop()
	usbWatcher:stop()
	litramenu:removeFromMenuBar()
end

function M.on()
	turnOn()
end

function M.off()
	turnOff()
end

return M
