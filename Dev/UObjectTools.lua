local UObjectTools = {}

local api = uevr.api
local dump_count = 0
local inspect = require("inspect")



local function try_get_properties_size(object)
	local s,r = pcall(function()
		local o = (object and (object.as_class and object:as_class()) or (object.get_class and object:get_class()))
		return (o and o.as_struct and o:as_struct():get_properties_size()) or nil
	end)
	if s then return r end
end

local function get_prop_entries(props)
	local t = {}
	if props == nil then
		return nil
	end
	for idx, val in ipairs(props) do
		local str = "\t\t" .. val.type .. "\t" .. val.name
		if val.value then
			str = str
				.. " = "
				.. (
					(type(val.value) == "userdata" and val.value.to_string) and val.value:to_string()
					or tostring(val.value)
				)
		end
		table.insert(t, str .. "\n")
	end
	return t
end

-- version for ingame menu inspection
local function get_props_lite(obj)
	local prop_buf = {}
	local params = obj:as_function() ~= nil and {} or nil
	if params then params.__orderedIndex = {} end
	prop_buf.__orderedIndex = {}
	local object = (obj:as_function() or (obj:as_class() or obj:get_class()):as_struct()) or obj:as_struct()
	if not object then return nil end
	local child_properties = object:get_child_properties()
	if child_properties == nil then
		return nil
	end
	local prop_index = 0
	while child_properties ~= nil do
		local utype = child_properties.get_class and child_properties:get_class():get_name()
		local name = child_properties.get_fname and child_properties:get_fname() and child_properties:get_fname():to_string()
		prop_buf[name] = {
			type = utype
		}
		table.insert(prop_buf.__orderedIndex, name)
		child_properties = child_properties:get_next()
	end
	for name, tbl in orderedPairs(prop_buf) do
		local fprop = object:find_property(name)
		if fprop then
			tbl.offset = fprop:get_offset()
		    tbl.pod = fprop.is_pod and fprop:is_pod()
		    if params ~= nil then
				if fprop.is_param and fprop:is_param() then
					tbl.is_param = true
					ordered_insert(params, name,
					{
						is_out_param = fprop:is_out_param(),
						is_return_param = fprop:is_return_param(),
						is_reference_param = fprop:is_reference_param()
					})
				end
			end
		end
	end

	return prop_buf, params
end

-- works on all uevr_ustruct types
local function get_properties_as_table(obj)
	local prop_buf = {}
	local object = (obj:as_function() or (obj:as_class() or obj:get_class()):as_struct())
	if object == nil then return end
	local child_properties =  object:get_child_properties()
	if child_properties == nil then
		return nil
	end
	local prop_index = 0
	while child_properties ~= nil do
		local prop_entry = {
			type = child_properties.get_class and child_properties:get_class():get_name(),
			name = child_properties.get_fname and child_properties:get_fname() and child_properties:get_fname():to_string(),
			index = prop_index
		}
        -- if the object is an instance we can try to get the values
        if not (object:as_class() or object:as_struct() or object:as_function()) then
			local value = object:get_property(child_properties:get_fname():to_string())
			if prop_entry.type == "StructProperty" then
                prop_entry.value = inspect(value)
			elseif prop_entry.type == "NameProperty" then prop_entry.value = value:to_string()
			elseif prop_entry.type:contains("ObjectProperty") then
				local Value = object[Property:get_fname():to_string()]
				if Value ~= nil then
					value = Value
				end
			elseif prop_entry.type == "ArrayProperty" then
				local t = {}
				for _, arraymember in ipairs(value) do
					table.insert(t, arraymember and (arraymember.get_fname and arraymember:get_fname():to_string() or arraymember.to_string and arraymember:to_string() or tostring(arraymember)))
				end
				prop_entry.value = t
			end
			if value ~= nil then
				prop_entry.value = value
			end
		end
		table.insert(prop_buf, prop_entry)
		prop_index = prop_index + 1
		child_properties = child_properties:get_next()
	end
	for i, data in ipairs(prop_buf) do
		local fprop = object:find_property(data.name)
		if fprop then
			local t = data
			t.offset = fprop.get_offset and fprop:get_offset()
			if fprop.is_param and fprop:is_param() then
				t["param_info"] = {
					is_param = true,
					index = t.index,
					is_out_param = fprop:is_out_param(),
					is_return_param = fprop:is_return_param(),
					is_reference_param = fprop:is_reference_param(),
				}
			-- don't really need this info with parameters
			-- actually I don't know that we need it at all but it can't hurt
			else

				t.pod = fprop.is_pod and fprop:is_pod()
				t.property_flags = fprop.get_property_flags and fprop:get_property_flags()
			end
			prop_buf[i] = t
		end
	end

	return prop_buf
