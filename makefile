#----------------------------------------------------------------------------
# Blinky Top Level Makefile
#----------------------------------------------------------------------------

# Target
TARGET=blinky

# Filenames
BUILD_DIR=build
BINARY_DIR=binary
FILENAME=$(BINARY_DIR)/$(TARGET)

# Debug?
DEBUG=1

# Global Makefile Vars
C_SRCS =
ASM_SRCS =
C_INCLUDES = .
ASM_INCLUDES =

#------------------------------------------------------------------
# Source
#------------------------------------------------------------------

# Add modules
-include os/os.mk
-include cpu/cmsis/cmsis.mk
-include cpu/stmicro_HAL/st.mk

# Top Level sources
C_SRCS += \
	main.c \
	Blinky_Demo/main_blinky.c

# Startup Files
ASM_SRCS += startup_stm32f769xx.s
C_SRCS += system_stm32f7xx.c

#------------------------------------------------------------------
# Toolchain
#------------------------------------------------------------------

PREFIX = arm-none-eabi-
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
ASM = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CC = $(PREFIX)gcc
ASM = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#------------------------------------------------------------------
# Compiler Flags
#------------------------------------------------------------------

# CPU
CPU = -mcpu=cortex-m7

# FPU
FPU = -mfpu=fpv5-d16

# float-abi
FLOAT_ABI = -mfloat-abi=hard

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT_ABI)

C_DEFS =  \
-DSTM32F769xx 

# Optimisation
ifeq ($(DEBUG),1)
	OPTIM_FLAGS=-Og
else
	OPTIM_FLAGS=
endif

# Debug Symbols
ifeq ($(DEBUG),1)
	DEBUG_FLAGS = -g -gdwarf-2
endif

# Add prefix to C_INCLUDES
C_INCLUDES := $(addprefix -I,$(C_INCLUDES))

# Generate Dependencies 
MAKE_DEPEND_C = -MMD -MP -MF"$(@:%.o=%.d)"

# C Flags
C_FLAGS = $(MCU) $(DEBUG_FLAGS) $(OPTIM_FLAGS) $(MAKE_DEPEND_C) $(C_DEFS) $(C_INCLUDES) -Wall -fdata-sections -ffunction-sections

# ASM Flags
ASM_FLAGS = $(MCU) $(DEBUG_FLAGS) $(OPTIM_FLAGS) -Wall -fdata-sections -ffunction-sections

#------------------------------------------------------------------
# Linker Flags
#------------------------------------------------------------------

# link script
LDSCRIPT = STM32F769NIHx_FLASH.ld

# libraries
LIBS = -lc -lm -lnosys
LIBDIR =
LDFLAGS = $(MCU) --specs=nano.specs -u _printf_float -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

#------------------------------------------------------------------
# Object List
#------------------------------------------------------------------

C_OBJS := $(addprefix $(BUILD_DIR)/,$(C_SRCS:.c=.o))
ASM_OBJS := $(addprefix $(BUILD_DIR)/,$(ASM_SRCS:.s=.o))

#------------------------------------------------------------------
# Build Objects
#------------------------------------------------------------------

# Generic C rule
$(BUILD_DIR)/%.o: %.c makefile
	@echo 'Building $< with generic rule.'
	mkdir -p $(@D)
	$(CC) -c $(C_FLAGS) -o "$@" "$<"
	@echo 'Finished building $<'
	@echo '----------'

# Generic ASM rule
$(BUILD_DIR)/%.o: %.s makefile
	@echo 'Building $< with generic rule.'
	mkdir -p $(@D)
	$(ASM) -c $(ASM_FLAGS) -o "$@" "$<"
	@echo 'Finished building $<'
	@echo '----------'

#------------------------------------------------------------------
# Build Binary
#------------------------------------------------------------------

all: elf bin hex

elf: $(FILENAME).elf

bin: $(FILENAME).bin

hex: $(FILENAME).hex

$(FILENAME).elf: $(C_OBJS) $(ASM_OBJS) Makefile
	mkdir -p $(@D)
	$(CC) $(C_OBJS) $(ASM_OBJS) $(LDFLAGS) -o $@
	$(SZ) $@

$(FILENAME).hex: $(FILENAME).elf
	mkdir -p $(@D)
	$(HEX) $< $@

$(FILENAME).bin: $(FILENAME).elf
	mkdir -p $(@D)
	$(BIN) $< $@

#------------------------------------------------------------------
# Clean
#------------------------------------------------------------------

clean: 
	$(RM) -rf $(BUILD_DIR)

clobber:
	$(RM) -rf $(BUILD_DIR) $(BINARY_DIR)


#------------------------------------------------------------------
# Dependencies
#------------------------------------------------------------------

C_DEPS := $(addprefix BUILD_DIR/,$(C_SRCS:.c=.d))
ASM_DEPS := $(addprefix BUILD_DIR/,$(ASM_SRCS:.s=.d))

# An empty rule for dependency file causes them to be marked out of date 
# whenever they do not exist (prevents missing file errors)
%.d: ;

-include $(C_DEPS) $(ASM_DEPS)


















