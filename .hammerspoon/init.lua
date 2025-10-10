PaperWM = hs.loadSpoon("PaperWM")

PaperWM:bindHotkeys({
	focus_left = { { "alt", "cmd" }, "h" },
	focus_right = { { "alt", "cmd" }, "l" },
	focus_up = { { "alt", "cmd" }, "k" },
	focus_down = { { "alt", "cmd" }, "j" },
  increase_width = {{"alt", "cmd"}, "o"}, --zoom in
  decrease_width = {{"alt", "cmd"}, "i"}, --zoom out
})
PaperWM.window_gap = 10
PaperWM.swipe_fingers = 3
PaperWM.swipe_gain = 1.0

PaperWM:start()

hs.hotkey.bind({"alt", "cmd"}, "t", "Ghostty", function()
	hs.application.launchOrFocus("Ghostty")
end)

hs.hotkey.bind({"alt", "cmd"}, "f", "Firefox", function()
  hs.application.launchOrFocus("Firefox")
end)

hs.hotkey.bind({"alt", "cmd"}, "z", "Zed", function()
  hs.application.launchOrFocus("Zed")
end)

hs.hotkey.bind({}, "F13", "Apps", function()
  hs.application.launchOrFocus("Apps")
end)

hs.hotkey.bind({"alt"}, "r", "Reload", function()
	hs.reload()
end)

hs.alert.show("Config loaded")
