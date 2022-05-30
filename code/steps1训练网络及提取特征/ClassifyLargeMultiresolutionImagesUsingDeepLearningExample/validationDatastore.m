% The validationDatastore datastore takes as input two datastores,
% dsCancer,dsNormal and returns numValidationPatchesPerClass number of
% patches from dsCancer and dsNormal each. This datastore is used for
% training validation.

% Copyright 2019 The MathWorks, Inc.

classdef validationDatastore < matlab.io.Datastore
    
    properties
        dsCancer;
        dsNormal;
        patchCount;
        NumPatchesPerClass;
    end
    
    methods
        
        function ds = validationDatastore(dsCancer,dsNormal,numValidationPatchesPerClass)
            ds.dsCancer = copy(dsCancer);
            ds.dsNormal = copy(dsNormal);
            ds.patchCount = 1;
            ds.NumPatchesPerClass = numValidationPatchesPerClass;
        end
        
        function [data, info] = read(ds)
            
            if mod(ds.patchCount,2) == 1
                if ~hasdata(ds.dsCancer)
                    reset(ds.dsCancer);
                end
                [data, info] = read(ds.dsCancer);
            else
                if ~hasdata(ds.dsNormal)
                    reset(ds.dsNormal);
                end
                [data, info] = read(ds.dsNormal);
            end
            
            ds.patchCount = ds.patchCount + 1;
        end
        
        function TF = hasdata(ds)
            % The set of cancer images determines the length of the
            % datastore. We reset the healthy image pool as needed, but
            % this reset should never be necessary under the assumption
            % that the healthy set is much bigger.
            TF = (ds.patchCount <= ds.NumPatchesPerClass);
        end
        
        function reset(ds)
            reset(ds.dsCancer);
            reset(ds.dsNormal);
            ds.patchCount = 1;
        end
        
        
    end
    
    
    
end