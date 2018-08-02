classdef frame < handle
    %FRAME this is one of the main classes of the project. It takes
    %information about the camera, emitter and the scene to generate the
    %iamge of the frame.
    
    properties
        camera
        emitter
        positions
        image
        coordinates
        exposure
        
    end
    
    methods
        function obj = frame(camera)
            %FRAME Construct an instance of this class
            %   Detailed explanation goes here
            obj.camera = camera;
%             obj.emitter = emitter;
%             obj.positions = positions;
%             obj.exposure = camera.exposure;
            
            obj.image = uint16(zeros(camera.physicalSize));
            obj.coordinates = camera.coordinates;
            
            % here we can add iteration in case we get more than one pos.
%             obj = addEmitterIm(obj, positions(1,:));
            
        
        end
        
        function hrIm = initHRimage( obj )
            % pixel size
            pSize = obj.camera.pixelSize;
            % camera size
            camSize = obj.camera.physicalSize;
            
            % find last row value of the hrImage
            lastRow = obj.coordinates.row(camSize(1),1)+pSize/2;
            % find last col value of the hrImage
            lastCol = obj.coordinates.col(1,camSize(2))+pSize/2;
            hrIm = uint16(zeros(lastRow, lastCol, 1));
            
        end
        
        function obj = addMultipleEmitters(obj, emitter, pos_list, exp_ms)
            
            assert(isa(emitter, 'emitter'), 'emitter must be of emitter class')
            
            assert(size(pos_list,2)==2, 'position list must be an nx2 matrix')
            nEmitters = size(pos_list,1);
            
            for i = 1:nEmitters
                pos = pos_list(i,:);
                obj.addEmitterIm(emitter, pos, exp_ms)
            end
            
        end
        
        function obj = addEmitterTrace(obj, emitter, traj)
            
            assert(isa(emitter, 'emitter'), 'emitter must be of emitter class')
            assert(isa(traj, 'trajectory'), 'trajectory must be of trajectory class')
            
            exposure_ms = traj.dTime;
            obj.updateExposure(exposure_ms, true);
            
            h = waitbar(0, 'Please wait, adding trace...');
            for i = 1:traj.length
                pos = traj.positions(i,:);
                obj.addEmitterIm(emitter, uint16(pos), exposure_ms);
                waitbar(i / traj.length)
            end
            close(h)

            total_exp_ms = traj.time;
            obj.updateExposure(total_exp_ms, true);
            
        end
        
        function obj = addEmitterIm(obj, emitter, pos, exp_ms)
            
            assert(isa(emitter, 'emitter'), 'emitter must be of emitter class')
            % update exposure
            obj.updateExposure(exp_ms);
            % add position to the list
            obj.addPos2list(pos);
            
            % init hrImage, which is just the same as obj.image but with
            % 1nm resolution
            hrImage = obj.initHRimage();
            
            % get number of counts to sample the psf
            n_counts = emitter.brightness * obj.exposure / 1000;
            
            % sample the psf
            hrEmitter = emitter.psf.sampleInFocus(n_counts);
            
            % add hrEmitter to hrImage
            % find size of hrImage
            lastImRow = size(hrImage,1);
            lastImCol = size(hrImage,2);
            % find size of hrEmitter
            lastEmRow = size(hrEmitter,1);
            lastEmCol = size(hrEmitter,2);
            % find middle
            mid = [ceil(lastEmRow/2), ceil(lastEmCol/2)];
            
            % shift coordinate axis to fit position value
            rowCoor = (1:lastEmRow) - mid(1) + double(pos(1));
            % find if some of the iamge is out of scope and remove it
            badIdx = or(rowCoor<1, rowCoor>lastImRow);
            rowCoor(badIdx) = [];
            hrEmitter(badIdx,:) = [];
            
            % shift coordinate axis to fit position value
            colCoor = (1:lastEmCol) - mid(2) + double(pos(2));
            % find if some of the image is out of scope and remove it
            badIdx = or(colCoor<1, colCoor>lastImCol);
            colCoor(badIdx) = [];
            hrEmitter(:,badIdx) = [];
            
            % simple test to make sure that some image is left
            if isempty(hrEmitter)
                warning('emitter is out of image bounds')
                return
            else
                hrImage(rowCoor, colCoor) = hrImage(rowCoor, colCoor) + hrEmitter;
            end
            
            % downsample the hrImage to create the final image
            lowResIM = convert2lowres(obj, hrImage);
            obj.image = obj.image + lowResIM;
        end
        
        function obj = addConstantInt(obj, value)
            assert(and(value>=0, isinteger(value)), 'value must be a positive integer')
            obj.image = obj.image + value;
            
        end
        
        function obj = addNoise(obj, model)
            
            switch model.name
                case 'Poisson'
                    obj.image = imnoise(obj.image,'poisson');
                case 'Gaussian'
                    
                    im = obj.image;
                    sDev = model.std;
                    gaus = normrnd(0,sDev, size(im));
                    im = double(im) + gaus;
                    obj.image = uint16(im);
                    
                otherwise
                    error(['dont know how to handle ' model ' noise. Only "Poisson"'])
            end
            
        end
        
        function im = convert2lowres(obj, hrImage)
            % scale factor
            sFactor = size(hrImage) ./ size(obj.image);
            assert(sFactor(1)==sFactor(2),'Unexpected')
            sFactor = sFactor(1);
            % averaging in a fun and efficient way
            im = reshape( hrImage ,[sFactor size(obj.image,1) sFactor size(obj.image,2)]);
            im = sum(im,1);
            im = sum(im,3);
            im = reshape(im,size(obj.image));
            im = uint16(im);
            
        end
        
        function obj = updateExposure(obj, exp_ms, force)
            
            switch nargin
                case 2
                    force = false;
                    
                case 3
                    % then we might want to force things a bit
                    
                otherwise
                    error('problems with inputs')
            end
            
            
            if isempty( obj.exposure )
                obj.exposure = exp_ms;
            elseif ~force
                assert(obj.exposure == exp_ms, 'unexpected, you cant change exposure on the fly')
            elseif force
                obj.exposure = exp_ms;
                disp('working with trajctories')
            else
                error('unexpected')
                
            end
            
        end
        
        function obj = addPos2list(obj, pos)
            assert(all(size(pos)==[1,2]), 'position must be a 1x2 vector')
            assert(isinteger(pos), 'Input position must be integer and in nm');
            obj.positions = cat(1,obj.positions, pos);
            
        end
        
        function showFrame(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            figure()
            imagesc(obj.image)
            axis image
        end
    end
end

