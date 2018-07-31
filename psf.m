classdef psf < handle
    %PSF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NA
        outDim % Dimentions of the output psf, [x y z], nm
        deltZ % Distance between z planes in nm
        pixSize
        emissionWL
        image
        dir2gen

    end
    
    methods
        function obj = psf(xySize,zSize, dir2gen, optics, emitter)
            %PSFPROPS Construct an instance of this class
            %   Detailed explanation goes here
            xyRes = 1; % [nm]
            zRes = 1; % [nm]
            
            obj.NA = optics.NA;
            
            assert(isinteger(xySize), 'xy size must be integer')
            assert(mod(xySize,2)==1, 'xy size must be odd')
            
            assert(isinteger(zSize), 'z size must be integer')
            assert(mod(zSize,2)==1, 'z size must be odd')
            assert(zSize>1, 'zSize must be >= 3')
            obj.outDim = [xySize, xySize, zSize]; % Dimentions of the output psf, [x y z], nm
            obj.deltZ = zRes;               % Distance between z planes in nm
            obj.pixSize = xyRes;             % Distance between pixels in nm
            obj.emissionWL = emitter.emissionWL;
            obj.dir2gen = dir2gen;
            obj.generate;
        end
        
        function obj = generate(obj)
            % Generation of the psf, remember you need access to the PSFGenerator.jar
            javaaddpath (obj.dir2gen)
            GenerateConfigFile( obj.emissionWL, obj.NA,...
                                obj.outDim, obj.deltZ,...
                                obj.pixSize, 'double'  )
            obj.image = PSFGenerator.compute('config.txt');  % Compute a PSF 
                                           % using the parameters of 
                                           % config.txt (without GUI)
        
        end
        
        function im = sampleInFocus(obj, n_counts, do_plots)
            
            switch nargin
                case 1
                    error('not enough inputs')
                case 2
                    do_plots = false;
            end
            
            % at the moment I'm leaving this as a private function I could
            % change it into a static method later
            [ im ] = emitter_image( obj.getInFocus, n_counts, do_plots );
            im = uint16(im);
        end
        
        function im = getInFocus(obj)
            zSize = obj.outDim(3);
            midIdx = ceil(zSize/2);
            im = obj.image(:,:,midIdx);
        end
        
        function obj = showInFocus(obj)
            im = getInFocus(obj);
            crSec = sum(im);
            crSec = crSec./max(crSec);
            figure()
            subplot(1,2,1)
            imagesc(im)
            axis image
            title('PSF in focus, res 1 nm')
            subplot(1,2,2)
            plot(1:obj.outDim(1), crSec)
            xlim([1,obj.outDim(1)])
            ylabel('Norm Intensity')
            xlabel('Pos in nm')
            title('Cross-section')
            shg

        end
        
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end
    end
end

