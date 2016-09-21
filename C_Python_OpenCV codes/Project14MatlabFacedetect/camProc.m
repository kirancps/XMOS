clear all;
close all;
clc;



vid=videoinput('winvideo',1,'YUY2_640x480');
set(vid,'ReturnedColorSpace','rgb');

inputImg = getsnapshot(vid);
buffImg=inputImg;
figure;
imshow(inputImg);
hsi=rgb2hsv(inputImg);
[m n o]=size(hsi);
h=zeros(m,n);
s=zeros(m,n);
%v=zeros(m,n);
for i=1:m
    for j=1:n
        
        %if(hsi(i,j,1)>130 && h(i,j,1)<160)
        h(i,j)=hsi(i,j,1);
        s(i,j)=hsi(i,j,2);
        %v(i,j)=hsi(i,j,3);
        %end;
        
       
    end;
end;

% figure;
% 
% imshow(s);
% figure;
% 
% imshow(v);
SE = strel('square',10);
IM2 = imerode(h,SE);
Im5 = imdilate(IM2,SE);



count=0;
thr=1024;
%temp=1;
figure;

imshow(Im5);
for i=1:m
    
    for  j=1:n
        
        if (Im5(i,j)>=0.81 && Im5(i,j)<=0.93 && s(i,j)>=0.52 && s(i,j)<=0.62)
            
           % if(h(i+3,j)<=0.81 || h(i,j+3)<=0.81 ||h(i-3,j)<=0.81 || h(i,j-3)<=0.81 || h(i+3,j)>=0.93 || h(i,j+3)>=0.93 || h(i-3,j)>=0.93 || h(i,j-3)>=0.93)
            count=count+1;
           
            %if( count<=thr && row(count)>0 && column(count)>0)
            row(count)=i;
            column(count)=j;
            
           %column(count)=j;
            
            %end;
           % buffImg(i,j,2)=512;
            % temp=i;
        end;
    end;
    
end;

mux=ceil(mean(row));
muy=ceil(mean(column));
% disp(row);
% disp(mux);
% disp(muy);
%start=mu;
for l=muy-10:muy+10
    
   
        
         buffImg(mux,l,2)=512;
         buffImg(mux+1,l,2)=512;
          buffImg(mux-1,l,2)=512;
            
end;


for l=mux-10:mux+10
    
   
        
         buffImg(l,muy,2)=512;
         buffImg(l,muy+1,2)=512;
          buffImg(l,muy-1,2)=512;
            
end;
        

%disp(count);
%disp(row);
%disp(column);

figure;

imshow(buffImg);

