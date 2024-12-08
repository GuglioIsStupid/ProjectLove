local class = {
  _NAME = "Class",
  _VERSION = "1.1.0",
  _DESCRIPTION = "A simple class implementation",
  _CREATOR = "GuglioIsStupid",
  _LICENSE = [[
      MIT LICENSE
  ]]
}

class.__index = class

--- Creates a new instance of the class
---@param ... any
---@return any
function class:new(...) end

--- Creates a new class that extends the current class
---@return table
function class:extend(name)
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self

    cls._NAME = name or "Class"
    setmetatable(cls, self)
    return cls
end

--- Implements a class into the current class
---@param ... table
---@return nil
function class:implement(...) 
    for _, cls in pairs({...}) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
    return nil
end

--- Checks if the current class is an instance of the given class
---@param cls table
---@return boolean
function class:isInstanceOf(cls)
    local m = getmetatable(self)
    while m do
        if m == cls then return true end
        m = m.super
    end
    return false
end

--- Returns the class ID
---@return string
function class:__tostring()
    return self.__NAME
end

--- Creates a new instance of the class
---@param ... any
---@return any
function class:__call(...)
    local inst = setmetatable({}, self)
    inst:new(...)

    return inst
end

return class