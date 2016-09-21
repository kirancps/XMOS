'''' This program demonstrtates the use of pyUSB to communicate with Vendor Specific device
  which receives and transfers data in bulk. Bulk data is sent and recieved and displayed on
  shell . XMOS Vendor specific USB driver installed with Vendor ID: 0x20b1 and product ID: 0xb1'''


import usb.core
import usb.util
import usb.backend

dev = usb.core.find(idVendor=0x20b1, idProduct=0xb1)
'''' Establishes the link to the USB device '''

'''Message should be in string format, else typrcast it with str()'''

print dev.set_configuration()
print dev

msg='Hello world'


'''CHooses deault OUT point and sends the message'''
dev.write(1, (msg))

'''Selects IN point  default 0x81 and reads message, pass the amount of data that has to be captured'''
ret = dev.read(0x81,len(msg))

'''converts back to ascii format'''

sret = ''.join([chr(x) for x in ret]) 
print sret
