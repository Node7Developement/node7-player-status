# NODE7 recipe integration

Place the resource at:

```text
resources/[node7-framework]/node7-player-status
```

Start it after `node7-core` and before optional gameplay HUD resources:

```cfg
ensure node7-core
ensure node7-player-status
```

No database migration or permission entry is required. The current NODE7 core recipe already has its original account HUD disabled. This resource also sets that client-side preference off so the two economy displays do not overlap when an older core configuration is used.
