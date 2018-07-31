function SimBinding(time_sec, exp_ms, meanPocketTime)

% storing values of movie time and exposure
simParams.movie.time_sec = time_sec;
simParams.movie.exp_ms   = exp_ms; 

% time in the pocket


% number of frames in the movie
nFrames = ceil(time_sec * 1000 / exp_ms);
% storing number of frames
simParams.movie.nFrames  = nFrames;

% model for the time in the pocket
% meanPocketTime = 200; 
timeStd = meanPocketTime * 0.05;
simParams.pocketModel = timeModel('Normal', meanPocketTime, timeStd);
                    
% time before a molecule goes into the pocket
simParams.diffModel = timeModel('Normal', 100, 5);

background.name = 'gaussian';
switch exp_ms
    case 50
        % image conditions for 50 ms
        exp_ms = 50;
        % image mean of 3300
        background.mean = 3300;
        % image std of 340
        background.std = 340;

        % further for an emitter radius of 4 and a single timepoint we get
        % total brightness values of around 20K-30K, which translates into 3-6
        % e5 counts per second
        emitt.brightness = 6e5; % counts per second
        
        % bleching time
        simParams.bleachModel = timeModel('Exponential', 1000);
%         simParams.bleachModel = timeModel('Normal', 1000, .1);

    case 30
        % image conditions for 30 ms
        exp_ms = 30;
        % image mean of 3300
        background.mean = 3400;
        % image std of 340
        background.std = 350;

        % further for an emitter radius of 4 and a single timepoint we get
        % total brightness values of around 15K-20K, which translates into
        emitt.brightness = 7e5; % counts per second
        
        % bleching time
        simParams.bleachModel = timeModel('Exponential', 100);
%         simParams.bleachModel = timeModel('Normal', 100, .1);

    case 16
        % image conditions for 30 ms
        exp_ms = 16;
        % image mean of 3300
        background.mean = 3600;
        % image std of 340
        background.std = 380;

        % further for an emitter radius of 4 and a single timepoint we get
        % total brightness values of around 10K-20K, which translates into
        emitt.brightness = 10e5; % counts per second

        % bleching time
        simParams.bleachModel = timeModel('Exponential', 30);
%         simParams.bleachModel = timeModel('Normal', 30, .1);
    otherwise
        error('I dont know the frame background properties for the given exposure')
end

simParams.background = background;
        
%% output directory
simParams.outputDir = [cd filesep 'output' filesep 'bindKinetics',...
                      filesep 'pocketTime_' num2str(meanPocketTime, '%.0f'),...
                      filesep 'exp_ms_' num2str(exp_ms, '%.0f')];

mkdir(simParams.outputDir);

%% getting the kinetics as activity time of the label on the pocket

bindKin = bindKinetics(exp_ms, nFrames, simParams.diffModel,...
                                        simParams.pocketModel,...
                                        simParams.bleachModel);
bindKin.getActivityTrace();
%% make movie    

% related to emitter and PSF
simParams.optics.NA = 1.2;
emitt.b_units    = 'counts per second';
emitt.emissionWL = 550;

simParams.emitter = emitt;
% properties of the optics
NA = simParams.optics.NA;
op = optics(NA);

% properties of the camera
simParams.camera.dimensions = [30, 30];
simParams.camera.pixSize_nm = 100;
cam = camera(simParams.camera.dimensions, simParams.camera.pixSize_nm);


em = emitter(simParams.emitter.emissionWL,...
             simParams.emitter.brightness, op);

mov = repmat( cam.image, 1, 1, nFrames);

for i = 1:nFrames
    actTime   = bindKin.activityTrace(i);
    relBright = emitt.brightness * (actTime / exp_ms);
    
    em.setBrightness(relBright);
    fr = frame(cam);
    fr.addEmitterIm(em, cam.getCenterOfFrame(), exp_ms);
    fr.addConstantInt(uint16(simParams.background.mean));
    model.name = 'Gaussian';
    model.std  = simParams.background.std;
    fr.addNoise(model);
    
    mov(:,:,i) = fr.image;
end

disp('Image generation done')

%% Saving into tif
fName = ['pocketTime_' num2str(meanPocketTime, '%.0f') '_exp_ms_' num2str(exp_ms, '%.0f') '.tif'];
fPathTiff = [simParams.outputDir filesep fName];
t = Tiff(fPathTiff, 'w');
t = dataStorage.writeTiff(t,mov,16);
t.close;

save([simParams.outputDir filesep 'simParams.mat'], 'simParams')
