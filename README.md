# ASCII Punk Deckbuilder RPG (Godot 4.6.1)

Minimal runnable MVP for a cyberpunk system-hacker **deckbuilder RPG** with standard Godot UI and ASCII art embedded inside widgets.

## File tree

```text
project.godot
scenes/
  Main.tscn
  Hub.tscn
  DeckBuilder.tscn
  Run.tscn
  Combat.tscn
  ui/
    CardView.tscn
    CardHand.tscn
    DropZone.tscn
    CRTOverlay.tscn
  tests/
    TestMenu.tscn
    CardSandbox.tscn
scripts/
  main.gd
  hub.gd
  deck_builder.gd
  run.gd
  combat_screen.gd
  models.gd
  state.gd
  persistence.gd
  systems/
    deck_system.gd
    combat_system.gd
    exploration_system.gd
    synergy_system.gd
  content/
    cards.gd
    enemies.gd
  ui/
    card_view.gd
    card_hand.gd
    drop_zone.gd
  tests/
    test_menu.gd
    card_sandbox.gd
shaders/
  crt_shader.gdshader
```

## Setup steps (Godot 4.6.1)
1. Import this folder as a Godot **4.6.1** project.
2. Ensure Autoload includes:
   - Name: `GameState`
   - Path: `res://scripts/state.gd`
3. Assign a monospace font to ASCII text widgets:
   - `Run/Outer/MapPanel/MapView`
   - `Combat/EnemyPanel/EnemyVBox/EnemyAscii`
   - `scenes/ui/CardView.tscn` -> `Art`
4. Open `scenes/Main.tscn` and run.


## Testing scenes
- Default runnable scene is still `res://scenes/Main.tscn` (full game loop).
- Added quick test launcher: `res://scenes/tests/TestMenu.tscn`.
- Added focused card interaction sandbox: `res://scenes/tests/CardSandbox.tscn` (drag/drop + hand fan + tilt).

## Controls
- Hub: `S` start run, `D` deck builder.
- Run: `WASD` / Arrow keys.
- Combat: mouse drag/drop cards to `PLAY AREA`, `1..5` to play indexed hand cards, `R` to end turn.

- Deck Builder now includes a live CardView preview pane (select collection/deck entries to inspect full description + ASCII art).
- Run movement polling uses action `just_pressed` in `_process`, so WASD/arrow movement works reliably regardless of UI focus.

## Notes
- Save file: `user://save.json`
- Deterministic RNG defaults to enabled via `save.settings.debug_seed`.
- CRT post-process is toggleable in Hub and persisted.
