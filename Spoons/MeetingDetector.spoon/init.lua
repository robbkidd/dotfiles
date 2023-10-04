--- === MeetingDetector ===
---
--- Detects when a Zoom meeting is in progress and notifies other watchers.
--- Watchers can choose to do something when a meeting starts or ends.
---
--- Example:
--- ```
--- hs.loadSpoon("MeetingDetector")
--- spoon.MeetingDetector:start()
---
--- meetingWatcher = hs.watchable.watch("MeetingDetector", "meeting_in_progress",
--- 	function(_watcher, _path, _key, meetingWasInProgress, meetingInProgressNow)
--- 		if meetingInProgressNow ~= meetingWasInProgress then -- there's been a change
--- 			if meetingInProgressNow then
--- 				hs.alert.show("Meeting in progress")
--- 			else
--- 				hs.alert.show("Meeting ended")
--- 			end
--- 		end
--- 	end
--- )
--- ```
local M = {}
M.__index = M

-- Metadata
M.name = "MeetingDetector"
M.version = "1.0"
M.author = "Robb Kidd <robb@thekidds.org>"
M.license = "MIT - https://opensource.org/licenses/MIT"

local logger = hs.logger.new('MeetingDetector')
local watchablePath = M.name

local zoomAppWatcher = nil
local meetingNotifier = nil
local meetingPoller = nil
local meetingInProgress = false

local function meetingInProgressCheck(zoomApp)
	local meetingInProgressNow = false -- assume we're not in a meeting

	local zoom = zoomApp or hs.application.find("zoom.us")
	if zoom then
		logger.d("Zoom found")
		local zoomMenus = zoom:getMenuItems()
		-- if the second Zoom menu item is "Meeting", you're in a meeting
		if zoomMenus and zoomMenus[2]["AXTitle"] == "Meeting" then
			meetingInProgressNow = true
		end
	else
		logger.d("Zoom not found, why am I even checking?")
	end

	if meetingInProgressNow ~= meetingInProgress then -- there's been a state change
		meetingInProgress = meetingInProgressNow
		if meetingInProgress then
			logger.i("📢: meeting in progress")
			meetingNotifier["meeting_in_progress"] = meetingInProgress
		else
			logger.i("📢: meeting ended")
			meetingNotifier["meeting_in_progress"] = meetingInProgress
		end
	end
end

local appEventTypes = {
	[hs.application.watcher.activated] = "got focus",
	[hs.application.watcher.deactivated] = "lost focus",
	[hs.application.watcher.hidden] = "hidden",
	[hs.application.watcher.launched] = "launched",
	[hs.application.watcher.launching] = "launching",
	[hs.application.watcher.terminated] = "terminated",
	[hs.application.watcher.unhidden] = "unhidden",
}

local function zoomAppEventHandler(appName, eventType, appObject)
	if (appName == "zoom.us") then
		logger.d("Zoom app " .. appEventTypes[eventType])
		if eventType == hs.application.watcher.terminated then
			-- if Zoom has been closed, stop polling for meeting state
			meetingPoller:stop()
		else
			-- it's an app event that means Zoom is running, so poll for meeting state
			if not meetingPoller:running() then meetingPoller:start() end
		end

		meetingInProgressCheck(appObject)
	end
end

function M:init()
	meetingNotifier = hs.watchable.new(watchablePath)
	meetingPoller = hs.timer.new(30, meetingInProgressCheck) -- to be started by zoomAppWatcher
	zoomAppWatcher = hs.application.watcher.new(zoomAppEventHandler)
end

function M:start(checkInterval)
	logger.i("Starting")
	zoomAppWatcher:start()
end

function M:stop()
	logger.i("Stopping")
	zoomAppWatcher:stop()
	meetingPoller:stop()
end

return M
