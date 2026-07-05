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
	posix.signal(posix.Signal(posix.SIGWINCH), proc "c" (posix.Signal) {
		size: struct { h: u16, w: u16 }
		linux.ioctl(0, TIOCGWINSZ, uintptr(&size))
	})
	root = new(win)
	root.y, root.x = 0, 0
	root.h, root.w = size.h, size.w
	border(root)
	print("^Q exit", y=root.y+root.h-2, x=root.x+1)
	print(y=root.y+1, x=root.x+1)
}

loop :: proc () {
	if k := getch(); k != 0 {
		print("\e[H\e[J")
		border(root)
		print("^Q exit", y=root.y+root.h-2, x=root.x+1)
		print(y=root.y+1, x=root.x+1)
		if k == 0x11 {
			zide.exit()
		}
	}
}

exit :: proc () {
	linux.write(1, transmute([]u8)string("\e[?1049l"))
	posix.tcsetattr(0, .TCSANOW, &term)
	free(root)
}

print :: proc (s: ..string, y: u16 = 0, x: u16 = 0) {
	buf: [16]u8
	linux.write(1, transmute([]u8)strings.concatenate({"\e[", strconv.write_uint(buf[:8], u64(y+1), 10), ";", strconv.write_uint(buf[8:], u64(x+1), 10), "H"}))
	for e in s do linux.write(1, transmute([]u8)e)
}

getch :: proc () -> rune {
	c: [4]u8
	n, _ := linux.read(0, c[:])
	k, _ := utf8.decode_rune(c[:n])
	if n > 0 do return k
	return 0
}
