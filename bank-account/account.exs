defmodule BankAccount do
  use GenServer

  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  @typedoc """
  An account handle.
  """
  @opaque account :: pid

  ###############
  # Client calls
  ###############

  @doc """
  Open the bank. Makes the account available.
  """
  @spec open_bank() :: account
  def open_bank() do
    {:ok, account} = GenServer.start_link(__MODULE__, {:open, 0})

    account
  end

  @doc """
  Close the bank. Makes the account unavailable.
  """
  @spec close_bank(account) :: none
  def close_bank(account) do
    GenServer.cast(account, :close)
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer
  def balance(account) do
    GenServer.call(account, :balance)
  end

  @doc """
  Update the account's balance by adding the given amount which may be negative.
  """
  @spec update(account, integer) :: any
  def update(account, amount) do
    GenServer.call(account, {:update, amount})
  end

  #####################
  # Server (Callbacks)
  #####################

  @impl true
  def init({:open, _amount} = account_state) do
    {:ok, account_state}
  end

  @impl true
  def handle_cast(:close, {:open, balance}) do
    {:noreply, {:closed, balance}}
  end

  @impl true
  def handle_call(_action, _from, {:closed, _b} = account_state) do
    {:reply, {:error, :account_closed}, account_state} 
  end

  def handle_call(:balance, _from, {:open, balance} = account_state) do
    {:reply, balance, account_state}
  end

  def handle_call({:update, amount}, _from, {:open, balance}) do
    updated_balance = balance + amount
    {:reply, updated_balance, {:open, updated_balance}}
  end
end
