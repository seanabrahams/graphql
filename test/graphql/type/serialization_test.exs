defmodule GraphQL.Lang.Type.SerializationTest do
  use ExUnit.Case, async: true
  import GraphQL.Types

  test "serializes output int" do
    assert 1 == serialize(%GraphQL.Type.Int{}, 1)
    assert 0 == serialize(%GraphQL.Type.Int{}, 0)
    assert -1 == serialize(%GraphQL.Type.Int{}, -1)
    assert 0 == serialize(%GraphQL.Type.Int{}, 0.1)
    assert 1 == serialize(%GraphQL.Type.Int{}, 1.1)
    assert -1 == serialize(%GraphQL.Type.Int{}, -1.1)
    #assert 100000 == serialize(%GraphQL.Type.Int{}, 1e5)
    assert nil == serialize(%GraphQL.Type.Int{}, 9876504321)
    assert nil == serialize(%GraphQL.Type.Int{}, -9876504321)
    #assert nil == serialize(%GraphQL.Type.Int{}, 1e100)
    #assert nil == serialize(%GraphQL.Type.Int{}, -1e100)
    assert -1 == serialize(%GraphQL.Type.Int{}, "-1.1")
    assert nil == serialize(%GraphQL.Type.Int{}, "one")
    assert 0 == serialize(%GraphQL.Type.Int{}, false)
    assert 1 == serialize(%GraphQL.Type.Int{}, true)
  end
end
