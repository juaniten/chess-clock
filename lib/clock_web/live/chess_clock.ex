defmodule ClockWeb.ChessClock do
  use ClockWeb, :live_view

  defp time_out?(state), do: state.black == 0 or state.white == 0

  def mount(%{"clock_id" => clock_id}, _session, socket) do
    case start_or_get_clock(clock_id) do
      {:ok, _pid} ->
        {:ok, initial_state} = Clock.ChessClockServer.subscribe(clock_id)
        {:ok, assign(socket, clock_id: clock_id, state: initial_state)}

      {:error, _reason} ->
        {:ok,
         socket
         |> put_flash(:error, "Clock not found")
         |> assign(clock_id: nil, state: nil)}
    end
  end

  def handle_event("switch", _params, socket) do
    {:ok, pid} = start_or_get_clock(socket.assigns.clock_id)
    Clock.ChessClockServer.switch(pid)
    {:noreply, socket}
  end

  def handle_info({:update, updates}, socket) do
    new_state =
      case socket.assigns.state do
        nil -> updates
        _ -> Map.merge(socket.assigns.state, updates)
      end

    # IO.inspect(new_state, label: "New state")
    {:noreply, assign(socket, state: new_state)}
  end

  defp start_or_get_clock(clock_id) do
    case Registry.lookup(Clock.ClockRegistry, clock_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> Clock.ChessClockServer.start(clock_id)
    end
  end

  def terminate(_reason, socket) do
    Clock.ChessClockServer.unsubscribe(socket.assigns.clock_id)
    :ok
  end
end
