#include <EventLoop.h>
#include <Arduino.h>

void EventLoop::run() {
    long tick = 0;

    while(true) {
        tick = tick + 1;

        actionToExecute->execute(tick);

        // Wait a bit, to ensure that communication has a chance to complete
        delay(100);
    }
}

void EventLoop::everyTick(EventLoopAction* action) {
    actionToExecute = action;
}

