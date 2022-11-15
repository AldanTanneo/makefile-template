# Modulable Cross-platform Makefile for C/C++ executables

This Makefile has been elaborated to compile executable C or C++ projects in 
an incremental fashion with minimal setup and sensible defaults.

## Usage

Edit the variables near the top of the file:

### Project name
```Makefile
PROJECT_NAME := your-project-name-here
```

### Location of the source files
```Makefile
PROJECT_ROOT := src
```

### Location of the header files
This folder will be added to the -I flag, making the headers discoverable through 
`#include <...>` instead of `#include "..."`. Using this is of course optional.

```Makefile
HEADERS_ROOT := include
```

### File extensions
For instance: `cpp`/`hpp`, `c`/`h`, etc.
```Makefile
FILE_EXTENSION   := c
HEADER_EXTENSION := h
```

### Compiler executable path
This can be any compiler that accepts gcc-like flags (clang, etc)
```Makefile
COMPILER := gcc
```

### Customisable compile flags
`OPT_DEBUG` only applies to debug builds, `OPT_RELEASE` to release builds, and `COMMON` applies to both.
```Makefile
OPT_DEBUG   := -O0
OPT_RELEASE := -O3
COMMON      := <your flags here>
```

## Available commands:
* `build`: builds a debug version of the project, as `main` or `main.exe` depending on the platform.
* `release`: builds a release version of the project, as `project-name(.exe)`. Optimisation flags are configurable.
* `run`: builds and runs a debug version of the project.
* `bench`: builds and runs a release version of the project.
* `clean`: cleans the current object files and executables.
* `rebuild`: cleans and rebuilds the project in debug mode.

It is recommended to add the executables and the `./obj` folder 
to your .gitignore
