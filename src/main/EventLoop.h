
#ifndef EventLoop_h
#define EventLoop_h

#include <EventLoopAction.h>

class EventLoop {
    private:
        EventLoopAction* actionToExecute;

    public:
        void run();
        void everyTick(EventLoopAction* action);
};

#endif EventLoop_h