package ui

import "core:strings"
import "core:strconv"
import "core:unicode/utf8"
import "core:sys/posix"
import "core:sys/linux"
import "base:runtime"

@(private = "file")
term: posix.termios

@(private = "file")
TIOCGWINSZ :: u32(0x5413)

@(private = "file")
size: struct { h: u16, w: u16 }

root: ^win

cell :: struct {
	c: rune,
	s: union{style},
}

@(private = "package")
oldbuf, newbuf: [][]cell

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
	linux.ioctl(0, TIOCGWINSZ, uintptr(&size))
	root = new(win)
	root.y, root.x = 0, 0
	resize(root, size.h, size.w)
	oldbuf = make([][]cell, size.h)
	for i in 0..<size.h do oldbuf[i] = make([]cell, size.w)
	newbuf = make([][]cell, size.h)
	for i in 0..<size.h do newbuf[i] = make([]cell, size.w)
	posix.signal(posix.Signal(posix.SIGWINCH), proc "c" (posix.Signal) {
		linux.ioctl(0, TIOCGWINSZ, uintptr(&size))
		context = runtime.default_context()
		for i in 0..<size.h do delete(oldbuf[i])
		delete(oldbuf)
		for i in 0..<size.h do delete(newbuf[i])
		delete(newbuf)
		oldbuf = make([][]cell, size.h)
		for i in 0..<size.h do oldbuf[i] = make([]cell, size.w)
		newbuf = make([][]cell, size.h)
		for i in 0..<size.h do newbuf[i] = make([]cell, size.w)
		resize(root, size.h, size.w)
	})
}

loop :: proc () {
	run :: proc (w: ^win) {
		if w.main != nil do w->main()
		for c in w.children do run(c)
	}
	run(root)
	refresh(root)
	for y in 0..<size.h {
		for x in 0..<size.w {
			if newbuf[y][x] != oldbuf[y][x] {
				cursor(y, x)
				switch s in newbuf[y][x].s {
				case nil:
					linux.write(1, transmute([]u8)string("\e[0m"))
				case style:
					switch s.w {
					case .NONE: linux.write(1, transmute([]u8)string("\e[0m"))
					case .BOLD: linux.write(1, transmute([]u8)string("\e[1m"))
					case .DIM:  linux.write(1, transmute([]u8)string("\e[2m"))
					}
					if s.italic do linux.write(1, transmute([]u8)string("\e[3m"))
					if s.underline do linux.write(1, transmute([]u8)string("\e[4m"))
					if s.strikethrough do linux.write(1, transmute([]u8)string("\e[9m"))
					if s.blink do linux.write(1, transmute([]u8)string("\e[5m"))
					if s.inverse do linux.write(1, transmute([]u8)string("\e[7m"))
					if s.hidden do linux.write(1, transmute([]u8)string("\e[8m"))
					if s.bg != nil do color_apply(s.bg.(color), .BG)
					if s.fg != nil do color_apply(s.fg.(color), .FG)
				}
				if newbuf[y][x].c == 0 do linux.write(1, []u8{' '})
				else {
					c, n := utf8.encode_rune(newbuf[y][x].c)
					linux.write(1, c[:n])
				}
				linux.write(1, transmute([]u8)string("\e[0m"))
			}
			oldbuf[y][x] = newbuf[y][x]
		}
	}
}

exit :: proc () {
	linux.write(1, transmute([]u8)string("\e[?25h\e[?1049l"))
	posix.tcsetattr(0, .TCSANOW, &term)
	free(root)
}

cursor :: proc(y, x: u16, s: enum { NONE = 0, BLOCK = 1, UNDERLINE = 2, BEAM = 3 } = .NONE) {
	by, bx: [8]u8
	linux.write(1, transmute([]u8)strings.concatenate({"\e[", strconv.write_uint(by[:], u64(y+1), 10), ";", strconv.write_uint(bx[:], u64(x+1), 10), "H"}))
	switch s {
	case .NONE:      linux.write(1, transmute([]u8)string("\e[?25l"))
	case .BLOCK:     linux.write(1, transmute([]u8)string("\e[?25h\e[1 q"))
	case .UNDERLINE: linux.write(1, transmute([]u8)string("\e[?25h\e[3 q"))
	case .BEAM:      linux.write(1, transmute([]u8)string("\e[?25h\e[5 q"))
	}
}

color_apply :: proc (c: color, g: enum { FG = 0, BG = 1 } = .FG) {
	switch c in c {
	case color_std:
		bs: [dynamic]string
		switch g {
		case .FG: append(&bs, "\e[9" if c.b else "\e[3")
		case .BG: append(&bs, "\e[10" if c.b else "\e[4")
		}
		append(&bs, string([]u8{'0'+u8(c.c)}), "m")
		linux.write(1, transmute([]u8)strings.concatenate(bs[:]))
	case color_rgb:
		bs: [dynamic]string
		switch g {
		case .FG: append(&bs, "\e[38;2;")
		case .BG: append(&bs, "\e[48;2;")
		}
		r, g, b: [3]u8
		append(&bs, strconv.write_uint(r[:], u64(c.r), 10), ";")
		append(&bs, strconv.write_uint(g[:], u64(c.g), 10), ";")
		append(&bs, strconv.write_uint(b[:], u64(c.b), 10), ";")
		append(&bs, "m")
		linux.write(1, transmute([]u8)strings.concatenate(bs[:]))
	}
}
