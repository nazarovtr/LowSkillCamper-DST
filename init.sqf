calculatePosition = {
    private _range = _this select 0 select 0;
    private _bearing = _this select 0 select 1;
    private _center = _this select 0 select 2;
    private _altitude = _this select 1;
    private _pos = _center vectorAdd [_range * (sin _bearing), _range * (cos _bearing), _altitude];
    _pos;
};

smallExplosion = {
    private _pos = [_this, 50] call calculatePosition;
    private _grenade = "G_40mm_HE" createVehicle _pos;
    _grenade setVelocity [0,0, -100];
    sleep 5;
};

bigExplosion = {
    private _pos = [_this, 1] call calculatePosition;
    "R_TBG32V_F" createVehicle _pos;
    sleep 5;
};

weaponFire = {
    private _unitType = _this select 3;
    private _pos = [_this, 0] call calculatePosition;
    private _group = createGroup east;
    private _unit =_group createUnit [_unitType, _pos, [], 0, "NONE"];
    if ((random 1) > 0.6) then {
        _unit doSuppressiveFire position barrel;
    } else {
        _unit setDir (_this select 1);
        _unit fire (currentMuzzle _unit);
        sleep 0.5;
        _unit fire (currentMuzzle _unit);
        sleep 0.5;
        _unit fire (currentMuzzle _unit);
        sleep 0.5;
        _unit fire (currentMuzzle _unit);
        sleep 0.5;
        _unit fire (currentMuzzle _unit);
    };
    sleep 5;
    deleteVehicle _unit;
    deleteGroup _group;
};

private _options = [
    ["big", 100, 1000],
    ["small", 30, 400],
    ["O_Soldier_AR_F", 30, 400],
    ["O_R_JTAC_F", 30, 400],
    ["O_R_Soldier_AR_F", 30, 400],
    ["O_soldier_M_F", 30, 400],
    ["O_Soldier_lite_F", 30, 300],
    ["O_HeavyGunner_F", 30, 400],
    ["O_Sharpshooter_F", 30, 900],
    ["O_sniper_F", 30, 1000]
];

private _testCount = 10;

private _directlyInFrontNumbers = [];
private _directlyBehindNumbers = [];

private _candidates = [];

for "_i" from 0 to _testCount - 1 do {
    _candidates pushBack _i;
};

_directlyInFrontNumbers pushBack (_candidates deleteAt round(random((count _candidates) - 1)));
_directlyInFrontNumbers pushBack (_candidates deleteAt round(random((count _candidates) - 1)));
_directlyBehindNumbers pushBack (_candidates deleteAt round(random((count _candidates) - 1)));
_directlyBehindNumbers pushBack (_candidates deleteAt round(random((count _candidates) - 1)));

private _tests = [];

for "_i" from 0 to _testCount - 1 do {
    private _bearing = random 360;
    if ((_directlyInFrontNumbers find _i) >= 0) then {
        _bearing = 0;
    };
    if ((_directlyBehindNumbers find _i) >= 0) then {
        _bearing = 180;
    };
    private _testType = selectRandom _options;
    private _minRange = _testType select 1;
    private _maxRange = _testType select 2;
    private _range = _minRange + random (_maxRange - _minRange);
    _tests pushBack [_testType select 0, _range, _bearing];
};

titleText ["<t size='2'>Welcome to LowSkillCamper directional sound test!</t>", "PLAIN", -1, true, true];
sleep 4;
titleText ["<t size='2'>Stay in place and look at the sphere ahead of you.<br/> It is directly north of you (bearing 0).</t>", "PLAIN", -1, true, true];
sleep 6;
titleText ["<t size='2'>You will hear sounds from different directions.<br/> There will be a message with the actual direction in 3 different formats after each sound.</t>", "PLAIN", -1, true, true];
sleep 8;
titleText [" ", "PLAIN", -1, true, true];
{
    private _test = _x;
    if ((_test select 0) == "big") then {
        [_test select 1, _test select 2, getPos cross] call bigExplosion;
    } else {
        if ((_test select 0) == "small") then {
            [_test select 1, _test select 2, getPos cross] call smallExplosion;
        } else {
            [_test select 1, _test select 2, getPos cross, _test select 0] call weaponFire;
        };
    };
    sleep 3;
    private _bearing = round (_test select 2);
    private _compassDirection = "";
    private _direction = "";
    if ((_bearing > 0 and _bearing <= 15) or (_bearing >= 345 and _bearing < 360)) then {
        _compassDirection = "North";
        _direction = "Front";
    };
    if (_bearing > 15 and _bearing < 70) then {
        _compassDirection = "Northeast";
        _direction = "Front-right";
    };
    if (_bearing >= 70 and _bearing <= 110) then {
        _compassDirection = "East";
        _direction = "Right";
    };
    if (_bearing > 110 and _bearing < 165) then {
        _compassDirection = "Southeast";
        _direction = "Behind-right";
    };
    if (_bearing >= 165 and _bearing <= 195) then {
        _compassDirection = "South";
        _direction = "Behind";
    };
    if (_bearing > 195 and _bearing < 250) then {
        _compassDirection = "Southwest";
        _direction = "Behind-left";
    };
    if (_bearing >= 250 and _bearing <= 290) then {
        _compassDirection = "West";
        _direction = "Left";
    };
    if (_bearing > 290 and _bearing < 345) then {
        _compassDirection = "Northwest";
        _direction = "Front-left";
    };
    if (_bearing == 0) then {
        _compassDirection = "Directly north";
        _direction = "Directly in front";
    };
    if (_bearing == 180) then {
        _compassDirection = "Directly south";
        _direction = "Directly behind";
    };
    titleText [format ["<t size='5'>Bearing: %1<br/>%2<br/>%3</t>", round (_test select 2), _compassDirection, _direction], "PLAIN", -1, true, true];
    sleep 5;
    titleText [" ", "PLAIN", -1, true, true];
} forEach _tests;

titleText ["<t size='2'>If your average error is less than 20 degrees,<br/> and you can easily distinguish sounds directly in front<br/> from sounds directly behind, your setup is good.</t>", "PLAIN", -1, true, true];
sleep 10;
titleText ["<t size='2'>Thank you for using this test! Subscribe to my channel!<br/> You can repeat the test, it is randomized.</t>", "PLAIN", -1, true, true];
sleep 10;
endMission "END1";
