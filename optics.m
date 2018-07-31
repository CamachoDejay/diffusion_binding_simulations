classdef optics < handle
    %OPTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NA
    end
    
    methods
        function obj = optics(NA)
            %OPTICS Construct an instance of this class
            %   Detailed explanation goes here
            obj.NA = NA;
        end
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end
    end
end

