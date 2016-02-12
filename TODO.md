# Defining schemas:

There are many ways to tackle this, let's first look at how we can rearrange the primitives we already have from porting the JS reference implementation.

https://www.npmjs.com/package/graphql-schema

# Considerations

- GraphQL IDL syntax is preferable but should convert to current syntax
  - this could be managed by macros or even changing the type def parser
- Can handle recursive type deps (ie friends of friends)
- Can add custom complex types / scalars easily
- How to define/implement Interfaces?
- Union Types
- Reusability / sharing of types across modules / schemas / projects


Module syntax is nice because you could either
1. use existing syntax (baseline)
2. use some elixir macros
3. use straight graphql inline + metadata
4. grab graphql off disk + metadata

should be able to mix and match

This is mostly inspired from Ecto, but instead of relation schemas, defining GraphQL types:

```elixir
defmodule MyApp.Types.User do
  use GraphQL.Type, path: "/blah/**/*.graphql"

  # use GraphQL.Type.Scalar

  # Q: Is it necessary to repeat the "User" string or
  # can it be grabbed from the module name __MODULE__?
  # A: Can reference the User module we're in directly

  type "User" do
    description: "A User of the system"
    # graphql_file: leave out graphql type def and it picks it up from disk
    graphql:
      """
      type User {
        id: ID!
        name: String!
      }
      """
    # or
    schema: %ObjectType{}
    # resolves should be separate or at least separable from the
    resolve: fn() -> end
  end
end

# or

defmodule MyApp.Types do
  use GraphQL.Type # expose all required fns

  defmodule User do
    # or be specific about current type?
    # use GraphQL.Type.ObjectType

    # metadata is graphql type system agnostic
    @description "A user of the system"

    type User do
      # name is given by the module name except what if you want to define more types
      #
      args ...
      field :blah

    end
  end
end

defmodule MyApp.Schema do

  def schema do
    %Schema{
      query: query,
      mutation: mutation,
      subscription: subscription
    }
  end
end
```

Like ecto:

```elixir
defmodule HelloPhoenix.Contact do
  use Ecto.Model

  schema "contacts" do
    field :name
    field :phone

    timestamps
  end
end
```

Something like `ex_machina` does factories:

```elixir
defmodule MyApp.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: MyApp.Repo

  # without Ecto
  use ExMachina

  def factory(:user) do
    %User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
    }
  end

  def factory(:article) do
    %Article{
      title: "Use ExMachina!",
      # associations are inserted when you call `create`
      comments: [build(:comment)],
      author: build(:user),
    }
  end

  def factory(:comment) do
    %Comment{
      text: "It's great!",
      article: build(:article),
    }
  end
end
```



```elixir
defmodule MyApp.Types do

  defmodule User do
    use GraphQL.Type # expose all required fns

    @description "A user of the system"
    resolve (args) do

    end
  end
end
```

```elixir
defmodule MyApp.Types do
  load_graphql(file_glob)
  # or
  @graphql_load_path path/glob

  # types on disk are defined as modules under this one (ie MyApp.Types.*)

  # full version
  @type_map %{
    User: %{
      resolve: fn -> ... end | {mod, fun}
      fields: %{
        field_name: %{
          resolve: fn -> ... end | {mod, fun}
        }
      }
      metadata: %{ # metadata_overrides
        description: etc,
        ...
      }
    },
    # shortest option
    Ship: {Mod, fun},

    # or
    "Film": {Mod, fun},
    "Ship.field.sub_field": {Mod, fun}
    # etc

  }

  # define the old way
  defmodule User do
    %ObjectType{
      name: "User",
      description: "",
    }
  end

  @resolve User, {mod, fun}
  @resolve User, {mod, fun}
end
```

```elixir
Schema = import_graphql_schema SCHEMA_PATH

defresolvers Schema.User do
	%{
		type|resolve: fn (...) ->
		fields: %{
			foo: fn (...) ->
		}
	}
end
```

```elixir
defmodule MyApp.Types do
  import_graphql_schema SCHEMA_PATH

  def(module|type|resolve) User do
  	%{
  		type: fn (...) ->
  		fields: %{
  			foo: fn (...) ->
  		}
  	}
  end
end
Schema =

```
