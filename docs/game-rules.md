# Ludo Game Rules

## Purpose

This document defines the permanent gameplay rules and logical board
conventions used by the Ludo game engine.

The game engine must remain independent from:

- Flutter rendering
- pixel coordinates
- screen size
- animation timing
- visual assets
- platform-specific UI behavior

Rendering code may visualize these rules, but it must not redefine them.

Rules that have not yet been formally decided, implemented, and tested by
the relevant Jira Story must not be treated as authoritative.

---

# 1. Core Game Concepts

A Ludo match consists of players controlling tokens and moving those tokens
along deterministic logical paths according to dice results and the game's
movement rules.

Each player owns a set of tokens.

Tokens begin outside the active movement path in the player's yard/base.

A token that is released from the yard enters the shared track at that
player's starting cell.

After completing its required shared-track movement, the token enters its
player-specific private home lane and eventually reaches its finish position.

The objective of the game is ultimately based on moving the player's tokens
to their finish positions.

The exact winner and ranking rules will be formally defined by the relevant
game-completion Story.

---

# 2. Player Colors

The supported player colors are:

- Red
- Green
- Yellow
- Blue

Player colors are game-domain concepts.

Flutter colors, gradients, textures, assets, shadows, and other visual
styling must not be stored in the game-rule model.

For example:

`PlayerColor.red`

is a domain concept.

A Flutter value such as:

`Color(0xFFFF0000)`

belongs to the presentation/design layer.

---

# 3. Logical Board Structure

The shared circular Ludo track contains:

- 52 logical main-track cells.
- Main-track cell IDs use the format `main_<index>`.
- Valid shared-track indexes are `0` through `51`.

Each player follows a player-relative logical movement path.

A complete player movement path contains:

- 51 shared main-track positions.
- 5 private home-lane positions.
- 1 final finish position.

Therefore, each player's complete logical movement path contains:

**57 logical positions**

A token enters its player's private home lane before it would otherwise
loop back onto its own starting cell.

---

# 4. Player Start Cells

Each player's shared-track starting position is:

| Player | Main-track index |
| ------ | ---------------: |
| Red    | 0 |
| Green  | 13 |
| Yellow | 26 |
| Blue   | 39 |

The four starting positions are separated by 13 cells around the shared
52-cell track.

From each player's perspective, relative progress `0` represents that
player's own starting cell.

Examples:

- Red progress `0` → `main_0`
- Green progress `0` → `main_13`
- Yellow progress `0` → `main_26`
- Blue progress `0` → `main_39`

This player-relative mapping allows the movement engine to use the same
logic for every player.

---

# 5. Player-Relative Progress

Player-relative progress is a zero-based index into a player's complete
logical movement path.

The progress ranges are:

| Progress | Meaning |
| -------: | ------- |
| `0` | Player's starting shared-track cell |
| `1–50` | Remaining shared-track positions |
| `51–55` | Player's five private home-lane cells |
| `56` | Player's finish position |

Therefore, valid on-board player-relative progress values are:

`0` through `56`

---

## 5.1 Shared-Track Progress

Progress `0` represents the player's starting cell.

Progress `1` represents the next shared-track cell in that player's
movement direction.

This continues until progress `50`.

Progress `50` represents the player's final shared-track position before
entering the private home lane.

---

## 5.2 Home-Lane Progress

Progress values:

- `51`
- `52`
- `53`
- `54`
- `55`

represent the player's five private home-lane cells.

---

## 5.3 Finish Progress

Progress `56` represents the player's logical finish position.

A token at progress `56` has completed its movement path.

---

# 6. Tokens Outside the Movement Path

A token that has not yet entered the movement path must be represented
separately from progress `0`.

A token in the player's yard/base is **not** considered to be standing on
the player's starting cell.

Conceptually:

`Yard/Base → Start Cell → Shared Track → Home Lane → Finish`

or:

`Yard/Base → progress 0 → ... → progress 50 → progress 51–55 → progress 56`

