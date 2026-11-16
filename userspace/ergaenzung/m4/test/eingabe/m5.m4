before
include(inc.m4)
after define(`z', `ZED') z
sinclude(nonexist.m4)
sinclude(inc.m4)dnl
last
