# Versions

## 1.1.1-node7.1

- Added a tiny visual-polish pass without changing the HUD layout.
- Added a short settle animation when the status overlay becomes visible.
- Added very rare, low-opacity economy micro-sparks.
- Added a subtle tick animation only when a money value actually changes.
- Added a restrained brass highlight for active duty/radio icons.
- Added reduced-motion support and kept the NUI fully transparent and passive.

## 1.1.0-node7.1

- Replaced the incorrect people-shaped gold icon with three actual gold bars.
- Rebuilt bank, job, duty, clock, radio, and online-player icons as clean local SVGs.
- Matched the supplied 1920x1080 spacing and top-screen economy layout more closely.
- Added complete NODE7 recipe metadata and startup fragments.
- Uses current `node7-core` money, player-load, job, duty, and pause-menu events.
- Prevents overlap with the older core account HUD configuration.
- Reduced redundant player-count traffic.
