classdef emitter < handle
    %EMITTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        emissionWL
        brightness % counts per second
        psf
        
    end
    
    methods
        function obj = emitter(emWL, brightness, optics)
            %EMITTER Construct an instance of this class
            %   Detailed explanation goes here
            obj.emissionWL = emWL;
            obj.brightness = brightness;
            psfSize_nm = [uint16(1001), uint16(1001), uint16(3)];
            dir2gen = [cd filesep 'ext' filesep 'PSFGenerator.jar' ];
            obj.psf = psf(psfSize_nm(1),psfSize_nm(3), dir2gen, optics, obj);

        end
        
        function obj = setBrightness(obj, b)
            obj.brightness = b;
            
        end
        
    end
end

