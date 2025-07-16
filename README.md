# Chess Clock

A simple Phoenix LiveView chess clock.

## Getting Started

To start the Phoenix server:

1. Run `mix setup` to install and configure dependencies.
2. Start the server with `mix phx.server`
       or inside IEx with `iex -S mix phx.server`.

Visit [`localhost:4000`](http://localhost:4000) in your browser.

## Multiple Chess Clocks

You can create independent clocks by visiting a unique URL like:

```
localhost:4000/clock/<id>
```

Example: [`localhost:4000/clock/1`](http://localhost:4000/clock/1)

Each clock is a separate LiveView, and all connected clients stay in sync. You can open as many clocks as needed by changing the `<id>`.

## How It Works

* Each player starts with 90 seconds.
* The active player's clock counts down.
* When time runs out, that player loses.
* A **Switch** button lets players toggle turns and start the other clock.

