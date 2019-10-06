#----------------------------------------------------------------------------
# Operating System Makefile
#----------------------------------------------------------------------------

# FreeRTOS version
FREE_RTOS_VERSION=10.2.1

FREE_RTOS_DIR=os/FreeRTOSv$(FREE_RTOS_VERSION)/FreeRTOS/Source

# Include Interface Folder
C_INCLUDES += $(FREE_RTOS_DIR)/Include

# Add common sources
C_SRCS += \
	$(FREE_RTOS_DIR)/croutine.c \
	$(FREE_RTOS_DIR)/event_groups.c \
	$(FREE_RTOS_DIR)/list.c \
	$(FREE_RTOS_DIR)/queue.c \
	$(FREE_RTOS_DIR)/stream_buffer.c \
	$(FREE_RTOS_DIR)/tasks.c \
	$(FREE_RTOS_DIR)/timers.c

# Add Heap Scheme 
C_SRCS += $(FREE_RTOS_DIR)/portable/MemMang/heap_4.c

# Add selected port
C_INCLUDES += $(FREE_RTOS_DIR)/portable/GCC/ARM_CM4F

C_SRCS += $(FREE_RTOS_DIR)/portable/GCC/ARM_CM4F/port.c

