local _uobject =  UEVR_UObject
local _ustruct  =  UEVR_UStruct --    setmetatable({}, uevr_ustruct)
local _uclass   =  UEVR_UClass --    setmetatable({}, uevr_uclass)
local _ufunction = UEVR_UFunction --     setmetatable({}, uevr_ufunction)
local _ffield   =  UEVR_FField --    setmetatable({}, uevr_ffield)
local _fproperty = UEVR_FProperty --        setmetatable({}, uevr_fproperty)
local _uevr_types = {
     _uobject,
     _ustruct,
     _uclass,
     _ufunction,
     _ffield,
     _fproperty
}

local EPropertyFlags = {
    CPF_None                                = 0x0000000000000000,

    CPF_Edit                                = 0x0000000000000001,
    CPF_ConstParm                           = 0x0000000000000002,
    CPF_BlueprintVisible                    = 0x0000000000000004,
    CPF_ExportObject                        = 0x0000000000000008,
    CPF_BlueprintReadOnly                   = 0x0000000000000010,
    CPF_Net                                 = 0x0000000000000020,
    CPF_EditFixedSize                       = 0x0000000000000040,
    CPF_Parm                                = 0x0000000000000080,
    CPF_OutParm                             = 0x0000000000000100,
    CPF_ZeroConstructor                     = 0x0000000000000200,
    CPF_ReturnParm                          = 0x0000000000000400,
    CPF_DisableEditOnTemplate               = 0x0000000000000800,

    CPF_Transient                           = 0x0000000000002000,
    CPF_Config                              = 0x0000000000004000,

    CPF_DisableEditOnInstance               = 0x0000000000010000,
    CPF_EditConst                           = 0x0000000000020000,
    CPF_GlobalConfig                        = 0x0000000000040000,
    CPF_InstancedReference                  = 0x0000000000080000,

    CPF_DuplicateTransient                  = 0x0000000000200000,
    CPF_SubobjectReference                  = 0x0000000000400000,

    CPF_SaveGame                            = 0x0000000001000000,
    CPF_NoClear                             = 0x0000000002000000,

   CPF_ReferenceParm                       = 0x0000000008000000,
   CPF_BlueprintAssignable                 = 0x0000000010000000,
   CPF_Deprecated                          = 0x0000000020000000,
   CPF_IsPlainOldData                      = 0x0000000040000000,
   CPF_RepSkip                             = 0x0000000080000000,
   CPF_RepNotify                           = 0x0000000100000000,
   CPF_Interp                              = 0x0000000200000000,
   CPF_NonTransactional                    = 0x0000000400000000,
   CPF_EditorOnly                          = 0x0000000800000000,
   CPF_NoDestructor                        = 0x0000001000000000,

    CPF_AutoWeak                            = 0x0000004000000000,
    CPF_ContainsInstancedReference          = 0x0000008000000000,
    CPF_AssetRegistrySearchable             = 0x0000010000000000,
    CPF_SimpleDisplay                       = 0x0000020000000000,
    CPF_AdvancedDisplay                     = 0x0000040000000000,
    CPF_Protected                           = 0x0000080000000000,
    CPF_BlueprintCallable                   = 0x0000100000000000,
    CPF_BlueprintAuthorityOnly              = 0x0000200000000000,
    CPF_TextExportTransient                 = 0x0000400000000000,
    CPF_NonPIEDuplicateTransient            = 0x0000800000000000,
    CPF_ExposeOnSpawn                       = 0x0001000000000000,
    CPF_PersistentInstance                  = 0x0002000000000000,
    CPF_UObjectWrapper                      = 0x0004000000000000,
    CPF_HasGetValueTypeHash                 = 0x0008000000000000,
    CPF_NativeAccessSpecifierPublic         = 0x0010000000000000,
    CPF_NativeAccessSpecifierProtected      = 0x0020000000000000,
    CPF_NativeAccessSpecifierPrivate        = 0x0040000000000000,
    CPF_SkipSerialization                   = 0x0080000000000000,
}

EPropertyFlags.__orderedIndex = {
    "CPF_None",
    "CPF_Edit",
    "CPF_ConstParm",
    "CPF_BlueprintVisible",
    "CPF_ExportObject",
    "CPF_BlueprintReadOnly",
    "CPF_Net",
    "CPF_EditFixedSize",
    "CPF_Parm",
    "CPF_OutParm",
    "CPF_ZeroConstructor",
    "CPF_ReturnParm",
    "CPF_DisableEditOnTemplate",
    "CPF_Transient",
    "CPF_Config",
    "CPF_DisableEditOnInstance",
    "CPF_EditConst",
    "CPF_GlobalConfig",
    "CPF_InstancedReference",
    "CPF_DuplicateTransient",
    "CPF_SubobjectReference",
    "CPF_SaveGame",
    "CPF_NoClear",
    "CPF_ReferenceParm",
    "CPF_BlueprintAssignable",
    "CPF_Deprecated",
    "CPF_IsPlainOldData",
    "CPF_RepSkip",
    "CPF_RepNotify",
    "CPF_Interp",
    "CPF_NonTransactional",
    "CPF_EditorOnly",
    "CPF_NoDestructor",
    "CPF_AutoWeak",
    "CPF_ContainsInstancedReference",
    "CPF_AssetRegistrySearchable",
    "CPF_SimpleDisplay",
    "CPF_AdvancedDisplay",
    "CPF_Protected",
    "CPF_BlueprintCallable",
    "CPF_BlueprintAuthorityOnly",
    "CPF_TextExportTransient",
    "CPF_NonPIEDuplicateTransient",
    "CPF_ExposeOnSpawn",
    "CPF_PersistentInstance",
    "CPF_UObjectWrapper",
    "CPF_HasGetValueTypeHash",
    "CPF_NativeAccessSpecifierPublic",
    "CPF_NativeAccessSpecifierProtected",
    "CPF_NativeAccessSpecifierPrivate",
    "CPF_SkipSerialization",
}

