# MapOptionsPlus

New powerful parameters for Options menu items.

> **Ikemen GO 1.0 only.**  
> Module developed by Rakíel.

This module lets you create menu items that set map values for all players. These map values use the item names as their names and can be used to modify in-game behavior via CNS/ZSS.
Map Options Plus supports both the main Options menu and in-game pause menus.

> MapOptions was originally created in 2022 by Wreq!. This version is a complete rewrite from the ground up, based on the original module's concept.

## Installation

1. Extract the archive contents into the `./external/mods/` directory.
2. Add your map options and their settings to `config.ini`.
3. Add the corresponding menu items to your `+system.def`.

## `config.ini` Parameters

The `[MapOptions]` section is used to define the map values and their corresponding Options menu items.

### Boolean

```ini
[MapOptions]

; Boolean option: 0 = No, 1 = Yes.
BoolTest = bool, 1
```

### Integer

```ini
; Integer option: minimum, maximum, default.
IntTest = int, 0, 10, 5
```

### Float

```ini
; Float option: minimum, maximum, default.
FloatTest = float, 0.5, 3.0, 1.5
```

### Custom Labels

Integer options can optionally use custom labels instead of displaying their numeric values. Labels are assigned in order, starting from the minimum value.

```ini
; Integer option with custom labels for each value.
LabelTest = int, 0, 3, 0 | Value 1, Value 2, Value 3, Value 4
```

For example, this displays:

| Value | Display |
| ----: | ------- |
|   `0` | Value 1 |
|   `1` | Value 2 |
|   `2` | Value 3 |
|   `3` | Value 4 |

If no label is provided for a value, the numeric value is displayed instead.

## Example

```ini
[MapOptions]
BoolTest = bool, 1
IntTest = int, 0, 10, 5
FloatTest = float, 0.5, 3.0, 1.5
LabelTest = int, 0, 3, 0 | Value 1, Value 2, Value 3, Value 4
```

## `+system.def`

After configuring `config.ini`, add the corresponding menu items to the appropriate menu section using `menu.itemname.<optionName>`.

Map Options Plus can be used in the main Options menu as well as in-game pause menus. You can add the items to `[Option Info]`, `[Pause Menu]`, `[Training Pause Menu]`, or any custom pause menu section.

### Main Options Menu
```ini
[Option Info]
menu.itemname.mapoptionsplus = Map Options Plus
menu.itemname.mapoptionsplus.booltest = Bool Test
menu.itemname.mapoptionsplus.inttest = Int Test
menu.itemname.mapoptionsplus.floattest = Float Test
menu.itemname.mapoptionsplus.labeltest = Label Test
```

### Training Pause Menu
```ini
[Training Pause Menu]
menu.itemname.menutraining.mapoptionsplus = Map Options Plus
menu.itemname.menutraining.mapoptionsplus.booltest = Bool Test
menu.itemname.menutraining.mapoptionsplus.inttest = Int Test
menu.itemname.menutraining.mapoptionsplus.floattest = Float Test
menu.itemname.menutraining.mapoptionsplus.labeltest = Label Test
menu.itemname.menutraining.mapoptionsplus.spacer = -
menu.itemname.menutraining.mapoptionsplus.mapoptionsdefault = Default Maps
```

The ``mapoptionsdefault`` item is optional and resets all Map Options Plus values to their configured default values.  
See the [Ikemen GO documentation](https://github.com/ikemen-engine/Ikemen-GO/wiki/Screenpack-features#submenus-grouping) for more information about menu item grouping.

## How It Works

When a new match starts, Map Options Plus applies each configured map value to all players.

For example:

```ini
DamageMultiplier = float, 0.5, 3.0, 1.0
```

creates a map value named `DamageMultiplier`, which can then be accessed from CNS/ZSS to customize in-game behavior.

## Credits

* **Wreq!** — Original MapOptions module, created in 2022.
