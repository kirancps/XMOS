/*
 * disp.cpp
 * This is source code for displaying image in host. The code consists of opencv and
 * XMOS xSCOPE libraries. The output shows still image of red,blue,green ,and white stripes
 * on a 200 X 200 screen
 *
 * xSCOPE libraries can be found in the installed folder "xscope_endpoint.so"
 * copy it into src folder and rename it to "libxscope_endpoint.so", In eclipse, under project setting
 * C++ build, add library search path and add library name as "xscope_endpoint" in -l
 *
 *  Created on: 19-Jun-2015
 *      Author: kiran
 */
 #include <time.h>
#include <unistd.h>
#include <opencv2/opencv.hpp>			//Opencv header files.
#include <opencv2/imgproc/imgproc.hpp>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include "xscope_endpoint.h"	//Header file to be included in the same project

#define height 200				//Height of the image to be displayed
#define width 200				//Width of the image to be displayed

using namespace cv;

unsigned int x;					//Pixel location X(row)
unsigned int y;					//Pixel location Y(column)
unsigned char b;				// Blue 8-bit
unsigned char g;				//Green 8-bit
unsigned char r;				//Res 8-bit


cv::Mat image = cv::Mat::zeros(height, width, CV_8UC3);	//Temporary Image Buffer

cv::Mat dimage = cv::Mat::zeros(190, 190, CV_8UC3);		//Resized image for interpolation


/*This function records the value from XMOS through xSCOPE endpoint*/
void xscope_record(unsigned int id,
                   unsigned long long timestamp,
		   unsigned int length,
		   unsigned long long dataval,
		   unsigned char *databytes) {

/* The data sent from xSCOPE is identified by the ID field. The ID is determined in
 * XMOS XC code. The ID value is determined by the order in which each signals are invoked
 * Each ID represents unique signal.*/

	switch(id){

	/*	case 0:
			 y=dataval;						//dataval is the data from the corresponding signal
			 break;
	//	case 1:
			x=dataval;
			break;
	*/	case 2:
			r=(unsigned char)dataval;
			break;
		case 3:
			g=(unsigned char)dataval;
			break;
		case 4:
			b=(unsigned char)dataval;
			break;


		}








}

int main (void) {

  xscope_ep_set_record_cb(xscope_record);		//This function receives the data from XSCOPE
  xscope_ep_connect("localhost", "10234");		//This function connects the host code to XMOS XCORE-200

  // Use for nanosleep : struct timespec tim;

  	  	  	  	  	  	  	  	  	  	  	  	  //In OpenCV Image is stored in BGR format
  while(1){


	  for( x=0;x<height;x++){
		  for(y=0;y<width;y++){
	  	  image.at<cv::Vec3b>(y,x)[0] = b;		// Blue value is stored
	  	  image.at<cv::Vec3b>(y,x)[1] = g;		//Green value is stored
	  	  image.at<cv::Vec3b>(y,x)[2] = r;  	  //Red Value is stored

	    	usleep(1);							//delay of 1ms, susspends the thread. Works on linux.
	  /*	tim.tv_sec = 0;
	    tim.tv_nsec = 5 ;
	  	nanosleep(&tim,NULL);*/					//To provide delay in nanoseconds, works on linux

		  }

	  }

	  	  imshow("xSCOPE Display", image);								//Displays Image. use of waitKey(int milliSec) is necessary.
	  	  if (waitKey(1) == 27)											 //wait for 'esc' key press for 10ms. If 'esc' key is pressed, break loop
	         {
	              printf("Esc pressed\n");
	              break;
	         }

	}

  return 0;
}

