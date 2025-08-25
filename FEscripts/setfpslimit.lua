
if getgenv().enable_fpscap then
    if getgenv().fps_amount ~= nil and tonumber(getgenv().fps_amount) then 
        setfpscap(getgenv().fps_amount)
    else
        setfpscap(20)
    end
 end