function SimDiffusion(exp_ms)

    % inputs that should be accessible to easy user change

    % esposure in ms
    % exp_ms = 16;

    % molecule speed in nm per ms
    molSpeed = [0, 10, 14.14, 22.36, 31.62, 44.72, 54.77, 63.25, 70.71, 77.46]; % in nm per ms
    movement = 'linear';

    % number of iterations in the simulation
    nSim = 500;

    % emission wavelength
    emWL = 550;

    % properties of the camera
    pixSize = 100;
    %%%%%%%%%% END OF USUAL INPUTS  %%%%%%%%%%%%%%%%%%%%%%%%%

    % properties of the optics
    NA = 1.2;

    % properties of the camera
    rowDim = 50;
    colDim = 20;

    % movement of molecule at the moment linear
    mov_angle = pi/2; % in radians, clockwhise

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
            
            % time resolution for the simulations in ms
            timeRes = 5; % in ms

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
            
            % time resolution for the simulations in ms
            timeRes = 5; % in ms

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

            % time resolution for the simulations in ms
            timeRes = 4; % in ms
        otherwise
            error('I dont know the frame background properties for the given exposure')
    end


    %% populating all simParams
    % here the idea is that I can work witout human interection if I want by
    % directly loading the simParams, which contains all parameters that are
    % relevant to the simulation:

    % general
    simParams.timeRes_ms = timeRes;
    simParams.iterations = nSim;

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
%     simParams.emitter.movement.speed = molSpeed;
    simParams.emitter.movement.s_units = 'nm per ms';
    simParams.emitter.movement.angle = mov_angle;
    simParams.emitter.emissionWL = emWL;

    for speed = molSpeed
        
        simParams.emitter.movement.speed = speed;
        % output directory
        outputDir = [cd filesep 'output' filesep 'linearDiffusion',...
                     filesep num2str(exp_ms, '%.0f') 'ms',...
                     filesep 'speed_' num2str(speed, '%.0f') '_int_' num2str(brightness, '%.1s')];
        simParams.outputDir = outputDir;

        %%
        simulate(simParams);
    end
    
    disp('-----------------')
    disp('All Done')
end

function simulate(simParams)
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
    detected = false(nSim,1);
    mov = repmat( cam.image, 1, 1, nSim);

    parfor i = 1:nSim
        [fr, detected(i), ~] = simSingleFrame(cam, em, traceModel, bgProps);
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
    disp('------ Some output for curiosity -----')
    disp(['Percentage of detected molecules: ' num2str(sum(detected)*100/nSim, '%.2f') ])

end


function [fr, detected, pos] = simSingleFrame(cam, em, traceModel, bgProps)
    %SIMSINGLEFRAME Summary of this function goes here
    %   Detailed explanation goes here
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

    % now we take the image and try to localize
    im = fr.image;
    delta = 5;
    FWHM_nm = 350;
    FWHM_pix = FWHM_nm/105;
    chi2 = 50;
    [ pos ] = Localization.smDetection( double(im), delta, FWHM_pix, chi2 );

    detected = ~isempty(pos);

end

