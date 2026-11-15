vim9script
# What the tests use to drive the server: this ViAI is the client.

import autoload '../autoload/viaimcp.vim'

var job: job
export var stderr: list<string> = []

export def StartServer(cmd = viaimcp.Command(), env: dict<string> = {})
  stderr = []
  job = job_start(cmd, {
    in_mode: 'mcp', out_mode: 'mcp', err_mode: 'nl',
    err_cb: (_, msg) => {
      add(stderr, msg)
    },
    env: env,
  })
  assert_equal('run', job_status(job))
enddef

export def StopServer()
  if job_status(job) == 'run'
    job_stop(job, 'kill')
  endif
enddef

# Sends a request and returns the response.
export def Request(method: string, params: dict<any> = {}): dict<any>
  var resp = ch_evalexpr(job, {method: method, params: params},
    {timeout: 10000})
  assert_equal(v:t_dict, type(resp), $'no response to {method}')
  return type(resp) == v:t_dict ? resp : {}
enddef

# Starts the server and does the handshake.
export def Initialize(version = '2025-06-18'): dict<any>
  StartServer()
  return Handshake(version)
enddef

export def Handshake(version = '2025-06-18'): dict<any>
  var resp = Request('initialize', {
    protocolVersion: version,
    capabilities: {},
    clientInfo: {name: 'viaimcp-test', version: '0'},
  })
  ch_sendexpr(job, {method: 'notifications/initialized'})
  return resp
enddef

# Calls a tool and returns its result.
export def CallTool(name: string, args: dict<any>): dict<any>
  return Request('tools/call', {name: name, arguments: args})
    ->get('result', {})
enddef

# The text of the result of a tool.
export def TextOf(result: dict<any>): string
  return result->get('content', [{}])[0]->get('text', '')
enddef

# vim: ts=2 sw=0 et
