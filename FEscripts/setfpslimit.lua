if getgenv().enable_fpscap then
    if type(setfpscap) == "function" then
        warn("setfpscapisreal")
        if getgenv().fps_amount ~= nil and tonumber(getgenv().fps_amount) then 
            while task.wait(10) do
                setfpscap(getgenv().fps_amount)
            end
        else
            while task.wait(10) do
                setfpscap(20)
            end
        end
    else
        warn("setfpscap Function not found!")
    end
end