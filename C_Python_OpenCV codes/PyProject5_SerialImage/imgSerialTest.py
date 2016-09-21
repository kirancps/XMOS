"""AUTHOR:KIRAN
This is a sample code written to send and recieve image from PC to XCORE200 eXplorer kit through
RS232 serial communication on 128K baud. The code takes sample picture and sends each pixel's RGB to xcore
and recieves it and prints on shell. Data rate is too slow to reconstruct hte image through this. Hence
the code prints the value of rgb on shell along with number of bytes written. on XCORE, the CDC example code is running with defaul echo mode
pySerial needs to be installed for this on python 2.7 and above. please check COM settings on your PC before running.
The code also needs opencv and numpy for python
"""

import numpy as np #imports numpy for OpenCV
import cv2         #imports OpenCV
import serial      #imports pySerial
ser=serial.Serial(43,128000, timeout=1) #sets Serial port with configuration 128kbps baud and establishes connection
print ser      #prints the object created by serial comm
print ser.isOpen() #gives status on serial port connection, returns true if open
img=cv2.imread('pisa.jpg')  #reads image


for x in range(0,img.shape[0]):

    for y in range(0,img.shape[1]):
        
        print ser.write((str(img[x,y][0])))   #sends image pixel value (R component ) to xcore
        print ser.readline(500)                 #receives the data
    


ser.close() #closes serial port
    
        
