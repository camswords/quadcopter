
BUILD_DIR = build
QUAD_ELF = $(BUILD_DIR)/quadcopter.elf
QUAD_BIN = $(BUILD_DIR)/quadcopter.bin

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
		-Os \
		-DUSE_STDPERIPH_DRIVER -DSTM32F4XX -DHSE_VALUE=8000000 \
		-I./src \
		-I./Libraries/CMSIS/Include/ \
		-I./Libraries/STM32F4xx_StdPeriph_Driver/inc/ \
		-Woverflow \
		-Wl,-T,./src/stm32_flash.ld \
		$^ -lm -lc -lnosys \
		-o $(QUAD_ELF)

clean:
	rm -rf build

deploy: all
	openocd -f deploy.cfg

.PHONY: clean, deploy


















