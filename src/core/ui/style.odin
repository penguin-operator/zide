package ui

style :: struct {
	w: enum u8 {
		NONE = 0,
		BOLD = 1,
		DIM = 2,
	},
	italic, underline, strikethrough: bool,
	blink, inverse, hidden: bool,
	bg, fg: union{color},
}

color :: union #no_nil {
	color_std,
	color_rgb,
}

color_std :: struct {
	c: enum u8 {
		BLACK = 0,
		RED = 1,
		GREEN = 2,
		YELLOW = 3,
		BLUE = 4,
		MAGENTA = 5,
		CYAN = 6,
		WHITE = 7,
	},
	b: bool,
}

color_rgb :: struct {
	r, g, b: u8,
}
