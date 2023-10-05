# OnAir

Turn a light on and off ... so long as it is plugged in to a Kasa outlet by TP-Link.

As the name implies, intended to be used to notify others that you're ON AIR.
Could be you're in a meeting.
Maybe you're recording a podcast.
I dunno.
You do you ... but with a light!

* Requires a build of kasa-plug to be present in `$HOME/bin/`

## Usage

Example pairing OnAir with MeetingDetector:

```lua
-- ~/.hammerspoon/init.lua
hs.loadSpoon("MeetingDetector")
spoon.MeetingDetector:start()

hs.loadSpoon("OnAir")
spoon.OnAir:start("10.10.10.10")

meetingWatcher = hs.watchable.watch("MeetingDetector", "meeting_in_progress",
	function(_watcher, _path, _key, meetingWasInProgress, meetingInProgressNow)
		if meetingInProgressNow ~= meetingWasInProgress then -- there's been a change
			if meetingInProgressNow then
				spoon.OnAir.on()
			else
				spoon.OnAir.off()
			end
		end
	end
)
```
