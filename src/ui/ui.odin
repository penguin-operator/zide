package ui

import "core:unicode/utf8"
import "core:strings"
import "core:strconv"
import "core:sys/linux"
import "core:sys/posix"
import zide "../core"

@(private = "file")
term: posix.termios

@(private = "file")
TIOCGWINSZ :: u32(0x5413)

root: ^win
focus: ^win = nil

init :: proc () {
	posix.tcgetattr(0, &term)
	t := term
	t.c_iflag -= {.BRKINT, .ICRNL, .INPCK, .ISTRIP, .IXON}
	t.c_oflag -= {.OPOST}
	t.c_cflag += {.CS8}
	t.c_lflag -= {.ECHO, .ICANON, .IEXTEN, .ISIG}
	t.c_cc[.VMIN] = 1
	t.c_cc[.VTIME] = 0
	linux.write(1, transmute([]u8)string("\e[?1049h\e[H"))
	posix.tcsetattr(0, .TCSANOW, &t)
	size: struct { h: u16, w: u16 }
	linux.ioctl(0, TIOCGWINSZ, uintptr(&size))
	posix.signal(posix.Signal(posix.SIGWINCH), proc "c" (posix.Signal) {
		size: struct { h: u16, w: u16 }
		linux.ioctl(0, TIOCGWINSZ, uintptr(&size))
	})
	root = new(win)
	root.h = size.h
	root.w = size.w
	root.y = 0
	root.x = 0
	focus = root
}

loop :: proc () {
	if focus == nil do exit()
	if focus.main != nil do focus.main(focus)
}

exit :: proc () {
	linux.write(1, transmute([]u8)string("\e[?1049l"))
	posix.tcsetattr(0, .TCSANOW, &term)
	free(root)
}

print :: proc (w: ^win, s: ..string, y: u16 = 0, x: u16 = 0) {
	buf: [16]u8
	linux.write(1, transmute([]u8)strings.concatenate({"\e[", strconv.write_uint(buf[:8], u64(w.y+y+1), 10), ";", strconv.write_uint(buf[8:], u64(w.x+x+1), 10), "H"}))
	for e in s do linux.write(1, transmute([]u8)e)
}

getch :: proc (w: ^win) -> rune {
	if w != focus do return 0
	c: [4]u8
	n, _ := linux.read(0, c[:])
	k, _ := utf8.decode_rune(c[:n])
	if n > 0 do return k
	return 0
}