This distinction is important because the engine must be able to
differentiate between:

- a token waiting in the yard; and
- a token currently occupying the player's starting cell.

The dice requirements for releasing a token from the yard are defined by
the legal-move rules and must not be inferred from the logical board model.

---

# 7. Private Home Lanes

Each player has five private home-lane cells.

Their logical IDs use the following formats.

## Red

- `red_home_lane_0`
- `red_home_lane_1`
- `red_home_lane_2`
- `red_home_lane_3`
- `red_home_lane_4`

## Green

- `green_home_lane_0`
- `green_home_lane_1`
- `green_home_lane_2`
- `green_home_lane_3`
- `green_home_lane_4`

## Yellow

- `yellow_home_lane_0`
- `yellow_home_lane_1`
- `yellow_home_lane_2`
- `yellow_home_lane_3`
- `yellow_home_lane_4`

## Blue

- `blue_home_lane_0`
- `blue_home_lane_1`
- `blue_home_lane_2`
- `blue_home_lane_3`
- `blue_home_lane_4`

Home-lane cells are player-specific.

Opponent tokens cannot legally enter another player's private home lane.

---

# 8. Finish Positions

Each player has one logical finish position:

- `red_finish`
- `green_finish`
- `yellow_finish`
- `blue_finish`

A finish position is distinct from a home-lane cell.

This allows the engine to distinguish between:

- a token still moving through its home lane; and
- a token that has completed its movement path.

Visually, a Ludo board may appear to contain six colored home positions.

Our logical model represents those as:

**5 private home-lane cells + 1 finish position**

Conceptually:

`home_lane_0`
→ `home_lane_1`
→ `home_lane_2`
→ `home_lane_3`
→ `home_lane_4`
→ `finish`

GAME-105 defines finish movement as exact-count movement. A token reaches
progress `56` only when the dice value lands exactly on finish. A move whose
calculated destination would exceed progress `56` is not legal.

---

# 9. Safe Cells

The following shared-track cells are currently defined as safe cells.

## 9.1 Player Start Cells

- `main_0`
- `main_13`
- `main_26`
- `main_39`

## 9.2 Additional Safe Cells

- `main_8`
- `main_21`
- `main_34`
- `main_47`

This gives:

**8 protected shared-track positions**

Tokens occupying a safe shared-track cell cannot be captured.

Private home-lane cells and finish positions are inherently protected
because opponents cannot legally occupy those routes.

Rules concerning multiple tokens occupying the same safe cell or possible
blockade behavior are not defined by the logical board model and must be
decided by the appropriate later game-rule Story.

---

# 10. Player Movement Paths

Each player's complete logical movement path is deterministic.

Every player traverses exactly:

**51 shared-track positions**

before entering their private home lane.

---

## 10.1 Red Path

Red begins at:

`main_0`

Red's final shared-track position is:

`main_50`

The path then continues:

`red_home_lane_0`
→ `red_home_lane_1`
→ `red_home_lane_2`
→ `red_home_lane_3`
→ `red_home_lane_4`
→ `red_finish`

Conceptually:

`main_0 → ... → main_50 → red_home_lane_0 → ... → red_home_lane_4 → red_finish`

---

## 10.2 Green Path

Green begins at:

`main_13`

Green traverses the circular shared track.

Its final shared-track position is:

`main_11`

The path then continues:

`green_home_lane_0`
→ `green_home_lane_1`
→ `green_home_lane_2`
→ `green_home_lane_3`
→ `green_home_lane_4`
→ `green_finish`

---

## 10.3 Yellow Path

Yellow begins at:

`main_26`

Yellow traverses the circular shared track.

Its final shared-track position is:

`main_24`

The path then continues:

`yellow_home_lane_0`
→ `yellow_home_lane_1`
→ `yellow_home_lane_2`
→ `yellow_home_lane_3`
→ `yellow_home_lane_4`
→ `yellow_finish`

---

## 10.4 Blue Path

Blue begins at:

`main_39`

Blue traverses the circular shared track.

