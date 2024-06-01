local dap = require("dap")
local dapui = require("dapui")

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
dapui.setup({
	-- Set icons to characters that are more likely to work in every terminal.
	--    Feel free to remove or use ones that you like more! :)
	--    Don't feel like these are good choices.
	icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
	controls = {
		icons = {
			pause = "⏸",
			play = "▶",
			step_into = "⏎",
			step_over = "⏭",
			step_out = "⏮",
			step_back = "b",
			run_last = "▶▶",
			terminate = "⏹",
			disconnect = "⏏",
		},
	},
})

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

dap.configurations.java = {
	{
		name = "Debug Launch (2GB)",
		type = "java",
		request = "launch",
		vmArgs = "" .. "-Xmx2g ",
	},
	{
		name = "Debug Attach (8000)",
		type = "java",
		request = "attach",
		hostName = "127.0.0.1",
		port = 8000,
	},
	{
		name = "Debug Attach (5005)",
		type = "java",
		request = "attach",
		hostName = "127.0.0.1",
		port = 5005,
	},
	{
		name = "Custom Java Run Configuration",
		type = "java",
		request = "launch",
		-- Extend the classPath to list your dependencies.
		-- 'nvim-jdtls' adds 'classPaths' property if it's missing
		-- classPaths = {},

		-- For multi-module projects
		-- projectName = "",

		-- javaExec = "java",
		mainClass = "replace.with.class",

		-- Needs to be extended when using JDK9+
		-- 'nvim-jdtls' populates this property automatically
		-- modulePaths = {},
		vmArgs = "" .. "-Xmx2g ",
	},
}

-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })
