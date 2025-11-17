# Interplanetary Fuel Calculator

A web application for calculating the fuel required for interplanetary travel missions.

## Demo

[![Watch the demo](https://cdn.loom.com/sessions/thumbnails/fb5c580b49654607b8f10a91fecbacd9-with-play.gif)](https://www.loom.com/share/fb5c580b49654607b8f10a91fecbacd9)

## Quick Start

```bash
# Install dependencies
mix deps.get

# Run tests
mix test

# Start the server
mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000)

## How It Works

The fuel calculator uses NASA's formulas for launch and landing:

- **Launch**: `mass * gravity * 0.042 - 33` (rounded down)
- **Landing**: `mass * gravity * 0.033 - 42` (rounded down)

Fuel adds weight to the spacecraft, requiring additional fuel recursively until the additional fuel needed is zero or negative.

### Example: Landing Apollo 11 CSM on Earth

```
Equipment mass: 28,801 kg
Earth gravity: 9.807 m/s²

9,278 fuel requires 2,960 more fuel
2,960 fuel requires 915 more fuel
915 fuel requires 254 more fuel
254 fuel requires 40 more fuel
40 fuel requires no more fuel

Total: 13,447 kg
```

## Supported Planets

| Planet | Gravity (m/s²) |
|--------|----------------|
| Earth  | 9.807          |
| Moon   | 1.62           |
| Mars   | 3.711          |

