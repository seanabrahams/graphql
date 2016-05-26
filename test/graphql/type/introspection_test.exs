defmodule GraphQL.Type.IntrospectionTest do
  use ExUnit.Case, async: true

  import ExUnit.TestHelpers

  alias GraphQL.Schema
  alias GraphQL.Type.ObjectType
  alias GraphQL.Type.String
  alias GraphQL.Type.Input

  defmodule TestSchema do
    def query do
      %ObjectType{
        name: "QueryRoot",
        fields: %{
          onlyField: %{type: %String{}}
        }
      }
    end

    def arg_input_type do
      %Input{
        name: "ArgInput",
        fields: %{
          id: %{type: %String{}},
        }
      }
    end

    def input_type_for_arg_mutation do
      %{
        name: "InputTypeForArgMutation",
        type: %ObjectType{
          name: "InputTypeForArgPayload",
          fields: %{
            id: %{type: %String{}},
          },
        },
        args: %{
          input: %{
            type: %Input{
              name: "InputTypeForArgInput",
              fields: %{
                test_input: %{type: arg_input_type}
              }
            }
          }
        }
      }
    end

    def mutation do
      %ObjectType{
        name: "Mutation",
        fields: %{
          input_type_for_arg: input_type_for_arg_mutation,
        }
      }
    end

    def schema do
      %Schema{
        query: query,
        mutation: mutation,
      }
    end
  end

  test "basic query introspection" do
    # assert_execute
    #   {GraphQL.Type.Introspection.query, TestSchema.schema},
  end

  test "includes input types when input type is an argument to a mutation" do
    assert_introspection_includes_type(TestSchema.schema, TestSchema.arg_input_type)
  end

  @tag :skip # order matters for this... ... hm.
  test "exposes descriptions on types and fields" do
    schema = %Schema{
      query: %ObjectType{
        name: "QueryRoot",
        fields: %{onlyField: %{type: %String{}}}
      }
    }

    query = """
    {
      schemaType: __type(name: "__Schema") {
        name
        description
        fields {
          name,
          description
        }
      }
    }
    """

    assert_execute {query, schema}, %{
      schemaType: %{
        name: "__Schema",
        description:
          """
          A GraphQL Schema defines the capabilities of a
          GraphQL server. It exposes all available types and
          directives on the server, as well as the entry
          points for query, mutation,
          and subscription operations.
          """,
        fields: [
          %{
            name: "types",
            description: "A list of all types supported by this server."
          },
          %{
            name: "queryType",
            description: "The type that query operations will be rooted at."
          },
          %{
            name: "mutationType",
            description: "If this server supports mutation, the type that mutation operations will be rooted at."
          },
          %{
            name: "subscriptionType",
            description: "If this server support subscription, the type that subscription operations will be rooted at.",
          },
          %{
            name: "directives",
            description: "A list of all directives supported by this server."
          }
        ]
      }
    }
  end
end
