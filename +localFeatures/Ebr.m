classdef Ebr < localFeatures.GenericLocalFeatureExtractor & ...
    helpers.GenericInstaller
% EBR Edge-based detector
%   EBR('OptionName',optionValue,...) Constructs wrapper around edge-based
%   detector binary [1] [2] used is downlaoded from:
%
%   http://www.robots.ox.ac.uk/~vgg/research/affine/det_eval_files/ebr.ln.gz
%
%   Only supported architectures are GLNX86 and GLNXA64 as for these the
%   binary is avaialable.
%
%   (No options available currently)
%
%   REFERENCES
%   [1] T. Tuytelaars, L. Van Gool. et al. Matching of affinely invariant
%   regions for visual servoing. ICRA, 1999.
%
%   [2] T. Tuytelaars, L. Van Gool. Matching Widely Seprated Views based on
%   Affine Invariant Regions. IJCV 59(1):61-85, 2004.

% AUTORIGHTS
  properties (Constant)
    rootInstallDir = fullfile('data','software','ebr','');
    binPath = fullfile(localFeatures.Ebr.rootInstallDir,'ebr.ln');
    softwareUrl = 'http://www.robots.ox.ac.uk/~vgg/research/affine/det_eval_files/ebr.ln.gz';
  end

  methods
    function obj = Ebr(varargin)
      import localFeatures.*;
      import helpers.*;
      % Check platform dependence
      machineType = computer();
      if ~ismember(machineType,{'GLNX86','GLNXA64'})
          error('Arch: %s not supported by EBR',machineType);
      end
      obj.name = 'EBR';
      obj.detectorName = obj.name;
      varargin = obj.checkInstall(varargin);
      obj.configureLogger(obj.name,varargin);
    end

    function [frames] = extractFeatures(obj, imagePath)
      import helpers.*;
      import localFeatures.*;

      frames = obj.loadFeatures(imagePath,false);
      if numel(frames) > 0; return; end;      
      startTime = tic;
      obj.info('Computing frames of image %s.',getFileName(imagePath));
      tmpName = tempname;
      framesFile = [tmpName '.feat'];
      args = sprintf('"%s" "%s"',imagePath, framesFile);
      cmd = [obj.binPath ' ' args];

      [status,msg] = system(cmd,'-echo');
      if status ~= 0
        error('%d: %s: %s', status, cmd, msg) ;
      end
      frames = localFeatures.helpers.readFramesFile(framesFile);
      delete(framesFile);
      timeElapsed = toc(startTime);
      obj.debug('%d frames from image %s computed in %gs',...
        size(frames,2),getFileName(imagePath),timeElapsed);
      obj.storeFeatures(imagePath, frames, []);
    end

    function sign = getSignature(obj)
      sign = helpers.fileSignature(obj.binPath);
    end
  end

  methods (Static)
    function [urls dstPaths] = getTarballsList()
      import localFeatures.*;
      urls = {Ebr.softwareUrl};
      dstPaths = {Ebr.rootInstallDir};
    end

    function compile()
      import localFeatures.*;
      % When unpacked, ebr is not executable
      helpers.setFileExecutable(Ebr.binPath);
    end
  end % ---- end of static methods ----
end % ----- end of class definition ----