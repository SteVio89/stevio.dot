vim.pack.add({
	{ src = "https://github.com/mfussenegger/nvim-lint", name = "nvim-lint" },
})

local lint = require("lint")

-- Linters chosen to COMPLEMENT the LSP, not duplicate it. Tools are provided
-- per-project via nix/direnv, so the executable guard below decides what runs.
lint.linters_by_ft = {
	zig = { "zlint" },
	lua = { "selene" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	nix = { "statix", "deadnix" },
	yaml = { "yamllint" },
	markdown = { "markdownlint" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	kotlin = { "ktlint" },
}

-- Run only the linters whose binary is on PATH in the current (direnv) env.
-- Keeps nvim-lint from erroring when a project doesn't provide a given tool.
local function lint_available()
	local names = lint.linters_by_ft[vim.bo.filetype] or {}
	local runnable = {}
	for _, name in ipairs(names) do
		local linter = lint.linters[name]
		local cmd = type(linter) == "table" and linter.cmd or name
		if type(cmd) ~= "string" then
			cmd = name
		end
		if vim.fn.executable(cmd) == 1 then
			table.insert(runnable, name)
		end
	end
	if #runnable > 0 then
		lint.try_lint(runnable)
	end
end

-- Save-only: zlint scans the whole project and is too slow for InsertLeave/BufRead.
-- Go is handled project-wide via golangci-lint-langserver in lsp.lua, not here.
local lint_group = vim.api.nvim_create_augroup("NvimLint", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = lint_group,
	callback = lint_available,
})
