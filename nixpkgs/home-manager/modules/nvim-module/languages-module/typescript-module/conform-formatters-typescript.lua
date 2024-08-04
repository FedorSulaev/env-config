local conform = require("conform")
conform.formatters.prettier = {
	prepend_args = { "--tab-width", "4" },
}
conform.formatters_by_ft.typescript = { "prettier" }
conform.formatters_by_ft.typescriptreact = { "prettier" }
