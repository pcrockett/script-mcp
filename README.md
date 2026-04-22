# script-mcp

an extremely minimal MCP server that exposes scripts to your AI agent.

currently only in the proof-of-concept stage. lightly tested, works.

## initial setup

- install nushell
- download the [script-mcp](./script-mcp) file wherever you like, and make it executable
- configure the MCP server with your agent. for opencode that looks like:
  ```json
  {
    "$schema": "https://opencode.ai/config.json",
    "mcp": {
      "script": {
        "enabled": true,
        "type": "local",
        "command": ["./script-mcp"]
      }
    }
  }
  ```
- now create a `tools` directory and start writing your tool scripts there.

## tools

it's easy to create your own tools. just add executable files to the `tools` directory.
requirements for each tool:

- the tool should parse arguments from stdin as JSON
- when the tool is finished, it should write results to stdout (JSON optional)
- executing your tool with a single parameter `discover` should cause your tool to
  output JSON metadata about the tool (including its description and expected inputs)

tools can be written in any language, and it doesn't matter if it's a scripting language
or a compiled executable. here's an example `echo` tool written in nushell:

```nushell
#!/usr/bin/env -S nu --stdin

# echo a message back to your AI agent
def main [] {
  let payload = $in | from json
  $payload.message | print
}

def "main discover" [] {
  {
    description: "Echo chamber"
    inputSchema: {
      type: "object"
      properties: {
        message: {
          type: "string"
          description: "The message you want to echo"
        }
      }
      required: [message]
    }
  } | to json --raw | print
}
```
