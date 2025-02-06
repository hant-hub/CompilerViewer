Super basic plugin for viewing compiled code. Currently it only works
with C and C++. It also depends on a compiled_commands.json file
being present.

On the todo list is support for arbitrary compilation, displaying
just the function the user is in, and also stripping debug and
assembler directives from the assembly output.

This is partially inspired by Godbolt.org which is a better version
of this in most regards, however this does run locally which has
its own benefits.

## Usage
Currently this only exports three commands.
CVrun will create a vertical split and display the
assembly, CVleft and CVright change which side
the new window appears on.

## Installation
It works just like any other plugin, the only thing
is that you need to call the setup function. This can
be done in the config call.
