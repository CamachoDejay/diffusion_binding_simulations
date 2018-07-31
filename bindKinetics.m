classdef bindKinetics < handle
    %BINDKINETICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        exposure_ms
        nFrames
        timeAxis
        activity % pocket activity: stepTime, timeBefore, timeOn, timeOccupied
        activityTrace
        diffusionModel
        pocketModel
        bleachingModel
    end
    
    methods
        function obj = bindKinetics(exp_ms, nFrames, diffModel, pocModel, blModel)
            %BINDKINETICS Construct an instance of this class
            %   Detailed explanation goes here
            obj.exposure_ms = exp_ms;
            obj.nFrames = nFrames;
            
            % set time axis
            obj.setTimeAxis;
            
            % init activity trace
            obj.activityTrace = zeros(obj.nFrames,1);
            
            % storing models
            obj.diffusionModel = diffModel;
            obj.pocketModel = pocModel;
            obj.bleachingModel = blModel;
            
        end
        
        function obj = getActivityTrace(obj)
        % find for each frame the amount of time the molecule should be on
            

            obj.getPocketActivity;
            
            % find when the binding spot was light up (ON)
            time1 = cumsum(obj.activity(:,1));
            goesON  = time1 - obj.activity(:,4);
            goesOFF = goesON + obj.activity(:,3);
            wasON = cat(2, goesON, goesOFF)';

            % init the activity trace
            actTrace = zeros(obj.nFrames,1);

            for i = 1:obj.nFrames
                time1 = obj.timeAxis(i);
                time2 = obj.timeAxis(i+1);
            
                [totOnTime] = obj.getTimeOn(time1, time2, wasON);
            
                actTrace(i) = totOnTime;


            end
            
            obj.activityTrace = actTrace;
            
        end
        
        
        function obj = getPocketActivity(obj)
            totTime  = obj.nFrames * obj.exposure_ms; % in ms
            
            % pocket activity: stepTime, timeBefore, timeOn, timeOccupied
            pocAct = [];
            currentT = 0;
            while currentT < totTime

                times = obj.getSingleBindEvent;
                % get total time of the event
                dTime = times.before + times.occupied;
                % arrange output
                t = cat(2, dTime, times.before, times.on, times.occupied);
                % store
                pocAct = cat(1,pocAct,t);

                currentT = sum(pocAct(:,1));

            end
            
            obj.activity = pocAct;
        end
        
        function times = getSingleBindEvent(obj)
            % get time before a molecule bind into the pocket due to diffusion
            time2bind = obj.diffusionModel.getTime;

            % get time that the molecule will ocupy the pocket
            timeBind = obj.pocketModel.getTime;

            % get time before the molecule bleaches
            time2bleach = obj.bleachingModel.getTime;

            % get time the molecule is on
            timeON = min([timeBind, time2bleach]);

            times.before = time2bind;
            times.occupied = timeBind;
            times.on = timeON;
            
        end
        
        
        
        
        function obj = setTimeAxis(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            totTime  = obj.nFrames * obj.exposure_ms; % in ms
            obj.timeAxis = linspace(0, totTime, obj.nFrames+1);
        end
        
        function set.diffusionModel(obj,value)
            assert(isa(value, 'timeModel'), 'Diffusion model must be a time model')
            obj.diffusionModel = value;
        end
        
        function set.pocketModel(obj,value)
            assert(isa(value, 'timeModel'), 'Pocket model must be a time model')
            obj.pocketModel = value;
        end
        
        function set.bleachingModel(obj,value)
            assert(isa(value, 'timeModel'), 'Bleaching model must be a time model')
            obj.bleachingModel = value;
        end
        
    end
    
    methods(Static)
        
        function totOnTime = getTimeOn(time1, time2, wasON)
            assert(size(wasON,1) == 2, 'wasON must be a 2 by n matrix')
            assert(size(wasON,2) >= 1, 'wasON must be a 2 by n matrix')
            assert(all(diff(wasON)>0), 'wasON does not make sense, [1,n] must be smaller than [2,n]')
            assert(time2 > time1, 'time window is incorrect, time2 > time1')

            % first we look for the special case where the frame is defined within a
            % single on interval
            t = and(time1 >= wasON(1,:), time2 <=  wasON(2,:));
            wasON(1,t) = time1;
            wasON(2,t) = time2;


            % now that we took that into account we can check which on intervals are
            % involved
            t = and(wasON >= time1, wasON <= time2);

            % we check now for the special cases where an on interval is only partially
            % involved in the time interval
            tmp = diff(t);
            wasON(2,tmp==-1) = time2;
            wasON(1,tmp==1)  = time1;

            t = and(wasON >= time1, wasON <= time2);
            times = wasON(t);
            dt = diff(times);
            dt = dt(1:2:length(dt));

            totOnTime = sum(dt);
            
        end
    end
    
end

