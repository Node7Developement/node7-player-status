# node7-player-status

Recipe-ready transparent RedM status HUD built specifically for `node7-core`.

## Displays

- NODE7 job and grade
- Duty state
- Native RedM game time
- Optional `node7-radio` power/frequency
- Online player count
- NODE7 core bank, gold, and cash balances

No weapon display is included.

## NODE7 recipe start order

```cfg
ensure node7-core
ensure node7-player-status
```

Or execute the included recipe fragment:

```cfg
exec @node7-player-status/recipe/node7-player-status.cfg
```

`node7-radio` is optional and is detected only when running.

The package contains no SQL, external icon library, or CDN. Every icon is a local inline SVG. The HUD never takes NUI focus and remains hidden during charselect, logout, the native pause frontend, and RedM's full native map UIAPP.

## Interface

Version `1.2.0-node7.1` uses a compact futuristic-western NODE7 telemetry style with angular smoked plates, brass/ember accents, clear economy labels, and restrained value feedback. The browser canvas, `html`, `body`, and full HUD root remain forced transparent; only the small status elements themselves use translucent surfaces. No fullscreen overlay or black-screen layer is included.
