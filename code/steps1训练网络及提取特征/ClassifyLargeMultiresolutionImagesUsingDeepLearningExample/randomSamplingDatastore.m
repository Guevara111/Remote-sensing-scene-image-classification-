% The randomSamplingDatastore datastore takes as input two datastores,
% dsCancer,dsNormal and returns data drawn from dsCancer and dsNormal with
% 50/50 probability. 
%
% The purpose of this datastore is achieve class balancing in Camelyon16,
% where tumor pixels are less common than normal tissue pixels. We achieve
% class balancing by selecting data from the datastore with cancer images
% as frequently as we select data from the datastore with normal images.
% Therefore, the classes the network is trained on should be approximately
% balanced.

% Copyright 2019 The MathWorks, Inc.

classdef randomSamplingDatastore < matlab.io.Datastore &...
        matlab.io.datastore.Partitionable &...
        matlab.io.datastore.Shuffleable
    
    
    properties
        dsCancer;
        dsNormal;
    end
    
    methods
        
        function ds = randomSamplingDatastore(dsCancer,dsNormal)
            ds.dsCancer = copy(dsCancer);
            ds.dsNormal = copy(dsNormal);
        end
        
        function [data, info] = read(ds)
            
            idx = randi(2);
            if idx == 1
                [data, info] = read(ds.dsCancer);
            else
                if ~hasdata(ds.dsNormal)
                    reset(ds.dsNormal);
                end
                [data, info] = read(ds.dsNormal);
            end
            
            if any(size(data{1}) ~= [299 299 3])
                fprintf('Read data from image number %d which has an incorrect size [%d %d %d]. Try reading again...\n',info{1}.ImageNumber,size(data{1},1),size(data{1},2),size(data{1},3));
                [data, info] = read(ds);
            end
            
            if iscell(info)
                info = info{1};
            end
            
        end
        
        function TF = hasdata(ds)
            % The set of cancer images determines the length of the
            % datastore. We reset the healthy image pool as needed, but
            % this reset should never be necessary under the assumption
            % that the healthy set is much bigger.
            TF = hasdata(ds.dsCancer);
        end
        
        function reset(ds)
            reset(ds.dsCancer);
            reset(ds.dsNormal);
        end
        
        
        %------------------------------------------------------------------
        function subds = partition(this, varargin)
            %partition Returns a partitioned portion of the randomPatchExtractionDatastore.
            %   subds = partition(pxds, N, index) partitions pxds into N
            %   parts and returns the partitioned
            %   randomPatchExtractionDatastore, subds, corresponding to
            %   index. An estimate for a reasonable value for N can be
            %   obtained by using the NUMPARTITIONS function.
            %
            %   subds = partition(pxds,'Files',index) partitions pxds by
            %   files in the Files property and returns the partition
            %   corresponding to index.
            %
            %   subds = partition(pxds,'Files',filename) partitions pxds by
            %   files and returns the partition corresponding to filename.
            
            try
                narginchk(3,3);
                
                newfirstds = partition(this.dsCancer, varargin{:});
                newsecondds = partition(this.dsNormal, varargin{:});
                
                subds = randomSamplingDatastore(newfirstds,newsecondds);
            catch ME
                throwAsCaller(ME)
            end
            
        end
        
        function newds = shuffle(this)
            
            newds = copy(this);
            % Reset the copied datastore because the orginal datastore's
            % state may have changed
            reset(newds);
            
            newds.dsCancer = shuffle(newds.dsCancer);
            newds.dsNormal = shuffle(newds.dsNormal);
        end
        
    end
    
    methods(Access = protected)
        function N = maxpartitions(this)
            N = min(numpartitions(this.dsNormal),numpartitions(this.dsCancer));
        end
    end
    
end