vim9script
# Runs every Test_ function in test/test_*.vim and reports what failed.
# Started by test/run, which is what to use.

const HERE = expand('<sfile>:p:h')

set nocompatible
set noswapfile
set nomore
set belloff=all
set cmdheight=10
if exists('+shellslash')
  set shellslash
endif

# The server is this ViAI started again, so it needs what the server needs.
if !has('viai-1.0.50')
  writefile(['This Vim cannot run the server, so nothing was tested.',
    'It needs ViAI 1.0.0050 or later.',
    'Name another with $VIMPROG:',
    '    VIMPROG=/path/to/viai ./run'], HERE .. '/messages')
  cquit 1
endif

import './helper.vim'

var failed: list<string> = []
var ran = 0
var report: list<string> = []

def RunOne(name: string)
  ran += 1
  v:errors = []
  v:errmsg = ''
  try
    execute 'call g:' .. name .. '()'
  catch
    add(v:errors, v:throwpoint .. ': ' .. v:exception)
  endtry
  # An error Vim reported without stopping the test, a compile check among
  # them, would otherwise be lost.
  if v:errmsg != ''
    add(v:errors, 'an error went unreported: ' .. v:errmsg)
  endif
  helper.StopServer()

  if v:errors->empty()
    add(report, 'ok     ' .. name)
  else
    add(failed, name)
    add(report, 'FAILED ' .. name)
    for err in v:errors
      add(report, '       ' .. err)
    endfor
  endif
enddef

def Main()
  for file in glob(HERE .. '/test_*.vim', false, true)->sort()
    execute 'source' fnameescape(file)
  endfor
  var names = getcompletion('Test_', 'function')
    ->map((_, n) => substitute(n, '()$', '', ''))
    ->filter((_, n) => n =~ '^Test_')
    ->sort()
  if $TEST_FILTER != ''
    names->filter((_, n) => n =~ $TEST_FILTER)
  endif
  for name in names
    RunOne(name)
  endfor
  add(report, '')
  add(report, $'{ran} tests, {len(failed)} failed')
  writefile(report, HERE .. '/messages')
enddef

try
  Main()
catch
  writefile(report + ['', 'Stopped: ' .. v:throwpoint .. ': '
    .. v:exception], HERE .. '/messages')
  cquit 1
endtry
if failed->empty()
  qall!
endif
cquit 1

# vim: ts=2 sw=0 et
