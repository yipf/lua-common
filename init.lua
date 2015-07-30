local dir="/home/yipf/lua-common"

local make_pattern=function(pattern)
	return string.format("%s/%s;",dir,pattern)
end

package.path=make_pattern("?.lua")..package.path
package.cpath=make_pattern("?.so")..package.cpath

----------------------------------------------------------------------------------------------------------------
--~ usage(in lua):
--~ dofile "path-of-this file"
----------------------------------------------------------------------------------------------------------------

