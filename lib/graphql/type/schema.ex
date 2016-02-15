defmodule GraphQL.Schema do
  defstruct query: nil, mutation: nil, types: []

  def reduce_types(type) do
    r=%{}
    |> reduce_types(type.query)
    |> reduce_types(type.mutation)
    |> reduce_types(GraphQL.Type.Introspection.Schema.type)
    Map.keys(r)
    r
  end

  def reduce_types(typemap, %GraphQL.Type.List{ofType: list_type}) do
    reduce_types(typemap, list_type)
  end

  def reduce_types(typemap, %GraphQL.Type.NonNull{ofType: list_type}) do
    reduce_types(typemap, list_type)
  end

  def reduce_types(typemap, %GraphQL.Type.Interface{} = type) do
    Map.put(typemap, type.name, type)
  end

  def reduce_types(typemap, %GraphQL.Type.ObjectType{} = type) do
    if Map.has_key?(typemap, type.name) do
      typemap
    else
      typemap = Map.put(typemap, type.name, type)
      thunk_fields = GraphQL.Execution.Executor.maybe_unwrap(type.fields)
      Enum.reduce(thunk_fields, typemap, fn({_,fieldtype},map) ->
        reduce_types(map, fieldtype.type)
      end)
    end
  end

  def reduce_types(typemap, type_module) when is_atom(type_module) do
    type = apply(type_module, :type, [])
    # IO.inspect name: type.name, type: type
    Map.put(typemap, type.name, type)
  end

  def reduce_types(typemap, %{name: name} = type) do
    Map.put(typemap, name, type)
  end

  def reduce_types(typemap, nil) do
    typemap
  end
end
