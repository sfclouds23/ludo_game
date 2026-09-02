# Ludo Design System

## Purpose

This document defines permanent presentation conventions used by the Ludo
client.

Gameplay rules and logical board topology remain defined separately in
`docs/game-rules.md` and the game domain layer.

Visual conventions must not redefine game behavior.

---

## Board Rendering

The production Ludo board is rendered using Flutter `CustomPainter`.

The board uses a normalized visual grid containing:

- 15 rows
- 15 columns
- equal-width square cells

The normalized grid is converted to logical Flutter pixels at render time.

No domain model stores:

- `Offset`
- `Size`
- `Rect`
- canvas coordinates
- screen dimensions
- device-pixel ratios

The required translation flow is:

`BoardCell → BoardGridPosition → responsive pixel Offset`

---

## Board Orientation

The production board uses the following fixed visual orientation:

| Position | Player |
| --- | --- |
| Top-left | Red |
| Top-right | Green |
| Bottom-right | Yellow |
| Bottom-left | Blue |

The four private home lanes move from their respective shared-track entry
areas toward the center finish area.

This orientation is a presentation convention. It does not change the
player-relative movement paths defined by GAME-101.

---

## Responsive Sizing

The board must:

- remain square;
- use the smaller available layout dimension;
- remain centered in its parent;
- scale consistently across phones, tablets, and web;
- use a maximum dimension of 720 logical pixels by default on large layouts.

Rendering calculations use logical Flutter pixels. Device-pixel density must
not change logical board geometry.

---

## Board Colors

The current production board palette is:

| Role | Value |
| --- | --- |
| Board surface | `#F8F4E8` |
| Track cell | `#FFFDF7` |
| Yard surface | `#FFFBF2` |
| Board border | `#292D32` |
| Cell border | `#50555C` |
| Red player | `#E4473D` |
| Green player | `#35A865` |
| Yellow player | `#F2BE35` |
| Blue player | `#3784D6` |

Flutter color values belong in the presentation layer and must not be added to
`PlayerColor` or another domain model.

---

## Board Markers

Player starting cells use the corresponding player color.

The four additional GAME-101 safe cells use a five-point star marker:

- `main_8`
- `main_21`
- `main_34`
- `main_47`

Safe-cell status remains a domain rule. The star is only its visual
representation.

---

## Finish Area

The center finish area uses four colored triangles:

- Red points inward from the left.
- Green points inward from the top.
- Yellow points inward from the right.
- Blue points inward from the bottom.

Every logical player finish currently maps to the center grid position.

Later token rendering may apply small visual offsets when multiple completed
tokens share that position. Such offsets must never alter logical occupancy or
completion state.

---

## Yard Token Slots

Each player yard displays four reserved circular token slots.

These circles are static board decoration during GAME-102.

GAME-103 will render actual token widgets or painted token layers separately
from the static board painter.

---

## Repaint Boundaries

The static board is isolated using `RepaintBoundary`.

The static painter must not repaint when its visual configuration has not
changed.

Future tokens, selection effects, dice, and movement animations should use
separate repaint scopes so animation does not continuously repaint the entire
static board.

---

## Ownership Boundaries

Responsibilities remain separated as follows:

- GAME-101 domain model defines logical board cells and paths.
- `BoardCoordinateMapper` maps logical cells to normalized visual positions.
- `BoardGeometry` converts normalized positions to responsive pixels.
- `LudoBoardPainter` paints the static board.
- `LudoBoard` owns responsive layout and repaint isolation.
- Future game-state and animation layers render dynamic tokens independently.

Animation must never determine logical game results.