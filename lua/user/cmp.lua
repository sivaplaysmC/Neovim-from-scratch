local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

local lspkind = require("lspkind")

local codicons = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
  }



local luasnip = require("luasnip")

luasnip.config.set_config({
  region_check_events = 'InsertEnter',
  delete_check_events = 'InsertLeave'
})


require("luasnip/loaders/from_vscode").lazy_load()


local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<C-e>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ["<CR>"] = cmp.mapping.confirm { select = true },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  },

  formatting = {
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format(' %s  %s', codicons[vim_item.kind] , vim_item.kind) -- This concatonates the icons with the name of the item kind
      -- Function function jkjjj()
      function cool()
        print("Hi There")
      end
      -- end
      -- Source  
      -- vim_item.menu = ({
      --   buffer = "[BUF]",
      --   nvim_lsp = "[LSP]",
      --   luasnip = "[SNP]",
      --   nvim_lua = "[LUA]",
      --   latex_symbols = "[LTX]",
      -- })[entry.source.name]
      return vim_item
    end
  },


  -- formatting = {
  --   max_width = 50,
  --   ellipsis_char = '...',
  --   format = lspkind.cmp_format{
  --           mode = "symbol_text",
  --           preset = "codicons"
  --       },
  --
  --   menu = ({
  --     buffer = "[BUF]",
  --     nvim_lsp = "[LSP]",
  --     luasnip = "[SNP]",
  --     nvim_lua = "[LUA]",
  --     latex_symbols = "[LTX]",
  --   })
  --   --[[ before = function(_, vim_item) ]]
  --   --[[   vim_item.kind = cmp_kinds[vim_item.kind] or "" ]]
  --   --[[   return vim_item ]]
  --   --[[ end, ]]
  -- },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  },
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
 window = {
    documentation = {
      border = {'╭', '─', '╮', '│', '╯', '─', '╰', '│'},
    },
    completion = {
      border = {'┌', '─', '┐', '│', '┘', '─', '└', '│'},
      winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
    }
  },
  experimental = {
    ghost_text = false,
    native_menu = false,
  },
}

    -- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' }
      }
    }
  })
})
