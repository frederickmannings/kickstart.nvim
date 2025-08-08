return {
  'lervag/vimtex',
  lazy = false,
  ft = { 'tex', 'bib' }, -- Only load for LaTeX files
  config = function()
    -- Disable default mappings that might conflict
    vim.g.vimtex_imaps_enabled = 0
    vim.g.vimtex_mappings_enabled = 1

    -- Compiler settings
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_compiler_latexmk = {
      build_dir = '',
      callback = 1,
      continuous = 1,
      executable = 'latexmk',
      hooks = {},
      options = {
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
        '-pdf',
      },
    }

    -- PDF viewer settings - adjust based on your system
    if vim.fn.has 'mac' == 1 then
      vim.g.vimtex_view_method = 'skim'
    elseif vim.fn.has 'unix' == 1 then
      vim.g.vimtex_view_method = 'zathura'
    elseif vim.fn.has 'win32' == 1 then
      vim.g.vimtex_view_method = 'general'
      vim.g.vimtex_view_general_viewer = 'SumatraPDF'
      vim.g.vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
    end

    -- Quickfix settings
    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_quickfix_ignore_filters = {
      'Underfull',
      'Overfull',
      'LaTeX Warning: .\\+ float specifier changed to',
      'Package hyperref Warning: Token not allowed in a PDF string',
      'LaTeX hooks Warning',
    }

    -- Folding
    vim.g.vimtex_fold_enabled = 1
    vim.g.vimtex_fold_manual = 1

    -- Completion
    vim.g.vimtex_complete_enabled = 1
    vim.g.vimtex_complete_close_braces = 1

    -- Error suppression
    vim.g.vimtex_log_ignore = {
      'Underfull',
      'Overfull',
      'specifier changed to',
      'Token not allowed in a PDF string',
    }

    -- Custom keymaps (optional)
    vim.keymap.set('n', '<localleader>ll', '<plug>(vimtex-compile)', { desc = 'VimTeX: Compile' })
    vim.keymap.set('n', '<localleader>lv', '<plug>(vimtex-view)', { desc = 'VimTeX: View PDF' })
    vim.keymap.set('n', '<localleader>le', '<plug>(vimtex-errors)', { desc = 'VimTeX: Show Errors' })
    vim.keymap.set('n', '<localleader>lc', '<plug>(vimtex-clean)', { desc = 'VimTeX: Clean' })
    vim.keymap.set('n', '<localleader>lC', '<plug>(vimtex-clean-full)', { desc = 'VimTeX: Clean Full' })
  end,
}
