cmake_minimum_required(VERSION 3.18...3.28)

# Allow selection of processor target (ARM or RISC-V)
set(PICO_PLATFORM rp2040)
#set(PICO_PLATFORM rp2350)
#set(PICO_PLATFORM rp2350-riscv)

# Initialize the SDK
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

# Set project name and language
project(picosdk C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# Initialize the Raspberry Pi Pico SDK
pico_sdk_init()

# Add executable
add_executable(${PROJECT_NAME}
    src/main.c
)

# Create map/bin/hex/uf2 outputs
pico_add_extra_outputs(${PROJECT_NAME})

# Link libraries
target_link_libraries(${PROJECT_NAME}
    pico_stdlib
    # Add other libraries as needed:
    hardware_gpio
    # hardware_i2c
    # hardware_spi
    # hardware_pwm
    # hardware_uart
)

# Enable USB output, disable UART output
pico_enable_stdio_usb(${PROJECT_NAME} 1)
pico_enable_stdio_uart(${PROJECT_NAME} 0)

# Add a helper message after configuration
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Build complete for ${PICO_PLATFORM}. Output: ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.uf2"
)