package ui

win :: struct {
	y, x, h, w: u16,
	main: proc(^win),
	children: [dynamic]^win,
	parent: ^win,
}

border :: proc (w: ^win) {
	print(w, "┌")
	print(w, "┐", x=w.w-1)
	print(w, "└", y=w.h-1)
	print(w, "┘", y=w.h-1, x=w.w-1)
	for i: u16 = 1; i < w.h - 1; i += 1 {
		print(w, "│", y=i)
		print(w, "│", y=i, x=w.w-1)
	}
	for i: u16 = 1; i < w.w - 1; i += 1 {
		print(w, "─", x=i)
		print(w, "─", y=w.h-1, x=i)
	}
}

remove :: proc (win: ^win) {
	for child in win.children do remove(child)
	if win.parent != nil {
		for i := 0; i < len(win.parent.children); i += 1 {
			if win.parent.children[i] == win {
				ordered_remove(&win.parent.children, i)
				break
			}
		}
		focus = win.parent
	} else do focus = nil
	free(win)
}
