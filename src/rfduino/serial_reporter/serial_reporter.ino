#include <RFduinoBLE.h>
/*
  CircularBuffer.h - circular buffer library for Arduino.
 
  Copyright (c) 2009 Hiroki Yagita.
 
  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  'Software'), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:
 
  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#ifndef CIRCULARBUFFER_h
#define CIRCULARBUFFER_h
#include <inttypes.h>
 
template <typename T, uint16_t Size>
class CircularBuffer {
public:
  enum {
    Empty = 0,
    Half = Size / 2,
    Full = Size,
  };
 
  CircularBuffer() :
    wp_(buf_), rp_(buf_), tail_(buf_+Size),  remain_(0) {}
  ~CircularBuffer() {}
  void push(T value) {
    *wp_++ = value;
    remain_++;
    if (wp_ == tail_) wp_ = buf_;
  }
  T pop() {
    T result = *rp_++;
    remain_--;
    if (rp_ == tail_) rp_ = buf_;
    return result;
  }
  int remain() const {
    return remain_;
  }
 
private:
  T buf_[Size];
  T *wp_;
  T *rp_;
  T *tail_;
  uint16_t remain_;
};
 
#endif

#define MAX_MILLIS_TO_WAIT 1000

CircularBuffer<char, 1000> buffer;
int connected = false;
int loops = 0;

void setup() {
  /* RX is Pin 0, TX is Pin 1 */
  Serial.begin(9600, 0, 1);
  RFduinoBLE.begin();
}

void RFduinoBLE_onConnect() {
  connected = true;
}

void loop() {
  unsigned long starttime = millis();
  
  while((Serial.available() > 0) && ((millis() - starttime) < MAX_MILLIS_TO_WAIT) ) {
    buffer.push(Serial.read());
  }

  if (connected) {
    int charactersToSend = min(20, buffer.remain());
    
    char buf[charactersToSend];
    for (int i = 0; i < charactersToSend; i++) {
      buf[i] = buffer.pop();
    }
    
    if (charactersToSend > 0) {
      // send is queued (the ble stack delays send to the start of the next tx window)
      while (! RFduinoBLE.send(buf, charactersToSend))
        ;  // all tx buffers in use (can't send - try again later)
    }
  }
}

