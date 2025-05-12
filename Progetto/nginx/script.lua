local API_ENDPOINT = os.getenv("API_ENDPOINT")

-- Elasticsearch endpoint and credentials
local elastic_url = os.getenv("ELASTIC_ENDPOINT")
local username = os.getenv("ELASTIC_USERNAME")
local password = os.getenv("ELASTIC_PASSWORD")

-- Auth token for elastic
local credentials = username .. ":" .. password
local auth_header_value = "Basic " .. ngx.encode_base64(credentials)

-- JSON and HTTP libs
local cjson = require "cjson"
local http = require "resty.http"

-- HTTP client for elastic connection
local httpc_elastic = http.new()

-- HTTP client for checker request
local httpc = http.new()
httpc:set_timeout(1000)

local function get_iso8601_timestamp()
    return os.date("!%Y-%m-%dT%H:%M:%SZ") -- '!' forza UTC, 'Z' è per l'offset zero
end

-- Checker results
local results = {}

-- GET and POST params
local args = ngx.req.get_uri_args()
ngx.req.read_body()
local post_args = ngx.req.get_post_args()

-- Function to check one param
local function check_param(param_value)
    local body_data = { p = param_value }
    local json_body = require("cjson").encode(body_data)

    -- Request to checker endpoint
    local res, err = httpc:request_uri(API_ENDPOINT, {
        method = "POST",
        body = json_body,
        headers = {
            ["Content-Type"] = "application/json",
        },
    })

    if not res then
        ngx.log(ngx.ERR, "Request failed: ", err)
        return nil
    end

    -- Ensure res.body is a valid JSON
    local ok, decoded_body = pcall(require("cjson").decode, res.body)
    if not ok then
        ngx.log(ngx.ERR, "Failed to decode JSON response: ", decoded_body)
        return nil
    end

    -- Validate the decoded response is a table
    if type(decoded_body) ~= "table" then
        ngx.log(ngx.ERR, "Unexpected response type: ", type(decoded_body))
        return nil
    end

    return decoded_body
end

local function save_data_to_elastic(json_data)
    -- Requesto to Elasticsearch to save data
    local res_elastic, err_elastic = httpc_elastic:request_uri(elastic_url, {
        method = "POST",
        body = json_data,
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = auth_header_value  -- Add Auth header
        }
    })

    if not res_elastic then
        ngx.say("Failed to send reques to elasticsearch: ", err_elastic)
    end
end

-- Check GET params
if args ~= nil then
	for k, v in pairs(args) do
	    local response = check_param(v)
	    if response then
		results[k] = { value = v, verdict = response.verdict, malicious = response.malicious }
	    else
		results[k] = { value = v, verdict = "Not checked, checker is unreachable.", malicious = false }
	    end
	end
end

-- Check POST params
if post_args ~= nil then
	for k, v in pairs(post_args) do
	    local response = check_param(v)
        local log_line = "Value: " .. v .. " Verdict: " .. response.verdict .. " Malicious: " .. response.malicious
        ngx.log(ngx.ERR, "RESPONSE FOR CHECK POST PARAM: ", log_line)
	    if response then
		results[k] = { value = v, verdict = response.verdict, malicious = response.malicious }
        
	    else
		results[k] = { value = v, verdict = "Not checked, checker is unreachable.", malicious = false }
	    end
	end
end

-- Set flag
local has_malicious = false
for _, result in pairs(results) do
    ngx.log(ngx.ERR, "result.malicious: ", result.malicious)
    ngx.log(ngx.ERR, "result.malicious type: ",type(result.malicious))
    if result.malicious == "True" then
        has_malicious = true
        break
    end
end

ngx.log(ngx.ERR, "has_malicious VALUE FOR CURRENT REQUEST: ", has_malicious)

-- Request's cookies
local cookies_string = ngx.var.http_cookie or ""
local cookies = {}

-- Split the cookie string into key-value pairs
for key, value in string.gmatch(cookies_string, "([^;=]+)=([^;]*)") do
    cookies[key:gsub("^%s*(.-)%s*$", "%1")] = value:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
end

local log_data = {
    -- ID and Time Information
    id = ngx.var.request_id,  -- Unique request ID
    timestamp = get_iso8601_timestamp(),

    -- Request Metadata
    client_ip = ngx.var.remote_addr,  -- Client's IP address
    uri = ngx.var.request_uri,  -- Request URI
    url = ngx.var.scheme .. "://" .. ngx.var.host .. ngx.var.request_uri,  -- Full URL
    method = ngx.req.get_method(),  -- HTTP method (GET, POST, etc.)
    http_version = ngx.req.http_version(),  -- HTTP version (1.0, 1.1, 2, etc.)
    scheme = ngx.var.scheme,  -- Request scheme (http or https)
    server_host = ngx.var.host,  -- Server host
    server_port = ngx.var.server_port,  -- Server port
    user_agent = ngx.var.http_user_agent,  -- User agent
    referer = ngx.var.http_referer or "no referrer",  -- Referrer
    content_length = tonumber(ngx.var.content_length) or 0,  -- Content length as a number
    accept_language = ngx.var.http_accept_language or "not provided",  -- Accept-Language header

    -- Request Data
    body = ngx.var.request_body or "no body",  -- Request body
    cookies = ngx.var.http_cookie or {},  -- Simplify cookie handling to a string or key-value pairs
    query_params = args,  -- Flatten query parameters (params)
    post_params = post_args,  -- Flatten POST parameters
    headers = ngx.req.get_headers(),  -- You could decide to extract key headers if this gets too large

    -- WAF Result (Malicious Request Detection)
    is_malicious = has_malicious or false,  -- Direct boolean flag for quick filtering
    results = results

    -- TODO: Geo-location
}

local key_order = { "id", "timestamp", "client_ip", "uri", "url", "method", "http_version", "scheme", "server_host", "server_port", "user_agent", "referer", "content_length", "accept_language", "body", "cookies", "query_params", "post_params", "headers", "is_malicious", "results" }
save_data_to_elastic(cjson.encode(log_data))

if has_malicious then
    ngx.exec("@block");
    -- ngx.exec("@monitor");
    -- ngx.exec("@static");
    -- ngx.exec("@redirect");
    -- ngx.exec("@timeout");
else
    ngx.exec("@proxy");
end
