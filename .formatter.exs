# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    assert_task: 1,
    assert_task_count: 1,
    refute_task: 1
  ],
  export: [
    locals_without_parens: [
      assert_task: 1,
      assert_task_count: 1,
      refute_task: 1
    ]
  ]
]
