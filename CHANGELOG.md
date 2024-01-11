# Changelog

## January 10 2024

### Added

- Four new predefined styles of line.

## January 4 2024

### Added

- Complete rework of the way the plugin deal with the comment strings which allow a complete support of multi-line comments!
A new option has been added (`comment_style`) that can take one of three states:
  - `"line"`:  no matter the type of comment applied to the selected comments, boxes, title lines and simple lines will always be commented with line style.
  - `"block"`: no matter the type of comment applied to the selected comments, boxes, title lines and simple lines will always be commented with block style.
  - `"auto"`: if you select one line, boxes, titled lines and simple lines will be commented with line style, if you select multiple lines, they will be commented with block style.

The plugin will bypass this option if the language of the file allow only block comments or only line comments.

### Changed

To keep a consistency in the nomenclature of the commands (older commands still work but are deprecated):
- `CBalbox` becomes `CBlabox`.
- `CBacbox` becomes `CBcabox`.
- `CBarbox` becomes `CBrabox`.
- `CBlline` has been added (same as `CBline`).

### Deprecated

- `CBalbox`.
- `CBacbox`.
- `CBarbox`.

## December 31 2023

### Added

- New category: titled lines (see [titled lines](#titled-lines)).
- [Quick Start](#quick-start) section for people with no time to waste!
- `CBy` and `CBd` can be used on titled lines as well.

### Changed

- `CBdbox` becomes `CBd`.