local function check_pflag(flags, flag)
    return (flags & EPropertyFlags[flag] ~= 0)
end

local function check_pflags(flags)
    local t = {}
    for k, v in orderedPairs(EPropertyFlags) do
        if flags & v ~= 0 then
            table.insert(t, k)
        end
    end
    return t
end

local function check_property_flags(object, property_name)
    local fprop = object:find_property(property_name)
    if fprop then
        return check_flags(fprop:get_property_flags())
    else
        return nil
    end
end


function _ffield:as_property(struct)
    return struct:find_property(self:get_fname():to_string())
end

function _fproperty:check_flags()
    return check_pflags(self:get_property_flags())
end

function _ffield:check_flags(parent_struct)
    local name = self:get_fname():to_string()
    local parent = self:get_outer() or
        api:find_uobject(self:get_full_name():sub(1, -#name)) or
        parent_struct
    if not parent then return end
    return check_property_flags(parent, name)
end


print("Actor childproperties check flags")
print(inspect(find_fast("Actor"):get_child_properties():as_property(find_fast("Actor")):check_flags()))


function _ffield:is_param(struct)
    return self:as_property(struct):is_param()
end
function _ffield:is_out_param(struct)
    return self:as_property(struct):is_out_param()
end


function _ustruct:get_property_data()
    local t = {}
    local child_properties = self:get_child_properties()
    while child_properties ~= nil do
        local name = child_properties:get_fname():to_string()
        local fprop = self:find_property(name)
        ordered_insert(t, name, {
            type = child_properties:get_class():get_name(),
            flags = fprop:check_flags()})
        child_properties = child_properties:get_next()
    end
    return t
end

function _ustruct:get_property_array()
    local t = {}
    local child_properties = self:get_child_properties()
    while child_properties ~= nil do
        t[#t+1] = child_properties
        child_properties = child_properties:get_next()
    end
    return t
end
function _ustruct:get_property_table()
    local t = {}
    local child_properties = self:get_child_properties()
    while child_properties ~= nil do
        local pname = child_properties:get_fname():to_string()
        t[pname] = child_properties
        t.__orderedIndex = t.__orderedIndex or {}
        t.__orderedIndex[#t.__orderedIndex+1] = pname
        child_properties = child_properties:get_next()
    end
    return t
end

--utest(pawn:get_class(), "get_property_data")


-- get names and types from child_properties
function _uobject:get_property_info()
    local struct = self.as_struct and self:as_struct() or self.get_class and self:get_class():as_struct()
    local s,r = pcall(function()
        local props = {}
        local properties = struct:get_child_properties()
        while properties ~= nil do
            local p = properties:get_fname():to_string()
            local utype = properties:get_class():get_name()
            local fprop = struct:find_property(p)

            props[#props + 1] =  {name = p, type = utype, flags = properties:check_flags(struct)}
            if self:is_instance() then
                props[#props]["Value"] = self[p]
            end
            properties = properties:get_next()
        end

        return props
    end)
    if s then return r end
end

-- get props as objects in a table
function _uobject:get_properties()
    local struct = self.as_struct and self:as_struct() or self.get_class and self:get_class():as_struct()
    local s,r = pcall(function()
        local props = {}
        local properties = struct:get_child_properties()
        while properties ~= nil do
            props[#props + 1] = properties
            properties = properties:get_next()

        end
        return props
    end)
    if s then return r end
end

UEVR_UObject.get_props = UEVR_UObject.get_properties

_ENV.UEVR_UObject =      _uobject
_ENV.UEVR_UStruct =      _ustruct
_ENV.UEVR_UClass =       _uclass
_ENV.UEVR_UFunction =    _ufunction
_ENV.UEVR_FField =       _ffield
_ENV.UEVR_FProperty =    _fproperty
_G.UEVR_UObject =        _uobject
_G.UEVR_UStruct =        _ustruct
_G.UEVR_UClass =         _uclass
_G.UEVR_UFunction =      _ufunction
_G.UEVR_FField =         _ffield
_G.UEVR_FProperty =      _fproperty
