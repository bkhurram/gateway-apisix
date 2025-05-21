local core = require("apisix.core")
local plugin_name = "auth-header"

local schema = {
    type = "object",
    properties = {
        required_headers = {
            type = "array",
            items = {
                type = "string"
            },
            minItems = 1
        }
    },
    required = {"required_headers"}
}

local _M = {
    version = 0.1,
    priority = 2500,
    name = plugin_name,
    schema = schema,
}

function _M.check_schema(conf)
    return core.schema.check(schema, conf)
end

function _M.rewrite(conf, ctx)
    local headers = core.request.headers(ctx)
    
    for _, header_name in ipairs(conf.required_headers) do
        if not headers[header_name:lower()] then
            return 401, { message = "Missing required header: " .. header_name }
        end
    end
end

return _M