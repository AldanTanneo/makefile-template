# Modulable Cross-platform Makefile for C/C++ executables
# 
# Copyright 2022 César SAGAERT
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
## USAGE
#
# Available commands:
# build: builds a debug version of the project, as `main` or `main.exe` 
#        depending on the platform
# release: builds a release version of the project, as `project-name(.exe)`. 
#          Optimisation flags are configurable.
# run: builds and runs a debug version of the project.
# bench: builds and runs a release version of the project.
# clean: cleans the current object files and executables.
# rebuild: cleans and rebuilds the project in debug mode.
#
# It is recommended to add the executables and the ./obj folder 
# to your .gitignore

PROJECT_NAME := project-name

# Location of the source files.
PROJECT_ROOT := src
# Location of the header files. They will be added to the -I flag, making them
# discoverable through #include <...>
HEADERS_ROOT := include

# File extensions, for instance cpp/hpp, c/h
FILE_EXTENSION   := c
HEADER_EXTENSION := h

# Compiler executable path
COMPILER := gcc

# Customisable compile flags
OPT_DEBUG   := -O0
OPT_RELEASE := -O3
COMMON      := 

# Platform specific variables
ifeq ($(OS),Windows_NT)
TARGET_DEBUG   := main.exe
TARGET_RELEASE := $(PROJECT_NAME).exe
DEL            := del
RMDIR          := rd /S /Q
MKDIR          := md
else
TARGET_DEBUG   := main
TARGET_RELEASE := $(PROJECT_NAME)
DEL            := rm -f
RMDIR          := rm -rf
MKDIR          := mkdir -p
endif

# Sources
SRC      := $(PROJECT_ROOT)
SRCS     := $(wildcard $(SRC)/*.$(FILE_EXTENSION)) $(wildcard $(SRC)/**/*.$(FILE_EXTENSION))
INCLUDE  := $(HEADERS_ROOT)
INCLUDES := $(wildcard $(INCLUDE)/*.$(HEADER_EXTENSION)) $(wildcard $(INCLUDE)/**/*.$(HEADER_EXTENSION))

# Object files
OBJ          := obj
OBJ_DEBUG    := $(OBJ)/debug
OBJ_RELEASE  := $(OBJ)/release
OBJS_DEBUG   := $(patsubst $(SRC)/%.$(FILE_EXTENSION),$(OBJ_DEBUG)/%.o,$(SRCS))
OBJS_RELEASE := $(patsubst $(SRC)/%.$(FILE_EXTENSION),$(OBJ_RELEASE)/%.o,$(SRCS))

# Dependencies
DEPS_DEBUG   := $(patsubst $(SRC)/%.$(FILE_EXTENSION),$(OBJ_DEBUG)/%.d,$(SRCS))
DEPS_RELEASE := $(patsubst $(SRC)/%.$(FILE_EXTENSION),$(OBJ_RELEASE)/%.d,$(SRCS))

# Compiler and compile flags
CC          := $(COMPILER)
CFLAGS      := -I$(INCLUDE) -Wall -Werror -Wfatal-errors -MMD -MP $(COMMON) # do not edit

# Cosmetics
MODE_DEBUG   := [debug]
MODE_RELEASE := [release]

# Cool colours
ESC   := 
NC    := $(ESC)[0m
BOLD  := $(ESC)[1m
NEG   := $(ESC)[7m
RED   := $(ESC)[31m
GREEN := $(ESC)[32m

# Useful commands
ifeq ($(OS),Windows_NT)
CREATE_DIR = if not exist $(subst /,\,$(dir $@)) $(MKDIR) $(subst /,\,$(dir $@))
else
CREATE_DIR = $(MKDIR) $(dir $@)
endif

build: $(TARGET_DEBUG)
rebuild: clean build

# Create build directories

$(OBJ_DEBUG) $(OBJ_RELEASE):
	@$(CREATE_DIR)

# Debug build

$(OBJ_DEBUG)/%.o: $(SRC)/%.$(FILE_EXTENSION) | $(OBJ_DEBUG)
	@echo $(BOLD)$(GREEN)  Compiling $(NC)$(notdir $@)$(GREEN) $(MODE_DEBUG)$(NC)
	@$(CREATE_DIR)
	@$(CC) -c $< -o $@ $(OPT_DEBUG) $(CFLAGS) 

$(TARGET_DEBUG): $(OBJS_DEBUG) | $(OBJ_DEBUG)
	@echo $(BOLD)$(GREEN)    Linking $(NC)$@$(GREEN) $(MODE_DEBUG)$(NC)
	@$(CC) -o $@ $(OBJS_DEBUG) $(OPT_DEBUG) $(CFLAGS)

# Release build

$(OBJ_RELEASE)/%.o: $(SRC)/%.$(FILE_EXTENSION) | $(OBJ_RELEASE)
	@echo $(BOLD)$(GREEN)  Compiling $(NC)$(notdir $@)$(GREEN) $(MODE_RELEASE)$(NC)
	@$(CREATE_DIR)
	@$(CC) -c $< -o $@ $(OPT_RELEASE) $(CFLAGS)

$(TARGET_RELEASE): $(OBJS_RELEASE) | $(OBJ_RELEASE)
	@echo $(BOLD)$(GREEN)    Linking $(NC)$@$(GREEN) $(MODE_RELEASE)$(NC)
	@$(CC) $(OBJS_RELEASE) -o $@ $(OPT_RELEASE) $(CFLAGS)

# Phony targets

debug: $(TARGET_DEBUG)

run: $(TARGET_DEBUG)
	@echo $(BOLD)$(GREEN)    Running $(NC)$(TARGET_DEBUG)$(GREEN) $(MODE_DEBUG)$(NC)
	@./$(TARGET_DEBUG)

release: $(TARGET_RELEASE)

bench benchmark: $(TARGET_RELEASE)
	@echo $(BOLD)$(GREEN)    Running $(NC)$(TARGET_RELEASE)$(GREEN) $(MODE_RELEASE)$(NC)
	@./$(TARGET_RELEASE)

clean:
ifneq ("$(wildcard $(TARGET_DEBUG))","")
	@echo $(BOLD)$(RED)Cleaning up $(NC)$(TARGET_DEBUG)$(RED)...$(NC)
	@$(DEL) $(TARGET_DEBUG)
endif
ifneq ("$(wildcard $(TARGET_RELEASE))","")
	@echo $(BOLD)$(RED)Cleaning up $(NC)$(TARGET_RELEASE)$(RED)...$(NC)
	@$(DEL) $(TARGET_RELEASE)
endif
ifneq ("$(wildcard $(OBJ))","")
	@echo $(BOLD)$(RED)Cleaning up $(NC)$(OBJ)$(RED)...$(NC)
	@$(RMDIR) $(OBJ)
endif

.PHONY: build rebuild debug run release bench benchmark clean

-include $(DEPS_DEBUG)
-include $(DEPS_RELEASE)
