#ifndef ANALYTICS_H_
#define ANALYTICS_H_

#include <stdint.h>
#include <buffered_serial.h>
#include <mavlink_types.h>
#include <stdint.h>

void InitialiseAnalytics();

void RecordPanicMessage(char *message);
void RecordWarningMessage(char *message);

void SendTelemetryHeartBeat();
void SendTelemetryRawImu();
void SendTelemetryScaledImu();
void SendTelementryLocalPosition();

void FlushMetrics();
void FlushAllMetrics();


/* Mavlink initialisation */
#define MAVLINK_USE_CONVENIENCE_FUNCTIONS

mavlink_system_t mavlink_system;

/* this is an adapter method that allows us to use the mavlink convenience methods */
static inline void comm_send_ch(mavlink_channel_t channel, uint8_t value)
{
    WriteToSerialBuffer(value);
}

#endif
