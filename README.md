# vim9mcp

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

The MCP client starts the server with `bin/vim9mcp` (`bin\vim9mcp.cmd` on
MS-Windows).  It runs `viai` from `$PATH`; `$VIM9MCP_VIM` names another
ViAI.

For Claude Code:

```sh
claude mcp add vim9mcp -- /path/to/vim9mcp/bin/vim9mcp
```

The server is started with `--clean`, so the plugins of the user are not on
`'runtimepath'`.  `$VIM9MCP_RUNTIMEPATH` gives the `'runtimepath'` to use,
for the help files of the plugins and the scripts imported by name; nothing
on it is run.  Get the value with `:echo &rtp` in your ViAI:

```sh
claude mcp add vim9mcp -e VIM9MCP_RUNTIMEPATH=... \
    -- /path/to/vim9mcp/bin/vim9mcp
```

See `:help vim9mcp` for the details.

## Tests

```sh
test/run
VIMPROG=/path/to/viai test/run
```

## License

The Vim license, see `LICENSE`.
