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
    seconds / 60 / 60 / 24 / planet_year_days(planet)
  end

  def planet_year_days(:mercury), do: 87.969
  def planet_year_days(:venus),   do: 224.701
  def planet_year_days(:earth),   do: 365.25
  def planet_year_days(:mars),    do: 686.971
  def planet_year_days(:jupiter), do: 4332.59
  def planet_year_days(:saturn),  do: 10759.22
  def planet_year_days(:uranus),  do: 30688.5
  def planet_year_days(:neptune), do: 60182

end
