require "metatable"

require "obj"

local element2key=obj2str

local insert_set=function(S,element)
	local elements=S.elements
	local key=element2key(element)
	if not elements[key] then
		elements[key]=element
		S.count=S.count+1
	end
	return S
end

local remove_set=function(S,element)
	local elements,count=S.elements,S.count
	local key=element2key(element)
	if count>0 and elements[key] then
		elements[key]=nil
		S.count=count-1
	end
	return S
end

local new_set=function(S,t)
	local s=copy_metatable(S,{elements={},count=0})
	local tp=type(t)
	if tp=="table" then
		for i,v in ipairs(t) do s:insert(v) end
	elseif tp=="number" and t>0 then
		for i=1,t do s:insert(i) end
	end
	return s
end

local element2str
element2str=function(element,head,tail)
	local tp=type(element)
	if tp=="table" and element.__PAIR then
		local t={}
		for i,e in ipairs(element) do
			t[i]=element2str(e)
		end
		return string.format("<%s>",table.concat(t,","))
	else
		return tostring(element)
	end
end

local set2str=function(S)
	local elements=S.elements
	local t={}
	local insert=table.insert
	for k,element in pairs(elements) do
		insert(t,element2str(element))
	end
	return string.format("{%s}",table.concat(t,","))
end

local include=function(S,element)
	return S.elements[element2key(element)]
end

local union=function(A,B)
	local s=A:new()
	for k,a in pairs(A.elements) do
		s:insert(a)
	end
	for k,b in pairs(B.elements) do
		s:insert(b)
	end
	return s
end

local exclude=function(A,B)
	local s=A:new()
	for k,a in pairs(A.elements) do
		if not B:include(a) then s:insert(a) end
	end
	return s
end

local intersection=function(A,B)
	local s=A:new()
	for k,a in pairs(A.elements) do
		if B:include(a) then s:insert(a) end
	end
	return s
end

local insert=table.insert
local make_pair=function(a,b)
	if type(a)~="table" or not a.__PAIR then
		return {a,b,__PAIR=true}
	end
	a=clone(a)
	insert(a,b)
	return a
end

local product=function(A,B)
	local s=A:new()
	for ka,a in pairs(A.elements) do
		for kb,b in pairs(B.elements) do
			s:insert(make_pair(a,b))
		end
	end
	return s
end

local clone_set=function(A)
	return copy_metatable(A,clone(A))
end

local le_set=function(A,B)
	for k,a in pairs(A.elements) do
		if not B:include(a) then return false end
	end
	return true
end

local eq_set=function(A,B)
	return le_set(A,B) and le_set(B,A)
end

local Set_mt=table2metatable{
	new=new_set,
	insert=insert_set,
	remove=remove_set,
	include=include,
	clone=clone_set,
	__tostring=set2str,
	__le=le_set,
	__eq=eq_set,
	__add=union,
	__sub=exclude,
	__mul=intersection,
	__pow=product,
}

Set=setmetatable({},Set_mt)