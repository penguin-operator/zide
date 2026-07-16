package home

import ".."
import "../ui"

init :: proc() {
	ui.root.main = proc (w: ^ui.win) {
		ui.print(ui.root, ui.style{fg=ui.color_std{.GREEN, true}}, "▗▄▄▄▄▖▗▄▄▄▖▗▄▄▄  ▗▄▄▄▖", x=(w.w/2-11), y=(0+4))
		ui.print(ui.root, ui.style{fg=ui.color_std{.GREEN, true}}, "   ▗▞▘  █  ▐▌  █ ▐▌   ", x=(w.w/2-11), y=(1+4))
		ui.print(ui.root, ui.style{fg=ui.color_std{.GREEN, true}}, " ▗▞▘    █  ▐▌  █ ▐▛▀▀▘", x=(w.w/2-11), y=(2+4))
		ui.print(ui.root, ui.style{fg=ui.color_std{.GREEN, true}}, "▐▙▄▄▄▖▗▄█▄▖▐▙▄▄▀ ▐▙▄▄▖", x=(w.w/2-11), y=(3+4))
		ui.print(
			w,
			ui.style{w=.BOLD, inverse=true}, "^Q", nil, " exit ",
			ui.style{w=.BOLD, inverse=true}, "^O", nil, " open ",
			y=w.h-1,
		)
		k := ui.getch(w)
		ui.cursor(w.y, w.x, .NONE)
		switch k {
		case 0x11:
			core.exit()
		case 0x0f:
			if len(w.children) != 0 do return
			find := new(ui.win)
			ui.resize(find, w.h - 4, w.w - 4)
			find.y, find.x = (w.h - find.h)/2, (w.w -find.w)/2
			find.parent = w
			find.main = proc (w: ^ui.win) {
				ui.border(w)
				ui.print(w, ui.style{w=.BOLD}, "> ", x=1, y=1)
				ui.cursor(w.y+1, w.x+3, .BLOCK)
				k := ui.getch(w)
				switch k {
				case 'q':
					ui.remove(w)
				}
			}
			append(&w.children, find)
		}
	}
}
