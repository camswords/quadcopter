#include <EventLoop.h>
#include <Arduino.h>

void EventLoop::run() {
    int tick = 0;

    while(true) {
        tick = tick + 1;

        // Wait a bit, to ensure that communication has a chance to complete
        delay(100);
    }
}

