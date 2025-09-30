---@meta

-- lua/swap/cases/init.lua

---@class swap.CasesSource
---@field id swap.ConfigCasesId
---@field name string
---@field parser fun(word: string): swap.CasesResult|boolean
---@field converter fun(parts: string[]): string
---@field screaming? swap.CasesSource

---@class swap.CasesType
---@field name string
---@field parser fun(word: string): swap.CasesResult|boolean
---@field converter fun(parts: string[]): string

---@class swap.CasesResult
---@field parts string[]
---@field case_type_id string
