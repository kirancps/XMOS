/*
 * main.c
 *
 *  Created on: May 22, 2015
 *      Author: KIRAN
 *
 *      This is the main function which calls test image pixel generation and
 *      prints hue components on console.
 */




#include <stdio.h>
#include <math.h>


 int c1,c2;
 int i,j;
 int m,n;

 int hue1;


int HueCal(chanend c);

void rgbVal0(chanend c, int i, int j);
int main(void){




    chan c;

    par{

        {

            for(i=2 ;i<110;i+2){
                for (j=1; j<100; j++){
                    rgbVal0(c,i,j);
                    c1++;
                }
            }
            printf("\n\t \t %d ", c1);

        }

       {
           for(m=2 ;m<110;m+2){
                           for (n=1; n<100; n++){
            hue1=HueCal(c);
            printf("%d\n",hue1);
            c2++;

                           }
           }

           printf("\n\t \t %d ", c2);
        }
    }



        return 0;

}



