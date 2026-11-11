local Rules = require("../src/shared/CloudTrackerRules")
return function(test, eq)
    test("tracker prioritizes new discoveries over nearby duplicates", function()
        local target = Rules.choose({
            {id="2",species="breeze",x=2,z=0},
            {id="1",species="storm",x=30,z=0},
        }, {breeze=5}, {x=0,z=0})
        eq(target.id, "1", "new discovery")
    end)
    test("tracker selects nearest and excludes distant or invalid targets", function()
        local target = Rules.choose({
            {id="far",species="a",x=500,z=0},
            {id="near",species="a",x=10,z=0},
            {id="nan",species="a",x=0/0,z=0},
        }, {}, {x=0,z=0})
        eq(target.id, "near", "nearest")
        eq(Rules.choose({}, {}, {x=0,z=0}), nil, "empty")
    end)
    test("tracker rejects dead, unready, remote or cooldown activations", function()
        eq(Rules.canActivate(12,35,true,true), true, "valid")
        eq(Rules.canActivate(15,35,true,true), false, "far")
        eq(Rules.canActivate(2,34,true,true), false, "cooldown")
        eq(Rules.canActivate(2,35,false,true), false, "unready")
        eq(Rules.canActivate(2,35,true,false), false, "dead")
        eq(Rules.canActivate(0/0,35,true,true), false, "nan")
    end)
end
