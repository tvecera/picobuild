#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"

// Raspberry Pi Pico onboard LED pin (GPIO 25)
const uint LED_PIN = 25;

int main() {
    // Initialize stdio
    stdio_init_all();

    // Initialize LED pin
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    printf("Pico SDK LED Blink Example\n");

    // Main loop
    while (true) {
        // Turn LED on
        gpio_put(LED_PIN, 1);
        printf("LED on\n");
        sleep_ms(500);

        // Turn LED off
        gpio_put(LED_PIN, 0);
        printf("LED off\n");
        sleep_ms(500);
    }

    return 0;
}