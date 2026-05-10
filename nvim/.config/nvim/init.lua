require("config.common.main")
if vim.fn.exists("g:vscode") ~= 0 then
  require("config.vscode.main")
else
  require("config.terminal.main")
end
require("config.postcommon.main")
