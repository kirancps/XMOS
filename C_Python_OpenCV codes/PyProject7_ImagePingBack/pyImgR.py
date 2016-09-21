
"""Author:KIRAN
   This code demonstartes bidirectional image transfer and reception of image from PC
   to USB device. The USB device is vendor specific which pings back the recieved
   data using bulk transfer. A sample image of 160X120 RGB image is taken in example
   OpenCV is used to access and recreate the image.
   XMOS Vendor specific USB driver installed with Vendor ID: 0x20b1 and product ID: 0xb1"""

import numpy as np    #imports numpy opencv and USB modules
import time
import cv2
import usb.core
import usb.util

#establishes connection between host and USB device
dev = usb.core.find(idVendor=0x20b1, idProduct=0xb1) 
dev.set_configuration() #usb class created and device is set for bulk transfer by default
print time.time()       #prints code start time interms of CPU seconds
img=cv2.imread('samp.jpg') #reads image
h=img.shape[0]             #size of image
w=img.shape[1]
rmg = np.zeros((h,w,3),np.uint8)#received image buffer(h x w x 3 matrix with 8 bit


#The following access the image RGB values and then forms packet.which is 9digit(3R+3B+3G) 8bit=3digit
#sends and recieves and reconstructs the image

for x in xrange(h):

    for y in xrange(w):


        r=str(img[x,y][0])
        g=str(img[x,y][1])
        b=str(img[x,y][2])
        
        if(img[x,y][0]<100):        #to ensure 9 digit packet is formed when RGB value<100(3digit)
            r='0'+r
           
        if(img[x,y][1]<100):
            g='0'+g
            
        if(img[x,y][2]<100):
            b='0'+b
            
                 
        
        s=r+g+b
       
        dev.write(1,s)
        
        ret=dev.read(0x81,len(s))
        sret = ''.join([chr(i) for i in ret])
       #reconstruction  of image
        rmg[x,y][0]=sret[0:3]
        rmg[x,y][1]=sret[3:6]
        rmg[x,y][2]=sret[6:9]
        
   
        

np.uint8(rmg)



        
print time.time()
cv2.imshow('hi',rmg)  #displays image
cv2.waitKey(0)
cv2.destroyAllWindows()