end
local function get_flags_lite(obj, newlines)
	if obj:as_function() then
		local flags = obj:as_function():check_flags()
		if flags and #flags > 0 then
			return flags
		end
	else
		return nil
	end
end
local function get_flags_as_table(obj, newlines)
	if obj:as_function() then
		local flags = obj:as_function():check_flags()
		if flags and #flags > 0 then
			if newlines then
				local t = {}
				for idx, val in ipairs(flags) do
					t[idx] = "\t\t" .. val .. "\n"
				end
				return t
			else
				return flags
			end
		end
	else
		return nil
	end
end

-- "/Script/Engine" → "Engine"
local function namespace_to_dir(ns)
    return ns:gsub("^/", "_"):gsub("/", "_")

end

-- not gonna bother doing my usual type handling, just pass a ufunction
function UObjectTools.ufunction_parameter_table(ufunc)
	local flags = get_flags_as_table(ufunc)
	local params = get_properties_as_table(obj)

end


function UObjectTools.property_table(object)
	return get_properties_as_table(object)
end

function UObjectTools.function_flags_table(obj, newlines)
	return get_flags_as_table(obj, newlines)
end



function UObjectTools.load_mod_actors()
	local t = {}
	pc = pc or api:get_player_controller(0)
		local arr = UEVR_FUObjectArray.get()
		for i = 0, arr:get_object_count() - 1 do
		local obj = arr:get_object(i)
			if obj and obj.as_class and obj:as_class() and (obj:as_class():get_full_name():contains("ModActor")) then
				local ma = api:spawn_object(obj, pc:get_outer())
				t[obj:as_class():get_full_name()] = ma
				t.__orderedIndex[#t.__orderedIndex+1] = ma
			end
		end
end




function UObjectTools.dump_namespaces()
	-- default to true if nil
	local last_namespace = nil

	local namespace_arrays = {}
	local array_data = {}
	local array_chunks = 1
	local current_chunk = 1
	local arr = UEVR_FUObjectArray.get()
	array_data.instance = arr
	array_data.chunked = arr:is_chunked()
	array_data.inlined = arr:is_inlined()
	array_data.offset = arr:get_objects_offset()
	array_data.distance = arr:get_item_distance()
	array_data.count = arr:get_object_count()
	array_data.ptr = arr:get_objects_ptr()
	local uobjects, uclasses, ufunctions, ustructs = {}
	for i = 0, arr:get_object_count() - 1 do
		local obj = arr:get_object(i)
			if obj and obj:to_string() ~= "" then

		local utype = obj:to_string():split(" ")[1]
		local namespace = obj:to_string():sub(#utype)
		if namespace:contains(".") then namespace = namespace:split(".")[1]
		end


		last_namespace = last_namespace or namespace
			local fname = obj:get_fname():to_string()
			local entry = {
				full_name = obj:to_string(),
				type = utype,
				mem_address = obj:get_address(),
				outer = obj:get_outer() and obj:get_outer():to_string(),
				uobject_index = i
			}

				namespace_arrays = namespace_arrays or {}
				namespace_arrays[namespace] = namespace_arrays[namespace] or {}
				local ns = namespace_arrays[namespace]
				ns.classes = ns.classes or {}
				ns.structs = ns.structs or {}
				ns.functions = ns.functions or {}
				ns.objects = ns.objects or {}
				if obj:as_struct() ~= nil then
					local property_data	, params = get_props_lite(obj)
					if obj:as_function() ~= nil then
						ordered_insert(ns.functions, obj:to_string(), params)
						entry.params = params
						local parent_class = obj:get_outer():get_fname():to_string()
						ns.classes[parent_class] = ns.classes[parent_class] or {}
						ordered_insert(ns.classes[parent_class], fname, entry)
					elseif obj:as_class() ~= nil then
						entry.property_data = property_data
						if obj.get_super_struct then
								entry.super = obj:get_super_struct():to_string()
							end
						ordered_insert(ns.classes, fname, entry)
					else
						entry.property_data = property_data
												if obj.get_super_struct then

						entry.super = obj:get_super_struct():to_string()
					end
						ordered_insert(ns.structs, fname, entry)
					end
				else
					ordered_insert(ns.objects, fname, entry)
				end
			end
		end
	for namespace, tbls in orderedPairs(namespace_arrays) do
		local nsn = (namespace:contains("/Script/") and (namespace:split("/Script/")[2]))
			or namespace:split("/Game/")[2]
		for utype, tbl in orderedPairs(tbls) do
			-- json.dump_file("UObjectModules\\"..nsn.."\\"..utype..".json", tbl, 4)
			fs.write("UObjectTest\\"..nsn.."\\"..utype..".txt", inspect(tbl))
		end
	end

end

function UObjectTools.test()
	t = {}
	local arr = UEVR_FUObjectArray.get()
	for i = 0, arr:get_object_count() - 1 do
		local obj = arr:get_object(i)
		if obj ~= nil then
			local systempath = Kismet("System"):GetSystemPath(obj)
			local path =Kismet("System"):GetPathName(obj)
			if path and systempath then
			table.insert(t, {systempath, path, obj:to_string()})
		end
	end
	end
json.safe_dump("test.json", t, 4)
end

local namespaces = {}
local classes = {}
local structs = {}
local function find_classes(arr)
	local t = {}
	for i = 0, arr:get_object_count() - 1 do
	local obj = arr:get_object(i)
		if obj and obj:to_string() ~= ""
		and obj.as_class and obj:as_class()
		then
		local fname = obj:get_fname():to_string()
		local fullname = obj:to_string()
		local parts = fullname:split(".")
		local ns = parts[1]


end
end
end




function UObjectTools.new_dump()
	-- default to true if nil
	local last_namespace = nil

	local namespace_arrays = {}
	local array_data = {}
	local array_chunks = 1
	local current_chunk = 1
	local arr = UEVR_FUObjectArray.get()
	array_data.instance = arr
	array_data.chunked = arr:is_chunked()
	array_data.inlined = arr:is_inlined()
	array_data.offset = arr:get_objects_offset()
	array_data.distance = arr:get_item_distance()
	array_data.count = arr:get_object_count()
	array_data.ptr = arr:get_objects_ptr()
	local uobjects, uclasses, ufunctions, ustructs = {}
	for i = 0, arr:get_object_count() - 1 do
		local obj = arr:get_object(i)
			if obj and obj:to_string() ~= "" then

		local utype = obj:to_string():split(" ")[1]
		local namespace = obj:to_string():sub(#utype + 1)
		if namespace:contains(".") then namespace = namespace:split(".")[1]

		end


		last_namespace = last_namespace or namespace
			local fname = obj:get_fname():to_string()
			local entry = {
				full_name = obj:to_string(),
				type = utype,
				mem_address = obj:get_address(),
				outer = obj:get_outer() and obj:get_outer():to_string(),
				uobject_index = i
			}

				namespace_arrays = namespace_arrays or {}
				namespace_arrays[namespace] = namespace_arrays[namespace] or {}
				local ns = namespace_arrays[namespace]
				ns.classes = ns.classes or {}
				ns.structs = ns.structs or {}
				ns.functions = ns.functions or {}
				ns.objects = ns.objects or {}
				if obj:as_struct() ~= nil then
					local property_data	, params = get_props_lite(obj)
					if obj:as_function() ~= nil then
						ordered_insert(ns.functions, obj:to_string(), params)
						entry.params = params
						local parent_class = obj:get_outer():get_fname():to_string()
						ns.classes[parent_class] = ns.classes[parent_class] or {}
						ordered_insert(ns.classes[parent_class], fname, entry)
					elseif obj:as_class() ~= nil then
						entry.property_data = property_data
						if obj.get_super_struct then
								entry.super = obj:get_super_struct():to_string()
							end
						ordered_insert(ns.classes, fname, entry)
					else
						entry.property_data = property_data
												if obj.get_super_struct then

						entry.super = obj:get_super_struct():to_string()
					end
						ordered_insert(ns.structs, fname, entry)
					end
				else
					ordered_insert(ns.objects, fname, entry)
				end
			end
		end
	for namespace, tbls in orderedPairs(namespace_arrays) do
		local nsn = (namespace:contains("/Script/") and (namespace:split("/Script/")[2]))
			or namespace:split("/Game/")[2]
		for utype, tbl in orderedPairs(tbls) do
			-- json.dump_file("UObjectModules\\"..nsn.."\\"..utype..".json", tbl, 4)
			fs.write("UObjectTest\\"..nsn.."\\"..utype..".txt", inspect(tbl))
		end
	end

end

local static_funcs
function UObjectTools.find_static_funcs()
	if static_funcs == nil then
		static_funcs = {}
		local arr = UEVR_FUObjectArray.get()

		for i = 0, arr:get_object_count() - 1 do

			local obj = arr:get_object(i)
			if obj ~= nil then
			local func = obj.as_function and obj:as_function()
			if func ~= nil then
				if func:check_flag("is_static") then
					ordered_insert(static_funcs, func:to_string(), {
						flags = func:check_flags(),
						params = func:get_param_info(),
						cdo = func:get_outer():get_class_default_object()
					})
				end
			end
		end
		end
	end
	return static_funcs
end


function static_func_caller(cdo, func, args)
	cdo = cdo or func:get_outer():as_class():get_class_default_object()


end

function UObjectTools.dump_to_json(chunk_count, dump_namespaces, dump_types)
	-- default to true if nil
	dump_namespaces = true or dump_namespaces == false
	dump_types = true or dump_types == false
	local last_namespace = nil
	local dump_chunk = false
	if dump_namespaces then
		local namespace_arrays = {}
	end
	if dump_types then
		local type_arrays = {}
	end
	local array_data = {}
	local array_chunks = 1
	local current_chunk = 1
	local arr = UEVR_FUObjectArray.get()
	array_data.instance = arr
	array_data.chunked = arr:is_chunked()
	array_data.inlined = arr:is_inlined()
	array_data.offset = arr:get_objects_offset()
	array_data.distance = arr:get_item_distance()
	array_data.count = arr:get_object_count()
	array_data.ptr = arr:get_objects_ptr()
	chunk_count = chunk_count or 4
	local chunk_size = math.ceil(array_data.count / chunk_count)
	json.dump_file("UObjectArray\\array_properties.json", array_data, 4)
	local uobjects = {}
	for i = 0, arr:get_object_count() - 1 do
		local obj = arr:get_object(i)
			if obj and obj:to_string() ~= "" then

		local utype = (obj:to_string():split(" "))
		local namespace = (obj:to_string():split(" ")[2]:split("."))[1]
		last_namespace = last_namespace or namespace
		if (i % chunk_size == 0) then dump_chunk = true end
			local entry = {
				fname = obj:get_fname():to_string(),
				full_name = obj:to_string(),
				object_index = i,
				-- if I just put address lua will automatically sort it first when dumping to json
				mem_address = to_hex_string(obj:get_address()),
				type = utype,
				property_binary_size = try_get_properties_size(obj),
				property_data = get_properties_as_table(obj),
				function_flags = get_flags_as_table(obj),
				outer = obj:get_outer() and obj:get_outer():to_string(),
				namespace = namespace,
			}
			table.insert(uobjects, entry)
			if dump_namespaces then
				namespace_arrays = namespace_arrays or {}
				namespace_arrays[namespace] = namespace_arrays[namespace] or {}
				table.insert(namespace_arrays[namespace], entry)
			end
			if dump_types then
				type_arrays = type_arrays or {}
				type_arrays[utype[1]] = type_arrays[utype[1]]  or {}
				table.insert(type_arrays[utype[1]], entry)
			end
		end
		if namespace ~= last_namespace and dump_chunk then
			json.dump_file("UObjectArray\\objects_chunk"..tostring(current_chunk)..".json", uobjects, 4)
			dump_chunk = false
			current_chunk = current_chunk + 1
			uobjects = {}
		end
	end
	if dump_namespaces then
		for namespace, objects in pairs(namespace_arrays) do

			json.dump_file("UObjectArrayModules\\"..namespace..".json", objects, 4)
		end
		end
	if dump_types then
		for utype, objects in pairs(type_arrays) do
			json.dump_file("UObjectTypes\\"..utype..".json", objects, 4)
		end
	end
	json.dump_file("UObjectArray\\objects_chunk"..tostring(current_chunk)..".json", uobjects, 4)
end


function UObjectTools.dump_funcs_to_json()
    local arr = UEVR_FUObjectArray.get()
	local uobjects = {}
	for i = 0, arr:get_object_count() - 1 do
		local obj = arr:get_object(i)
		if obj and obj:as_function() or obj:to_string().split()[1].endswith("Function") then
			local entry = {
				fname = obj:get_fname():to_string(),
				full_name = obj:to_string(),
				uobject_index = i,
				-- if I just put address lua will automatically sort it first when dumping to json
				mem_address = to_hex_string(obj:get_address()),
				type = obj:to_string():split()[1],
				function_flags = obj:check_flags()
			}
			table.insert(uobjects, entry)
		end
	end
	json.dump_file("functionarray.json", uobjects, 4)
end


function UObjectTools.dump_all_objects()
	dump_count = dump_count + 1
	local array = UEVR_FUObjectArray.get()
	local file_path = string.format("object_dump_%d.txt", dump_count)
	local file = io.open(file_path, "w")

	if not file then
		print("Failed to open file for writing:", file_path)
		return
	end

	file:write("Chunked: ", tostring(array:is_chunked()), "\n")
	file:write("Inlined: ", tostring(array:is_inlined()), "\n")
	file:write("Objects offset: ", array:get_objects_offset(), "\n")
	file:write("Item distance: ", array:get_item_distance(), "\n")
	file:write("Object count: ", array:get_object_count(), "\n")
	file:write("------------\n")
	-- local extra_lines = 0
	for i = 0, array:get_object_count() - 1 do
		-- local i = idx + extra_lines
		local obj = array:get_object(i)
		if obj and obj:to_string() ~= "" then
			local flags = get_flags_as_table(obj, true)
			local prop_size = try_get_properties_size(obj)
			local props = prop_size and get_prop_entries(get_properties_as_table(obj))
			if props then
				file:write(
					i,
					" ",
					obj:to_string(),
					" [" .. tostring(obj:get_address()) .. "]",
					"\n",
					"\t\tProperties Size: ",
					prop_size,
					"\n",
					table.unpack(props)
				)
			if flags then
				file:write(
					i,
					" ",
					obj:to_string(),
					" [" .. tostring(obj:get_address()) .. "]",
					"\n",
					"\t\tFunction Flags: ",
					"\n",
					table.unpack(flags)
				)
			else
				file:write(i, " ", obj:to_string(), " [" .. tostring(obj:get_address()) .. "]", "\n")
			end
		end
	end

	file:close()
	print("Dumped UObjectArray to:", file_path)
end

-- Find object by class name (e.g., "Function", "Class", etc.)
function UObjectTools.find_by_class(class_name)
	local array = UEVR_FUObjectArray.get()
	local results = {}

	for i = 0, array:get_object_count() - 1 do
		local obj = array:get_object(i)
		if obj and obj:get_class():get_fname():to_string() == class_name then
			table.insert(results, {
				index = i,
				name = obj:to_string(),
				outer = obj:get_outer() and obj:get_outer():to_string() or "None",
			})
		end
	end

	return results
end



local array = UEVR_FUObjectArray.get()

function UObjectTools.find_class_functions()
	local function_full_names = {}
	local funcs = {}
	local array = UEVR_FUObjectArray.get()
	for i = 0, array:get_object_count() - 1 do
		local obj = array:get_object(i)
		if obj and obj:as_function() ~= nil then
			table.insert(function_full_names, obj:to_string())
			local parent = obj:get_outer()
			local name = obj:get_fname():to_string()
			local parent_name = parent and parent.get_full_name and parent:to_string()
			if parent_name then
				pcall(function()
				if not funcs[parent_name] then funcs[parent_name] = {} end
				if not funcs[parent_name]["parent_info"] then funcs[parent_name]["parent_info"] = {
					fname = parent:get_fname():to_string(),
					full_name = parent_name,
					uobject_index = i,
					mem_address = to_hex_string(parent:get_address()),
					type = parent:to_string():split()[1],
					property_binary_size = try_get_properties_size(parent),
					property_data = get_properties_as_table(parent),

				} end
				if not funcs[parent_name]["functions"] then funcs[parent_name]["functions"]  = {} end

				if not funcs[parent_name]["functions"][name] then funcs[parent_name]["functions"][name] = {} end
				funcs[parent_name]["functions"][name].uobject_index = i
				funcs[parent_name]["functions"][name].full_name = obj:to_string()
				funcs[parent_name]["functions"][name].mem_address = to_hex_string(obj:get_address())
				funcs[parent_name]["functions"][name].function_flags = obj:check_flags()
					local params = obj:get_param_info()
					if params ~= nil then
						-- for k, v in pairs(params) do
						-- 	if v.is_out_param and v:is_out_param() then params.k["out"] = true end
						-- 	if v.is_reference_param and v:is_reference_param() then params.k["reference"] = true end
						-- 	if v.is_return_param and v:is_return_param() then params.k["return"] = true end
						-- end
						funcs[parent_name]["functions"][name].params = params
					end


				end)
			end
		end
	end
	json.dump_file("class_functions.json", funcs, 4)
	json.dump_file("function_full_names.json", function_full_names, 4)
	return funcs
end
-- Find function by name and return its outer class
function UObjectTools.find_items()
	local objects = {}
	local array = UEVR_FUObjectArray.get()
	for i = 0, array:get_object_count() - 1 do
		local obj = array:get_item(i)
		if obj ~= nil then
			local parent = obj:get_outer()
			local name = obj:get_fname():to_string()
			local parent_name = parent and parent.get_full_name and parent:to_string()
			if parent_name then
				pcall(function()
				if not objects[parent_name] then objects[parent_name] = {} end
				if not objects[parent_name]["parent_info"] then objects[parent_name]["parent_info"] = {
					fname = parent:get_fname():to_string(),
					full_name = parent_name,
					mem_address = to_hex_string(parent:get_address()),
					type = parent:to_string():split()[1],
					property_binary_size = try_get_properties_size(parent),
					property_data = get_properties_as_table(parent),

				} end
				if not objects[parent_name]["functions"] then objects[parent_name]["functions"]  = {} end

				if not objects[parent_name]["functions"][name] then objects[parent_name]["functions"][name] = {} end
				objects[parent_name]["functions"][name].uobject_index = i
				objects[parent_name]["functions"][name].full_name = obj:to_string()
				objects[parent_name]["functions"][name].mem_address = to_hex_string(obj:get_address())
				objects[parent_name]["functions"][name].function_flags = get_flags_as_table(obj)
					local params = get_properties_as_table(obj)
					if params ~= nil then
						objects[parent_name]["functions"][name].params = params
					end


				end)
			end
		end
	end
	json.dump_file("uitems.json", objects, 4)
	return objects
end

-- Find function by name and return its outer class
function UObjectTools.find_objects()
	local objects = {}
	local array = UEVR_FUObjectArray.get()
	for i = 0, array:get_object_count() - 1 do
		local obj = array:get_object(i)
		if obj ~= nil then
			local parent = obj:get_outer()
			local name = obj:get_fname():to_string()
			local parent_name = parent and parent.get_full_name and parent:to_string()
			if parent_name then
				pcall(function()
				if not objects[parent_name] then objects[parent_name] = {} end
				if not objects[parent_name]["parent_info"] then objects[parent_name]["parent_info"] = {
					fname = parent:get_fname():to_string(),
					full_name = parent_name,
					mem_address = to_hex_string(parent:get_address()),
					type = parent:to_string():split()[1],
					property_binary_size = try_get_properties_size(parent),
					property_data = get_properties_as_table(parent),

				} end
				if not objects[parent_name]["functions"] then objects[parent_name]["functions"]  = {} end

				if not objects[parent_name]["functions"][name] then objects[parent_name]["functions"][name] = {} end
				objects[parent_name]["functions"][name].uobject_index = i
				objects[parent_name]["functions"][name].full_name = obj:to_string()
				objects[parent_name]["functions"][name].mem_address = to_hex_string(obj:get_address())
				objects[parent_name]["functions"][name].function_flags = get_flags_as_table(obj)
					local params = get_properties_as_table(obj)
					if params ~= nil then
						objects[parent_name]["functions"][name].params = params
					end


				end)
			end
		end
	end
	json.dump_file("uobjects.json", objects, 4)
	return objects
end

local merged_ufuncs = nil
-- Find function by name and return its outer class
function UObjectTools.find_functions()
	--local funcs = {}
	local array = UEVR_FUObjectArray.get()
	for i = 0, array:get_object_count() - 1 do
		local obj = array:get_object(i)
		if obj and obj:as_function() ~= nil then
			local parent = obj:get_outer():to_string()
			local name = obj:get_fname():to_string()
			merged_ufuncs = merged_ufuncs or {}
			merged_ufuncs[name] = merged_ufuncs[name] or {}
			merged_ufuncs[name][parent]  = {
				parent = parent:to_string(),
				flags = obj:as_function():check_flags(),
			}

			merged_ufuncs[name].params = merged_ufuncs[name].params or obj:as_function():get_param_info()



				-- table.insert(funcs,	{
				-- 	index = i,
				-- 	function_name = name,
				-- 	params = get_properties_as_table(obj),
				-- 	class = parent and parent.get_full_name and parent:to_string() or "",
				-- 	full_name = obj:to_string(),
				-- 	mem_address = to_hex_string(obj:get_address()),
				-- 	function_flags = get_flags_as_table(obj),
				-- })
		end
	end
	fs.write("mergedfuncs.txt", inspect(merged_ufuncs))
	json.dump_file("merged_functions.json", merged_ufuncs, 4)
--	json.dump_file("functions.json", funcs, 4)
	return merged_ufuncs
end


-- Find function by name and return its outer class
function UObjectTools.find_function_and_class(func_name)
	local array = UEVR_FUObjectArray.get()

	for i = 0, array:get_object_count() - 1 do
		local obj = array:get_object(i)
		if obj and obj:as_function() ~= nil then
			local name = obj:get_fname():to_string()
			if name == func_name or obj:to_string():find(func_name, 1, true) then
				local outer = obj:get_outer()
				while outer:get_class():get_super():find_function(func_name) ~= nil do
					outer = outer:get_class():get_super()
				end
				return {
					index = i,
					function_name = name,
					full_name = obj:to_string(),
					outer_class = outer:get_class(),
					outer = outer,
					function_flags = get_flags_as_table(obj),
				}
			end
		end
	end

	return nil
end

return UObjectTools