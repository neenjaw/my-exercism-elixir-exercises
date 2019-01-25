defmodule Markdown do
  @initial_parsing_state [ul_open: false, html: ""]

  # Refactor note:
  # 1. changed to a pipeline instead of nested function calls
  # 2. Instead of Split -> map -> join, changed to a reduce so that could use the state
  #     of the previous lines in determining the correct handling of the current line.
  # 
  #     For example, previously a header or paragraph line followed by a list followed 
  #     by anything then another list would not produce valid html since the patch/1 function
  #     would only prepend <ul> to the first <li> and append </ul> to the last </li> which in
  #     the case of multiple lists, would make: <ul><li>a</li><p>paragraph</p><li>b</li></ul>
  #
  #     `Markdown.parse("# Header\n* Item A\nparagraph\n* Item 1")` now correctly produces
  #     "<h1>Header</h1><ul><li>Item A</li></ul><p>paragraph</p><ul><li>Item 1</li></ul>"

  @doc """
    Parses a given string with Markdown syntax and returns the associated HTML for that string.

    ## Examples

    iex> Markdown.parse("This is a paragraph")
    "<p>This is a paragraph</p>"

    iex> Markdown.parse("#Header!\n* __Bold Item__\n* _Italic Item_")
    "<h1>Header!</h1><ul><li><em>Bold Item</em></li><li><i>Italic Item</i></li></ul>"
  """
  @spec parse(String.t()) :: String.t()
  def parse(m) do
    m
    |> String.split("\n")
    |> Enum.reduce(@initial_parsing_state, &parse_line/2)
    |> parse_final_state
  end

  # parse a line of the mark down text, using the state previous line's state for whether a 
  #   <ul> tag is open to be able to close it with </ul> appropriately 
  defp parse_line(line, [ul_open: list_open?, html: html]) do
    {line_type, line_html} = line |> handle_line
       
    case {line_type, list_open?} do
      {:li, false} -> [ul_open: true,  html: (html <> "<ul>" <> line_html)]
      {:li, true}  -> [ul_open: true,  html: (html <> line_html)]
      {_,   true}  -> [ul_open: false, html: (html <> "</ul>" <> line_html)]
      {_,   open}  -> [ul_open: open,  html: (html <> line_html)]
    end
  end

  defp parse_final_state([ul_open: list_open?, html: html]) do
    case list_open? do
      true -> html <> "</ul>"
      _    -> html
    end
  end

  # Refactor note:
  # Changed the complicated if-else control to a case control
  # Changed the return value to a tuple with an atom indicating the line type to
  #   faciliate proper parsing
  defp handle_line(line) do
    case String.first(line) do
      "#" -> {:h,  parse_header_md_level(line)}
      "*" -> {:li, parse_list_md_level(line)}
       _  -> {:p,  parse_paragraph(line)}
    end
  end

  # Refactor note:
  # Changed from String.split/1 to String.split/3 to remove an extra Enum.join/2 call
  # Changed to string interpolation
  defp parse_header_md_level(header_line) do
    [hashes | title] = String.split(header_line, " ", parts: 2)
    
    enclose_contents_with_tag(title, "h#{String.length(hashes)}")
  end

  # Refactor note:
  # Changed to pipeline, refactored the tag enclosure to separate function
  defp parse_list_md_level(list_line) do
    list_line
    |> String.trim_leading("* ")
    |> String.split()
    |> join_words_with_tags()
    |> enclose_contents_with_tag("li")
  end
  
  defp parse_paragraph(paragraph_line) do
    paragraph_line
    |> String.split()
    |> join_words_with_tags()
    |> enclose_contents_with_tag("p")
  end

  # Refactor note:
  # Created enclose with tag for consistency with previous design but added second parameter
  #   so that could remove similar but distinct functions for each tag type
  # String concatenation to string interpolation
  defp enclose_contents_with_tag(contents, tag), do: "<#{tag}>#{contents}</#{tag}>"

  # Refactor note:
  # pipe operator for clarity, map_join instead of map then successive join call
  defp join_words_with_tags(words) do
    words
    |> Enum.map_join(" ", fn word -> replace_md_with_tag(word) end)
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
  # (eg. "__" <> w or "_" <> w) I chose to Regex and String.replace just 
  # to make it consistent since overloading can't match to an unknown string 
  # on the left side (eg. w <> "__")
  defp replace_md_with_tag(word) do
    @md_to_html_tags
    |> Enum.reduce(word, fn {rule, replace}, word -> String.replace(word, rule, replace) end)
  end
end
