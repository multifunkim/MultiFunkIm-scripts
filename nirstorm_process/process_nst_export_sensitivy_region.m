function varargout = process_nst_export_sensitivy_region( varargin )
% Export the sensitivity of the montage to each region of a definied atlas.
% For each channel, report the average sensitivity to eah region of the
% atlas and export it as tsv file. 
% Authors: Edouard Delaire (2024) 

eval(macro_method);
end

function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'Export nirs sensitivity to tsv';
    sProcess.FileTag     = '';
    sProcess.Category    = 'File';
    sProcess.SubGroup    = {'Multifunkim', 'fNIRS'};
    sProcess.Index       = 7001;
    sProcess.Description = '';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data', 'raw'};
    % Definition of the outputs of this process
    sProcess.OutputTypes = {'results'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;
    sProcess.isSeparator = 0;


    % === Process description
    % === CLUSTERS
    sProcess.options.scouts.Comment = '';
    sProcess.options.scouts.Type    = 'scout';
    sProcess.options.scouts.Value   = {};


    SelectOptions = {...
        '', ...                            % Filename
        '', ...                            % FileFormat
        'save', ...                        % Dialog type: {open,save}
        'Select output folder...', ...     % Window title
        'ExportData', ...                  % LastUsedDir: {ImportData,ImportChannel,ImportAnat,ExportChannel,ExportData,ExportAnat,ExportProtocol,ExportImage,ExportScript}
        'single', ...                      % Selection mode: {single,multiple}
        'files', ...                        % Selection mode: {files,dirs,files_and_dirs}
        {{'.tsv'}, '*.tsv'}, ... % Available file formats
        'MriOut'};                         % DefaultFormats: {ChannelIn,DataIn,DipolesIn,EventsIn,AnatIn,MriIn,NoiseCovIn,ResultsIn,SspIn,SurfaceIn,TimefreqIn}
    % Option definition
    % TODO: add flag to enable ouput
    sProcess.options.outputdir.Comment = 'Output file:';
    sProcess.options.outputdir.Type    = 'filename';
    sProcess.options.outputdir.Value   = SelectOptions;

end

%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
    Comment = sProcess.Comment;
end


%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>

    OutputFiles = {};
    
    % Save the new head model
    sStudy = bst_get('Study', sInputs.iStudy);
    
    sForward    = in_bst_headmodel(sStudy.HeadModel(sStudy.iHeadModel).FileName);
    sCortex     = in_tess_bst(sForward.SurfaceFile);
    
    nChannel    = size(sForward.Gain,1);
    
    % ROI selection
    ROI     = sProcess.options.scouts.Value;
    iAtlas  = find(strcmp( {sCortex.Atlas.Name},ROI{1}));
    iRois   = cellfun(@(x)find(strcmp( {sCortex.Atlas(iAtlas).Scouts.Label},x)),   ROI{2});
    
    % Threshold : remove all sensitivity lower than -5db
    threshold_value = -2; % in db

    varTypes = ["string",  repmat("double", 1 , length(iRois))];
    varNames = [{'Channel'}, {sCortex.Atlas(iAtlas).Scouts.Label}];
    sz = [nChannel, length(varNames)];
    
    T = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

    % Average the gain of the two wavelength 
    gain_matrix = squeeze(mean(sForward.Gain, 2));
    max_gain    = max(max(gain_matrix));

    iRow = 1;
    for iPair = 1:nChannel

        gain_channel = squeeze(gain_matrix(iPair,:)); 
        gain_channel(gain_channel <  10^(threshold_value)*max_gain) = 0;


        for iCluster = 1:length(iRois)
            sROI = sCortex.Atlas(iAtlas).Scouts(iRois(iCluster));
            vertex = sROI.Vertices;

            T{iRow, sROI.Label} = sum(gain_channel(vertex));
        end

        T{iRow,'Channel'} = sForward.pair_names(iPair);
        iRow = iRow + 1;
    end
    
    
    fileName = sProcess.options.outputdir.Value{1};
    writetable(T,fileName, 'FileType','text');


end
