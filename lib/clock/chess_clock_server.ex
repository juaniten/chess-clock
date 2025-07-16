defmodule Clock.ChessClockServer do
  @clock_initial_time 90
  use GenServer
  # Client API

  def start(clock_id),
    do: GenServer.start(__MODULE__, clock_id, name: via(clock_id))

  defp via(clock_id), do: {:via, Registry, {Clock.ClockRegistry, clock_id}}

  def subscribe(clock_id), do: GenServer.call(via(clock_id), {:subscribe, self()})

  def unsubscribe(clock_id), do: GenServer.cast(via(clock_id), {:unsubscribe, self()})

  def switch(pid), do: GenServer.cast(pid, :switch)

  # Server callbacks

  @impl GenServer
  def init(_clock_id) do
    state = %{
      current_player: :white,
      white: @clock_initial_time,
      black: @clock_initial_time,
      subscribers: MapSet.new(),
      game_result: nil
    }

    tick()
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:subscribe, pid}, _from, state) do
    Process.monitor(pid)
    new_state = %{state | subscribers: MapSet.put(state.subscribers, pid)}
    {:reply, {:ok, new_state}, new_state}
  end

  @impl GenServer
  def handle_cast({:unsubscribe, pid}, state),
    do: {:noreply, %{state | subscribers: MapSet.delete(state.subscribers, pid)}}

  @impl GenServer
  def handle_cast(:switch, %{current_player: :white} = state),
    do: {:noreply, %{state | current_player: :black}}

  @impl GenServer
  def handle_cast(:switch, %{current_player: :black} = state),
    do: {:noreply, %{state | current_player: :white}}

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    IO.inspect(reason, label: "A LiveView reported down, reason")
    {:noreply, %{state | subscribers: MapSet.delete(state.subscribers, pid)}}
  end

  @impl GenServer
  def handle_info(:tick, %{black: 0} = state) do
    IO.puts("Server says: White wins!")
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_info(:tick, %{white: 0} = state) do
    IO.puts("Server says: Black wins!")
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    new_state = update_in(state[state.current_player], &(&1 - 1))
    tick()

    broadcast_updates(
      new_state.subscribers,
      Map.take(new_state, [:current_player, :black, :white])
    )

    {:noreply, new_state}
  end

  # Private functions

  defp tick, do: Process.send_after(self(), :tick, 1000)

  defp broadcast_updates(subscribers, updates),
    do:
      Enum.each(subscribers, fn pid ->
        send(pid, {:update, updates})
      end)
end
