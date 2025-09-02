return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        python = { 'ruff', 'mypy' },
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
        '--show-column-numbers',
        '--show-error-end',
        '--hide-error-codes',
        '--hide-error-context',
        '--no-color-output',
        '--no-error-summary',
        '--no-pretty',
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

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
