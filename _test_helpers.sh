#!/usr/bin/env bash

function exp() {
  if [ "$1" == "[[" ]; then
    echo "Error: 'exp' helper does not yet work with '[[' syntax."
    exit 1
  fi

  if ! "$@"; then
    echo "Expected: $@"
    exit 1
  fi
}

function mock_function() {
  local func_name="$1"
  eval "
  unset ${func_name}__last_call
  unset ${func_name}__stubs
  export ${func_name}__called=false
  export ${func_name}__call_count=0
  export ${func_name}__calls=()
  function ${func_name} {
    export ${func_name}__called=true
    export ${func_name}__call_count=\$((${func_name}__call_count+1))
    export ${func_name}__last_call=\"\$*\"
    ${func_name}__calls+=( \"\$${func_name}__last_call\" )

    if [ -n \"\$${func_name}__stubs\" ]; then
      [[ \$${func_name}__stubs =~ .*\"|\$*:\"([^|]*)\"|\".* ]]
      echo -n \"\${BASH_REMATCH[1]}\"
    fi
  }

  function ${func_name}:stdout() {
    local args=\"\${@:1:\$#-1}\" # all parameters except the last
    local out=\"\${!#}\" # last parameter 

    export ${func_name}__stubs=\"\$${func_name}__stubs|\$args:\$out|\"
  }
  "
  export -f ${func_name}
  export -f ${func_name}:stdout
}