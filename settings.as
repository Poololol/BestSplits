[Setting category="General" name="Window Enabled" description=""]
bool sg_winEnabled = true;
[Setting category="General" name="Max Rows" description=""]
uint sg_maxRows = 13;
[Setting category="General" name="Look Ahead" description=""]
uint sg_lookAhead = 5;

[Setting category="Headers" name="Sum Of Best" description=""]
bool sh_SOB = false;
[Setting category="Headers" name="Best Possible" description=""]
bool sh_BP = true;
[Setting category="Headers" name="PB" description=""]
bool sh_PB = false;
[Setting category="Headers" name="Best Delta" description=""]
bool sh_bestDelta = true;

[Setting category="Columns" name="Best Time" description=""]
bool sc_best = true;
[Setting category="Columns" name="Best Delta" description=""]
bool sc_bestDelta = true;
[Setting category="Columns" name="Best - PB Delta" description=""]
bool sc_bestPBDelta = true;
[Setting category="Columns" name="PB Delta" description=""]
bool sc_PBDelta = false;

[Setting category="Columns" name="Best Speed" description=""]
bool sc_bestSpeed = true;
[Setting category="Columns" name="Best Speed Delta" description=""]
bool sc_bestSpeedDelta = true;
[Setting category="Columns" name="Best - PB Speed Delta" description=""]
bool sc_bestPBSpeedDelta = true;
[Setting category="Columns" name="PB Speed Delta" description=""]
bool sc_PBSpeedDelta = false;

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
[Setting category="Colors" name="Medal Color" color description="Have to reload plugin for changes to take effect"]
vec3 sc_medal = vec3(204./255, 0, 204./255);
#endif

[Setting category="Colors" name="Time Equal" color]
vec4 sc_timeEqual = vec4(0.625, 0.625, 0.625, 1);
[Setting category="Colors" name="Time Minus Min" color]
vec4 sc_timeMinusMin = vec4(0.625, 0.625, 0.875, 1);
[Setting category="Colors" name="Time Minus Max" color]
vec4 sc_timeMinusMax = vec4(0.125, 0.125, 0.875, 1);
[Setting category="Colors" name="Time Plus Min" color]
vec4 sc_timePlusMin = vec4(1, 0.5, 0.5, 1);
[Setting category="Colors" name="Time Plus Max" color]
vec4 sc_timePlusMax = vec4(1, 0, 0, 1);
[Setting category="Colors" name="Time Scale" description="Time in ms at which the Time Max colors will be used" min=0]
int sc_timeScale = 1000;

[Setting category="Colors" name="Speed Equal" color]
vec4 sc_speedEqual = vec4(0.625, 0.625, 0.625, 1);
[Setting category="Colors" name="Speed Minus Min" color]
vec4 sc_speedMinusMin = vec4(0.625, 0.625, 0.875, 1);
[Setting category="Colors" name="Speed Minus Max" color]
vec4 sc_speedMinusMax = vec4(0.125, 0.125, 0.875, 1);
[Setting category="Colors" name="Speed Plus Min" color]
vec4 sc_speedPlusMin = vec4(1, 0.5, 0.5, 1);
[Setting category="Colors" name="Speed Plus Max" color]
vec4 sc_speedPlusMax = vec4(1, 0, 0, 1);
[Setting category="Colors" name="Speed Scale" description="Speed at which the Speed Max colors will be used" min=0]
int sc_speedScale = 50;