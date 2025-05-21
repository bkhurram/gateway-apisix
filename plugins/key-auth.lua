local core = require("apisix.core")
local plugin_name = "key-auth"

local schema = {
    type = "object",
    properties = {
        header = {
            type = "string",
            default = "apikey"
        },
        key = {
            type = "string"
        }
    },
    required = {"key"}
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
    local apikey = core.request.header(ctx, conf.header)
    if not apikey then
        return 401, { message = "Missing API key" }
    end

    if apikey ~= conf.key then
        return 401, { message = "Invalid API key" }
    end
end

return _M