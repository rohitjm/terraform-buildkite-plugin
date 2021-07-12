#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following line to debug stub failures
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

export BUILDKITE_PLUGIN_TERRAFORM_DELEGATE_ROLE="buildkite-agent-delegate-role"
export BUILDKITE_PIPELINE_SLUG="test-repo-a"
export BUILDKITE_BUILD_NUMBER="105"

@test "Scope everyone passes" {
  export BUILDKITE_BUILD_CREATOR_TEAMS="everyone:orchestration:orchestration-delivery"
  export BUILDKITE_PLUGIN_TERRAFORM_DELEGATE_ACCOUNT_ID="0123456"
  export BUILDKITE_COMMAND="tf_plan"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Permission scoped to everyone."
}

@test "Scope happy path" {
  export BUILDKITE_BUILD_CREATOR_TEAMS="orchestration-delivery"
  export BUILDKITE_PLUGIN_TERRAFORM_DELEGATE_ACCOUNT_ID="0123456"
  export BUILDKITE_COMMAND="tf_plan"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Permission scoped to user."

}

@test "Fails on no team" {
  export BUILDKITE_BUILD_CREATOR_TEAMS="not-orchestration-delivery"
  export BUILDKITE_PLUGIN_TERRAFORM_DELEGATE_ACCOUNT_ID="0123456"
  export BUILDKITE_COMMAND="tf_plan"
  export AGE_IN_SECONDS=10
  export CACHE_MAX_AGE=100

  run "$PWD/hooks/pre-command"

  assert_failure
  assert_output --partial "Permission not scoped to user."
}
