local path = "/usr/local/openresty/nginx/html/static.html"
local f = io.open(path, "r")  
if f then
    local data = f:read("*a")
    ngx.header.content_type = "text/html"
    ngx.print(data)
    f:close()
else
    ngx.status = ngx.HTTP_NOT_FOUND
end