Its final shared-track position is:

`main_37`

The path then continues:

`blue_home_lane_0`
→ `blue_home_lane_1`
→ `blue_home_lane_2`
→ `blue_home_lane_3`
→ `blue_home_lane_4`
→ `blue_finish`

---

# 11. Deterministic Shared-Track Mapping

Shared-track movement must be calculated from player-relative progress
rather than implemented using separate movement logic for each player.

For shared-track progress values `0` through `50`, the corresponding
shared-track index is calculated conceptually as:

`(playerStartIndex + relativeProgress) mod 52`

---

## Example — Red

Start index:

`0`

Relative progress:

`10`

Calculation:

`(0 + 10) mod 52 = 10`

Result:

`main_10`

---

## Example — Green

Start index:

`13`

Relative progress:

`10`

Calculation:

`(13 + 10) mod 52 = 23`

Result:

`main_23`

---

## Example — Yellow

Start index:

`26`

Relative progress:

`30`

Calculation:

`(26 + 30) mod 52 = 4`

Result:

`main_4`

---

## Example — Blue

Start index:

`39`

Relative progress:

`20`

Calculation:

`(39 + 20) mod 52 = 7`

Result:

`main_7`

---

This deterministic mapping prevents player-specific movement branches and
allows the same movement algorithm to work for all four players.

Once relative progress exceeds `50`, the token leaves the shared track and
uses its player's private home-lane and finish mapping.

---

# 12. Dice-Based Movement

Once a token is legally present on its movement path, movement distance is
determined by the applicable dice result.

For example, if a token is legally allowed to move and the applicable dice
value is `3`, the movement system attempts to advance that token by three
logical steps.

The logical board model does not determine whether every possible dice
movement is legal.

The legal-move system is responsible for deciding whether:

- a token may leave the yard;
- a token may move by the rolled value;
- a token may enter its home lane;
- a token may reach finish;
- a movement would exceed finish;
- another game rule prevents the movement.

## 12.1 GAME-105 Legal-Move Rules

GAME-105 establishes the following authoritative legal-move rules:

- only a completed logical dice result may be used for legal-move evaluation;
- a pending dice result that is still being animated is not available to the
  legal-move engine;
- only a dice result of `6` releases a token from the yard;
- releasing a yard token places it on player-relative progress `0`;
- the release action consumes that move choice and does not additionally move
  the released token six progress steps;
- when a `6` can both release a yard token and move an existing token, both are
  legal choices and the player may choose either token;
- a token already on its movement path advances exactly the rolled number of
  player-relative progress steps when that destination is legal;
- a token may move from the shared track into its own private home lane through
  the same player-relative progress calculation;
- a token may move within its own private home lane;
- exact dice movement is required to reach progress `56`;
- a move that would exceed progress `56` is illegal;
- a token already at progress `56` has no further legal movement;
- legal-move evaluation considers only tokens owned by the player being
  evaluated;
- when none of that player's tokens can legally use the completed dice result,
  GAME-105 reports a no-legal-move outcome and does not mutate token state or
  advance the current player.

The turn engine will later consume the legal-move outcome to perform the
appropriate turn transition. GAME-105 does not own current-player advancement,
bonus-roll sequencing, capture resolution, or movement animation.

## 12.2 GAME-106 Movement Transaction Contract

GAME-106 establishes how an approved legal move changes authoritative logical
state:

- a move must still match the current legal move for its token when committed;
  stale, unknown, or fabricated move data is rejected;
- committing an approved move creates a new immutable `GameState` rather than
  mutating the previous state or token objects in place;
- only the selected token is replaced at the approved logical destination;
  unrelated tokens and their ordering are preserved;
- the final logical destination is committed before presentation movement
  begins;
- a movement transaction also exposes an ordered sequence of logical positions
  that presentation may use for one-cell-at-a-time visual playback;
- for an on-path move, the visual sequence contains every progress value after
  the source through and including the approved destination;
