
#include <ring_buffer.h>
#include <string.h>

void InitialiseRingBuffer(RingBuffer *_this) {
	/*
	The following clears:
		-> buf
		-> head
		-> tail
		-> count
		and sets head = tail
	*/
	memset(_this, 0, sizeof (*_this));
}

unsigned int modulo_inc (const unsigned int value, const unsigned int modulus)
{
    unsigned int my_value = value + 1;
    if (my_value >= modulus)
    {
      my_value  = 0;
    }
    return my_value;
}

unsigned int modulo_dec (const unsigned int value, const unsigned int modulus)
{
    return (0 == value) ? (modulus - 1) : (value - 1);
}

int RingBufferIsEmpty(RingBuffer *_this) {
	return 0 == _this->count;
}

int RingBufferIsFull(RingBuffer *_this) {
	return _this->count >= RING_BUFFER_SIZE;
}

uint16_t RingBufferPop(RingBuffer *_this) {
	if (_this->count <= 0) {
		return -1;
	}

	uint16_t value = _this->buffer[_this->tail];
	_this->tail = modulo_inc(_this->tail, RING_BUFFER_SIZE);
	--_this->count;
	return value;
}

void RingBufferPut(RingBuffer *_this, uint16_t value) {
	if (_this->count < RING_BUFFER_SIZE) {
	  _this->buffer[_this->head] = value;
	  _this->head = modulo_inc(_this->head, RING_BUFFER_SIZE);
	  ++_this->count;
	}
}

