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
local meetingNotifier = nil
local meetingInProgressWatcher = nil
local meetingInProgress = false

local function meetingInProgressCallback()
	local meetingInProgressNow = false
	local zoom = hs.application.find("zoom.us")
	if zoom then
		logger.i("Zoom found")
		local zoomWindows = zoom:allWindows()
		for i, window in ipairs(zoomWindows) do
			if window:title() == "Zoom Meeting" then
				meetingInProgressNow = true
				break
			end
		end
	end
	if meetingInProgressNow ~= meetingInProgress then
		meetingInProgress = meetingInProgressNow
		if meetingInProgress then
			logger.i("Meeting in progress")
			meetingNotifier["meeting_in_progress"] = meetingInProgress
		else
			logger.i("Meeting ended")
			meetingNotifier["meeting_in_progress"] = meetingInProgress
		end
	end
end

function M:start()
	logger.i("Starting")
	meetingNotifier = hs.watchable.new(watchablePath)
	meetingInProgressWatcher = hs.timer.doEvery(5, meetingInProgressCallback)
end

function M:stop()
	logger.i("Stopping")
	meetingInProgressWatcher:stop()
end

return M
