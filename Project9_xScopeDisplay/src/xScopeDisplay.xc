/*
 * xScopeDisplay.xc
 *
 *  Created on: 19-Jun-2015
 *      Author: Kiran
 *
 *    This is source code for XMOS to display image on host using xSCOPE
 *    Developed for XCORE-200 eXplorer kit. Suitable changes in makefile can be done to
 *    port on any other XMOS microcontroller
 *
 *    It creates four color vertical bands on display. Size of the image is 200 X 200
 *    ***************************************
 *    *     *       *       *       *       *
 *    *     *       *       *       *       *
 *    *     *       *       *       *       *
 *    *Red  * Green *  Blue * Yellow* White *
 *    *     *       *       *       *       *
 *    *     *       *       *       *       *
 *    *     *       *       *       *       *
 *    ***************************************
 */


#include <xs1.h>
#include <platform.h>
#include <xscope.h>
#include <print.h>
#include <stdlib.h>
#include <stdio.h>

#define height 200
#define width 200



void output_xscope() {

  delay_milliseconds(1);
  unsigned char r,g,b;              //8 bit RGB variables
  while(1){

  for (int i = 0; i < height; i++) {   //Accsessing pixel locations (ROW)

      for (int j=0; j<width;j++)      //Accessing pixel location (COL)
      {


          if(j>=0 && j<=40)         //Red Band
          {
              r=255;g=0;b=0;
          }
          if(j>40 && j<=80){       //Green Band
              r=0;g=255;b=0;

          }                         //Blue Band
          if(j>80 && j<=120){
              r=0;g=0;b=255;
          }
          if(j>120 && j<=160){      //Yellow Band
              r=255;g=255;b=0;
          }
          if(j>160){                //White Band
              r=255;g=255;b=255;
          }



                                      //Check config.xscope file for xscope signal declarration
                                     //The order in which the function is invoked determines ID
    xscope_int(R,r);                //ID is numbered from 0...4
    xscope_int(G,g);                //Integer value are being sent to the host
    xscope_int(B,b);
    //delay_milliseconds(16);         //Delay provided in millSec for scanning
      }

      }
  }

  }



int main (void) {
  par {
    on tile[0]: output_xscope();    //Runs on single thread.
  }

  return 0;
}
