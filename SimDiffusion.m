function out = SimDiffusion(exp_ms, molSpeed, nImages)
% SIMDIFFUSION simulates a stack of images with 3rd dimention = nImages,
% molecular speed along the focal plane = molSpeed [nm / ms], and exposure
% time = exp_ms [ms]

    % simple preconditions
    assert(length(exp_ms)== 1,'give only one exposure time')
    assert(length(molSpeed) == 1, 'give only one molecular speed')
    assert(length(nImages) == 1, 'give only one number for the amount of images to simulate')

    % end of preconditions
    
    % some parameters tht we do not change in the simulations
    movement = 'linear';
    disp('Currently only linear motion model available')

    % emission wavelength
    emWL = 550;
    disp(['Using generic emission wavelength of ' num2str(emWL) ' nm'])

    % properties of the camera
    pixSize = 100;
    disp(['Camera has a pixel size of ' num2str(pixSize) ' nm per pixel',...
          ', which is a typical value for super-resolution imaging'])
    
    % properties of the optics
    NA = 1.2;
    disp(['Objective has a NA of ' num2str(NA) ', which is important for ',...
          'psf calculation'])
    
    % properties of the camera, number of pixels
    rowDim = 50;
    colDim = 20;

    % movement of molecule at the moment linear
    mov_angle = pi/2; % in radians, clockwhise

    % time resolution for the simulations in ms
    timeRes = 4; % in ms
    %% populating properties that have been experimentaly determined
    switch exp_ms
        case 50
            % image conditions for 50 ms
            exp_ms = 50;
            % image mean of 3300
            frame_mean = 3300;
            % image std of 340
            frame_std = 340;

            % further for an emitter radius of 4 and a single timepoint we get
            % total brightness values of around 20K-30K, which translates into 3-6
            % e5 counts per second
            brightness = 6e5; % counts per second

        case 30
            % image conditions for 30 ms
            exp_ms = 30;
            % image mean of 3300
            frame_mean = 3400;
            % image std of 340
            frame_std = 350;

            % further for an emitter radius of 4 and a single timepoint we get
            % total brightness values of around 15K-20K, which translates into
            brightness = 7e5; % counts per second

        case 16
            % image conditions for 30 ms
            exp_ms = 16;
            % image mean of 3300
            frame_mean = 3600;
            % image std of 340
            frame_std = 380;

            % further for an emitter radius of 4 and a single timepoint we get
            % total brightness values of around 10K-20K, which translates into
            brightness = 10e5; % counts per second

        otherwise
            error('I dont know the frame background properties for the given exposure')
    end


    %% populating all simParams
    % here the idea is that I can work witout human interection if I want
    % by directly loading the simParams, which contains all parameters that
    % are relevant to the simulation. Thus lets create the simParams
    % structure

    % general
    simParams.timeRes_ms = timeRes;
    simParams.iterations = nImages;

    % related to the camera and frame
    simParams.exposure_ms = exp_ms;

    simParams.camera.dimensions = [rowDim,colDim];
    simParams.camera.pixSize_nm = pixSize;

    simParams.background.name = 'gaussian';
    simParams.background.mean = frame_mean;
    simParams.background.std = frame_std;

    % related to emitter and PSF
    simParams.optics.NA = NA;

    simParams.emitter.brightness = brightness;
    simParams.emitter.b_units    = 'counts per second';

    simParams.emitter.movement.name = movement;
    simParams.emitter.movement.speed = molSpeed;
    simParams.emitter.movement.s_units = 'nm per ms';
    simParams.emitter.movement.angle = mov_angle;
    simParams.emitter.emissionWL = emWL;

    
    % output directory
    outputDir = [cd filesep 'output' filesep 'linearDiffusion',...
                 filesep num2str(exp_ms, '%.0f') 'ms',...
                 filesep 'speed_' num2str(molSpeed, '%.0f') '_brightness_' num2str(brightness, '%.1s')];
    simParams.outputDir = outputDir;

    %% run the simulation, function defined below
    simulate(simParams);
    out = true;
end

function simulate(simParams)
% SIMULATE loads the simulation parameters and calls the simulation of a
% single frame
    % saving sim params
    outputDir = simParams.outputDir;
    [status,msg] = mkdir(outputDir);
    save([outputDir filesep 'simParams.mat'], 'simParams')

    % now the real code starts
    % init the optics
    op = optics(simParams.optics.NA);

    % properties of the emitter
    em = emitter(simParams.emitter.emissionWL,...
                 simParams.emitter.brightness,...
                 op);

    % camera
    cam = camera(simParams.camera.dimensions,...
                 simParams.camera.pixSize_nm);

    % properties of molecule trace
    % number of timepoints in the trace
    tpoints = round(simParams.exposure_ms/simParams.timeRes_ms);
    % populating trace model
    traceModel.name  = simParams.emitter.movement.name;
    traceModel.angle = simParams.emitter.movement.angle; % in radians, clockwhise
    traceModel.speed = simParams.emitter.movement.speed; % in nm per ms
    traceModel.time  = simParams.exposure_ms; % in ms
    traceModel.tPoints = tpoints; % length of the trajectory

    % properties of backgorund
    bgProps.mean = simParams.background.mean;
    bgProps.std  = simParams.background.std;
    bgProps.name = simParams.background.name;


    % number of simulations
    nSim = simParams.iterations;

    % init ouput variables
    mov = repmat( cam.image, 1, 1, nSim);

    parfor i = 1:nSim
        [fr] = simSingleFrame(cam, em, traceModel, bgProps);
        mov(:,:,i) = fr.image;
        disp(['Done ' num2str(i) ' out of ' num2str(nSim)])
    end

    % saving tif
    fName = ['linear_motion_' num2str(simParams.emitter.movement.speed),...
             '_nm_per_ms_exp_' num2str(simParams.exposure_ms) 'ms.tif'];

    fPathTiff = [simParams.outputDir filesep fName];
    t = Tiff(fPathTiff, 'w');
    t = dataStorage.writeTiff(t,mov,16);
    t.close;

    %
    disp('------ frames saved -----')
end


function [fr] = simSingleFrame(cam, em, traceModel, bgProps)
%SIMSINGLEFRAME Simulates a single frame of the camera, using the emitter
%defined in em, and using the proper trace and background properties

    % init empty frame
    fr = frame(cam);
    center = cam.getCenterOfFrame();
    traj = trajectory(double(center), traceModel);
    fr.addEmitterTrace(em,traj);

    % add background properties to the frame
    frame_mean = bgProps.mean;
    frame_std  = bgProps.std;

    fr.addConstantInt(uint16(frame_mean));
    bgModel.name = 'Gaussian';
    bgModel.std  = frame_std;
    fr.addNoise(bgModel);
    
    % Localization is done out of image simulation to use same analysis
    % pipeline as in the article. I leave below an example on how to do it
    % in the code
%     % now we take the image and try to localize
%     im = fr.image;
%     delta = 5;
%     FWHM_nm = 350;
%     FWHM_pix = FWHM_nm/105;
%     chi2 = 50;
%     [ pos ] = Localization.smDetection( double(im), delta, FWHM_pix, chi2 );
% 
%     detected = ~isempty(pos);

end

