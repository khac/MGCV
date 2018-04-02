function [im_out PSNR SSIM]   =  NCSR_Superresolution( par )
par.step      =   2;
par.win       =   6;
par.cls_num   =   64;
par.s1        =   25;
par.hp        =   75;

s             =   par.scale;
lr_im         =   par.LR;
[lh lw ch]    =   size(lr_im);
hh            =   lh*s;
hw            =   lw*s;
hrim          =   uint8(zeros(hh, hw, ch));
ori_im        =   zeros(hh,hw);

if  ch == 3
    lrim           =   rgb2ycbcr( uint8(lr_im) );
    lrim           =   double( lrim(:,:,1));    
    b_im           =   imresize( lr_im, s, 'bicubic');
    b_im2          =   rgb2ycbcr( uint8(b_im) );
    hrim(:,:,2)    =   b_im2(:,:,2);
    hrim(:,:,3)    =   b_im2(:,:,3);
    if isfield(par, 'I')
        ori_im         =   rgb2ycbcr( uint8(par.I) );
        ori_im         =   double( ori_im(:,:,1));
    end
else
    lrim           =   lr_im;
    
    if isfield(par, 'I')
        ori_im             =   par.I;
    end
end
hr_im    =   imresize(lrim, s, 'bicubic');
hr_im    =   Superresolution(lrim, par, ori_im, hr_im, 0, 4);
hr_im    =   Superresolution(lrim, par, ori_im, hr_im, 1, 2);

if isfield(par,'I')
   [h w ch]  =  size(par.I);
   PSNR      =  csnr( hr_im(1:h,1:w), ori_im, 0, 0 );
   SSIM      =  cal_ssim( hr_im(1:h,1:w), ori_im, 0, 0 );
end
if ch==3
    hrim(:,:,1)  =  uint8(hr_im);
    im_out       =  double(ycbcr2rgb( hrim ));
else
    im_out  =  hr_im;
end
return;





