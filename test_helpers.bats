
#!/usr/bin/env bats

setup() {
  source "$BATS_TEST_DIRNAME"/_test_helpers.sh
}

teardown() {
  :
}

@test "my_func:stdout mocks multiple stdout values" {
  mock_function my_func
  my_func:stdout "a" "1"
  my_func:stdout "b" "2"

  run my_func "a"
  [ "$status" == 0 ]
  [ "$output" == "1" ]
  run my_func "b"
  [ "$status" == 0 ]
  [ "$output" == "2" ]
}

@test "my_func:stdout mocks multiple stdout value for n args" {
  mock_function my_func
  my_func:stdout "1"
  my_func:stdout "a" "b" "2"

  run my_func
  [ "$status" == 0 ]
  [ "$output" == "1" ]
  run my_func "a" "b"
  [ "$status" == 0 ]
  [ "$output" == "2" ]
}

@test "exp evaluates condition" {
  run exp [ 1 == 1 ]
  [ "$status" == 0 ]

  run exp [ 0 == 1 ]
  [ "$status" == 1 ]
}

@test "exp evaluates condition with spaces" {
  run exp [ "a b" == "a b" ]
  [ "$status" == 0 ]

  run exp [ "a b" == "c d" ]
  [ "$status" == 1 ]
}

@test "exp error on conditions with double brackets" {
  run exp [[ "a b" == "a b" ]]

  [ "$status" == 1 ]
  [ "$output" == "Error: 'exp' helper does not yet work with '[[' syntax." ]
}

@test "exp outputs expected condition on failure" {
  run exp [ 1 == 2 ]
  [ "$output" == "Expected: [ 1 == 2 ]" ]
}

@test "exp doesn't output expected condition on success" {
  run exp [ 1 == 1 ]
  [ "$output" == "" ]
}