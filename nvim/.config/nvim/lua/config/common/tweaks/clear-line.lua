local keymap = require("config.common.utils.keymap")

keymap.define_keymap("n", "g/", "0d$", "Clear line", { silent = true })
