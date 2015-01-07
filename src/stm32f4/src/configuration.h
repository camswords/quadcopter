
#ifndef CONFIGURATION_H_
#define CONFIGURATION_H_


// ANGULAR POSITION
#define HOW_MUCH_I_TRUST_THE_GYROSCOPE     			0.98f
#define HOW_MUCH_I_TRUST_THE_ACCELEROMETER			1 - HOW_MUCH_I_TRUST_THE_GYROSCOPE
#define GYROSCOPE_SAMPLE_RATE              			1.0f / (1000.0f / 1.0f)	/* sample rate is closer to 1.74k per second now that time is not measured */


// ANALYTICS
#define ANALYTICS_FLUSH_FREQUENCY 		   			1000 / 200 	/* how often to flush the metrics (20 times per second) */
#define	ANALYTICS_CHARACTERS_TO_SEND_PER_FLUSH 		5

// METRICS
#define SECONDS_ELAPSED								0
#define LOOP_FREQUENCY								1
#define GRYOSCOPE_X_POSITION						2
#define GRYOSCOPE_Y_POSITION						3
#define GRYOSCOPE_Z_POSITION						4
#define GRYOSCOPE_TEMPERATURE						5
#define GRYOSCOPE_SAMPLE_RATE						6
#define ACCELEROMETER_X_POSITION					7
#define ACCELEROMETER_Y_POSITION					8
#define ACCELEROMETER_Z_POSITION					9
#define ACCELEROMETER_SAMPLE_RATE					10
#define ANGULAR_X_POSITION							11
#define ANGULAR_Y_POSITION							12
#define ANGULAR_Z_POSITION							13
#define PID_X_ADJUSTMENT							14
#define PID_Y_ADJUSTMENT							15
#define PID_PROPORTIONAL							16
#define REMOTE_THROTTLE								17
#define PROPELLOR_B_SPEED							18
#define PROPELLOR_E_SPEED							19
#define PROPELLOR_C_SPEED							20
#define PROPELLOR_A_SPEED							21
#define METRICS_BUFFER_SIZE							22

#endif
