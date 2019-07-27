defmodule Bob do
  def hey(input) do
    cond do
      blank? input ->
        "Fine. Be that way!"

      question?(input) and capitals?(input) and letters?(input) ->
        "Calm down, I know what I'm doing!"

      question?(input) ->
        "Sure."

      capitals?(input) and letters?(input) ->
        "Whoa, chill out!"

      true ->
        "Whatever."
    end
  end

  defp question?(input) do
    String.ends_with?(input, "?")
  end

  defp capitals?(input) do
    input == String.upcase(input)
  end

  defp blank?(input) do
    "" == String.trim(input)
  end

  defp letters?(input) do
    String.upcase(input) != String.downcase(input)
  end
end
