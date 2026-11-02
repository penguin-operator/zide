package home

import ".."
import "../ui"

init :: proc() {
	ui.root.main = proc (w: ^ui.win) {
		k := ui.getch(w)
		switch k {
		case 0x11:
			core.exit()
		case 0x0f:
			if len(w.children) != 0 do return
			open := new(ui.input_field)
			ui.resize(open, w.h - 4, w.w - 4)
			open.y, open.x = (w.h - open.h)/2, (w.w - open.w)/2
			open.parent = w
			open.main = proc (w: ^ui.input_field) {
				k := ui.getch(w)
				if k != 0 {
					if p, ok := w.on[k]; ok do p(w)
					else do append(&w.inbuf, k)
				}
				ui.cursor = {w.y+1, w.x+u16(len(w.inbuf)+3), .BLOCK}
				ui.border(w)
				ui.print(w, ui.style{w=.BOLD}, "> ", x=1, y=1)
				ui.print(w, w.inbuf[:], x=3, y=1)
			}
			open.on[0x7f] = proc (w: ^ui.input_field) {
				if len(w.inbuf) > 0 do ordered_remove(&w.inbuf, len(w.inbuf)-1)
			}
			open.on['\r'] = proc (w: ^ui.input_field) {
				ui.print(w, "caught!", y=2, x=1)
			}
			open.on['\e'] = proc (w: ^ui.input_field) {
				ui.remove(w)
			}
			append(&w.children, open)
		}
		ui.print(w, ui.style{fg=ui.color_std{.GREEN, true}}, "▗▄▄▄▄▖▗▄▄▄▖▗▄▄▄  ▗▄▄▄▖", x=(w.w/2-11), y=(0+4))
		ui.print(w, ui.style{fg=ui.color_std{.GREEN, true}}, "   ▗▞▘  █  ▐▌  █ ▐▌   ", x=(w.w/2-11), y=(1+4))
		ui.print(w, ui.style{fg=ui.color_std{.GREEN, true}}, " ▗▞▘    █  ▐▌  █ ▐▛▀▀▘", x=(w.w/2-11), y=(2+4))
		ui.print(w, ui.style{fg=ui.color_std{.GREEN, true}}, "▐▙▄▄▄▖▗▄█▄▖▐▙▄▄▀ ▐▙▄▄▖", x=(w.w/2-11), y=(3+4))
		ui.print(
			w,
			ui.style{w=.BOLD, inverse=true}, "^Q", nil, " exit ",
			ui.style{w=.BOLD, inverse=true}, "^O", nil, " open ",
			y=w.h-1,
		)
		ui.cursor = {w.y, w.x, .NONE}
	}
}
