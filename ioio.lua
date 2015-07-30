local str2file_=function(str,filepath)
	local f=io.open(filepath,"w")
	if f then
		f:write(str)
		f:close()
		return filepath
	end
end

local file2str_=function(filepath)
	local f=io.open(filepath,"r")
	if f then
		local str=f:read("*a")
		f:close()
		return str
	end
end

str2file,file2str=str2file_,file2str_