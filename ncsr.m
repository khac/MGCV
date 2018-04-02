function  hr_im     =   Superresolution(lr_im, par, ori_im, hr_im0, flag, K)
hr_im      =   imresize( lr_im, par.scale, 'bicubic' );
[h   w]    =   size(hr_im);
[h1 w1]    =   size(ori_im);
y          =   lr_im;
lamada     =   par.lamada;

lam       =   zeros(0);
gam       =   zeros(0);
BTY       =   par.B'*y(:);
BTB       =   par.B'*par.B;
cnt       =   0;
if  flag==1  
     hr_im    =  hr_im0;
end

for k    =  1:K    
    Dict                 =   KMeans_PCA( hr_im, par, par.cls_num );
    [blk_arr wei_arr]    =   Block_matching( hr_im, par); 

    if flag==1
        lam      =   Sparsity_estimation( hr_im, par, Dict, blk_arr, wei_arr );        
    end
    Reg          =   @(x, y)NCSR_Regularization(x, y, par, Dict, blk_arr, wei_arr, lam, flag );
    f            =   hr_im;
    X_m          =   Update_NLM( f, par, blk_arr, wei_arr );
        
    for  iter    =   1 : par.iters
        cnt      =   cnt  +  1;           
        f_pre    =   f;
   
        if (mod(cnt, 40) == 0)
            if isfield(par,'I')
                PSNR     =  csnr( f(1:h1,1:w1), ori_im, 0, 0 );
                fprintf( 'NCSR super-resolution, iter. %d : PSNR = %f\n', cnt, PSNR );
            end
        end

        f        =   f_pre(:);
        for i = 1:par.n
            f    =   f + lamada.*(BTY - BTB*f);
        end
        
        if ( mod(iter, 2)==0 )
            X_m    =  Update_NLM( reshape(f, h,w), par, blk_arr, wei_arr );
        end                
        
        f        =  Reg( reshape(f, h,w), X_m );        
    end
    hr_im   =  f;
end
