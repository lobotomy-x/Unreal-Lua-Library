example plugin showing a method to execute lua from C++ without needing to build against lua/sol

on_lua_exec.lua must go in global scripts folder, example_plugin.dll in global plugins
project was thrown together in one night, text editor is incomplete but has syntax highlighting, file opening but not saving 
all lua scripts share a state so you can access stuff from other scripts

