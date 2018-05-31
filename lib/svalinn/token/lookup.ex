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
              do: {:ok, struct(unquote(__CALLER__.module), id: Map.fetch!(s, unquote(id)))}
          end
        end
      else
        quote do
          defimpl Svalinn.Tokenize, for: unquote(struct) do
            def token(s = %unquote(struct){}),
              do: {:ok, struct(unquote(__CALLER__.module), id: unquote(__CALLER__.module).id(s))}
          end
        end
      end

    load =
      if lookup = opts[:lookup] do
        quote do: unquote(lookup).(id)
      else
        quote do: lookup(id)
      end

    quote do
      @enforce_keys [:id]
      defstruct @enforce_keys

      @impl Svalinn.Token
      @spec __token_parse__(map) :: any
      def __token_parse__(%{id: id}), do: id

      @impl Svalinn.Token
      @spec __token_load__(any, any) :: any
      def __token_load__(id, _), do: unquote(load)

      unquote(tokenizer)
    end
  end
end
