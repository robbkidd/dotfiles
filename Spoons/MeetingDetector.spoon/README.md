# MeetingDetector

Announce to interested parties that you're in a meeting.

Supported VTC software:

* Zoom
* ... that's it

## Usage

```lua
-- ~/.hammerspoon/init.lua
hs.loadSpoon("MeetingDetector")
spoon.MeetingDetector:start()

meetingWatcher = hs.watchable.watch("MeetingDetector", "meeting_in_progress",
	function(_watcher, _path, _key, meetingWasInProgress, meetingInProgressNow)
		if meetingInProgressNow ~= meetingWasInProgress then -- there's been a change
			if meetingInProgressNow then
				hs.alert.show("Meeting in progress")
                -- turn on a light!
                -- update Slack status!
                -- notify coffee maker to brew another cup!
			else
				hs.alert.show("Meeting ended")
                -- turn off a light!
                -- update Slack status!
                -- start a break timer!
			end
		end
	end
)
```
