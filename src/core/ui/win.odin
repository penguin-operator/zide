package ui

import "core:unicode/utf8"
import "core:sys/linux"

win :: struct {
	y, x, h, w: u16,
	buf: [][]cell,
	main: proc (w: ^win),
	children: [dynamic]^win,
	parent: ^win,
}

@(private = "file")
inbuf: rune

getch :: proc (w: ^win) -> rune {
	c: [4]u8
	if inbuf != 0 {
		k := inbuf
		return k
	}
	n, _ := linux.read(0, c[:])
	k, _ := utf8.decode_rune(c[:n])
	inbuf = 0 if n == 0 else k
	return 0 if n == 0 else k
}

refresh :: proc (w: ^win) {
	wy, wx := w.y, w.x
	for p := w.parent; p != nil; p = p.parent {
		wy += p.y
		wx += p.x
	}
	for y in 0..<w.h {
		for x in 0..<w.w {
			newbuf[wy+y][wx+x] = w.buf[y][x]
			w.buf[y][x].c = 0
			w.buf[y][x].s = nil
		}
	}
	for c in w.children do refresh(c)
	inbuf = 0
}

remove :: proc (win: ^win) {
	for child in win.children do remove(child)
	if win.parent != nil {
		for i in 0..< len(win.parent.children) {
			if win.parent.children[i] == win {
				ordered_remove(&win.parent.children, i)
				break
			}
		}
	}
	free(win)
}

resize :: proc (win: ^win, h: u16, w: u16) {
	for i in 0..<win.h do delete(win.buf[i])
	delete(win.buf)
	win.h = h
	win.w = w
	win.buf = make([][]cell, h)
	for i in 0..<h do win.buf[i] = make([]cell, w)
}

print :: proc (w: ^win, t: ..union{rune,string,style}, y: u16 = 0, x: u16 = 0) {
	cy, cx: u16 = y, x
	s: union{style}
	for e in t {
		switch e in e {
		case nil:
			s = nil
		case rune:
			w.buf[cy][cx].s = s
			w.buf[cy][cx].c = e
			cx += 1
			if cx >= w.w {
				cx = 0
				cy += 1
			}
			if cy >= w.h do cy = 0
		case string:
			for r in utf8.string_to_runes(e) {
				w.buf[cy][cx].s = s
				w.buf[cy][cx].c = r
				cx += 1
				if cx >= w.w {
					cx = 0
					cy += 1
				}
				if cy >= w.h do cy = 0
			}
		case style:
			s = e
		}
	}
}

border :: proc (w: ^win, r: bool = false, s: style = style{}) {
	if r {
		w.buf[0][0] = cell{'╭', s}
		w.buf[0][w.w-1] = cell{'╮', s}
		w.buf[w.h-1][0] = cell{'╰', s}
		w.buf[w.h-1][w.w-1] = cell{'╯', s}
	} else {
		w.buf[0][0] = cell{'┌', s}
		w.buf[0][w.w-1] = cell{'┐', s}
		w.buf[w.h-1][0] = cell{'└', s}
		w.buf[w.h-1][w.w-1] = cell{'┘', s}
	}
	for x in 1..<w.w-1 {
		w.buf[0][x] = cell{'─', s}
		w.buf[w.h-1][x] = cell{'─', s}
	}
	for y in 1..<w.h-1 {
		w.buf[y][0] = cell{'│', s}
		w.buf[y][w.w-1] = cell{'│', s}
	}
}
