vim9script
# The help of plugins, on the 'runtimepath' given to the server.

import autoload '../autoload/vim9mcp.vim'
import './helper.vim'

const HERE = expand('<sfile>:p:h')
const PLUGIN = HERE .. '/Xplugin'

# Puts a help file in the plugin.
def AddHelp()
  mkdir(PLUGIN .. '/doc', 'p')
  writefile(['*xplugin.txt*	A plugin', '',
    'Some text.', '',
    'XPluginCmd					*:XPluginCmd*',
    '	Does the thing.', '',
    'XPluginOther					*:XPluginOther*',
    '	Does another thing.'], PLUGIN .. '/doc/xplugin.txt')
  execute 'helptags' fnameescape(PLUGIN .. '/doc')
enddef

# The command of the server without the 'runtimepath' of this Vim.
def ServerCommand(): list<string>
  return [v:progpath, '--clean', '--stdio-channel', '-S',
    fnamemodify(HERE, ':h') .. '/autoload/vim9mcp.vim']
enddef

def g:Test_runtimepath_from_environment()
  mkdir(PLUGIN, 'R')
  AddHelp()
  # $VIMRUNTIME is left out: the server adds it.
  helper.StartServer(ServerCommand(), {VIM9MCP_RUNTIMEPATH: PLUGIN})
  helper.Handshake()
  var result = helper.CallTool('viai_help_search', {pattern: '^:XPlugin'})
  assert_equal(":XPluginCmd\txplugin.txt\n:XPluginOther\txplugin.txt",
    helper.TextOf(result))
  result = helper.CallTool('viai_help_read', {tag: ':XPluginCmd'})
  assert_equal("xplugin.txt:5\nXPluginCmd\t\t\t\t\t*:XPluginCmd*\n"
    .. "\tDoes the thing.", helper.TextOf(result))
  # The help of ViAI is still there.
  result = helper.CallTool('viai_help_read', {tag: 'ch_sendexpr()'})
  assert_false(result.isError)
enddef

def g:Test_runtimepath_without_environment()
  mkdir(PLUGIN, 'R')
  AddHelp()
  var save_rtp = &runtimepath
  &runtimepath ..= ',' .. PLUGIN
  try
    helper.StartServer(ServerCommand())
  finally
    &runtimepath = save_rtp
  endtry
  helper.Handshake()
  var result = helper.CallTool('viai_help_search', {pattern: '^:XPlugin'})
  assert_match('^No help tag matches', helper.TextOf(result))
enddef

def g:Test_command_passes_runtimepath()
  mkdir(PLUGIN, 'R')
  AddHelp()
  var save_rtp = &runtimepath
  &runtimepath ..= ',' .. PLUGIN
  try
    helper.StartServer(vim9mcp.Command())
  finally
    &runtimepath = save_rtp
  endtry
  helper.Handshake()
  var result = helper.CallTool('viai_help_search', {pattern: '^:XPluginCmd$'})
  assert_equal(":XPluginCmd\txplugin.txt", helper.TextOf(result))
enddef

def g:Test_viai_vimscript_check_import_by_name()
  mkdir(PLUGIN .. '/import', 'pR')
  writefile(['vim9script', 'export def Num(): number', '  return 1',
    'enddef'], PLUGIN .. '/import/xlib.vim')
  var source = "vim9script\nimport 'xlib.vim'\n"
    .. "def F(): number\n  return xlib.Num()\nenddef\n"

  helper.StartServer(ServerCommand(), {VIM9MCP_RUNTIMEPATH: PLUGIN})
  helper.Handshake()
  assert_equal('No errors found', helper.TextOf(
    helper.CallTool('viai_vimscript_check', {source: source})))
  helper.StopServer()

  # Not found without the plugin on 'runtimepath'.
  helper.StartServer(ServerCommand())
  helper.Handshake()
  assert_match('E1053: Could not import "xlib.vim"', helper.TextOf(
    helper.CallTool('viai_vimscript_check', {source: source})))
enddef

# vim: ts=2 sw=0 et
