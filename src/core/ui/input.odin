package ui

import "core:slice"

input_field :: struct {
	using win: win,
	inbuf: [dynamic]rune,
	on: map[rune]proc(^input_field),
}

@(private = "package")
inbuf: rune

@(private = "package")
input_queue: [dynamic]^win

getch :: proc (w: ^win) -> rune {
	if !slice.contains(input_queue[:], w) {
		append(&input_queue, w)
		return 0
	}
	return inbuf
}
