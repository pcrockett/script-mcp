#!/usr/bin/env bats

source tests/util.sh

@test 'invalid json -- always -- returns error response' {
  # missing curly brace at end:
  echo '{"method":"foobar","id":"1234"' >requests

  script-mcp <requests >responses 2>errors
  exit_code=$?
  assert_eq ${exit_code} 0 "Exit code should be 0."

  errors="$(cat errors)"
  assert_eq "${errors}" "" "There should be no errors."

  response="$(cat responses)"
  expected_response=$(echo '{
    "jsonrpc": "2.0",
    "id": null,
    "error": {
      "code": -32700,
      "message": "Parse error",
      "data": "Invalid JSON received"
    }
  }' | jq --compact-output)
  assert_eq "${response}" "${expected_response}" "Response does not match expected."
}

@test 'missing id -- always -- returns error response' {
  echo '{
     "method": "foobar"
  }' | jq --compact-output >requests

  script-mcp <requests >responses 2>errors
  exit_code=$?
  assert_eq ${exit_code} 0 "Exit code should be 0."

  errors="$(cat errors)"
  assert_eq "${errors}" "" "There should be no errors."

  response="$(cat responses)"
  expected_response=$(echo '{
    "jsonrpc": "2.0",
    "id": null,
    "error": {
      "code": -32600,
      "message": "Invalid request",
      "data": "Missing required field: \"id\""
    }
  }' | jq --compact-output)
  assert_eq "${response}" "${expected_response}" "Response does not match expected."
}

@test 'missing method -- always -- returns error response' {
  echo '{
     "id": "1234"
  }' | jq --compact-output >requests

  script-mcp <requests >responses 2>errors
  exit_code=$?
  assert_eq ${exit_code} 0 "Exit code should be 0."

  errors="$(cat errors)"
  assert_eq "${errors}" "" "There should be no errors."

  response="$(cat responses)"
  expected_response=$(echo '{
    "jsonrpc": "2.0",
    "id": "1234",
    "error": {
      "code": -32600,
      "message": "Invalid request",
      "data": "Missing required field: \"method\""
    }
  }' | jq --compact-output)
  assert_eq "${response}" "${expected_response}" "Response does not match expected."
}

@test 'unrecognized method -- always -- returns error response' {
  echo '{
     "method": "foobar",
     "id": "1234"
  }' | jq --compact-output >requests

  script-mcp <requests >responses 2>errors
  exit_code=$?
  assert_eq ${exit_code} 0 "Exit code should be 0."

  errors="$(cat errors)"
  assert_eq "${errors}" "" "There should be no errors."

  response="$(cat responses)"
  expected_response=$(echo '{
    "jsonrpc": "2.0",
    "id": "1234",
    "error": {
      "code": -32601,
      "message": "Method not found"
    }
  }' | jq --compact-output)
  assert_eq "${response}" "${expected_response}" "Response does not match expected."
}

@test 'initialize -- no tools -- returns response' {
  echo '{
     "method": "initialize",
     "id": "1234"
  }' | jq --compact-output >requests

  script-mcp <requests >responses 2>errors
  exit_code=$?
  assert_eq ${exit_code} 0 "Exit code should be 0."

  errors="$(cat errors)"
  assert_eq "${errors}" "" "There should be no errors."

  response="$(cat responses)"
  expected_response=$(echo '{
    "jsonrpc": "2.0",
    "id": "1234",
    "result": {
      "protocolVersion": "2024-11-05",
      "capabilities": {
        "tools": {}
      },
      "serverInfo": {
        "name": "script-mcp",
        "version": "0.0.1"
      }
    }
  }' | jq --compact-output)
  assert_eq "${response}" "${expected_response}" "Response does not match expected."
}

@test 'tools/list -- no tools -- returns response' {

  rm -rf tools

  echo '{
     "method": "tools/list",
     "id": "5678"
  }' | jq --compact-output >requests

  script-mcp <requests >responses 2>errors
  exit_code=$?
  assert_eq ${exit_code} 0 "Exit code should be 0."

  errors="$(cat errors)"
  assert_eq "${errors}" "" "There should be no errors."

  response="$(cat responses)"
  expected_response=$(echo '{
    "jsonrpc": "2.0",
    "id": "5678",
    "result": {
      "tools": []
    }
  }' | jq --compact-output)
  assert_eq "${response}" "${expected_response}" "Response does not match expected."
}

@test 'tools/list -- some tools exist -- returns response' {
  echo '{
     "method": "tools/list",
     "id": "5678"
  }' | jq --compact-output >requests

  script-mcp <requests >responses 2>errors
  exit_code=$?
  assert_eq ${exit_code} 0 "Exit code should be 0."

  errors="$(cat errors)"
  assert_eq "${errors}" "" "There should be no errors."

  response="$(cat responses)"
  expected_response=$(echo '{
    "jsonrpc": "2.0",
    "id": "5678",
    "result": {
      "tools": [
        {
          "name": "echo",
          "description": "Echo chamber",
          "inputSchema": {
            "type": "object",
            "properties": {
              "message": {
                "type": "string",
                "description": "The message you want to echo"
              }
            },
            "required": ["message"]
          }
        }
      ]
    }
  }' | jq --compact-output)

  assert_eq "${response}" "${expected_response}" "Response does not match expected."
}

# @test 'tools/call -- no tools -- returns response' {
#   echo '{
#      "method": "tools/call",
#      "id": "abcd"
#   }' | jq --compact-output >requests

#   script-mcp <requests >responses 2>errors
#   exit_code=$?
#   assert_eq ${exit_code} 0 "Exit code should be 0."

#   errors="$(cat errors)"
#   assert_eq "${errors}" "" "There should be no errors."

#   response="$(cat responses)"
#   expected_response=$(echo '{
#     "jsonrpc": "2.0",
#     "id": "abcd",
#     "result": {
#       "foo": "bar"
#     }
#   }' | jq --compact-output)
#   assert_eq "${response}" "${expected_response}" "Response does not match expected."
# }

