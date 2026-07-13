package home

import ".."
import "../ui"

init :: proc() {
	ui.root.main = proc (w: ^ui.win) {
		// ui.print(w, "hello")
		ui.print(w, ui.cursor {x=(0), y=(0)}, ui.style{fg=ui.color_std{.GREEN, true}}, "▗▄▄▄▄▖▗▄▄▄▖▗▄▄▄  ▗▄▄▄▖")
		ui.print(w, ui.cursor {x=(0), y=(1)}, ui.style{fg=ui.color_std{.GREEN, true}}, "   ▗▞▘  █  ▐▌  █ ▐▌   ")
		ui.print(w, ui.cursor {x=(0), y=(2)}, ui.style{fg=ui.color_std{.GREEN, true}}, " ▗▞▘    █  ▐▌  █ ▐▛▀▀▘")
		ui.print(w, ui.cursor {x=(0), y=(3)}, ui.style{fg=ui.color_std{.GREEN, true}}, "▐▙▄▄▄▖▗▄█▄▖▐▙▄▄▀ ▐▙▄▄▖")
		// ui.print(
		// 	w,
		// 	ui.cursor {y=w.h-1},
		// 	ui.style{w=.BOLD, inverse=true}, "^Q", nil, " exit ",
		// 	ui.style{w=.BOLD, inverse=true}, "^O", nil, " open ",
		// )
		// k := ui.getch(w)
		// switch k {
		// case 0x11:
		// 	core.exit()
		// case 0x0f:
			
		// }
	}
}
