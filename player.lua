Player = {}
Player.__index = Player

function Player.n(name, bodies, selected)
  local p = {}
  setmetatable(p,Player)
  p.name = name
  p.bodies = bodies
  p.selected = selected
  p.tot_value = 0
  for _,b in pairs(bodies) do
    p.tot_value = p.tot_value+ b.value
    b.player = p
  end
  p.score = 0
  selected.selected = true
  p.launching = {
    status = false,
    x = 0,
    y = 0
  }
  return p
end

function Player:points()
  local point=0
  for _,b in pairs(self.bodies) do
    point =point+ b.points*b.value
  end
  return point/self.tot_value
end

PlayerAI = {}
PlayerAI.__index = PlayerAI

function PlayerAI.n(name, bodies, selected, enemy)
  local p = {}
  setmetatable(p,PlayerAI)
  p.name = name
  p.bodies = bodies
  p.selected = selected
  p.tot_value = 0
  for _,b in pairs(bodies) do
    p.tot_value = p.tot_value+ b.value
    b.player = p
  end
  p.score = 0
  selected.selected = true
  p.t = 0
  p.enemy = enemy
  p.launching = {
    t = 0,
  }
  return p
end

function PlayerAI:points()
  local point=0
  for _,b in pairs(self.bodies) do
    point =point+ b.points*b.value
  end
  return point/self.tot_value
end

function PlayerAI:update(dt)
  self.t = self.t +dt
  if self.t > self.launching.t+3+2*math.random() then
    self.launching.t = self.t
    if self.selected==nil or self.selected.rockets <= 0 or self.selected.points <=0  or math.random()>0.7 then
      self:switch_selected()
    end
    if self.selected~=nil and self.selected.rockets >0 then
      local target = self:select_target(self.selected)
      if target~=nil then
        local v = (target.position-self.selected.position)+(target.speed-self.selected.speed) + Vec2D.rand(40)
        v = (0.4+math.random()*0.6)*150*v/v:mod()
        return self.selected:launch(v.x,v.y)
      end
    end
  end
  return nil
end

function PlayerAI:switch_selected()
  local mp = 1/#self.bodies
  local pp = mp
  for _,p in pairs(self.bodies) do
    if p.points> 0 and math.random()< mp then
      p.selected = true
      self.selected.selected = false
      self.selected = p
      return
    end
    pp = pp+mp
  end
  if self.selected.points == 0 then
    self.selected = nil
  end
end

function PlayerAI:select_target(o)
  local selected = nil
  local d = 1000
  for _,p in pairs(self.enemy.bodies) do
    local vd =  (o.position-p.position)
    if p.points>0  and (selected == nil or vd:mod2() < d) then
      d=vd:mod2()
      selected = p
    end
  end
  return selected
end
