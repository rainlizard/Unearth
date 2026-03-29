# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

Unearth is a map editor for Dungeon Keeper 1.

# Godot GDScript Style Guide

**Environment:** Godot 3.5.3 | Language: GDScript

## Core Architecture & Design Principles

- Apply DRY (Don't Repeat Yourself) - eliminate repetitive code
- Prefer self-documenting code over comments
- Create helper functions for common patterns
- Instead of duplicating large logic blocks, reuse existing scripts
- Analyze and refactor code to reduce lines while maintaining functionality
- **Type A functions:** Call multiple Type B functions
- **Type B functions:** Single responsibility, self-contained, independent
- **Type B functions:** Take input, return output with one value (no concatenated dict/array returns)
- **Type B functions:** Should be reusable - extract repeated code into new Type B functions
- Avoid creating new functions for 1-2 line operations

## Node References & Structure

- Always use onready nodelist references: `onready var oNode = Nodelist.list["oNode"]`
- `oNode` almost always maps to `Node.gd` (without 'o' prefix)
- Use dollar sign ($) for child nodes with generic names (PanelContainer2, VBoxContainer7)
- Use as many node references as needed, but remove unused ones

## Naming Conventions

- Full scope variables/functions: `snake_case`
- Local variables/arguments: `camelCase`
- Constants/enum values: `UPPER_SNAKE_CASE`
- Variable/function names must clearly describe purpose/content
- Function names: maximum 3 words
- Function names: no leading underscores (except Godot built-ins)
- Function names: no abbreviations
- Function names: simple vocabulary - avoid: 'execute', 'sync', 'operation', 'prerequisite'
- Godot built-in methods/signals: retain standard underscore prefix

## Code Structure & Formatting

- Target 80-120 characters per line
- Function bodies: remove internal empty lines
- Function separation: 2 empty lines between functions
- Consolidate variable declarations - combine similar operations into single lines
- Remove redundant variables - use direct usage where clearer
- Consolidate error handling - combine similar error checks
- Simplify loops and operations with concise syntax

## Control Flow & Conditionals

- Use `expression == false`, not `not expression`
- Simplify conditionals with early returns to reduce nesting
- **Use if/else statements on separate lines for better readability** - avoid ternary operators
- **NEVER use call_func** - use direct function calls instead
- **Favor direct function calls over signals** - decoupling isn't necessary
- Consolidate error handling where possible
- Avoid unnecessary safety checks (e.g., null, is_valid) unless required

## Documentation & Comments

- **NEVER add new comments** - code should be self-documenting
- Keep existing comments when present