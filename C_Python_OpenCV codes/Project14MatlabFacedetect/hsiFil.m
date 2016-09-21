clear all;
clc;
close all;

inputIm=(imread('sample10.jpg'));
inputImg=double(inputIm);
figure;
imshow(inputIm,[0 255]);
[m n o]=size(inputImg);
hsiImg=zeros(m,n);
% disp(inputImg(5,6,1));
% disp(inputImg(5,6,2));
% disp(inputImg(5,6,3));

buffImg=inputIm;
for i=1:m
    for j=1:n
        
        
            
            R=inputImg(i,j,1);
            G=inputImg(i,j,2);
            B=inputImg(i,j,3);
            r=R/(R+G+B);
            g=G/(R+G+B);
            b=B/(R+G+B);
            
            
            
            num=0.5*((r-g)+(r-b));
            den=((r-g)^2)+(r-b)*(g-b);
%             if(den>0)
%                 
%                 v=num/(den^0.5);
%             
%             else
%                 v=1;
%             end;
             v=num/(den^0.5);
            theta=acos(v);
            
            if(b<=g)
                
                hsiImg(i,j)=theta;
                
            else
                
                hsiImg(i,j)=2*pi-theta;
            end;
    end;
end;
sam=rgb2hsv(inputImg);

for i=1:m
    for j=1:n
        
        k(i,j)=sam(i,j,1);
    end;
end;


for i=1:m
    
    for  j=1:n
        
        if (hsiImg(i,j)>=0.24 && hsiImg(i,j)<=0.34)
            
            buffImg(i,j,2)=512;
           
        end;
    end;
    
end;

%BW=edge(hsiImg,'canny');

figure;
imshow(hsiImg);
figure;
imshow(buffImg);
                
            
            
