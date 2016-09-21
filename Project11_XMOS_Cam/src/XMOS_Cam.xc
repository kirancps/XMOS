/*
 * XMOS_Cam.xc
 *  This code interface camera slice(Aptina MT9v034) onto XCORE 200 slicke kit and
 *  sends data to host through xscope, the code is incomplete and needs
 *  modification for proper operation. The camera is operated in slave mode
 *  STLN_OUT, STFRM_OUT, and EXPOSURE control the camera capture and readout
 *  Camera can be condifgured by modifying register through I2C. Check Camera datasheet in detail.
 *  OpenCV is used to display the image. Add necessary libraries while compiling
 *  Created on: Jul 8, 2015 in Ubuntu
 *      Author: KIRAN
 */

#include <timer.h>
#include <stdio.h>
#include <xs1.h>
#include "i2c.h"
#include <platform.h>                           //Needed for on tile[] statement
#include <xscope.h>


#define CamAddress 0x90>>1                      //I2C address of camera
#define chipControlAddr 0x07                    //Address of register Chip Control
#define slaveSelect 0x0380                      //Value to configure camera in slave mode
#define verticalBlankAddr 0x06                  //Address of vertical blanking register
#define verticalVal 4                           //value to configure vertical blanking of camera

unsigned int frame;                             //value to read FRAME_VALID
unsigned int line;                              //reads LINE_VALID
unsigned int dataB;                             //reads 10 bit data
unsigned int clk;                               //reads PIX_CLK


unsigned int rowRead[720];                      //reads on row of camera and stores in buffer

void generateSignals(void);                                         //function protype
void readI2c(client interface i2c_master_if i2c,unsigned int reg);
void readData(void);
void writeI2c(client interface i2c_master_if i2c,unsigned int reg,unsigned int value);

/* Please check the schematics of camera slice and XCORE200 slice for port pins and interconnection*/

//I2C pins

on tile[1]:  port sclk=XS1_PORT_1H;             //SCLK of I2c
on tile[1]:  port sdata=XS1_PORT_1I;            //SDATA of I2c

//Master mode input pins

on tile[1]: in port pix_clock=XS1_PORT_1J;          //PIX_CLOCK
on tile[1]: in port frame_valid=XS1_PORT_1K;        //FRAME_VALID
on tile[1]: in port line_valid=XS1_PORT_1L;         //LINE_VALID
on tile[1]: in buffered port:8 data=XS1_PORT_8C;    //first 8 bit of 10bit camera data out, To access all 10 bit, use XS1_PORT_16B and configure for 10bit read

//Slave mode output

on tile[1]:out port exposure=XS1_PORT_1E;           //EXPOSURE
on tile[1]:out port stln_out=XS1_PORT_1P;           //STLN_OUT
on tile[1]:out port stfrm_out=XS1_PORT_1D;          //STFRM_OUT

on tile[1]:clock clks =XS1_CLKBLK_1;                //xcore clock




/*This function generates control signals to operate camera in slave mode
 * Please refer datasheet of camera in detail(slave mode) for pulse timings
 * and waveforms
 *
 *  */


void generateSignals(void){
    while(1){
     exposure <:0x00;           //0x00: OFF, 0x01: ON on one bit port
     stln_out  <:0x00;
     stfrm_out <:0x00;

    delay_milliseconds(10);

     exposure <:0x01;
     delay_milliseconds(20);  //exposure on time
     exposure <: 0x00;
     delay_milliseconds(40);  //wait for pixel integration
     stfrm_out <:0x01;
     delay_milliseconds(5);  //frame read pulse
     stfrm_out<: 0x00;
     delay_milliseconds(5);
     for(unsigned int i=0;i<=420;i++){  //stln pulse generated

         stln_out <: 0x01;
         delay_microseconds(30);
         stln_out <: 0x00;
         delay_microseconds(30);
     }
    }

}

/*This functions reads first 8 bit of camera data and stores it in buffer, and sends
 * to host through xscope. The port is configured as buffered port, so until the data variable fills with the specified
 * number of bits, the data is not passed on. Data is collected on LINE_VALID strobe. When LINE_VALID is high
 * for each PIX_CLK, data is stored in buffered port. Signals can be checked on realtime xscope display by settings in "Run Configurartion"
 *
 */

