local block = 50

-- 12x16 grid
walls = {
    {x = 0,  y = 0,  w = 1,  h = 12 }, -- left
    {x = 0,  y = 0,  w = 16, h = 1  }, -- top
    {x = 15, y = 0,  w = 1,  h = 12 }, -- right
    {x = 0,  y = 11, w = 16, h = 1  }, -- bottom

    {x = 3,  y = 3,  w = 1,  h = 3  },
    {x = 4,  y = 4,  w = 4,  h = 1  },

    {x = 8,  y = 2,  w = 1,  h = 1  },

    {x = 9,  y = 7,  w = 3,  h = 1  },
    {x = 12, y = 3,  w = 1,  h = 5  },

    {x = 4,  y = 8,  w = 1,  h = 2  },

    {x = 6,  y = 7,  w = 1,  h = 3  },

    {x = 10, y = 9,  w = 1,  h = 1  }
}
for _, wall in pairs(walls) do
    wall.x = wall.x * block
    wall.y = wall.y * block
    wall.w = wall.w * block
    wall.h = wall.h * block
end
