defmodule Svalinn.Token do
  @callback __token_parse__(map) :: map
  @callback __token_load__(map, Keyword.t()) :: map

  defmacro __using__(opts \\ []) do
    base = if opts[:type], do: base(opts[:type], Keyword.delete(opts, :type))

    quote do
      @behaviour unquote(__MODULE__)
      unquote(base)
    end
  end

  ### Base Type ###
  @base_types %{
    security: __MODULE__.Security,
    data: __MODULE__.Data,
    lookup: __MODULE__.Lookup
  }

  defp base(type, opts) do
    if base = @base_types[type], do: quote(do: use(unquote(base), unquote(opts)))
  end
end