void readData(void){
    unsigned int i=0;

    configure_clock_src(clks,pix_clock);                        //configures clock on which data has to be read, uses pix_clk
    configure_in_port(data,clks);                               //configures buffered port
    configure_in_port(line_valid,clks);                         //configures LINE_VALID
    configure_in_port_strobed_slave(data,line_valid,clks);      //reads and saves data in buffered port on LINE_VALID and each cycle of PIX_CLK
    start_clock(clks);
    delay_milliseconds(50);



while(1){

    dataB=0;
    pix_clock :> clk;
    frame_valid :> frame;
    line_valid :> line;


   if(i<=720 ){                                 //stores one row of data in buffer
           data :> dataB;

          rowRead[i]=dataB;
          i++;
    }


    xscope_int(LINE_VALID, line);               //sends to host through xscope
    xscope_int(FRAME_VALID, frame);

   if(i>=720){
       i=0;                                     //After on buffer is stored , it ise sent to host through xscope
       for(unsigned int v=0;v<120;v++){

     xscope_int(DATA,rowRead[i]);
     delay_milliseconds(15);
   }
   }

}

}


/*
 * This function writes 16bit to I2C device,uses i2c library
 * IN:I2C interface, register address , 16bit value to be written
 * OUT: NIL
 *
 * i2c library provides 8 bit write and read. to write 16bit value, first 8bits are sent, and then next 8 bits are sent to
 * slave. Refer camera data sheet for 8bit i2c write.
 */

void writeI2c(client interface i2c_master_if i2c,unsigned int reg,unsigned int value)
{


    i2c_regop_res_t result;

    unsigned char writeVal[2];

    writeVal[0]=value&0x00ff;               //stores lower 8 bits
    writeVal[1]=(value&0xff00)>>8;          //stores upper 8 bits
    result=i2c.write_reg(CamAddress,reg,writeVal[1]);   //writes upper 8 bits to adrress
    if (result != I2C_REGOP_SUCCESS) {
        printf("I2C write reg failed\n");
      }
    else{printf("Writing data 0x%04x to  R0x%04x completed\n",value,reg);}

    result=i2c.write_reg(CamAddress,0xF0,writeVal[0]);  //writes lower 8 bits
        if (result != I2C_REGOP_SUCCESS) {
            printf("I2C write reg failed\n");
          }


}
/*
 * This function reads 16bit value from I2C devices.
 * IN:I@C interface, register address
 * OUT :NIL
 *
 * i2c library is used. It provide read for 8bit. To read 16bit from device, two read operation
 * are performed, first read  fetches upper 8 bits, next read fetches lower 8 bits.
 */

void readI2c(client interface i2c_master_if i2c,unsigned int reg)
{
    unsigned int chip=0;
    i2c_regop_res_t result;
    unsigned char data = 0;

    data = i2c.read_reg(CamAddress, reg, result); //Reads upper 8 bits
        if (result != I2C_REGOP_SUCCESS) {
          printf("I2C read reg failed\n");

        }
   chip=data<<8;

   data = i2c.read_reg(CamAddress, 0xF0, result);   //Reads lower 8 bits
           if (result != I2C_REGOP_SUCCESS) {
             printf("I2C read reg failed\n");

           }

    chip|=data;

    printf("Reading[0x%04x]=0x%04x\n",reg,chip);



}

/*
 * This function configures camera slice to operate in slave mode. Refer camera datasheet for register
 * configuration and values to configure.
 */

void configCam(client interface i2c_master_if i2c){

        readI2c(i2c,chipControlAddr);
        writeI2c(i2c,chipControlAddr,slaveSelect);
        delay_milliseconds(15);
        readI2c(i2c,chipControlAddr);
        readI2c(i2c,verticalBlankAddr);
        writeI2c(i2c,verticalBlankAddr,verticalVal);
        delay_milliseconds(15);
        readI2c(i2c,verticalBlankAddr);

}

/*
 * main function runs four threads parallely in tile 1.Circle slot on XCORE200 slice kit
 * is connected to camera slice. Circle slot is connected to tile 1.
 */
int main(void){
    i2c_master_if i2c[1];                   //I2C interface

    par{

      on tile[1]:  i2c_master(i2c, 1,sclk, sdata, 100);

      on tile[1]:  readData();
      on tile[1]: generateSignals();


      on tile[1]: configCam(i2c[0]);

    }
return 0;
}
