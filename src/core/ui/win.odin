package ui

import "zide:core/util"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"
import "core:sys/linux"

win :: struct {
	y, x, h, w: u16,
	buf: [dynamic]union{rune,string,style,cursor},
	main: proc(^win),
	children: [dynamic]^win,
	parent: ^win,
}

refresh :: proc (w: ^win) {
	linux.write(1, transmute([]u8)string("\e[?25l"))
	for e, i in w.buf {
		if w.done[i] do continue
		w.done[i] = true
		switch e in e {
		case nil:
			linux.write(1, transmute([]u8)string("\e[0m"))
		case rune:
			s, _ := utf8.encode_rune(e)
			linux.write(1, s[:])
		case string:
			linux.write(1, transmute([]u8)e)
		case style:
			switch e.w {
			case .NONE: linux.write(1, transmute([]u8)string("\e[22m"))
			case .BOLD: linux.write(1, transmute([]u8)string("\e[1m"))
			case .DIM:  linux.write(1, transmute([]u8)string("\e[2m"))
			}
			linux.write(1, transmute([]u8)string("\e[3m" if e.italic else "\e[23m"))
			linux.write(1, transmute([]u8)string("\e[4m" if e.underline else "\e[24m"))
			linux.write(1, transmute([]u8)string("\e[9m" if e.strikethrough else "\e[29m"))
			linux.write(1, transmute([]u8)string("\e[5m" if e.blink else "\e[25m"))
			linux.write(1, transmute([]u8)string("\e[7m" if e.inverse else "\e[27m"))
			linux.write(1, transmute([]u8)string("\e[8m" if e.hidden else "\e[28m"))
			bn, br, bg, bb: [3]u8
			if e.bg != nil {
				switch c in e.bg.(color) {
				case color_std: linux.write(1, transmute([]u8)strings.concatenate({"\e[", "10" if c.b else "4", strconv.write_uint(bn[:], u64(c.c), 10), "m"}))
				case color_rgb: linux.write(1, transmute([]u8)strings.concatenate({"\e[48;2;", strconv.write_uint(br[:], u64(c.r), 10), ";", strconv.write_uint(bg[:], u64(c.g), 10), ";", strconv.write_uint(bb[:], u64(c.b), 10), "m "}))
				}
			}
			if e.fg != nil {
				switch c in e.fg.(color) {
				case color_std: linux.write(1, transmute([]u8)strings.concatenate({"\e[", "9" if c.b else "3", strconv.write_uint(bn[:], u64(c.c), 10), "m"}))
				case color_rgb: linux.write(1, transmute([]u8)strings.concatenate({"\e[38;2;", strconv.write_uint(br[:], u64(c.r), 10), ";", strconv.write_uint(bg[:], u64(c.g), 10), ";", strconv.write_uint(bb[:], u64(c.b), 10), "m"}))
				}
			}
		case cursor:
			by, bx: [8]u8
			linux.write(1, transmute([]u8)strings.concatenate({"\e[", strconv.write_uint(by[:], u64(e.y+1), 10), ";", strconv.write_uint(bx[:], u64(e.x+1), 10), "H"}))
			switch e.s {
			case .NONE:      linux.write(1, transmute([]u8)string("\e[?25l"))
			case .BLOCK:     linux.write(1, transmute([]u8)string("\e[?25h\e[1 q"))
			case .UNDERLINE: linux.write(1, transmute([]u8)string("\e[?25h\e[3 q"))
			case .BEAM:      linux.write(1, transmute([]u8)string("\e[?25h\e[5 q"))
			}
		}
	}
	for c in w.children do refresh(c)
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
	}
	free(win)
}

print :: proc (w: ^win, t: ..union{rune,string,style,cursor}) {
	i := 0
	for d in util.differentiate(w.buf[:], t) {
		switch d.action {
		case .KEEP: i += 1
		case .INSERT: append(&w.buf, d.value) i += 1
		case .DELETE: ordered_remove(&w.buf, i) i -= 1
		}
	}
}

getch :: proc (w: ^win) -> rune {
	c: [4]u8
	n, _ := linux.read(0, c[:])
	k, _ := utf8.decode_rune(c[:n])
	return 0 if n == 0 else k
}
