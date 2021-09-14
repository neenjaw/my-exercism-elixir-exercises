defmodule Username do
  def sanitize(username) do
    Enum.map(username, fn x -> x end)
  end
end
