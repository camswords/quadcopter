
#ifndef EchoTickToSerialConnection_h
#define EchoTickToSerialConnection_h

#import <EventLoopAction.h>

class EchoTickToSerialConnection : public EventLoopAction {
    public:
        virtual void execute(long tickNumber);
};

#endif /* EchoTickToSerialConnection_h */