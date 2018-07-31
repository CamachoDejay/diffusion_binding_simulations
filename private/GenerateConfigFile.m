function GenerateConfigFile( Em_wavelength, Num_aper, out_dim, delt_z, pix_size, num_type  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Lambda      = Em_wavelength; % emission wavelength 
NA          = Num_aper;   %numerical aperture
NX          = out_dim(1);  % number of pixels in x
NY          = out_dim(2);  % number of pixles in y
NZ          = out_dim(3);   % number of z planes
ResAxial    = delt_z; % distance between z planes
ResLateral  = pix_size; % XY pixel size
S           = 'Linear'; % Linear scale
T           = num_type; % number type

fileID = fopen('config.txt','w');
fprintf(fileID,'#PSF Generator \r\n');
t = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
fprintf(fileID,['#' datestr(t) '\r\n' ]);
fprintf(fileID,['Lambda=' num2str(Lambda,'%.1f') '\r\n' ]);
fprintf(fileID,['LUT=Fire' '\r\n' ]);
fprintf(fileID,['NA=' num2str(NA,'%.2f') '\r\n' ]);
fprintf(fileID,['NX=' num2str(NX,'%.0f') '\r\n' ]);
fprintf(fileID,['NY=' num2str(NY,'%.0f') '\r\n' ]);
fprintf(fileID,['NZ=' num2str(NZ,'%.0f') '\r\n' ]);
fprintf(fileID,['ResAxial=' num2str(ResAxial,'%.1f') '\r\n' ]);
fprintf(fileID,['ResLateral=' num2str(ResLateral,'%.1f') '\r\n' ]);
fprintf(fileID,['Scale=' S '\r\n' ]);
fprintf(fileID,['Type=' T '\r\n' ]);

% Lateral / Axial 
% These synthetic PSFs are defined by the tensor product of 2 functions,
% the lateral 2D function and the axial Z-function. At the Z defocussed
% plane the 2D lateral function is two times larger than the focal plane.
fprintf(fileID,['psf-Astigmatism-axial=Linear' '\r\n' ]);
fprintf(fileID,['psf-Astigmatism-defocus=100.0' '\r\n' ]);
fprintf(fileID,['psf-Astigmatism-focus=0.0' '\r\n' ]);


% Optical Model - BW must stand for Born and Wolf
fprintf(fileID,['psf-BW-accuracy=Good' '\r\n' ]);
fprintf(fileID,['psf-BW-NI=1.5' '\r\n' ]);


s = 'psf-Cardinale-Sine-axial=Linear';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Cardinale-Sine-defocus=100.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Cardinale-Sine-focus=0.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Circular-Pupil-axial=Linear';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Circular-Pupil-defocus=100.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Circular-Pupil-focus=0.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Cosine-axial=Linear';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Cosine-defocus=100.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Cosine-focus=0.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Defocus-DBot=30.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Defocus-DMid=1.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Defocus-DTop=30.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Defocus-K=275.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Defocus-ZI=2000.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Double-Helix-axial=Linear';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Double-Helix-defocus=100.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Double-Helix-focus=0.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Gaussian-axial=Linear';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Gaussian-defocus=100.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Gaussian-focus=0.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-GL-accuracy=Good';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-GL-NI=1.5';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-GL-NS=1.33';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-GL-TI=150.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-GL-ZPos=2000.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Koehler-dBot=6.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Koehler-dMid=3.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Koehler-dTop=1.5';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Koehler-n0=1.5';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Koehler-n1=1.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Lorentz-axial=Linear';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Lorentz-defocus=100.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Lorentz-focus=0.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Oriented-Gaussian-axial=Linear';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Oriented-Gaussian-defocus=100.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-Oriented-Gaussian-focus=0.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-RW-accuracy=Good';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-RW-NI=1.5';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-TV-NI=1.5';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-TV-NS=1.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-TV-TI=150.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-TV-ZPos=2000.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-VRIGL-accuracy=Good';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-VRIGL-NG=1.5';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-VRIGL-NI=1.5';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-VRIGL-NS1=1.33';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-VRIGL-NS2=1.4';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-VRIGL-RIvary=Linear';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-VRIGL-TG=170.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-VRIGL-TI=150.0';  fprintf(fileID,[s '\r\n' ]);
s = 'psf-VRIGL-ZPos=2000.0';  fprintf(fileID,[s]);
% % s = '';  fprintf(fileID,[s '\r\n' ]);
fclose(fileID);

end






