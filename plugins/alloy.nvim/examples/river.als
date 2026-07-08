// Sample Alloy 6 model for smoke-testing the tree-sitter grammar.
module example/river

open util/ordering[State] as ord

abstract sig Object {}
sig Farmer, Fox, Chicken, Grain extends Object {}

sig State {
  var near: set Object,
  var far:  set Object,
}

fact Partition {
  all s: State | s.near & s.far = none
  all s: State | s.near + s.far = Object
}

pred safe[s: State] {
  // chicken can't be alone with fox or grain
  not (Chicken in s.near and Fox in s.near and Farmer not in s.near)
  not (Chicken in s.far  and Fox in s.far  and Farmer not in s.far)
}

pred step[s, s': State] {
  some x: Object | x in s.near iff x not in s'.near
  safe[s']
}

fact Transitions {
  always (some s: State | step[s, s'])
}

assert ChickenSurvives {
  always (Chicken in State.near + State.far)
}

run safe for 5 but exactly 1 Farmer
check ChickenSurvives for 4
