defmodule PigLatin do
  @vowels ["a", "e", "i", "o", "u"]
  @vowel_combos ["yt", "xr", "yd", "xb"]
  @consonant_combos ["squ", "qu"]

  @doc """
  Given a `phrase`, translate it a word at a time to Pig Latin.

  Words beginning with consonants should have the consonant moved to the end of
  the word, followed by "ay".

  Words beginning with vowels (aeiou) should have "ay" added to the end of the
  word.

  Some groups of letters are treated like consonants, including "ch", "qu",
  "squ", "th", "thr", and "sch".

  Some groups are treated like vowels, including "yt" and "xr".
  """
  @spec translate(phrase :: String.t()) :: String.t()
  def translate(phrase) do
    phrase
      |> String.split()
      |> Enum.map(&translate_word(&1))
      |> Enum.join(" ")
  end

  def translate_word(<<v :: binary-size(1)>> <> rest) when v in @vowels, do: v <> rest <> "ay"
  def translate_word(word) do
    new_word = cond do
      String.starts_with?(word, @vowel_combos) -> word
      String.starts_with?(word, @consonant_combos) -> @consonant_combos
          |> Enum.find(&String.starts_with?(word, &1))
          |> (&String.slice(word, String.length(&1), String.length(word)) <> &1).()
      String.first(word) not in @vowels -> word
          |> String.graphemes()
          |> Enum.split_while(&(&1 not in @vowels))
          |> (fn {prefix, suffix} -> Enum.concat(suffix, prefix) end).()
          |> Enum.join()
      true -> word
    end

    new_word <> "ay"
  end
end
