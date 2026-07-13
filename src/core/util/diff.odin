package util

difference :: struct (T: typeid) {
	action: enum u8 {
		KEEP = 0,
		INSERT = 1,
		DELETE = 2,
	},
	value: T,
}

differentiate :: proc (o, n: []$T) -> []difference(T) {
	lo, ln := len(o), len(n)
	t := make([][]int, lo+1)
	for i in 0..=lo do t[i] = make([]int, ln+1)
	defer {
		for i in 0..=lo do delete(t[i])
		delete(t)
	}
	for i in 1..=lo {
		for j in 1..=ln {
			if o[i-1] == n[j-1] {
				t[i][j] = 1 + t[i-1][j-1]
			} else {
				t[i][j] = max(t[i-1][j], t[i][j-1])
			}
		}
	}
	i, j := lo, ln
	r: [dynamic]difference(T)
	for i > 0 && j > 0 {
		if o[i-1] == n[j-1] {
			append(&r, difference(T){.KEEP, o[i-1]})
			i -= 1
			j -= 1
		} else if t[i-1][j] > t[i][j-1] {
			append(&r, difference(T){.DELETE, o[i-1]})
			i -= 1
		} else {
			append(&r, difference(T){.INSERT, n[j-1]})
			j -= 1
		}
	}
	for i > 0 {
		append(&r, difference(T){.DELETE, o[i-1]})
		i -= 1
	}
	for j > 0 {
		append(&r, difference(T){.INSERT, n[j-1]})
		j -= 1
	}
	for k in 0..=(len(r)/2) {
		p := len(r) - 1 - k
		r[k], r[p] = r[p], r[k]
	}
	return r[:]
}
