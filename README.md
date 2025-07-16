# Clock

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Access multiple chess clocks

Independent clocks can be spawn by visiting [`localhost:4000/clock/<id>`](http://localhost:4000/clock/1) with any id, which will generate a LiveView for interacting with the clock. You can generate as many LiveViews as you want and they will keep in sync.

