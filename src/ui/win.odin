package ui

win :: struct {
	y, x, h, w: u16,
	main: proc(^win),
	children: []^win,
}

border :: proc (win: ^win) {
	print("┌", y=win.y, x=win.x)
	print("┐", y=win.y, x=win.x + win.w-1)
	print("└", y=win.y + win.h-1, x=win.x)
	print("┘", y=win.y + win.h-1, x=win.x + win.w-1)
	for i := win.y + 1; i < win.y + win.h - 1; i += 1 {
		print("│", y=i, x=win.x)
		print("│", y=i, x=win.x + win.w - 1)
	}
	for i := win.x + 1; i < win.x + win.w - 1; i += 1 {
		print("─", y=win.y, x=i)
		print("─", y=win.y + win.h - 1, x=i)
	}
}
