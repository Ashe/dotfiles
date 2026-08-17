-- Derive default settings from JAVA_HOME
local function java_home_defaults()
	local home = os.getenv("JAVA_HOME")
	if not home then
		return {}
	end

	local java = { import = { gradle = { java = { home = home } } } }
	local ok, lines = pcall(vim.fn.readfile, home .. "/release")
	local raw = ok and table.concat(lines, " "):match('JAVA_VERSION="([^"]+)"') or nil
	if raw then
		-- "1.8.0_392" is runtime JavaSE-1.8; modern JDKs are the major
		local major = raw:match("^1%.%d+") or raw:match("^%d+")
		java.configuration = {
			runtimes = {
				{ name = "JavaSE-" .. major, path = home, default = true },
			},
		}
	end
	return { java = java }
end

-- Only warn the user that jdtls isn't installed once
local warned = false

-- Used to filter out noisy messages
local muted_messages = {
	["Validate documents"] = true,
	["Publish Diagnostics"] = true,
}

-- Progress tokens whose reports are currently being dropped
local muted_progress = {}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("UserJdtls", {}),
	pattern = "java",
	callback = function(ev)
		local jdtls = try_require("jdtls")
		if not jdtls then
			return
		end

		-- Combine default config and vim.lsp.config() overrides from .nvim.lua files
		local config = vim.deepcopy(vim.lsp.config["jdtls"] or {})
		config.name = "jdtls"

		-- jdtls should be available on the PATH in a java project
		if type(config.cmd) ~= "table" then
			config.cmd = { "jdtls" }
		end

		-- Skip quietly when the project does not expose a jdtls binary
		if vim.fn.executable(config.cmd[1]) == 0 then
			if not warned then
				warned = true
				vim.notify("No jdtls on PATH, java LSP disabled", vim.log.levels.WARN)
			end
			return
		end

		-- start_or_attach does not read root_markers itself
		config.root_dir = config.root_dir
			or vim.fs.root(ev.buf, config.root_markers or { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" })

		-- Give every project its own jdtls workspace unless the cmd already has one
		if not vim.list_contains(config.cmd, "-data") then
			local root = config.root_dir or vim.fn.getcwd()
			local dir = vim.fn.stdpath("cache")
				.. "/jdtls/"
				.. vim.fn.fnamemodify(root, ":t")
				.. "-"
				.. vim.fn.sha256(root):sub(1, 8)
			vim.list_extend(config.cmd, { "-data", dir })
		end

		-- Below any explicit config, honour the environment's JAVA_HOME
		config.settings = vim.tbl_deep_extend("keep", config.settings or {}, java_home_defaults())

		-- Advertise nvim-jdtls' extra refactoring capabilities
		config.init_options = vim.tbl_deep_extend("keep", config.init_options or {}, {
			extendedClientCapabilities = jdtls.extendedClientCapabilities,
		})

		-- Propagate ensure import-affecting settings are received by jdtls
		config.init_options.settings =
			vim.tbl_deep_extend("keep", config.init_options.settings or {}, config.settings or {})

		-- Mute message spam
		config.handlers = config.handlers or {}
		config.handlers["$/progress"] = config.handlers["$/progress"]
			or function(err, result, ctx)
				local token = result and result.token
				local value = (result and result.value) or {}
				if token ~= nil then
					if value.kind == "begin" and muted_messages[value.title] then
						muted_progress[token] = true
					end
					if muted_progress[token] then
						if value.kind == "end" then
							muted_progress[token] = nil
						end
						return
					end
				end
				return vim.lsp.handlers["$/progress"](err, result, ctx)
			end

		config.handlers["language/status"] = config.handlers["language/status"]
			or function(_, result)
				if result and result.type == "Error" then
					vim.notify(result.message, vim.log.levels.ERROR)
				end
			end

		jdtls.start_or_attach(config)
	end,
})
