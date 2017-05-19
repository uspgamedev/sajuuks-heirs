
local enet = require 'enet'

local TURN = 0.2

local host
local peers

local units

function love.load()
  host = enet.host_create("localhost:1337")
  peers = {}
  units = {}
  local unit = {400,300}
  units[unit] = true
end

local function update_net()
  local event = host:service()
  while event do
    if event.type == "receive" then
      print("Got message: ", event.data, event.peer)
      --event.peer:send( "pong" )
    elseif event.type == "connect" then
      print(event.peer, "connected.")
      peers[event.peer] = true
    elseif event.type == "disconnect" then
      print(event.peer, "disconnected.")
      peers[event.peer] = nil
    end
    event = host:service()
  end
  for unit in pairs(units) do
    for peer in pairs(peers) do
      peer:send(("%d,%d"):format(unit[1], unit[2]))
    end
  end
end

local function tick()
  local rand = love.math.random
  for unit in pairs(units) do
    unit[1] = unit[1] + rand(-1,1)
    unit[2] = unit[2] + rand(-1,1)
  end
end

do
  local lag = 0
  function love.update (dt)
    lag = lag + dt
    while lag >= TURN do
      lag = lag - TURN
      tick()
      update_net()
    end
  end
end



