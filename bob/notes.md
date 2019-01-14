```elixir
    pattern = :binary.compile_pattern([" ", ",", "?", ";", "."])
    String.split(input, pattern, trim: true)
      |> Enum.join()
      |> String.match?(~r/^\d+$/)
```