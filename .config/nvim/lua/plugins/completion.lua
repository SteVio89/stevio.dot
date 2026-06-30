local function set_inline_completion_hl()
	vim.api.nvim_set_hl(0, "ComplHint", { fg = "#585b70", italic = true })
	vim.api.nvim_set_hl(0, "ComplHintMore", { fg = "#585b70", italic = true })
end

set_inline_completion_hl()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_inline_completion_hl,
})

vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }

local function compare_completions(a, b)
	local a_client = vim.lsp.get_client_by_id(a.user_data.nvim.lsp.client_id)
	local b_client = vim.lsp.get_client_by_id(b.user_data.nvim.lsp.client_id)
	local a_is_scls = a_client and a_client.name == "scls"
	local b_is_scls = b_client and b_client.name == "scls"
	if a_is_scls ~= b_is_scls then
		return not a_is_scls
	end
	local itema = a.user_data.nvim.lsp.completion_item
	local itemb = b.user_data.nvim.lsp.completion_item
	return (itema.sortText or itema.label) < (itemb.sortText or itemb.label)
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client or not client:supports_method("textDocument/completion") then
			return
		end

		vim.lsp.completion.enable(true, client.id, ev.buf, {
			autotrigger = true,
			cmp = compare_completions,
		})
	end,
})

vim.keymap.set("i", "<Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-n>"
	elseif vim.snippet.active({ direction = 1 }) then
		return "<cmd>lua vim.snippet.jump(1)<cr>"
	else
		return "<Tab>"
	end
end, { expr = true })

vim.keymap.set("i", "<S-Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-p>"
	elseif vim.snippet.active({ direction = -1 }) then
		return "<cmd>lua vim.snippet.jump(-1)<cr>"
	else
		return "<S-Tab>"
	end
end, { expr = true })

vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		return vim.keycode("<C-y>")
	else
		return require("mini.pairs").cr()
	end
end, { expr = true, replace_keycodes = false })

vim.keymap.set("i", "<C-Space>", function()
	vim.lsp.completion.get()
end)
