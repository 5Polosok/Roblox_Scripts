local the_table = {}
    for _,v in pairs(getgc()) do
        if type(v) == "function" then
            table.insert(the_table, getinfo(v).name)
        end
    end


local httpservice = game:GetService("HttpService")
writefile("RaCc0oNHubGetGC.txt", httpservice:JSONEncode(the_table))