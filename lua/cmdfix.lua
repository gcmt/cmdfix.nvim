local M = {}
local plugin_name = "cmdfix"

M.commands = {}
M.ignored = {}
M.config = {}
M.config_defaults = {
	enabled = true,
	threshold = 2,
	ignore = { "Next" },
	aliases = {},
}

-- Find all defined user commands
-- Skip all ignored commands and setup aliases
M.discover_commands = function()
	M.commands = {}
	M.ignored = {}
	for _, v in pairs(M.config.ignore) do
		M.ignored[v] = true
	end
	for _, cmd in pairs(vim.fn.getcompletion("", "command")) do
		if M.config.aliases[cmd] then
			M.commands[M.config.aliases[cmd]] = cmd
		end
		if not M.ignored[cmd] and string.match(cmd, "^%u") then
			M.commands[string.lower(cmd)] = cmd
		end
	end
end

-- Return the command line as a table
local function getcmdline()
	return vim.split(vim.fn.getcmdline(), " ", { trimempty = false })
end

-- Replace the command with the canonical command
local function fix_cmdline()
	if vim.v.event.abort or vim.fn.expand("<afile>") ~= ":" then
		return
	end
	local cmdpos = vim.fn.getcmdpos()
	local cmdline = getcmdline()
	if #cmdline == 0 then
		return
	end
	local raw = cmdline[1]
	local startpos, endpos = string.find(raw, "%a+", 1, false)
	if not startpos then
		return
	end
	local threshold = M.config.threshold
	local cmd = string.sub(raw, startpos, endpos)
	local repl = M.commands[string.lower(cmd)]
	if string.match(cmd, "%u") and not repl and not M.ignored[cmd] then
		-- User id typing explicitly an uppercase command. If it is not
		-- a tracked user-defined command and it is not an ignored command,
		-- make it lowercase as it could be a typing mistake
		-- This helps fixing mistakes such as :Set -> :set (but only if :Set is
		-- not a user-defined command)
		repl = string.lower(cmd)
		threshold = 1
	end
	if not repl or #cmd < threshold then
		return
	end
	cmdline[1] = string.sub(raw, 1, startpos - 1) .. repl .. string.sub(raw, endpos + 1)
	local newpos = cmdpos + #repl - #cmd
	vim.fn.setcmdline(table.concat(cmdline, " "), newpos)
end

-- Trigger command line fix when a space is pressed just after the first command
local function fix_cmdline_on_change()
	local cmdline = getcmdline()
	if #cmdline == 2 and cmdline[#cmdline] == "" then
		fix_cmdline()
	end
end

-- Setup autocommands
local function setup_autocommands()
	local group = vim.api.nvim_create_augroup(plugin_name, { clear = true })
	-- Triggered just before the command is executed or cancelled
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		group = group,
		desc = "Fix command when typing enter",
		callback = fix_cmdline,
	})
	-- Triggered each time a charactrer is pressed at the command line
	vim.api.nvim_create_autocmd("CmdlineChanged", {
		group = group,
		desc = "Fix command after pressing space",
		callback = fix_cmdline_on_change,
	})
	-- Autoimatically discover commands at statup
	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		once = true,
		desc = "Discover user-defined commands",
		callback = M.discover_commands,
	})
end

-- Setup config
-- Before falling back to the default value, look for options
-- definied with vimscript (eg via let g:cmdfix_enabled = v:true)
local function setup_config(config)
	for k, v in pairs(M.config_defaults) do
		if config[k] ~= nil then
			M.config[k] = config[k]
		elseif vim.g[plugin_name .. "_" .. k] ~= nil then
			M.config[k] = vim.g[plugin_name .. "_" .. k]
		else
			M.config[k] = v
		end
	end
end

M.setup = function(config)
	setup_config(config)
	if not M.config.enabled then
		return
	end
	setup_autocommands()
end

return M
