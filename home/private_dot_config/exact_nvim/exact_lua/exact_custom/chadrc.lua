---@type ChadrcConfig
local M = {}

local headers = require "custom.core.headers"

local function get_venv(variable)
  local venv = os.getenv(variable)
  if venv ~= nil and string.find(venv, "/") then
    local orig_venv = venv
    for w in orig_venv:gmatch "([^/]+)" do
      venv = w
    end
    venv = string.format("%s", venv)
  end
  return venv
end

local function get_header()
  if vim.g.random_header then
    local headerNames = {}
    for name, _ in pairs(headers) do
      table.insert(headerNames, name)
    end

    local randomName = headerNames[math.random(#headerNames)]
    local randomHeader = headers[randomName]
    return randomHeader
  else
    return headers["hydra"]
  end
end

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  theme = "onedark",
  theme_toggle = { "onenord", "onedark" },
  lsp_semantic_tokens = false, -- needs nvim v0.9, just adds highlight groups for lsp semantic tokens
  hl_override = highlights.override,
  hl_add = highlights.add,
  extended_integrations = {
    "notify",
  }, -- these aren't compiled by default, ex: "alpha", "notify"
  telescope = { style = "bordered" }, -- borderless / bordered
  cmp = {
    icons = false,
    lspkind_text = true,
    style = "default", -- default/flat_light/flat_dark/atom/atom_colored
    border_color = "grey_fg", -- only applicable for "default" style, use color names from base30 variables
    selected_item_bg = "colored", -- colored / simple
  },

  --- nvchad_ui modules ---
  statusline = {
    theme = "vscode_colored", -- default/vscode/vscode_colored/minimal
    -- default/round/block/arrow separators work only for default statusline theme
    -- round and block will work for minimal theme only
    separator_style = "default",
  },

  -- lazyload it when there are 1+ tabs
  tabufline = {
    show_numbers = true,
    enabled = true,
    lazyload = true,
  },

  nvdash = {
    load_on_startup = true,
    header = get_header(),
    buttons = {
      { "  Find File", "Spc f f", "Telescope find_files" },
      { "󰈚  Recent Files", "Spc f r", "Telescope oldfiles" },
      { "󰈭  Find Word", "Spc f w", "Telescope live_grep" },
      { "  Find Projects", "Spc f p", "Telescope projects" },
      { "󰔚  Find Sessions", "Spc f s", "Telescope persisted" },
      { "  Themes", "Spc f t", "Telescope themes" },
      { "  Mappings", "Spc n c", "NvCheatsheet" },
    },
  },

  cheatsheet = { theme = "grid" }, -- simple/grid

}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
