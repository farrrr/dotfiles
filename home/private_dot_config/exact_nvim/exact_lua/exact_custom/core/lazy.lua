return {
  lockfile = vim.fn.stdpath "config" .. "/lua/custom/lazy-lock.json"
  change_detection = {
    -- automatically check for config file changes and reload the ui
    enabled = true,
    notify = false, -- get a notification when changes are found
  },
  diff = {
    cmd = "diffview.nvim",
  },
  performance = {
    rtp = {
      disabled_plugins = {

      }
    }
  }
}