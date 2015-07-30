local setmetatable,getmetatable=setmetatable,getmetatable

local clone_ 
clone_=function(src,dst)
	if type(src)~='table' then return src end
	dst= dst or {}
	local rawset=rawset
	for k,v in pairs(src) do
		rawset(dst,clone_(k),clone_(v))
	end
	setmetatable(dst,getmetatable(src))
	return dst
end


local le_
le_=function(a,b,iter_f)
	if a==b then return true end
	iter_f=iter_f or ipairs
	local tp=type(a)
	if tp~=type(b) then return false end
	if tp~="table" then return a<=b end
	for k,v in iter_f(a) do
		if not le_(v,b[k]) then return false end
	end
	return true
end

local eq_=function(a,b,iter_f)
	return le_(a,b,iter) and le_(b,a,iter)
end

local format,concat,insert=string.format,table.concat,table.insert

local obj2str_
obj2str_=function(obj)
	local tp=type(obj)
	if tp=="table" then
		local t={}
		for k,v in pairs(obj) do
			insert(t,format("[%s]=%s",obj2str(k),obj2str(v)))
		end
		return format("{%s}",concat(t,","))
	elseif tp=="string" then
		return format("%q",obj)
	else
		return tostring(obj)
	end
end

local file2obj_=function(filepath)
	return dofile(filepath)
end

clone,le,eq,obj2str,file2obj=clone_,le_,eq_,obj2str_,file2obj_



