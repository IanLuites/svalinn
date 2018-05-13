defmodule Svalinn.Token.Data do
  @moduledoc ~S"""

  """

  @doc @moduledoc
  defmacro __using__(_opts \\ []) do
    quote do
      @impl Svalinn.Token
      def __token_parse__(token = %{}), do: Map.from_struct(token)

      @impl Svalinn.Token
      def __token_load__(token, _) do
        data = for {key, val} <- token, into: %{}, do: {String.to_atom(key), val}

        struct(__MODULE__, data)
      end
    end
  end
end
