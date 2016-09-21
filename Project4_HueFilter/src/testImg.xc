



/*
 * testImg.xc
 *
 *  Created on: May 22, 2015
 *      Author: KIRAN
 *
 *      Generates test image pixel values of red, blue , green (random values)
 */





void rgbVal(chanend c, float i, float j){


    float rbArray[3];

    rbArray[0]=i*6+j*3.0;
    rbArray[1]=i*1+j*3.0;
    rbArray[2]=i*4+j*1.0;

    unsigned int k;
    for(k=0;k<3;k++){
        c <: rbArray[k];
    }



}

void rgbVal0(chanend c, int i, int j){ //Generates random RGB value and sends it to the
                                       // calling function


    int rbArray[3];

    rbArray[0]=i*60+j*3;
    rbArray[1]=i*1+j*30;
    rbArray[2]=i*40+j*1;

    unsigned int k;
    for(k=0;k<3;k++){
        c <: rbArray[k];
    }



}


