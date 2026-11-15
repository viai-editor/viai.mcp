vim9script
# The tools.

import './helper.vim'

def g:Test_viai_help_search()
  helper.Initialize()
  var result = helper.CallTool('viai_help_search', {pattern: '^ch_sendexpr'})
  assert_false(result.isError)
  assert_match("\\(^\\|\n\\)ch_sendexpr()\tchannel\\.txt\\($\\|\n\\)",
    helper.TextOf(result))
enddef

def g:Test_viai_help_search_many()
  helper.Initialize()
  var result = helper.CallTool('viai_help_search', {pattern: '^E\d'})
  var lines = split(helper.TextOf(result), "\n")
  assert_equal(51, len(lines))
  assert_match('^\.\.\. and \d\+ more$', lines[-1])
enddef

def g:Test_viai_help_search_no_match()
  helper.Initialize()
  var result = helper.CallTool('viai_help_search',
    {pattern: '^NoSuchTagXyz$'})
  assert_false(result.isError)
  assert_match('^No help tag matches', helper.TextOf(result))
enddef

def g:Test_viai_help_search_bad_arguments()
  helper.Initialize()
  assert_true(helper.CallTool('viai_help_search', {}).isError)
  assert_true(helper.CallTool('viai_help_search', {pattern: 1}).isError)
  assert_true(helper.CallTool('viai_help_search', {pattern: '\('}).isError)
enddef

def g:Test_viai_help_read()
  helper.Initialize()
  var result = helper.CallTool('viai_help_read', {tag: 'ch_sendexpr()'})
  assert_false(result.isError)
  var lines = split(helper.TextOf(result), "\n")
  assert_match('^channel\.txt:\d\+$', lines[0])
  assert_match('\*ch_sendexpr()\*', lines[1])
  # It stops before the next function.
  assert_equal(-1, match(lines, '\*ch_sendraw()\*'))
  assert_notmatch('^\s*$', lines[-1])
enddef

def g:Test_viai_help_read_option()
  helper.Initialize()
  var result = helper.CallTool('viai_help_read', {tag: "'tabstop'"})
  assert_false(result.isError)
  assert_match("\\*'tabstop'\\*", helper.TextOf(result))
enddef

def g:Test_viai_help_read_bad_arguments()
  helper.Initialize()
  assert_true(helper.CallTool('viai_help_read', {}).isError)
  assert_true(helper.CallTool('viai_help_read',
    {tag: 'NoSuchTagXyz'}).isError)
  # A pattern is not a tag.
  assert_true(helper.CallTool('viai_help_read', {tag: 'ch_send.*'}).isError)
enddef

def g:Test_viai_vimscript_check_source()
  helper.Initialize()
  var source = "vim9script\ndef F()\n  var x: number = 'a'\nenddef\n"
  var result = helper.CallTool('viai_vimscript_check', {source: source})
  assert_false(result.isError)
  var text = helper.TextOf(result)
  assert_match('E1012: Type mismatch; expected number but got string', text)
  assert_match('<source>', text)
  assert_notmatch('\V' .. escape(tempname()->fnamemodify(':p:h'), '\'), text)
enddef

def g:Test_viai_vimscript_check_source_ok()
  helper.Initialize()
  var source = "vim9script\ndef F(): number\n  return 1\nenddef\n"
  var result = helper.CallTool('viai_vimscript_check', {source: source})
  assert_false(result.isError)
  assert_equal('No errors found', helper.TextOf(result))
enddef

def g:Test_viai_vimscript_check_does_not_run()
  helper.Initialize()
  var file = tempname()
  var source = $"vim9script\nwritefile(['ran'], '{file}')\n"
  helper.CallTool('viai_vimscript_check', {source: source})
  assert_false(filereadable(file))
enddef

def g:Test_viai_vimscript_check_path()
  helper.Initialize()
  var file = tempname() .. '.vim'
  writefile(['vim9script', 'def G()', '  NoSuchFunc()', 'enddef'], file)
  var result = helper.CallTool('viai_vimscript_check', {path: file})
  delete(file)
  assert_false(result.isError)
  assert_match('E117: Unknown function: NoSuchFunc', helper.TextOf(result))
enddef

def g:Test_viai_vimscript_check_bad_arguments()
  helper.Initialize()
  assert_true(helper.CallTool('viai_vimscript_check', {}).isError)
  assert_true(helper.CallTool('viai_vimscript_check',
    {path: 'x.vim', source: 'x'}).isError)
  assert_true(helper.CallTool('viai_vimscript_check',
    {path: '/no/such/file.vim'}).isError)
  assert_true(helper.CallTool('viai_vimscript_check', {source: 1}).isError)
enddef

# vim: ts=2 sw=0 et
