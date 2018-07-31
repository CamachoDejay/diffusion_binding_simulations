classdef timeModel < handle
    %TIMEMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        mean
        std
    end
    
    methods
        function obj = timeModel(name,meanValue, stdValue)
            %TIMEMODEL Construct an instance of this class
            %   Detailed explanation goes here
            assert(ischar(name), 'name must be a character')
            
            
            obj.name = name;
            obj.mean = meanValue;
            
            switch name
                case 'Normal'
                    obj.std  = stdValue;
                case 'Exponential'
                    obj.std = [];
                otherwise
                    error('name must be Normal or Exponential')
            end
            
        end
        
        function time = getTime(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            switch obj.name
                case 'Normal'
                    time = normrnd(obj.mean,obj.std);

                case 'Exponential'
                    time = exprnd(obj.mean);

                otherwise
                    error(['I dont know how to hande ' obj.name])

            end
        end
    end
end

