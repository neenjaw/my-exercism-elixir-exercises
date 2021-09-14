defmodule Helpers do
  defmacro one_of_or_unknown(name, list) do
    {attr_name, _, _} = name
    expanded_list = Macro.expand(list, __CALLER__)

    type =
      case [:unknown | expanded_list] do
        [only] ->
          only

        [last, prev | rest] ->
          Enum.reduce(rest, {:|, [], [prev, last]}, &{:|, [], [&1, &2]})
      end

    quote do
      @type unquote(name) :: unquote(type)
      def unquote(attr_name)(), do: unquote(expanded_list)
    end
  end
end
