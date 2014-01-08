
#ifndef EventLoopAction_h
#define EventLoopAction_h

class EventLoopAction {
    public:
        virtual void execute(long tickNumber);
};

#endif EventLoopAction_h