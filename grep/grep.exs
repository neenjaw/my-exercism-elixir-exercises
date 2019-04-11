defmodule Grep.File do
  @moduledoc """
  A struct for holding the file being searched and its matches
  """

  @enforce_keys [:file_name]
  defstruct [:file_name, matches: []]
end

defmodule Grep.Match do
  @moduledoc """
  A struct for holding the line number and line of a match in a file
  """

  @enforce_keys [:line_number, :line]
  defstruct [:line_number, :line]
end

defmodule Grep.Flags do
  @moduledoc """
  A Struct for creating and holding flag data
  """

  defstruct [
    print_line_numbers: false,
    print_file_names: false,
    print_only_file_names: false,
    case_insensitive: false,
    invert_match: false,
    match_whole_line: false
  ]

  @doc """
  A function which takes a parameter, and selects the proper do_function to parse the list
  based on the type.
  """
  def parse(flags) when is_list(flags), do: flags |> parse_list #|> check_inconsistent_flags

  @doc """
  Parses the flags from a list of flags
  """
  defp parse_list(list, map \\ %Grep.Flags{})
  defp parse_list([], map), do: map
  defp parse_list(["-n" | rest], map), do: parse_list(rest, %{map | print_line_numbers: true})
  defp parse_list(["-l" | rest], map), do: parse_list(rest, %{map | print_only_file_names: true})
  defp parse_list(["-i" | rest], map), do: parse_list(rest, %{map | case_insensitive: true})
  defp parse_list(["-v" | rest], map), do: parse_list(rest, %{map | invert_match: true})
  defp parse_list(["-x" | rest], map), do: parse_list(rest, %{map | match_whole_line: true})
  defp parse_list([opt | rest], map), do: raise ArgumentError, "Unknown option '#{opt}'"

  @doc """
  A function to check if inconsistent flags are selected.
  """
  defp check_inconsistent_flags(%Grep.Flags{print_only_file_names: true, print_line_numbers: true}),
    do: raise ArgumentError
  defp check_inconsistent_flags(map), do: map
end

defmodule Grep do
  @moduledoc """
  A Grep-like function which takes a pattern, flags, and a list of files to perform a match and then
  return results
  """

  @doc """
  The main function of the module, calling private functions in sequence to return the results
  """
  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flag_list, files) do
    with safe_pattern <- Regex.escape(pattern),
         flags        <- Grep.Flags.parse(flag_list),
         multi_flags  <- %{flags | print_file_names: (length(files) > 1)},
         match_func   <- get_match_function(pattern, multi_flags),
         matches      <- do_grep(match_func, multi_flags, files)
    do
      format_results(matches, multi_flags)
    end
  end

  @doc """
  A recursive function with recurses through the list of files.  Processing them in sequence.
  """
  defp do_grep(match_function, flags, files_to_read, matches \\ [])

  defp do_grep(_match_function, flags, [], matches), do: matches |> Enum.reverse

  defp do_grep(match_function, flags, [file | rest], matches) do
    file_matches =
      process_file(file, match_function, flags)

    file_record =
      %Grep.File{file_name: file, matches: file_matches}

    do_grep(match_function, flags, rest, [file_record | matches])
  end

  @doc """
  Function with takes a filename, then opens a File.Stream to process the file and look
  for matches based on the match_function and flags specified
  """
  defp process_file(file, match_function, flags) do
    "./#{file}"
    |> File.stream!()
    |> Stream.with_index(1)
    |> Stream.map(fn {line, line_number} ->
      process_line(line, line_number, match_function)
    end)
    |> Stream.filter(fn
      %Grep.Match{} -> true
      _ -> false
    end)
    |> Enum.to_list
  end

  @doc """
  Function which takes the line and line_number, returns either a %Grep.Match{} or :no_match
  """
  defp process_line(line, line_number, match?) do
    if match?.(line) do
      %Grep.Match{line_number: line_number, line: line}
    else
      :no_match
    end
  end

  @doc """
  Based on the pattern, flags, builds a regular expression for searching the line of the file.
  """
  defp get_match_function(pattern, flags) do
    options =
      "u"
      |> (fn o, flags -> if flags.case_insensitive, do: o <> "i", else: o end).(flags)

    pattern_source =
      pattern
      |> (fn p, flags -> if flags.match_whole_line, do: "^#{p}$", else: p end).(flags)

    {:ok, compiled_pattern} =
      Regex.compile(pattern_source, options)

    # use a closure to get the match function
    match_function =
      fn line ->
        String.match?(line, compiled_pattern)
      end

    # use a closure to invert the match if specified
    case flags.invert_match do
      false -> match_function
      true  -> (fn line -> not match_function.(line) end)
    end
  end

  @doc """
  Formats the results based on flags specified
  """
  defp format_results(matches, flags = %Grep.Flags{print_only_file_names: true}) do
    matches
    |> Enum.filter(fn file -> if file.matches == [], do: false, else: true end)
    |> Enum.map_join(fn file -> file.file_name <> "\n" end)
  end
  defp format_results(matches, flags = %Grep.Flags{}) do
    Enum.map_join(matches, fn file ->
      Enum.map_join(file.matches, &match_to_string(&1, file.file_name, flags))
    end)
  end

  @doc """
  Formats a %Grep.Match{} into a string.
  """
  defp match_to_string(match, file_name, flags) do
    prepend_file_name = fn str ->
      if flags.print_file_names do
        "#{file_name}:#{str}"
      else
        str
      end
    end

    prepend_line_number = fn str ->
      if flags.print_line_numbers do
        "#{match.line_number}:#{str}"
      else
        str
      end
    end

    # build the string
    match.line
    |> prepend_line_number.()
    |> prepend_file_name.()
  end
end
