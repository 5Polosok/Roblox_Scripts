if getgenv().enable_fpscap then
    if type(setfpscap) == "function" then
        warn("setfpscapisreal")
        if getgenv().fps_amount ~= nil and tonumber(getgenv().fps_amount) then 
            setfpscap(getgenv().fps_amount)
        else
            setfpscap(20)
        end
    else
        warn("setfpscap Function not found!")
    end
end