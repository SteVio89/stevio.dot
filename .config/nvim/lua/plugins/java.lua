vim.pack.add({
	-- nvim-java's README pins spring-boot.nvim to this commit
	{
		src = "https://github.com/JavaHello/spring-boot.nvim",
		name = "spring-boot",
		version = "218c0c26c14d99feca778e4d13f5ec3e8b1b60f0",
	},
	{ src = "https://github.com/nvim-java/nvim-java", name = "nvim-java" },
})

require("java").setup()
vim.lsp.enable("jdtls")

local function project_jdk_runtime(home)
	local ok, lines = pcall(vim.fn.readfile, home .. "/release")
	if not ok then
		return
	end
	for _, line in ipairs(lines) do
		local version = line:match('^JAVA_VERSION="([^"]+)"')
		if version then
			local major = version:match("^(1%.%d+)") or version:match("^(%d+)")
			return { name = "JavaSE-" .. major, path = home, default = true }
		end
	end
end

local java_home = vim.env.JAVA_HOME
local runtime = java_home and project_jdk_runtime(java_home)
if runtime then
	vim.lsp.config("jdtls", {
		settings = {
			java = {
				configuration = { runtimes = { runtime } },
				import = { gradle = { java = { home = java_home } } },
			},
		},
	})
end
