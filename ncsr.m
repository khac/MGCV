clc;
clear;

fn                 =    'C:\Users\MAHE\Documents\MATLAB\NCSR_IR\Data\SR_test_images\car.jpg';     
psf                =    fspecial('gauss', 7, 1.6);
scale              =    3;
nSig               =    0;

par                =    NCSR_SR_Par( nSig, scale, psf );
par.I              =    double( imread( fn ) );
LR                 =    Blur('fwd', par.I, psf);
LR                 =    LR(1:par.scale:end,1:par.scale:end,:);    
par.LR             =    Add_noise(LR, nSig);   
par.B              =    Set_blur_matrix( par );  

[im PSNR SSIM]     =    NCSR_Superresolution( par );
disp( sprintf('%s :  PSNR = %2.2f  SSIM = %2.4f\n\n', fn, PSNR, SSIM));

if nSig == 0
    imwrite(im./255, 'C:\Users\MAHE\Documents\MATLAB\Results\SR_results\Noiseless\NCSR_car300x300.jpg');
else
    imwrite(im./255, 'Results\SR_results\Noisy\NCSR_car400x400.jpg');
end
