defmodule Markdown do
  @doc """
    Parses a given string with Markdown syntax and returns the associated HTML for that string.

    ## Examples

    iex> Markdown.parse("This is a paragraph")
    "<p>This is a paragraph</p>"

    iex> Markdown.parse("#Header!\n* __Bold Item__\n* _Italic Item_")
    "<h1>Header!</h1><ul><li><em>Bold Item</em></li><li><i>Italic Item</i></li></ul>"
  """

  # Refactor note:
  # changed to a pipeline instead of nested function calls
  @spec parse(String.t()) :: String.t()
  def parse(m) do
    m
    |> String.split("\n")
    # process each line of the mark down text, keeping state for whether a <ul> tag is open to
    # be able to handle it appropriately 
    |> Enum.reduce([ul_open: false, html: ""], fn line, [ul_open: list_open, html: html] ->
      {line_type, processed_line} = line |> process
       
      cond do
        line_type == :list and list_open == false -> [ul_open: true, html:  (html <> "<ul>" <> processed_line)]
        line_type == :list and list_open == true ->  [ul_open: true, html:  (html <> processed_line)]
        line_type != :list and list_open == true ->  [ul_open: false, html: (html <> "</ul>" <> processed_line)]
        true -> [ul_open: list_open, html: (html <> processed_line)]
      end
    end)
    # close the ul tag if it is open after the last line
    |> (fn 
      [ul_open: true, html: html] -> html <> "</ul>"
      [ul_open: _,    html: html] -> html
    end).()
  end

  # Refactor note:
  # Changed the complicated if-else control to a case control
  defp process(t) do
    case String.first(t) do
      "#" -> {:header,    parse_header_md_level(t)}
      "*" -> {:list,      parse_list_md_level(t)}
       _  -> {:paragraph, parse_paragraph(t)}
    end
  end

  # Refactor note:
  # changed from String.split/1 to String.split/3 to remove an extra Enum.join/2 call
  # changed to string interpolation
  defp parse_header_md_level(hwt) do
    [h | t] = String.split(hwt, " ", parts: 2)
    
    {"#{String.length(h)}", t}
    |>enclose_with_header_tag()
  end

  # Refactor note:
  # String concatenation to string interpolation, changed to pipeline
  defp parse_list_md_level(l) do
    l
    |> String.trim_leading("* ")
    |> String.split()
    |> join_words_with_tags()
    |> enclose_with_li_tag()
  end
  
  defp parse_paragraph(t) do
    t
    |> String.split()
    |> join_words_with_tags()
    |> enclose_with_paragraph_tag()
  end

  # Refactor note:
  # Created enclose with li tag for consistency with previous design
  defp enclose_with_li_tag(t), do: "<li>#{t}</li>"

  # Refactor note:
  # String concatenation to string interpolation
  defp enclose_with_header_tag({hl, htl}), do: "<h#{hl}>#{htl}</h#{hl}>"

  # Refactor note:
  # Moved join words function call to outer call to keep this function simple
  defp enclose_with_paragraph_tag(t), do: "<p>#{t}</p>"

  # Refactor note:
  # pipe operator for clarity, map_join instead of map then successive join call
  defp join_words_with_tags(t) do
    t
    |> Enum.map_join(" ", fn w -> replace_md_with_tag(w) end)
  end

  # declare the regex match and replace rule pairs
  @md_to_html_tags [
    {~r/^__([^_])/, "<strong>\\1"},
    {~r/([^_])__$/, "\\1</strong>"},
    {~r/^_([^_])/, "<em>\\1"},
    {~r/([^_])_$/, "\\1</em>"}
  ]

  # Refactor note:
  # While could use overloading to detect the prefix notation 
  # (eg. __ <> "w" or _ <> "w") I chose to Regex and String.replace just 
  # to make it consistent since overloading can't match to an unknown string 
  # on the left side (eg. "w" <> "__")
  defp replace_md_with_tag(w) do
    @md_to_html_tags
    |> Enum.reduce(w, fn {rule, replace}, w -> String.replace(w, rule, replace) end)
  end

  defp patch(l) do
    String.replace_suffix(
      String.replace(l, "<li>", "<ul><li>", global: false),
      "</li>",
      "</li></ul>"
    )
  end
end
