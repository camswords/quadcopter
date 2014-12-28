#include <analytics.h>
#include <mavlink.h>
#include <gyroscope.h>
#include <accelerometer.h>
#include <angular_position.h>
#include <systick.h>
#include <stdint.h>

void InitialiseAnalytics() {
	InitialiseSerialBuffer();

	mavlink_system.sysid = 1;
	mavlink_system.compid = 1;
}

void RecordWarningMessage(char *message) {
	// todo!
}

void RecordPanicMessage(char *message) {
	// todo!
}

void SendTelemetryHeartBeat() {
	mavlink_msg_heartbeat_send(MAVLINK_COMM_0, MAV_TYPE_QUADROTOR, MAV_AUTOPILOT_GENERIC, MAV_MODE_AUTO_ARMED, 0, MAV_STATE_ACTIVE);
}

void SendTelemetryRawImu() {
	mavlink_msg_raw_imu_send(MAVLINK_COMM_0, intermediateMillis * 1000, (accelerometerReading.xG * 1000.0f), (accelerometerReading.yG * 1000.0f), (accelerometerReading.zG * 1000.0f), gyroscopeReading.rawX, gyroscopeReading.rawY, gyroscopeReading.rawZ, 0, 0, 0);
}

void SendTelemetryScaledImu() {
	mavlink_msg_scaled_imu_send(MAVLINK_COMM_0, intermediateMillis, angularPosition.x, angularPosition.y, angularPosition.z, gyroscopeReading.x, gyroscopeReading.y, gyroscopeReading.z, 0, 0, 0);
}

void SendTelementryLocalPosition() {
	float x =  angularPosition.x * 3.141592f / 180.0f;
	float y =  angularPosition.y * 3.141592f / 180.0f;
	float z =  angularPosition.z * 3.141592f / 180.0f;
	float quaternion[4];

	mavlink_euler_to_quaternion(x, y, z, quaternion);
	mavlink_msg_attitude_quaternion_send(MAVLINK_COMM_0, intermediateMillis, quaternion[0], quaternion[1], quaternion[2], quaternion[3], 0, 0, 0);
}

void FlushMetrics() {
	FlushPortionOfSerialBuffer();
}

void FlushAllMetrics() {
	FlushEntireSerialBuffer();
}

