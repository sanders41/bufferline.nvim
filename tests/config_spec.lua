local fmt = string.format

describe("Config tests", function()
  local whitesmoke = "#F5F5F5"
  local config = require("bufferline.config")

  after_each(function() config.__reset() end)

  describe("Setting config", function()
    it("should add defaults to user values", function()
      config.set({
        options = {
          show_close_icon = false,
        },
      })
      local under_test = config.apply()
      assert.is_false(under_test.options.show_close_icon)
      assert.is_false(vim.tbl_isempty(under_test.highlights))
      assert.is_true(vim.tbl_count(under_test.highlights) > 10)
    end)

    it("should create vim highlight groups names for the highlights", function()
      config.set({
        highlights = {
          fill = {
            guifg = "red",
          },
        },
      })
      local under_test = config.apply()

      assert.equal(under_test.highlights.fill.fg, "red")
      assert.equal(under_test.highlights.fill.hl_group, "BufferLineFill")
    end)

    it("should derive colors from the existing highlights", function()
      vim.cmd(fmt("hi Comment guifg=%s", whitesmoke))
      config.set({})
      local under_test = config.apply()
      assert.equal(whitesmoke:lower(), under_test.highlights.info.fg)
    end)

    it("should update highlights on colorscheme change", function()
      config.set({
        highlights = {
          buffer_selected = {
            guifg = "red",
          },
        },
      })
      local conf = config.apply()
      conf = config.update_highlights()
      assert.is_equal(conf.highlights.buffer_selected.fg, "red")
    end)

    it('should not underline anything if options.indicator.style = "icon"', function()
      config.set({ options = { indicator = { style = "icon" } } })
      local conf = config.apply()
      for _, value in pairs(conf.highlights) do
        assert.is_falsy(value.underline)
      end
    end)

    it('should only underline valid fields if options.indicator.style = "underline"', function()
      config.set({ options = { indicator = { style = "underline" } } })
      local conf = config.apply()
      local valid = {
        "numbers_selected",
        "buffer_selected",
        "modified_selected",
        "indicator_selected",
        "tab_selected",
        "close_button_selected",
        "tab_separator_selected",
        "duplicate_selected",
        "separator_selected",
        "pick_selected",
        "close_button_selected",
        "diagnostic_selected",
        "error_selected",
        "error_diagnostic_selected",
        "info_selected",
        "info_diagnostic_selected",
        "warning_selected",
        "warning_diagnostic_selected",
        "hint_selected",
        "hint_diagnostic_selected",
      }
      for hl, value in pairs(conf.highlights) do
        if vim.tbl_contains(valid, hl) then
          assert.is_true(value.underline)
        else
          assert.is_falsy(value.underline)
        end
      end
    end)
  end)
end)
