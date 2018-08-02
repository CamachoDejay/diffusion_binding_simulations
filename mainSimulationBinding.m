% the purpose of this script is to run all simulations used for the binding
% model

clear 
close all
clc

% total time in seconds of the simulated movie
time_sec = 50;

% mean pocket time in ms
for meanPocketTime = [1000, 500, 200, 100, 50, 25, 10]

    % exposure time in ms which sets the noise parameters
    for exp_ms = [50, 30, 16]
        % single movie simulation
        SimBinding(time_sec, exp_ms, meanPocketTime)
        disp(['Done for pocket time ' num2str(meanPocketTime),...
              ', and exp: ' num2str(exp_ms, '%.0f')])

    end
    disp(['Done for pocket times ' num2str(meanPocketTime)])
    
end

disp('Main script finished')
