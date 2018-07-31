classdef camera < handle
    %CAMERA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pixelSize % in nm
        physicalSize % in pixels
        coordinates % in nm
        image
%         exposure % in ms
    end
    
    methods
        function obj = camera(physicalSize, pixelSize)
            %CAMERA Construct an instance of this class
            %   Detailed explanation goes here
            obj.physicalSize = physicalSize;
            obj.pixelSize = pixelSize;
%             obj.exposure = exp; % in ms
            rowIdx = 1:physicalSize(1);
            colIdx = 1:physicalSize(2);
            
            row_nm = (rowIdx-0.5) .* pixelSize;
            col_nm = (colIdx-0.5) .* pixelSize;
            
            [obj.coordinates.col, obj.coordinates.row ] = meshgrid(col_nm,row_nm);
            obj.image = uint16(zeros(physicalSize));
        end
        
        function [row, col] = getPixCoor(obj,row_idx, col_idx)
            row = obj.coordinates.row(row_idx,col_idx);
            col = obj.coordinates.col(row_idx,col_idx);            
        end
        
        function displayImage(obj)
            figure()
            imagesc(obj.image)
            axis image
            title('Current frame')
        end
        
        function center = getCenterOfFrame(obj)
            center = ([obj.physicalSize(1) * obj.pixelSize / 2,...
                      obj.physicalSize(2) * obj.pixelSize /2]);
            center = uint16(center);
        end

    end
end

