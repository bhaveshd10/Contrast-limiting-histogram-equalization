clear all;clc;close all;

img=imread('NYC.tif');              % Read input image
temp_img=img;
[l,n]=size(temp_img);

histo=zeros(1,256);
for i=1:l
    for j=1:n
        histo(temp_img(i,j)+1)= histo(temp_img(i,j)+1)+1;   % Calculate Histogram of input image
    end
end

S=10;
C=(S*l*n)./256;             % Find C
clip_histo=[];

sum=0;
top=C;
bot=0;
while (top-bot)>1
    P=(top+bot)/2;
    for i=1:256
        if histo(i)>P
            sum=sum+(histo(i)-P);
        end
    end
    if sum>((C-P)*256)
        top=P;
    else
        bot=P;  
    end
end

actual_clip=round(top);         % Actual clip of image P

new_sum=0;
for i=1:256                         % Clip the histogram above the threshold
    if histo(i)>actual_clip
        new_sum=new_sum+(histo(i)-actual_clip);
        clip_histo(i)=P;
    else
        clip_histo(i)=histo(i);
    end
end

new_sum=round(new_sum/256);
clip_histo=clip_histo+new_sum;      % Equally distribute the clipped values

cumu_sum=0;
for i=1:256
    cumu_sum=cumu_sum+clip_histo(i);
    lut(i)=cumu_sum;                
end
lut=round((lut*256)./(l*n));        % Create LUT

for i=1:l
    for j=1:n
        temp_lut=temp_img(i,j);
        out(i,j)=lut(temp_lut);     % Map LUT into output image
    end
end

histo_out=zeros(1,256);
for i=1:l
    for j=1:n  
        if out(i,j)==256
            histo_out(out(i,j))= histo_out(out(i,j));
        else
            histo_out(out(i,j)+1)= histo_out(out(i,j)+1)+1;     % Histogram of output image
        end
    end
end

count1=0;
for i=1:256
    if histo(i)~=0
        count1=count1+1;        % No. of bins occupied in input image
    end
end
count2=0;
for i=1:256
    if histo_out(i)~=0
        count2=count2+1;       % No. of bins occupied in output image 
    end
end
count1
count2

max_slope=lut(2)-lut(1);
for i=2:255    
    if ((lut(i+1)-lut(i))>max_slope)
        max_slope=(lut(i+1)-lut(i));    % Max slope of LUT
    end
end
max_slope

% Plot
figure,plot(lut),title('Look Up Table CLHE'),grid on
figure,stem(histo),title('Histogram of image'),grid on
xlabel('pixel bins'),ylabel('count'),grid on
figure,stem(histo_out),title('Equalized Histogram Plot'),grid on
xlabel('pixel bins'),ylabel('count'),grid on
figure,subplot(1,2,1),imshow(img),title('NYC image')
subplot(1,2,2),imshow(uint8(out)),title('CLHE output image')
