
local enet = require 'enet'

local TURN = 0.2

local host, server

local units

function love.load()
  host = enet.host_create()
  server = host:connect('localhost:1337')
  units = {}
  local unit = {400,300}
  units[unit] = true
end

local function update_net()
  local event = host:service()
  while event do
    if event.type == "receive" then
      print("Got message: ", event.data, event.peer)
      for unit in pairs(units) do
        local x, y = event.data:match("(%d+),(%d+)")
        unit[1], unit[2] = tonumber(x), tonumber(y)
      end
    elseif event.type == "connect" then
      print(event.peer, "connected.")
    elseif event.type == "disconnect" then
      print(event.peer, "disconnected.")
      love.event.push 'quit'
    end
    event = host:service()
  end
end

local function disconnect()
  server:disconnect()
end

do
  local lag = 0
  function love.update (dt)
    lag = lag + dt
    while lag >= TURN do
      lag = lag - TURN
      update_net()
    end
  end
end

function love.keypressed (k)
  if k == 'escape' then
    print "Requesting disconnect"
    disconnect()
  end
end

function love.draw ()
  local g = love.graphics
  for unit in pairs(units) do
    g.circle('fill', unit[1], unit[2], 16, 16)
  end
end

