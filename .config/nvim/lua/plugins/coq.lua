return {
	"ms-jpq/coq_nvim",
	version = false,
	lazy = false,
	priority = 1000,
	build = ":COQdeps",
	dependencies = {
		{ "ms-jpq/coq.artifacts", branch = "artifacts", build = ":COQdeps" },
	},
	-- config = function() end, --config must be made before loading lazy
}
