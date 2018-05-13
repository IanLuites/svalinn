defmodule Svalinn.Token.Security do
  @moduledoc ~S"""

  """

  @default_random_bytes 128

  @doc @moduledoc
  defmacro __using__(opts \\ []) do
    _bytes = Keyword.get(opts, :bytes, @default_random_bytes)

    quote do
    end
  end
end
