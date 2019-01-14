defmodule SpaceAge do
  @type planet ::
          :mercury
          | :venus
          | :earth
          | :mars
          | :jupiter
          | :saturn
          | :uranus
          | :neptune

  @doc """
  Return the number of years a person that has lived for 'seconds' seconds is
  aged on 'planet'.
  """
  @spec age_on(planet, pos_integer) :: float
  def age_on(planet, seconds) do
    case planet do
      # planet -> seconds / mm / hh / dd / y
      :mercury -> seconds / 60 / 60 / 24 / 87.969
      :venus   -> seconds / 60 / 60 / 24 / 224.701
      :earth   -> seconds / 60 / 60 / 24 / 365.25
      :mars    -> seconds / 60 / 60 / 24 / 686.971
      :jupiter -> seconds / 60 / 60 / 24 / 4332.59
      :saturn  -> seconds / 60 / 60 / 24 / 10759.22
      :uranus  -> seconds / 60 / 60 / 24 / 30688.5
      :neptune -> seconds / 60 / 60 / 24 / 60182
    end
  end

end
