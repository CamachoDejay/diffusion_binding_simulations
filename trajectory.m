classdef trajectory < handle
    %TRAJECTORY takes a movement model, for the moment just linear, and
    %given the start position calculates the position of the particle over
    %time.
    
    properties
        model
        initPos
        positions
        time
        dTime
        length
    end
    
    methods
        function obj = trajectory(initPos,model)
            %TRAJECTORY Construct an instance of this class
            %   Detailed explanation goes here
            obj.initPos = initPos;
            obj.time = model.time;
            switch model.name
                case 'linear'
                    
                    angle = model.angle;
                    speed = model.speed; % in nm per ms
                    time  = model.time; % total time in ms
                    obj.length = model.tPoints; % total number of timepoints
                    
                    obj.dTime = time/obj.length; % in ms
                    
                    obj.model = model;
                    
                    dDist = speed * obj.dTime; % in  nm
                    
                    % angle is set to give clockwise rotation on the image
                    % display. where 0 correspons to horizontal (col-wise)
                    % right movement
                    dRow = sin(angle) * dDist;
                    dCol = cos(angle) * dDist;
                    
                    row = (0:obj.length-1).*dRow + obj.initPos(1);
                    col = (0:obj.length-1).*dCol + obj.initPos(2);
                    
                    traj = cat(2, row(:), col(:));
                    
                    obj.positions = traj;
                    
                otherwise
                    error(['cant handle ' model.name ' at the moment'])
            end
            
      
        end
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end
    end
end

