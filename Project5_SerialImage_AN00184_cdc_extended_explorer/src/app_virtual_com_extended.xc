// Copyright (c) 2015, XMOS Ltd, All rights reserved

#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <string.h>
#include <timer.h>
#include "i2c.h"
#include "xud_cdc.h"

/* App specific defines */
#define MENU_MAX_CHARS  30
#define MENU_LIST       11
#define DEBOUNCE_TIME   (XS1_TIMER_HZ/50)
#define BUTTON_PRESSED  0x00

// FXOS8700EQ register address defines - From AN00181
#define FXOS8700EQ_I2C_ADDR 0x1E
#define FXOS8700EQ_XYZ_DATA_CFG_REG 0x0E
#define FXOS8700EQ_CTRL_REG_1 0x2A
#define FXOS8700EQ_DR_STATUS 0x0
#define FXOS8700EQ_OUT_X_MSB 0x1
#define FXOS8700EQ_OUT_X_LSB 0x2
#define FXOS8700EQ_OUT_Y_MSB 0x3
#define FXOS8700EQ_OUT_Y_LSB 0x4
#define FXOS8700EQ_OUT_Z_MSB 0x5
#define FXOS8700EQ_OUT_Z_LSB 0x6

/* PORT_4A connected to the 4 LEDs */
on tile[0]: port p_led = XS1_PORT_4F;

/* PORT_4C connected to the 2 Buttons */
on tile[0]: port p_button = XS1_PORT_4E;

char app_menu[MENU_LIST][MENU_MAX_CHARS] = {
        {"\n\r-------------------------\r\n"},
        {"XMOS USB Virtual COM Demo\r\n"},
        {"-------------------------\r\n"},
        {"1. Switch to Echo mode\r\n"},
        {"2. Toggle LED 1\r\n"},
        {"3. Toggle LED 2\r\n"},
        {"4. Toggle LED 3\r\n"},
        {"5. Toggle LED 4\r\n"},
        {"6. Read Accelerometer\r\n"},
        {"7. Print timer ticks\r\n"},
        {"-------------------------\r\n"},
};

char echo_mode_str[3][30] = {
        {"Entered echo mode\r\n"},
        {"Press Ctrl+Z to exit it\r\n"},
        {"\r\nExit echo mode\r\n"},
};

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

/* Sends out the App menu over CDC virtual port*/
void show_menu(client interface usb_cdc_interface cdc)
{
    unsigned length;
    for(int i = 0; i < MENU_LIST; i++) {
        length = strlen(app_menu[i]);
        cdc.write(app_menu[i], length);
    }
}

/* Function to set LED state - ON/OFF */
void set_led_state(int led_id, int val)
{
  int value;
  /* Read port value into a variable */
  p_led :> value;
  if (!val) {
      p_led <: (value | (1 << led_id));
  } else {
      p_led <: (value & ~(1 << led_id));
  }
}

/* Function to toggle LED state */
void toggle_led(int led_id)
{
    int value;
    p_led :> value;
    p_led <: (value ^ (1 << led_id));
}

/* Function to get button state (0 or 1)*/
int get_button_state(int button_id)
{
    int button_val;
    p_button :> button_val;
    button_val = (button_val >> button_id) & (0x01);
    return button_val;
}

/* Checks if a button is pressed */
int is_button_pressed(int button_id)
{
    if(get_button_state(button_id) == BUTTON_PRESSED) {
        /* Wait for debounce and check again */
        delay_ticks(DEBOUNCE_TIME);
        if(get_button_state(button_id) == BUTTON_PRESSED) {
            return 1; /* Yes button is pressed */
        }
    }
    /* No button press */
    return 0;
}

int read_acceleration(client interface i2c_master_if i2c, int reg) {
    i2c_regop_res_t result;
    int accel_val = 0;
    unsigned char data = 0;

    // Read MSB data
    data = i2c.read_reg(FXOS8700EQ_I2C_ADDR, reg, result);
    if (result != I2C_REGOP_SUCCESS) {
      return 0;
    }

    accel_val = data << 2;

    // Read LSB data
    data = i2c.read_reg(FXOS8700EQ_I2C_ADDR, reg+1, result);
    if (result != I2C_REGOP_SUCCESS) {
      return 0;
    }

    accel_val |= (data >> 6);

    if (accel_val & 0x200) {
      accel_val -= 1023;
    }

    return accel_val;
}

