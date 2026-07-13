package zide

import "core:fmt"
import "core"
import "core/ui"
import "core/home"
import "core/util"

main :: proc () {
	// fmt.printf("%v\n", util.differentiate([]int{2, 0, 5}, []int{2, 0, 4, 6}))
	append(&core.plugins, core.plugin { ui.init, ui.loop, ui.exit })
	append(&core.plugins, core.plugin { home.init, nil, nil })
	core.init()
	for do core.loop()
}
