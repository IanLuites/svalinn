defmodule Svalinn.Token.Lookup do
  @moduledoc ~S"""

  """

  @doc @moduledoc
  defmacro __using__(opts \\ []) do
    struct = opts[:struct] || raise "Need to set lookup struct."

    tokenizer =
      if id = opts[:id] do
        quote do
          defimpl Svalinn.Tokenize, for: unquote(struct) do
            def token(s = %unquote(struct){}),
              do: struct(unquote(__CALLER__.module), id: Map.fetch!(s, unquote(id)))
          end
        end
      else
        quote do
          defimpl Svalinn.Tokenize, for: unquote(struct) do
            def token(s = %unquote(struct){}),
              do: struct(unquote(__CALLER__.module), id: unquote(__CALLER__.module).id(s))
          end
        end
      end

    load =
      if lookup = opts[:lookup] do
        quote do: def(__token_load__(id, _), do: unquote(lookup).(id))
      else
        quote do: def(__token_load__(id, _), do: lookup(id))
      end

    quote do
      @enforce_keys [:id]
      defstruct @enforce_keys

      @impl Svalinn.Token
      def __token_parse__(%{id: id}), do: id

      @impl Svalinn.Token
      unquote(load)

      unquote(tokenizer)
    end
  end
end
