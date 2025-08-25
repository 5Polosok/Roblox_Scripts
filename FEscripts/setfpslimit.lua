
if getgenv().setfpscap then
    if getgenv().fpsamount ~= nil and tonumber(getgenv().fpsamount) then 
        setfpscap(getgenv().fpsamount)
    else
        setfpscap(20)
    end
 end