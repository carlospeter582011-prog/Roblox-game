return function(test, eq)
    local Motion = require("../src/shared/CloudMotionRules")
    test("elemental cloud movement is bounded and deterministic", function()
        for _, element in ipairs({"Air","Water","Storm","Fire","Ice","Cosmic","Nature","Earth","Light","Shadow"}) do
            for _, seconds in ipairs({0, 1, 10, 1000}) do
                local x,y,z = Motion.offset(element, seconds, 17)
                local xx,yy,zz = Motion.offset(element, seconds, 17)
                eq(x,xx,"deterministic x")
                eq(y,yy,"deterministic y")
                eq(z,zz,"deterministic z")
                if math.abs(x)>3 or math.abs(y)>1.1 or math.abs(z)>3 then error("unbounded "..element) end
            end
        end
    end)
    test("invalid motion inputs cannot move server targets", function()
        local x,y,z=Motion.offset("Air", math.huge, 1)
        eq(x,0,"infinite time x");eq(y,0,"infinite time y");eq(z,0,"infinite time z")
        x,y,z=Motion.offset("Storm", 1, 0/0)
        eq(x,0,"nan seed x");eq(y,0,"nan seed y");eq(z,0,"nan seed z")
    end)
    test("elements have visibly different paths", function()
        local ax=Motion.offset("Air",2,4)
        local ix=Motion.offset("Ice",2,4)
        if ax==ix then error("same motion for Air and Ice") end
    end)
end
