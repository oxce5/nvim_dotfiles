-- Shared helpers used across the config.

local M = {}

--- Build a GitHub URL from a short repo path.
---@param repo string e.g. 'folke/which-key.nvim'
---@return string url
function M.gh(repo) return 'https://github.com/' .. repo end

return M

-- vim: ts=2 sts=2 sw=2 et
