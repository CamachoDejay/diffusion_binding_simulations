% the purpose of this script is to run all simulations used for the
% diffusion model

clear
close all
clc

% molecule speed in nm per ms for linear model
molSpeed = [0, 10, 14.14, 22.36, 31.62, 44.72, 54.77, 63.25, 70.71, 77.46];

% exposure time in ms
exp_ms = [50, 30, 16];

% number of iterations/images in the simulation
nImages = 500;

for exposure = exp_ms
    for speed = molSpeed
        % run a simulation for specific parameters
        SimDiffusion(exposure, speed, nImages);
    end
end

disp('Main script finished')
