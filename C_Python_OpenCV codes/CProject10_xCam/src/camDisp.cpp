/*
 * camDisp.cpp
 *
 *  Created on: 13-Jul-2015
 *      Author: kiran
 */


/*
 * disp.cpp
 * This is source code for displaying image in host. The code consists of opencv and
 * XMOS xSCOPE libraries. The code needs to be completed in order to display camera data on host.
 *
 *  Created on: 13-Jul-2015
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
#define width 220				//Width of the image to be displayed

using namespace cv;

unsigned int x;					//Pixel location X(row)
unsigned int y;					//Pixel location Y(column)
unsigned char b;				// Blue 8-bit
unsigned char g;				//Green 8-bit
unsigned char r;				//Res 8-bit
//unsigned int r;


cv::Mat image = cv::Mat::zeros(height, width, CV_8UC3);	//Temporary Image Buffer

cv::Mat bayerImg = cv::Mat::zeros(height, width, CV_8UC1);		//Resized image for interpolation


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
		case 1:
			x=dataval;
			break;
*/		case 2:
			r=(unsigned char)dataval;
			break;
	/*	case 3:
			g=(unsigned char)dataval;
			break;
		case 4:
			b=(unsigned char)dataval;
			break;
   redundant part, ignore code in comments, the config.xscope file in xcode needs to be changed

	*/	}








}

int main (void) {

  xscope_ep_set_record_cb(xscope_record);		//This function receives the data from XSCOPE
  xscope_ep_connect("localhost", "10234");		//This function connects the host code to XMOS XCORE-200

  struct timespec tim;

  	  	  	  	  	  	  	  	  	  	  	  	  //In OpenCV Image is stored in BGR format
  while(1){





	 if(x==1){
	  for( x=0;x<height;x++){
		  for(y=0;y<width;y++){

	  	  bayerImg.at<char>(x,y) = r;		//camera data stored in bayer matrix

		  }

	  }
	 }


	  cvtColor(bayerImg,image,CV_BayerBG2RGB); //converts BG bayer to BGR format, openCV uses BGR format
	  	  imshow("xSCOPE Display",image);								//Displays Image. use of waitKey(int milliSec) is necessary.
	  	  if (waitKey(1) == 27) //wait for 'esc' key press for 10ms. If 'esc' key is pressed, break loop
	         {
	              printf("Esc pressed\n");
	              break;
	         }

	}


  return 0;
}




