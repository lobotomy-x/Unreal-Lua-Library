
function __genOrderedIndex(t)
	local orderedIndex = {}
	for key in pairs(t) do
		table.insert(orderedIndex, key)
	end
	table.sort(orderedIndex)
	return orderedIndex
end


-- F
function orderedNext(t, state)
	local key = (t.__orderedIndex ~= nil and state == nil) and t.__orderedIndex[1] or nil
	--print("orderedNext: state = "..tostring(state) )
	if state == nil and t.__orderedIndex == nil then
		-- the first time, generate the index
		t.__orderedIndex = __genOrderedIndex(t)
		key = t.__orderedIndex[1]
	else
		-- fetch the next value
		for i = 1, #t.__orderedIndex do
			if t.__orderedIndex[i] == state then
				key = t.__orderedIndex[i + 1]
			end
		end
	end

	if key then
		return key, t[key]
	end

	-- no more value to return, cleanup
	t.__orderedIndex = nil
	return
end

function orderedPairs(t, keys)
    if keys ~= nil then
		t.__orderedIndex = keys
    end
	return orderedNext, t, nil
end

local params = 
{"bBlockingHit",
"bInitialOverlap",
"Time",
"Distance",
"Location",
"ImpactPoint",
"Normal",
"ImpactNormal",
"PhysMat",
"HitActor",
"HitComponent",
"HitBoneName",
"HitItem",
"ElementIndex",
"FaceIndex",
"TraceStart",
"TraceEnd"}
local function build_out_params()
    local out = {}
    local ordered = {}
    for i, p in pairs(params) do
        out[p] = {}
        table.insert(ordered, p)
    end
    return out, ordered
end



function BreakHitResult()

    local outs, ordered = build_out_params()
    local args = { }
    
    
    -- Correct Order but requires manually setting up a secondary table and demands more flexible thinking 
    
    for i, name in ipairs(ordered) do
		table.insert(args, name)
    end
--bBlockingHit	bInitialOverlap	Time	Distance	Location	
-- ImpactPoint	Normal	ImpactNormal	PhysMat	HitActor	HitComponent
-- HitBoneName	HitItem	ElementIndex	FaceIndex	TraceStart	TraceEnd


    -- Random Order, worthless
    
    -- for name, tbl in pairs(outs) do
    --     table.insert(args, name)
    -- end
 --   HitComponent	HitBoneName	Distance	PhysMat	Time	Normal	bInitialOverlap	
 -- ElementIndex	bBlockingHit	ImpactPoint	TraceEnd	HitItem	FaceIndex
 -- ImpactNormal	Location	HitActor	TraceStart


    -- Correct Order, very easy and simple to use, supports alphabetical order automatically, 
    -- Requires more setup but I've done the work for you 
    
--     for name, tbl in orderedPairs(outs, ordered) do
--         table.insert(args, name)
--     end
--bBlockingHit	bInitialOverlap	Time	Distance	Location	ImpactPoint	Normal	ImpactNormal	
--PhysMat	HitActor	HitComponent	HitBoneName	
--HitItem	ElementIndex	FaceIndex	TraceStart	TraceEnd

        
   print(table.unpack(args))

end
BreakHitResult()

