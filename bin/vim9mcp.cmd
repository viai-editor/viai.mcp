@echo off
rem Starts vim9mcp: a ViAI that serves the Model Context Protocol on its stdin
rem and stdout.  %VIM9MCP_VIM% names the ViAI to use, "viai" from %PATH%
rem otherwise.
setlocal
if "%VIM9MCP_VIM%"=="" set VIM9MCP_VIM=viai
"%VIM9MCP_VIM%" --clean --stdio-channel -S "%~dp0..\autoload\vim9mcp.vim"
