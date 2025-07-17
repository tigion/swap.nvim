---@meta

-- lua/swap/todos/init.lua

---@class swap.TodosStates
---@field switch string[] The states to switch between.
---@field find? string[] The extra states to find.

---@class swap.TodosPattern
---@field before string The capture before the state.
---@field state string The capture of the state.
---@field after string The capture after the state.

---@class swap.TodosSyntax
---@field pattern swap.TodosPattern The pattern to search for.
---@field states swap.TodosStates The states to find and switch between.

---@alias swap.TodosSyntaxByFt table<string, swap.TodosSyntax>
---@alias swap.TodosSyntaxes swap.TodosSyntax[]
