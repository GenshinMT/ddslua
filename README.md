![Status](https://img.shields.io/badge/status-work%20in%20progress-%23bb77d1)
![licence](https://img.shields.io/github/license/GenshinMT/dds_parse)
# dds_parse (Dialogues Done Simple)
A parsing module that translates a simple custom format useful for textbox dialogues into LUA tables

## Usage

The **dds.lua** file should be dropped into an existing project and required by it:

```lua
dds = require "dds"
```

The module provides the following function:

**dds.parse(file, directory)**

Returns a table value representing the decoded data from the file.

```lua
dds.parse("test.dds", "/dds_parse/sample files/")
```
