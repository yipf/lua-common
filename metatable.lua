local set_mt,get_mt=setmetatable,getmetatable

copy_metatable=function(src,dst)
	return  set_mt(dst,get_mt(src))
end

table2metatable=function(mt)
	mt=mt or {}
	mt.__index=mt
	return mt
end
