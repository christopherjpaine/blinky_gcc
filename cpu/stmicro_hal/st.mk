#----------------------------------------------------------------------------
# ST Micro HAL makefile
#----------------------------------------------------------------------------

# Include Interfaces
C_INCLUDES += cpu/stmicro_HAL/STM32f7xx/Inc

# Add all sources
C_SRCS += $(wildcard cpu/stmicro_HAL/STM32f7xx/Src/*.c)