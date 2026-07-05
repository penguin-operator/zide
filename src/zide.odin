package zide

import "core"
import "ui"

main :: proc () {
	core.plugins["ui"] = { ui.init, ui.loop, ui.exit }
	core.init()
	for do core.loop()
}
