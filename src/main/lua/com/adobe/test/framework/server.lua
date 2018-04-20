---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by trifan.
--- DateTime: 20/04/2018 10:49
---
local ev = require'ev'
local cjson = require 'cjson'

local Server = {}

function Server:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end


function Server:start()
    -- create a copas webserver and start listening
    self.server = require'websocket'.server.ev.listen
    {
        -- listen on port 8080
        port = 9333,
        -- the protocols field holds
        --   key: protocol name
        --   value: callback on new connection
        protocols = {
            echo = self.handler
        },
        default = self.handler
    }

    -- use the lua-ev loop
    ev.Loop.default:loop()
end

function Server:enhanceClient(ws)
    ws.handlers = {}
    function ws:on(message, handler)
        self.handlers[message] = handler
    end
end

function Server:handler(ws)
    self:enhanceClient(ws)
    self:_registerHandlers(ws)

    ws:on_message(function(ws,message)
        local decodedMessage = cjson.decode(message)
        if ws.handlers[decodedMessage.event] then
            local status, data = pcall(ws.handlers[decodedMessage.event], decodedMessage.data)
            if not status then
                print("failed handler ", tostring(data))
            end
        else
            print( "no handler for message type ", decodedMessage.event)
        end
    end)
end

function Server:_registerHandlers(webSocketConnection)
    local parent = self

    webSocketConnection:on("continue", function()
        parent:writeFile("/etc/api-gateway/continue", "continue")
    end)

    webSocketConnection:on("introspect", function(message)
        local content = parent:readFile("/etc/api-gateway/introspection")
        webSocketConnection:send(content)
    end)
end

