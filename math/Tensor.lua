require "metatable"

local new_tensor=function(T,n)
	local t=copy_metatable(T,{})
	local tp=type(n)
	if tp=="table" then
		for i,v in ipairs(n) do t[i]=v end
	elseif tp=="number" and n>0 then
		for i=1,n do t[i]=i end
	end
	return t
end

require "obj"

local clone_tensor=function(T)
	return clone(T)
end

local element2str
element2str=function(element)
	if type(element)~="table" then return tostring(element) end
	local t={}
	for i,e in ipairs(element) do
		t[i]=element2str(e)
	end
	return string.format(element.__ISPAIR and "<%s>" or "[%s]",table.concat(t,","))
end

local map=function(T,func,value)
	if type(T)=="table" then
		for i,v in ipairs(T) do
			T[i]=func(v,value,i)
		end
	end
	return T
end

local unm
unm=function(T)
	if type(T)=="table" then
		T=clone(T)
		for i,v in ipairs(T) do
			T[i]=unm(v)
		end
	else
		return -T
	end
	return T
end

local gen_tensor_operator=function(op)
	local tensor_operator
	tensor_operator=function(A,B)
		local ta,tb=type(A),type(B)
		if tb=='table' then
			A=clone(A)
			assert(#A==#B,"Inputs must have same elements")
			for i,a in ipairs(A) do A[i]=tensor_operator(a,B[i]) end
			return A
		else
			return ta=='table' and map(clone_tensor(A),tensor_operator,B) or op(A,B)
		end
	end
	return tensor_operator
end

local add=gen_tensor_operator(function(a,b) return a+b end)
local sub=gen_tensor_operator(function(a,b) return a-b end)
local mul=gen_tensor_operator(function(a,b) return a*b end)
local div=gen_tensor_operator(function(a,b) return a/b end)

local reduce
reduce=function(T,func,value)
	if type(T)=="table" then
		for i,v in ipairs(T) do value=reduce(v,func,value) end
	else
		return func(T,value)
	end
	return value
end

local gen_tensor_reduce_func=function(func,value)
	return function(T)
		return reduce(T,func,value)
	end
end

local nrm=gen_tensor_reduce_func(function(v,value) return v+value end,0)
local nrm2=gen_tensor_reduce_func(function(v,value) return v*v+value end,0)

local gen_tensor_test_func=function(A,B,func)
	if type(T)=="table" then
		for i,v in ipairs(T) do value=reduce(v,func,value) end
	else
		return func(T,value)
	end
	return value
end

local gen_tensor_test_func=function(test_f)
	local test_operator
	test_operator=function(A,B)
		local ta,tb=type(A),type(B)
		if tb=='table' then
			assert(#A==#B,"Inputs must have same elements")
			for i,a in ipairs(A) do 
				if not test_operator(a,B[i]) then return false end
			end
			return true
		else
			if ta=='table' then
				for i,a in ipairs(A) do 
					if not test_operator(a,B) then return false end
				end
				return true
			else
				return test_f(A,B)
			end
		end
	end
	return test_operator
end

local eq=gen_tensor_test_func(function(a,b)  return a==b end)
local le=gen_tensor_test_func(function(a,b) return a<=b end)

local index_tensor=function(T,...)
	local args={...}
	for i=1,#args do
		if type(T)~='table' then return T end
		T=T[args[i]]
	end
	return T
end

local make_pair=function(a,b)
	return {__ISPAIR=true,a,b}
end

local gen_span_space=function(A,B,func)
	local S,row={}
	func=func or make_pair
	for i,a in ipairs(A) do
		row={}
		for j,b in ipairs(B) do
			row[j]=func(a,b)
		end
		S[i]=row
	end
	return S
end

local product=function(A,B)
	local p=gen_span_space(A,B,make_pair)
	return new_tensor(A,p)
end

local dims=function(T)
	local ds,i={},0
	while type(T)=="table" and not T.__ISPAIR do
		i=i+1
		ds[i]=#T
		T=T[1]
	end
	return ds,i
end

local basic_func_table={
	new=new_tensor,
	clone=clone_tensor,
	transpose=transpose_tensor,
	map=map,
	reduce=reduce,
	nrm=nrm,
	nrm2=nrm2,
	dims=dims,
	__tostring=element2str,
	__le=le,
	__eq=eq,
	__add=add,
	__sub=sub,
	__mul=mul,
	__div=div,
	__unm=unm,
	__call=index_tensor,
	__pow=product,
}

local Tensor_mt=table2metatable(clone(basic_func_table))

Tensor=setmetatable({},Tensor_mt)

--------------------------------------------------------
-- vector
--------------------------------------------------------

local dot=function(A,B)
	assert(type(B)=='table' and #A==#B,"Input vectors must have same number of elements!")
	local sum=0
	for i,v in ipairs(A) do		sum=sum+v*B[i]	end
	return sum
end

local Vector_mt=table2metatable(clone(basic_func_table))
Vector_mt.__mod=dot

Vector=setmetatable({},Vector_mt)

--------------------------------------------------------
-- metrix
--------------------------------------------------------

local column=function(M,j)
	local col={}
	for i,row in ipairs(M) do
		col[i]=row[j]
	end
	return Vector:new(col)
end

local row=function(M,i)
	return Vector:new(M[i])
end

local transpose=function(M)
	local dims=M:dims()
	local r,c=unpack(dims)
	local m={}
	for i=1,c do
		m[i]=M:column(i)
	end
	return M:new(m)
end

local matrix_mul=function(M,A)
	local dims1,dims2=M:dims(),A:dims()
	assert(dims1[2]==dims2[1],"The column of first matrix must equal the row of second matrix")
	A=transpose(A)
	local m,row={}
	for i,mrow in ipairs(M) do
		row={}
		for j,arow in ipairs(A) do
			row[j]=dot(mrow,arow)
		end
		m[i]=row
	end
	return M:new(m)
end

local Matrix_mt=table2metatable(clone(basic_func_table))
Matrix_mt.transpose=transpose
Matrix_mt.column=column
Matrix_mt.row=row
Matrix_mt.__mod=matrix_mul

Matrix=setmetatable({},Matrix_mt)

