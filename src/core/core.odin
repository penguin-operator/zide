package core

import "core:sys/linux"

plugin :: struct {
	init, loop, exit: proc(),
}

plugins: map[string]plugin

init :: proc () {
	for name, plugin in plugins {
		if plugin.init != nil do plugin.init()
	}
}

loop :: proc () {
	for name, plugin in plugins {
		if plugin.loop != nil do plugin.loop()
	}
}

exit :: proc (status: i32 = 0) -> ! {
	for name, plugin in plugins {
		if plugin.exit != nil do plugin.exit()
	}
	linux.exit(status)
}
