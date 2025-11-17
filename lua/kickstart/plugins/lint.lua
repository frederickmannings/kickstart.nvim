return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        python = { 'mypy', 'ruff' },
        javascript = { 'eslint' },
        typescript = { 'eslint' },
        javascriptreact = { 'eslint' },
        typescriptreact = { 'eslint' },
        svelte = { 'eslint' },
      }

      ----------------------- python config -----------------------
      -- helper function to find project root and check for .venv
      local function get_project_tool_cmd(tool_name)
        -- find project root by looking for common markers
        local root_patterns = { '.git', 'pyproject.toml', 'setup.py', 'requirements.txt' }
        local root_dir = vim.fs.dirname(vim.fs.find(root_patterns, { upward = true })[1])

        if root_dir then
          local venv_tool = root_dir .. '/.venv/bin/' .. tool_name
          -- check if the tool exists in the venv
          if vim.fn.executable(venv_tool) == 1 then
            return venv_tool
          end
        end

        -- fallback to global installation
        return tool_name
      end

      -- custom mypy configuration to respect pyproject.toml and use local venv
      lint.linters.mypy.cmd = function()
        return get_project_tool_cmd 'mypy'
      end
      lint.linters.mypy.args = {
        '--strict',
        '--show-column-numbers',
        '--show-error-end',
        '--hide-error-codes',
        '--hide-error-context',
        '--no-color-output',
        '--no-error-summary',
        '--no-pretty',

        function()
          -- Add the current file as the target
          return vim.api.nvim_buf_get_name(0)
        end,
        '-',
      }

      -- custom ruff configuration to respect pyproject.toml and use local venv
      lint.linters.ruff.cmd = function()
        return get_project_tool_cmd 'ruff'
      end
      lint.linters.ruff.args = {
        'check',
        '--output-format=json',
        '--no-cache',
        '--quiet',
        '--stdin-filename',
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
        '-',
      }
      -------------------------------------------------------------

      ----------------------- eslint config -----------------------
      -- helper function to find project-local eslint
      local function get_eslint_cmd()
        local root_patterns = { '.git', 'package.json', '.eslintrc.js', '.eslintrc.json' }
        local root_dir = vim.fs.dirname(vim.fs.find(root_patterns, { upward = true })[1])

        if root_dir then
          local local_eslint = root_dir .. '/node_modules/.bin/eslint'
          if vim.fn.executable(local_eslint) == 1 then
            return local_eslint
          end
        end

        return 'eslint' -- fallback to global
      end

      lint.linters.eslint.cmd = get_eslint_cmd
      -------------------------------------------------------------

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