- yard release uses progress `0` as its single movement destination;
- presentation playback and input-lock state are not authoritative game state;
  they may visualize or temporarily gate interaction but cannot change the
  committed token destination;
- interrupting, rebuilding, or skipping presentation playback must not roll back
  or otherwise redefine the already-committed logical `GameState`.

GAME-106 does not resolve captures or blockades and does not decide bonus turns,
current-player transitions, winner/ranking state, or multiplayer authority.

---

# 13. Reference Gameplay Rules Identified

Reference Ludo rules reviewed during development describe several gameplay
behaviors beyond the logical board model.

These include:

- games supporting between two and four players;
- each player beginning with four tokens/pawns;
- dice results determining movement distance;
- tokens beginning inside a player's starting area;
- tokens being released onto their starting point after a qualifying dice
  result;
- landing on an opponent token potentially returning that token to its
  starting area;
- captures potentially granting a bonus roll;
- tokens entering their colored home route after completing the shared
  track;
- the objective of moving all four tokens to the final home/end position.

These behaviors are recorded as **reference gameplay rules**, not
automatically as authoritative rules for this project.

Some Ludo implementations use different variants.

For example, the reviewed reference rules allow a token to be released
from its starting area after rolling either:

- `1`; or
- `6`.

GAME-105 explicitly chooses a different rule for this project: only `6`
releases a token from the yard.

---

# 14. Gameplay Rules Pending Formal Decision

The logical board model intentionally does not define every gameplay policy.

Some movement rules were formally decided by GAME-105 and GAME-106 and are
recorded above. The following remaining policies still require explicit
decisions or later implementation in their relevant Jira Stories.

## 14.1 Match Setup

To decide:

- supported player counts;
- number of tokens per player;
- two-player color arrangements;
- starting-player selection.

---

## 14.2 Token Release

Decided by GAME-105:

- only `6` releases a token from the yard;
- release places the chosen token on progress `0`;
- when a release and an existing-token move are both legal, both remain valid
  choices and the player chooses which token to use.

Still pending for future configuration work:

- whether alternate game modes may configure different release values.

---

## 14.3 Dice and Extra Turns

Decided gameplay direction:

- rolling `6` grants another roll, including when the current `6` has no legal
  token move;
- an unusable `6` is not carried forward or added to a later result; the next
  roll is a new independent dice result.

The legal-move engine does not execute this bonus-roll behavior. GAME-108 will
own the turn-state transition and bonus-roll sequencing.

Still to decide:

- consecutive-six behavior beyond the basic extra roll;
- whether three consecutive sixes cause a penalty;
- maximum extra-turn chains.

---

## 14.4 Capture Rules

To decide:

- normal capture behavior;
- whether captured tokens return to the yard;
- whether capture grants another roll/turn;
- capture exceptions;
- interaction between capture and safe cells.

---

## 14.5 Multiple Tokens and Blockades

To decide:

- whether multiple same-color tokens may occupy one cell;
- whether stacked tokens create a blockade;
- whether opponents may pass a blockade;
- whether blockades may exist on safe cells;
- how blockades interact with movement.

---

## 14.6 Finish Rules

Decided by GAME-105:

- exact dice movement is required to reach finish at progress `56`;
- a dice result that would move a token beyond progress `56` cannot be used by
  that token;
- a token at progress `56` is fully completed for movement purposes and cannot
  move again.

Still to decide in later turn/completion Stories:

- whether finishing a token grants another roll;
- match winner/ranking consequences after tokens finish.

---

## 14.7 Winner and Ranking Rules

To decide:

- exact winner condition;
- whether the first player finishing all tokens immediately ends the match;
- whether remaining players continue playing;
- second/third/fourth-place ranking;
- elimination and resignation behavior.

---

## 14.8 Turn and Timeout Rules

GAME-105 defines only the no-legal-move outcome: when no owned token can use the
completed dice result, no token movement occurs for that result. The legal-move
engine does not itself change the current player.

The GAME-108 turn engine will later decide and execute the resulting player
transition, including the already-decided extra-roll behavior for a `6`.

