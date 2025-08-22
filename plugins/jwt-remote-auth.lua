local core = require("apisix.core")
local http = require("resty.http")

local plugin_name = "jwt-remote-auth"

local schema = {
    type = "object",
    properties = {
        validation_url = { type = "string" },
        header_auth = { type = "string", default = "Authorization" },
        header_user = { type = "string", default = "X-User-Id" }
   },
    required = { "validation_url" }
}

local _M = {
    version = 0.1,
    priority = 2500, -- run before proxying
    name = plugin_name,
    schema = schema,
}

function _M.check_schema(conf, schema_type)
    local ok, err = core.schema.check(schema, conf)
    if not ok then
        return false, err
    end

    return true
end

function _M.rewrite(conf, ctx)
    core.log.warn("plugin rewrite phase, conf: ", core.json.encode(conf))
    core.log.warn("conf_type: ", ctx.conf_type)
    core.log.warn("conf_id: ", ctx.conf_id)
    core.log.warn("conf_version: ", ctx.conf_version)
end

-- 🔹 1. REWRITE PHASE
function _M.rewrite(conf, ctx)
    core.log.warn("plugin rewrite phase")
end

-- 🔹 2. ACCESS PHASE
function _M.access(conf, ctx)
    core.log.warn("plugin access phase, conf: ", core.json.encode(conf))

    local auth_header = core.request.header(ctx, conf.header_auth)
    core.log.warn("plugin auth header", auth_header)

    if not auth_header then
        return 401, { message = "Missing Authorization header" }
    end

    local httpc = http.new()
    local res, err = httpc:request_uri(conf.validation_url, {
        method = "GET",
        headers = {
            ["Authorization"] = auth_header
        },
        ssl_verify = false,
    })

    local status = res.status
    core.log.warn("status:", status, "res: ", res.body)

    if not res then
        core.log.error("Failed to call validation service: ", err)
        return 500, { message = "JWT validation failed" }
    end

    if res.status ~= 200 then
        return 401, { message = "Invalid token" }
    end

    -- Optional: parse user info from res.body and set to ctx
    core.log.info("JWT validated successfully")

    local body   = core.json.decode(res.body) -- parse str json

    -- set request header
    ngx.req.set_header(conf.header_user, body.id)

    -- optionally log
    core.log.warn("Set header: ", conf.header_user, " = ", body.id)

    return
end

function _M.log(conf, ctx)
    core.log.warn("conf: ", core.json.encode(conf))
    core.log.warn("ctx: ", core.json.encode(ctx, true))
end

return _M