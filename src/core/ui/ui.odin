package ui

import "core:sys/posix"
import "core:sys/linux"
import "base:runtime"

@(private = "file")
term: posix.termios

@(private = "file")
TIOCGWINSZ :: u32(0x5413)

root: ^win

init :: proc () {
	posix.tcgetattr(0, &term)
	t := term
	t.c_iflag -= {.BRKINT, .ICRNL, .INPCK, .ISTRIP, .IXON}
	t.c_oflag -= {.OPOST}
	t.c_cflag += {.CS8}
	t.c_lflag -= {.ECHO, .ICANON, .IEXTEN, .ISIG}
	t.c_cc[.VMIN] = 0
	t.c_cc[.VTIME] = 0
	linux.write(1, transmute([]u8)string("\e[?1049h\e[H"))
	posix.tcsetattr(0, .TCSANOW, &t)
	size: struct { h: u16, w: u16 }
	linux.ioctl(0, TIOCGWINSZ, uintptr(&size))
	root = new(win)
	root.h = size.h
	root.w = size.w
	root.y = 0
	root.x = 0
	posix.signal(posix.Signal(posix.SIGWINCH), proc "c" (posix.Signal) {
		size: struct { h: u16, w: u16 }
		linux.ioctl(0, TIOCGWINSZ, uintptr(&size))
		root.h = size.h
		root.w = size.w
	})
}

loop :: proc () {
	// linux.write(1, transmute([]u8)string("\e[H\e[J"))
	run :: proc (w: ^win) {
		if w.main != nil do w.main(w)
		for child in w.children do run(child)
	}
	run(root)
	refresh(root)
}

exit :: proc () {
	linux.write(1, transmute([]u8)string("\e[?25h\e[?1049l"))
	posix.tcsetattr(0, .TCSANOW, &term)
	free(root)
}
