if vim.fn.has("nvim-0.11") ~= 1 then
  vim.notify(
    "Your nvim is too fucking old. Upgrade to at least 0.11.",
    vim.log.levels.WARN
  )
end
