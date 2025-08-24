local requiredfunc = "playAnimation"
local func
for _,v in pairs(getgc()) do
    if type(v) == "function" and getinfo(v).name == requiredfunc then
        func = v
        break
    end
end
if func then
    print("Hooked: ", getinfo(func).name)
    local hooked
    hooked = hookfunction(func, function(...)
        local args = {...}
        print(getinfo(func).name , " called with arguments:")
        for i = 1, select('#', ...) do
            local arg = args[i]
            print(("Argument %d: %s (Type: %s)"):format(i, tostring(arg), type(arg)))
        end
        
        return hooked(...)
    end)
else
    warn(getinfo(func).name, " function not found")
end