/* Initializes the Application */
void app_init(client interface i2c_master_if i2c)
{
    i2c_regop_res_t result;

    /* Set all LEDs to OFF (Active low)*/
    p_led <: 0x0F;
    /* Accelerometer setup */

    // Configure FXOS8700EQ
    result = i2c.write_reg(FXOS8700EQ_I2C_ADDR, FXOS8700EQ_XYZ_DATA_CFG_REG, 0x01);
    if (result != I2C_REGOP_SUCCESS) {
      return;
    }

    // Enable FXOS8700EQ
    result = i2c.write_reg(FXOS8700EQ_I2C_ADDR, FXOS8700EQ_CTRL_REG_1, 0x01);
    if (result != I2C_REGOP_SUCCESS) {
      return;
    }
}

/* Application task */
void app_virtual_com_extended(client interface usb_cdc_interface cdc, client interface i2c_master_if i2c)
{
    unsigned int length, led_id;
    int x = 0;
    int y = 0;
    int z = 0;
    char value, tmp_string[50];
    unsigned int button_1_valid, button_2_valid;
    timer tmr;
    unsigned int timer_val;

    app_init(i2c);
    show_menu(cdc);

    button_1_valid = button_2_valid = 1;

    while(1)
    {
        /* Check for a change in button 1 - Detects 1->0 transition */
        if(is_button_pressed(0)) {
            if(button_1_valid) {
                button_1_valid = 0;
                length = sprintf(tmp_string, "\r\nButton 1 Pressed!\r\n");
                cdc.write(tmp_string, length);
            }
        } else {
            button_1_valid = 1;
        }


        /* Check for a change in button 2 - Detects 1->0 transition */
        if(is_button_pressed(1)) {
            if(button_2_valid) {
                button_2_valid = 0;
                length = sprintf(tmp_string, "\r\nButton 2 Pressed!\r\n");
                cdc.write(tmp_string, length);
            }
        } else {
            button_2_valid = 1;
        }

        /* Check if user has input any character */
        if(cdc.available_bytes())
        {
            value = cdc.get_char();

            /* Do the chosen operation */
            if(value == '1') {
                length = strlen(echo_mode_str[0]);
                cdc.write(echo_mode_str[0], length);
                length = strlen(echo_mode_str[1]);
                cdc.write(echo_mode_str[1], length);

                while(value != 0x1A) { /* 0x1A = Ctrl + Z */
                    value = cdc.get_char();
                    cdc.put_char(value);
                }
                length = strlen(echo_mode_str[2]);
                cdc.write(echo_mode_str[2], length);
            }
            else if((value >= '2') && (value <= '5')) {
                /* Find out which LED to toggle */
                led_id = (value - 0x30) - 2;    // 0x30 used to convert the ascii to number
                toggle_led(led_id);
            }
            else if(value == '6') {
                char status_data = 0;
                i2c_regop_res_t result;

                // Wait for valid accelerometer data
                do {
                  status_data = i2c.read_reg(FXOS8700EQ_I2C_ADDR, FXOS8700EQ_DR_STATUS, result);
                } while (!status_data & 0x08);

                // Read x and y axis values
                x = read_acceleration(i2c, FXOS8700EQ_OUT_X_MSB);
                y = read_acceleration(i2c, FXOS8700EQ_OUT_Y_MSB);
                z = read_acceleration(i2c, FXOS8700EQ_OUT_Z_MSB);

                length = sprintf(tmp_string, "Accelerometer: x[%d] y[%d] z[%d]\r\n", x, y, z);
                cdc.write(tmp_string, length);
            }
            else if(value == '7') {
                /* Read 32-bit timer value */
                tmr :> timer_val;
                length = sprintf(tmp_string, "Timer ticks: %u\r\n", timer_val);
                cdc.write(tmp_string, length);
            }
            else {
                show_menu(cdc);
            }
        }
    } /* end of while(1) */
}
