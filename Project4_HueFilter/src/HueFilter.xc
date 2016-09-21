/*
 * HueFilter.xc
 *
 *  Created on: May 22, 2015
 *      Author: KIRAN
 *
 *      This function returns hue value for the given RGB value fo the image.
 *      Retruns in radians.
 */


#include <math.h>

#define MIN3(x,y,z)  ((y) <= (z) ? \
                        ((x) <= (y) ? (x) : (y)) \
                      : \
                         ((x) <= (z) ? (x) : (z)))

#define MAX3(x,y,z)  ((y) >= (z) ? \
                          ((x) >= (y) ? (x) : (y)) \
                      : \
                          ((x) >= (z) ? (x) : (z)))

#define pi 3.14




float calculateHue( chanend c){
    float theta;            //hue value
    float num;
    float r,g,b;
    float R,G,B;
    unsigned int i;
    for (i=0;i<3;i++){
       c :> R;
       c :> G;
       c :> B;
    }
    float den;
    r=(R/(R+G+B));          //normalized value of r,g,b
    g=(G/(R+G+B));
    b=(B/(R+G+B));

    num=0.5*((r-g)+(r-b));              //theta=cos^-1  (0.5*(r-g)+(r-b))
    den=sqrt(pow((r-g),2)+(r-b)*(g-b));      //              -----------------
                                        //              sqrt((r-g)^2+(r-b)(r-g))
   ///if(den>0){

        theta=acos(num/den);

        //  }

   //else
      //  theta=acos(num/0.001);              // hue={ theta ;b<=g
                                            //       2*pi-theta ;b>g
 // if(B<=G){

        return theta;
 // }

 //  else

    //   return (2*pi-theta);
}



int HueCal(chanend c){   //Integer approximation of caluclation of hue value


    int hue;
    int i;
    //int j;
    int rmax,rmin;

    int r,g,b;
    for(i=0;i<3;i++)
    {
        c :> r;
        c :> g;
        c :> b;



    }

    rmax=MAX3(r,g,b);
    rmin=MIN3(r,g,b);

    if(rmax==r){

        hue=0+43*(g-b)/(rmax-rmin);
        if(hue<0){
            hue+=360;
        }
            }

    else if (rmax==g)
    {
        hue=85+43*(r-b)/(rmax-rmin);

    }

    else
    {
        hue=171+43*(r-g)/(rmax-rmin);
    }



    return hue;

}









