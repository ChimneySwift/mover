# Mover

A Minetest mod which adds a tool that makes moving nodes containing metadata such as chests and protection blocks extremely simple.

The tool abides by protection rules, including owner metadata and the `protection_bypass` priv.

It coppies all node metadata to the tool on left click and on rightclick places the node and coppies metadata over to the node. Including inventories.

Since the device uses the on_place function there is no worrying about unconfigured nodes (such as protection blocks without owners).
