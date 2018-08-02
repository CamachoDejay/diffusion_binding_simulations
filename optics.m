classdef optics < handle
    %OPTICS is at the moment a bit of a silly class. More could go in here
    %if the project grows. The idea is for it to contain information about
    %the optics used to calculate the PSF
    
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

