
local eval_string_=function(str,env)
	env=env or _G
	local f=loadstring("return "..str)
	return setfenv(f,env)()
end

local id=function(o)
	return o
end

str2table=function(str,pattern,process)
	local t,i={},0
	pattern=pattern or "%S+"
	process=process or id
	for w in string.gmatch(str,pattern) do
		i=i+1
		t[i]=process(w)
	end
	return t,i
end

eval_string=eval_string_

