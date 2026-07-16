package zide

import "core"
import "core/ui"
import "core/home"

main :: proc () {
	append(&core.plugins, core.plugin { ui.init, ui.loop, ui.exit })
	append(&core.plugins, core.plugin { home.init, nil, nil })
	core.init()
	for do core.loop()
}
