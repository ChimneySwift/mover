# Mover

<!-- For forums: -->
<!-- [**Download**](https://github.com/ChimneySwift/mover/archive/master.zip)
[**GitHub**](https://github.com/ChimneySwift/mover) -->

**Code license:** [MIT](https://opensource.org/licenses/MIT)

**Textures license:** [MIT](https://opensource.org/licenses/MIT)

**Dependencies:** none

**Optional Dependencies:** default (For craft recipie)

**Contributors:** LadyK (textures)

## Description

A Minetest mod which adds a tool that makes moving nodes containing metadata such as chests and protection blocks extremely simple.

The tool abides by protection rules, including owner metadata and the `protection_bypass` priv.

It copies all node metadata to the tool on left click and on rightclick places the node and copies metadata over to the node. Including inventories.

Since the device uses the on_place function there is no worrying about unconfigured nodes (such as protection blocks without owners).