Still to decide:

- turn duration;
- dice-roll timeout;
- move-selection timeout;
- automatic actions after timeout;
- skipped-turn policy beyond the legal-move outcome;
- disconnect handling.

---

# 15. Logical vs Visual Coordinates

Game rules must never depend on pixel coordinates.

The game engine works with logical concepts such as:

- `BoardCell`
- `PlayerPath`
- player-relative progress
- start positions
- safe cells
- home lanes
- finish positions

The presentation layer is responsible for converting a logical
`BoardCell` into visual coordinates.

For example:

`BoardCell(main_13) → Presentation Mapping → Screen Coordinate`

The resulting screen coordinate is not part of the game rule.

This allows the same logical game state to be rendered differently across:

- Android phones
- iPhones
- tablets
- Web browsers
- different screen sizes
- different orientations

without changing gameplay behavior.

---

# 16. Architecture Dependency Direction

The required dependency direction is:

`Game Rules → Game State → Application/Controller → Presentation → Animation`

Game rules must not depend on presentation.

Game state must not depend on animation.

Animation must never determine logical game results.

For example:

A token movement animation visualizes an already-determined logical
movement.

The animation itself must never determine where the token finishes.

---

# 17. Server-Authoritative Multiplayer

The offline game engine is being designed so the same gameplay rules can
later be validated by the authoritative backend.

For online multiplayer, the server owns or validates authoritative gameplay
outcomes including:

- dice results;
- current player;
- legal moves;
- token destinations;
- captures;
- timers;
- match state;
- finish state;
- winner;
- ranking;
- XP;
- virtual currency;
- rewards.

Flutter clients send player intentions and render confirmed authoritative
state.

For example, the client may send:

`MOVE_TOKEN(tokenId)`

The client should **not** determine and send authoritative outcomes such as:

`MOVE_TOKEN(tokenId, destination, capturedPlayer, reward)`

Instead:

`Player Intent → Server Validation → Authoritative State → Flutter Rendering`

The client must never be trusted to determine:

- dice outcomes;
- legal destinations;
- captured tokens;
- winner;
- ranking;
- XP;
- rewards.

This trust boundary applies even if the offline Flutter game engine contains
equivalent rule logic for local gameplay, prediction, testing, or
presentation purposes.

---

# 18. Rule Documentation Process

This document evolves alongside the game engine.

When a Jira Story formally defines a permanent gameplay rule:

1. Discuss the rule and relevant variants.
2. Choose the rule for this project.
3. Implement it in the game engine.
4. Add unit tests covering normal and edge cases.
5. Verify the Story's acceptance criteria.
6. Update this document.
7. Treat the documented rule as authoritative after acceptance.

Reference rules, assumptions, or behavior observed in other Ludo games must
not silently become permanent project rules.

If implementation and this document disagree, the discrepancy must be
investigated and resolved rather than allowing two independent rule systems
to develop.

---

# 19. Current Rule-Scope Status

The current authoritative scope primarily covers:

- logical shared-track structure;
- player start positions;
- player-relative progress;
- private home-lane structure;
- finish positions;
- safe-cell identification;
- deterministic player path mapping;
- completed-dice-only legal-move evaluation;
- yard release on `6` to progress `0`;
- player choice between yard release and another legal move on `6`;
- normal shared-track and private home-lane movement legality;
- exact-finish and overshoot rejection;
- no-legal-move detection without turn mutation;
- immutable approved-move transactions that commit final logical state before
  presentation playback;
- ordered movement-step plans used only for presentation sequencing;
- presentation interruption cannot redefine or roll back committed logical
  movement;
- the decided extra-roll direction for rolling `6`, with execution deferred to
  GAME-108;
- separation between logical and visual coordinates;
- server-authoritative architecture boundaries.

Capture resolution, blockade policy, detailed extra-turn chains, turn timing,
winner/ranking behavior, and multiplayer execution remain deferred to their
corresponding Jira Stories.