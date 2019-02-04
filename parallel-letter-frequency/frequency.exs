defmodule Frequency do
  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map
  def frequency(texts, workers) do

  # Create stream from strings
  # Send Streams to Task
  #   Each task creates a map
  # Merge the maps
  #   Merge.map/3
  end
end
