defmodule BankAccount do
  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  def account(balance \\ 0, status \\ :active) do
    case status do
      :active ->
        receive do
          {sender, :balance} ->
            send(sender, {self(), balance})
            account(balance, status)

          {sender, {:update, amount}} ->
            send(sender, {self(), :ok})
            account(balance + amount, status)

          {sender, :close} ->
            send(sender, {self(), :closed})
            account(balance, :closed)
        end

      :closed ->
        receive do
          {sender, _query} ->
            send(sender, {self(), :error, :account_closed})
            account(balance, status)

          _ ->
            account(balance, status)
        end
    end
  end

  @typedoc """
  An account handle.
  """
  @opaque account :: pid

  @doc """
  Open the bank. Makes the account available.
  """
  @spec open_bank() :: account
  def open_bank() do
    spawn(fn -> account() end)
  end

  @doc """
  Close the bank. Makes the account unavailable.
  """
  @spec close_bank(account) :: none
  def close_bank(account) do
    send(account, {self(), :close})

    receive do
      {^account, :closed} -> nil
    end
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer
  def balance(account) do
    send(account, {self(), :balance})

    receive do
      {^account, balance} -> balance
      {^account, :error, :account_closed} -> {:error, :account_closed}
    end
  end

  @doc """
  Update the account's balance by adding the given amount which may be negative.
  """
  @spec update(account, integer) :: any
  def update(account, amount) do
    send(account, {self(), {:update, amount}})

    receive do
      {^account, :ok} -> :ok
      {^account, :error, :account_closed} -> {:error, :account_closed}
    end
  end
end