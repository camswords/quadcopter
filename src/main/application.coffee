# this file should only require the quadcopter.
# it is excluded during tests, otherwise tests will run forever.

require ['quadcopter'], (quadcopter) -> quadcopter.fly()
