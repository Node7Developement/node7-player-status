[README.md](https://github.com/user-attachments/files/30807512/README.md)
# node7-player-status


<img width="1920" height="949" alt="playerstatus" src="https://github.com/user-attachments/assets/f9ad5f69-4fc7-4e7d-8261-6bee021a0eb9" />

Recipe-ready transparent RedM status overlay built specifically for `node7-core`.

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

The package contains no SQL, external icon library, or CDN. Every icon is a local inline SVG. The overlay never takes NUI focus and remains hidden during charselect, logout, and the native pause menu.

## Visual polish

The overlay includes a restrained NODE7 polish pass: a short entrance settle, rare micro-sparks around economy entries, subtle money-change feedback, and a brass highlight for active duty/radio states. The layout, transparency, and passive no-focus behavior remain unchanged.
