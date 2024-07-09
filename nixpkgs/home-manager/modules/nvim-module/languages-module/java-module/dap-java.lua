local dap = require("dap")

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
