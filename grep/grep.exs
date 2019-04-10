defmodule Grep do
  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flags, files) do
    parsed_flags =
      Grep.Flags.parse(flags)

    match_function =
      get_match_function(pattern, parsed_flags)

    do_grep(match_function, parsed_flags, files)
  end

  defp do_grep(match_function, flags, files_to_read, matches \\ [])

  defp do_grep(_match_function, flags, [], matches), do: matches

  defp do_grep(match_function, flags, [file | rest], matches) do
    file_matches =
      process_file(file, match_function, flags)


  end

  defp process_file(file, match_function, flags) do
    "./#{file}"
    |> File.stream!()
    |> Stream.with_index(1)
    |> Stream.map(fn {line, line_number} -> process_line(line, line_number, match_function))
  end

  defp process_line(line, match_function) do

  end

  def get_match_function(pattern, flags) do
    options =
      "u"
      |> (fn o, flags -> if flags.case_insensitive, do: o <> "i", else: o end).(flags)

    pre_compiled_pattern =
      pattern
      |> (fn p, flags -> if flags.match_whole_line, do: "^#{p}$", else: p end).(flags)

    {:ok, compiled_pattern} =
      Regex.compile(pre_compiled_pattern, options)

    # use a closure to get the match function
    match_function =
      fn line ->
        String.match?(line, compiled_pattern)
      end

    # use a closure to invert the match
    case flags.invert_match do
      false -> match_function
      true  -> (fn line -> not match_function.(line) end)
    end
  end

end

defmodule Grep.Flags do
  defstruct [
    print_line_numbers: false,
    print_file_names: false,
    case_insensitive: false,
    invert_match: false,
    match_whole_line: false
  ]

  def parse(flags) when is_list(flags), do: parse_list(flags)

  defp parse_list(list, map \\ %Grep.Flags{})
  defp parse_list([], map), do: map
  defp parse_list(["-n" | rest], map), do: parse_list(rest, %{map | print_line_numbers: true})
  defp parse_list(["-l" | rest], map), do: parse_list(rest, %{map | print_file_names: true})
  defp parse_list(["-i" | rest], map), do: parse_list(rest, %{map | case_insensitive: true})
  defp parse_list(["-v" | rest], map), do: parse_list(rest, %{map | invert_match: true})
  defp parse_list(["-x" | rest], map), do: parse_list(rest, %{map | match_whole_line: true})
  defp parse_list([opt | rest], map), do: raise ArgumentError, "Unknown option '#{opt}'"
end

defmodule Grep.File do
  @enforce_keys [:filename]
  defstruct [:filename, matches: []]
end

defmodule Grep.Match do
  @enforce_keys [:line_number, :line_match]
  defstruct [:line_number, :line_match]
end
