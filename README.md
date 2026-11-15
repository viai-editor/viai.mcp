# viai.mcp

[![Test](https://github.com/viai-editor/viai.mcp/actions/workflows/test.yml/badge.svg)](https://github.com/viai-editor/viai.mcp/actions/workflows/test.yml)
[![Update doc/tags](https://github.com/viai-editor/viai.mcp/actions/workflows/update-doc-tags.yml/badge.svg)](https://github.com/viai-editor/viai.mcp/actions/workflows/update-doc-tags.yml)
[![ViAI 1.0.0050+](https://img.shields.io/badge/ViAI-1.0.0050%2B-06281A?logo=data:image/svg%2bxml;base64,PHN2ZyByb2xlPSJpbWciIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48dGl0bGU+VmlBSTwvdGl0bGU+PHBhdGggZmlsbD0iI0ZGRkZGRiIgZD0iTTUuNzAyIDMuNDg5TDE4Ljk3OSAzLjQ4OUwxOC45NzkgNy41NzRMMjQgNy41NzRMMjQgMjRMNS43MDIgMjRBNS43MDIgNS43MDIgMCAwIDEgMCAxOC4yOThMMCA5LjE5MUE1LjcwMiA1LjcwMiAwIDAgMSA1LjcwMiAzLjQ4OVpNOC45MzYgMjEuMTA2TDEyLjM0IDIxLjEwNkwxOC4yMTMgNy4wNjRMMTQuNTUzIDcuMDY0TDEwLjYzOCAxNy4xOTFMNi43MjMgNy4wNjRMMy4wNjQgNy4wNjRaTTE4Ljk3OSAyMS4xMDZMMjIuMDQzIDIxLjEwNkwyMi4wNDMgMTIuMjU1TDE4Ljk3OSAxMi4yNTVaTTE4Ljk3OSAwTDIyLjA0MyAwTDIyLjA0MyAzLjA2NEwxOC45NzkgMy4wNjRaTTIyLjcyMyAwTDI0IDBMMjQgMy4wNjRMMjIuNzIzIDMuMDY0WiIvPjwvc3ZnPgo=)](#requirements)

A [Model Context Protocol](https://modelcontextprotocol.io) server for ViAI
help and Vim script, run by [ViAI](https://github.com/viai-editor/viai)
itself.

It is written in Vim9 script and runs in a ViAI of its own, which talks MCP
on its stdin and stdout with the "mcp" channel mode.  The answers come from
that ViAI: its help files, the help files of the plugins on the
`'runtimepath'` it is given, and what it reports when it reads a script.

## Tools

- `viai_help_search {pattern}`: the help tags that match a Vim regular
  expression, with the help file each is in, at most 50.
- `viai_help_read {tag}`: the help text of a tag, from the tag to the next
  one, at most 300 lines.
- `viai_vimscript_check {path}` or `viai_vimscript_check {source}`: the
  errors that ViAI reports when it reads the script with `:source ++dryrun`,
  which runs nothing in it.

## Requirements

ViAI 1.0.0050 or later, which has the "mcp" channel mode.

## Setup

Put viai.mcp on the `'runtimepath'` of your ViAI for `:help viaimcp` and
`viaimcp#Command()`, with a plugin manager, vim-plug for instance:

```vim
Plug 'viai-editor/viai.mcp'
```

There is no `plugin/` directory in it, so ViAI runs none of it at startup.

The MCP client starts the server with `bin/viaimcp` (`bin\viaimcp.cmd` on
MS-Windows).  It runs `viai` from `$PATH`; `$VIAIMCP_VIM` names another
ViAI.

For Claude Code:

```sh
claude mcp add viaimcp -- /path/to/viai.mcp/bin/viaimcp
```

The server is started with `--clean`, so the plugins of the user are not on
`'runtimepath'`.  `$VIAIMCP_RUNTIMEPATH` gives the `'runtimepath'` to use,
for the help files of the plugins and the scripts imported by name; nothing
on it is run.  Get the value from your ViAI with your vimrc, on Unix:

```sh
claude mcp add viaimcp \
    -e VIAIMCP_RUNTIMEPATH="$(viai -u ~/.vimrc -i NONE -es \
    -c 'call writefile([&rtp], "/dev/stdout")' -c 'qa!')" \
    -- /path/to/viai.mcp/bin/viaimcp
```

`-es` reads no vimrc, thus `-u` names it.  After changing the plugins, run
`claude mcp remove viaimcp` and the command again.  On other systems get the
value with `:echo &rtp` in your ViAI.

See `:help viaimcp` for the details.

## Tests

```sh
test/run
VIMPROG=/path/to/viai test/run
```

## License

The Vim license, see `LICENSE`.
