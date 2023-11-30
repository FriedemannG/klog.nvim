local M = require('lualine.component'):extend()
local highlight =  require'lualine.highlight'

local default_options = {
  stop ='#ff5189',
  warn = '#fe8019',
  stop_limit = 9,
  warn_limit = 8
}

function M:init(options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  self.colors = { stop = highlight.create_component_highlight_group(
      {fg =  self.options.stop}, 'klog_stop', self.options),
        warn = highlight.create_component_highlight_group(
      {fg =  self.options.warn}, 'klog_warn', self.options)}
  -- self.icon_hl_cache = {}
end

function M:update_status()
    local ret = io.popen("klog total --today --now --no-style", "r")
    if ret == nil then
      return highlight.component_format_highlight(self.colors["stop"]) .. "Klog error"
    end
    local s   = ret:read("*l")
    if (s == nil) then
      return highlight.component_format_highlight(self.colors["stop"]) .. "No Klog Entry"
    end
    local min = s.match(s,"%d+m")
    local hours = s.match(s,"%d+h")
    if min == nil and hours == nil then
      return highlight.component_format_highlight(self.colors["stop"]) .. "No Klog Entry"
    end
    if min == nil then
      min = "0m"
    end
    if hours == nil then
      hours = "0h"
    end
    local nuMin = min.match(min, "%d+")
    nuMin = tonumber(nuMin)
    local nuHours = hours.match(hours, "%d+")
    nuHours = tonumber(nuHours)
    if nuMin == 0 and nuHours == 0 then
      return highlight.component_format_highlight(self.colors["stop"]) .. "No Klog Entry"
    end
    local color = "none"
    if nuHours >= self.options.stop_limit then
      color = "stop"
    elseif nuHours >= self.options.warn_limit then
      color = "warn"
    else
      return hours .. min
    end
    -- table.insert(retTab,highlight.component_format_highlight(self.colors['stop']))
    -- local str = table.concat(retTab, ' ')
    local str = highlight.component_format_highlight(self.colors[color])
    str = str .. hours .. min
  return str
end


return M
