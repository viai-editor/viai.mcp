vim9script
# The protocol: the handshake and the methods other than the tools.

import './helper.vim'

def g:Test_initialize()
  var resp = helper.Initialize('2025-06-18')
  var result = resp.result
  assert_equal('2025-06-18', result.protocolVersion)
  assert_equal({tools: {}}, result.capabilities)
  assert_equal('vim9mcp', result.serverInfo.name)
enddef

def g:Test_initialize_unknown_version()
  var resp = helper.Initialize('1999-01-01')
  assert_equal('2025-11-25', resp.result.protocolVersion)
enddef

def g:Test_ping()
  helper.Initialize()
  assert_equal({}, helper.Request('ping').result)
enddef

def g:Test_unknown_method()
  helper.Initialize()
  var resp = helper.Request('no/such/method')
  assert_equal(-32601, resp.error.code)
  assert_false(resp->has_key('result'))
enddef

def g:Test_tools_list()
  helper.Initialize()
  var tools = helper.Request('tools/list').result.tools
  assert_equal(['viai_help_read', 'viai_help_search', 'viai_vimscript_check'],
    tools->mapnew((_, t) => t.name)->sort())
  for tool in tools
    assert_equal('object', tool.inputSchema.type, tool.name)
    assert_notequal('', tool.description, tool.name)
  endfor
enddef

def g:Test_unknown_tool()
  helper.Initialize()
  var resp = helper.Request('tools/call', {name: 'eval', arguments: {}})
  assert_equal(-32602, resp.error.code)
enddef

def g:Test_arguments_not_object()
  helper.Initialize()
  var resp = helper.Request('tools/call',
    {name: 'viai_help_read', arguments: ['tag']})
  assert_equal(-32602, resp.error.code)
enddef

# vim: ts=2 sw=0 et
