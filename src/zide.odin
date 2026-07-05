package zide

import "core"
import "ui"

main :: proc () {
	core.plugins["ui"] = { ui.init, ui.loop, ui.exit }
	core.init()
	ui.root.main = proc (w: ^ui.win) {
		ui.print(w, "\e[?25l")
		ui.border(w)
		ui.print(w,
			"\e[1;32m▗▄▄▄▄▖▗▄▄▄▖▗▄▄▄  ▗▄▄▄▖\e[0m\e[22D\e[1B",
			"\e[1;32m   ▗▞▘  █  ▐▌  █ ▐▌   \e[0m\e[22D\e[1B",
			"\e[1;32m ▗▞▘    █  ▐▌  █ ▐▛▀▀▘\e[0m\e[22D\e[1B",
			"\e[1;32m▐▙▄▄▄▖▗▄█▄▖▐▙▄▄▀ ▐▙▄▄▖\e[0m\e[22D\e[1B",
			y=(w.h-4)/2-2, x=(w.w-22)/2);
		ui.print(w, "\e[1;7m^Q\e[0m exit", y=w.h-2, x=1)
		ui.print(w, "\e[?25h", y=1, x=1)
		k := ui.getch(w)
		switch k {
		case 0x11:
			core.exit()
		case 0x0f:
			
		}
	}
	for do core.loop()
}
