
BUILD_DIR = build
QUAD_ELF = $(BUILD_DIR)/quadcopter.elf
QUAD_BIN = $(BUILD_DIR)/quadcopter.bin

CFLAGS="-ggdb -O0"

SRC = \
	./Libraries/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc_ride7/startup_stm32f40xx.s \
	./src/*.c \
	./Libraries/STM32F4xx_StdPeriph_Driver/src/*.c

all: $(BUILD_DIR) $(QUAD_BIN)
	@echo "\n\n$(QUAD_BIN) is ready to fly.\n"

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(QUAD_BIN): $(QUAD_ELF)
	arm-none-eabi-objcopy -O binary $(QUAD_ELF) $(QUAD_BIN)

$(QUAD_ELF): $(SRC)
	arm-none-eabi-gcc \
		-mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb-interwork -std=c99 \
		-DUSE_STDPERIPH_DRIVER -DSTM32F4XX -DHSE_VALUE=8000000 \
		-ggdb -O0 \
		-I./src \
		-isystem ./Libraries/CMSIS/Include/ \
		-isystem ./Libraries/STM32F4xx_StdPeriph_Driver/inc/ \
		-isystem ./Libraries/mavlink/ \
		-isystem ./Libraries/mavlink/common \
		-Werror \
		-Wall \
		-Wl,-T,./src/stm32_flash.ld \
		$^ -lm -lc -lnosys \
		-o $(QUAD_ELF)

clean:
	rm -rf build

deploy: all
	openocd -f deploy.cfg

debugging-server:
	@echo "Please ensure the SWDIO (PA13), SWCLK (PA14), RST (NRST), GND and 5V are connected to the ST-Link and that it is connected to your machine."
	@echo "starting debugging server...\n\n"
	openocd -f debug.cfg

debugging-client:
	@echo "Please ensure you have started the debugging server using [make debugging-server] first."
	@echo "starting debugging client...\n\n"
	arm-none-eabi-gdb --eval-command="target remote localhost:3333" build/quadcopter.elf

.PHONY: clean, deploy, debugging-server, debugging-client


















