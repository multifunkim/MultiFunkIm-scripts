function varargout = process_mfip_consensusmaps_mojenastoprule_rasheda( varargin )
%
% _________________________________________________________________________
% SUMMARY process_mfip_mfip_consensusmaps_mojenastoprule_rasheda
%
% Calculates consensus maps and average signals by clustering source-level 
% brain activity using Ward's hierarchical clustering and 
% Mojena's stopping rule
% The details of the consensus map approach can be found in this paper:
% Chowdhury et al (2018). Reproducibility of EEG-MEG fusion source analysis
% of interictal spikes: Relevance in presurgical evaluation of epilepsy. 
% Human brain mapping, 39(2), 880–901. https://doi.org/10.1002/hbm.23889
%
% Select a small window around the spikes ( for example: -50ms to +50ms)
% _________________________________________________________________________
% INPUTS
% Single spike source localization source results for either EEG, MEG or
% fusion (MEEG) modality:
% source maps
% signals
% _________________________________________________________________________
% OUTPUTS
% Averaged source maps for each cluster
% Averaged spike signal for each cluster
%
% _________________________________________________________________________
% SEE ALSO
%
%
% _________________________________________________________________________
% COMMENTS
%
%   * BRAINSTORM Process
%
% _________________________________________________________________________
% Copyright (c) Rasheda Arman Chowdhury, Biomedical Engineering Dpt, McGill Univ, 2013.
% Maintainer : christophe.grova@mcgill.ca
% See licensing information in the code.
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
eval(macro_method);
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
% Description the process
sProcess.Comment     = 'Consensus Maps - Mojena stop rule';
sProcess.FileTag     = '';
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'mfip';
sProcess.Index       = 201;
sProcess.Description = 'Clusters source maps using Ward hierarchical clustering and Mojena stopping rule to generate cluster-averaged consensus maps.';
% Definition of the input accepted by this process
sProcess.InputTypes  = {'results'};
sProcess.OutputTypes = {'results'};
%     sProcess.OutputTypes = {'export'};
sProcess.nInputs     = 1;
sProcess.nMinFiles   = 1;
sProcess.options.timewindow.Comment = 'Time Window';
sProcess.options.timewindow.Type    = 'timewindow';
sProcess.options.timewindow.Value   = [];
sProcess.options.separator.Type     = 'separator';
% Modality selection parameter
sProcess.options.modality.Comment = 'Sensor Modality: ';
sProcess.options.modality.Type    = 'text';
sProcess.options.modality.Value   = 'MEG';
end

%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
Comment = sProcess.Comment;
end

%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>
OutputFiles = {};
timewindow = sProcess.options.timewindow.Value{1};

% Get selected modality name from GUI (e.g. 'MEG', 'EEG', 'MEEG')
if isfield(sProcess.options, 'modality') && ~isempty(sProcess.options.modality.Value)
    modality_name = strtrim(sProcess.options.modality.Value);
else
    modality_name = 'MEG'; % Default fallback
end


if length(unique(cell2mat({sInputs.iStudy}))) == 1
    iStudy     = sInputs(1).iStudy;
else
    [~,iSubject] = bst_get('Subject',sInputs(1).SubjectFile);
    [~,iStudy]   = bst_get('AnalysisIntraStudy', iSubject);
end

nbFiles = length(sInputs);
data    = cell(1,nbFiles);

%%%%%%%%%%%% PERFORMING THE PCA
for i = 1:nbFiles
    sData        = load(file_fullpath(sInputs(i).FileName),'Time','ImageGridAmp');
    Signal_data  = load(file_fullpath(sInputs(i).DataFile));
    sChannel     = in_bst_channel(sInputs(i).ChannelFile);
    
   
    % List of MEG channels
    iMeeg   = good_channel(sChannel.Channel, Signal_data.ChannelFlag, modality_name);
    iTime   = panel_time('GetTimeIndices', sData.Time, timewindow);
    iTime1  = panel_time('GetTimeIndices', sData.Time, [-1,1]);

    SignalSel(:,:,i)     = Signal_data.F(iMeeg, iTime);
    SignalSelTot(:,:,i)  = Signal_data.F(:, iTime);
    SignalSelTot1(:,:,i) = Signal_data.F(:, :);
    
    % Compute ImageGridAmp if stored as kernel product
    if iscell(sData.ImageGridAmp)
        sData.ImageGridAmp = sData.ImageGridAmp{1} * sData.ImageGridAmp{2};
    end

    data_orig{i} = sData.ImageGridAmp(:,iTime) - ...
        repmat(mean(sData.ImageGridAmp(:,iTime),2),1,length(iTime));   %(use measurements with zero mean- subtracting off the mean)

    source_map{i} = sData.ImageGridAmp(:,iTime);
    data_orig1{i} = sData.ImageGridAmp(:,:) - ...
        repmat(mean(sData.ImageGridAmp(:,:),2),1,length(sData.Time));   %(use measurements with zero mean- subtracting off the mean)
    source_map1{i} = sData.ImageGridAmp(:,:);
    
    IM = abs(data_orig{i});
    IM = IM / norm(IM,'fro') ;
    data{i} = IM;
end

SubjectName = sInputs(i).SubjectName;
nb_vertices = size(source_map{1},1);
similarity_value = NaN(size(data,2),size(data,2));

for i = 1:size(data,2)
    for j = 1:size(data,2)
        similarity_value(i,j) = sum(sum(data{i}.*data{j}));
        Euclidean_value(i,j)  = sum((data{i}(:)-data{j}(:)).^2).^0.5;
    end
end

[rt,ind] = sort(similarity_value);
p_d      = ones(size(similarity_value)) - similarity_value;

% Calculate linkage matrix
Zsource = linkage(nonzeros(triu(p_d,1)')','ward');
figure, dendrogram(Zsource)
title(['Dendrogram (Ward hierarchical clustering) - ' modality_name]);
xlabel('Object number');
ylabel('Cluster linkage value');


% Run Mojena's Stopping Rule 1 helper function
nb_cluster = mojenaStopRule1(Zsource, modality_name);

% Cluster hierarchy based on chosen number of clusters
c = cluster(Zsource,'maxclust',nb_cluster);

All_data      = NaN(size(data_orig1{1},1),size(data_orig1{1},2),nbFiles);
All_sourcemap = NaN(size(source_map1{1},1),size(source_map1{1},2),nbFiles);

for i = 1:nbFiles
    All_data(:,:,i)      = data_orig1{i};
    All_sourcemap(:,:,i) = source_map1{i};
end

for ind_c = 1:nb_cluster
    [my_ind] = find(c == ind_c);
    if length(my_ind)==1
        avg_source{ind_c} = All_data(:,:,my_ind);
        avg_signal{ind_c} = SignalSelTot1(:,:,my_ind);
    else
        avg_source{ind_c} = mean(All_data(:,:,my_ind),3);
        avg_signal{ind_c} = mean(SignalSelTot1(:,:,my_ind),3);
    end
    
    new_sData = db_template('datamat');
    
    new_sData = bst_history('add',  new_sData,  'clustering', ...
        ['Cluster number : ' num2str(ind_c) ' is composed of '...
        num2str(length(my_ind)) ' spikes: ']);
    
    for i = 1:length(sInputs)
        if ismember(i,my_ind)
            tmp = bst_get('Study',sInputs(i).iStudy);
            new_sData = bst_history('add',  new_sData,  'clustering', ...
                [sInputs(i).Condition ': ' tmp.Result(sInputs(i).iItem).Comment 'Spike number: ' num2str(i)]);
        end
    end
    
    sp_file = load(file_fullpath(sInputs(1).DataFile),'Comment');
    sp_ind = strfind(sp_file.Comment,'(');
    spike_name = sp_file.Comment(1:sp_ind(end)-1);
    
    new_sData.F           = avg_signal{ind_c};
    
    if length(my_ind)==1
        new_sData.Comment = cat(2, spike_name, modality_name,'_Cluster_',num2str(ind_c), '_', num2str(length(my_ind)), 'spike',num2str(timewindow(1)*1000),'_to_',num2str(timewindow(2)*1000));
    else
        new_sData.Comment = cat(2, spike_name, modality_name,'_Cluster_',num2str(ind_c), '_', num2str(length(my_ind)), 'spikes_avg',num2str(timewindow(1)*1000),'_to_',num2str(timewindow(2)*1000));
    end
    
    new_sData.ChannelFlag = ones(size(Signal_data.F,1), 1);
    new_sData.Time        = Signal_data.Time(iTime1);
    new_sData.DataType    = 'recordings';
    new_sData.Device      = 'CTF';
    new_sData.nAvg        = length(my_ind);
    
    isReload = 0;
    
    if length(unique(cell2mat({sInputs.iStudy}))) > 1
        [sStudy,iStudy] = bst_get('AnalysisIntraStudy', iSubject);
    else
        iStudy = sInputs(1).iStudy;
        sStudy = bst_get('Study', iStudy);
    end
    MyDataFile = db_add(iStudy, new_sData, isReload);
    clear new_sData
    
    sResult = db_template('resultsmat');
    sResult.ImageGridAmp = avg_source{ind_c};
    sResult.Time         = Signal_data.Time(iTime1);
    sResult.Comment      = cat(2,spike_name,'- _new Consensus map - ','Cluster number : ', num2str(ind_c),' is composed of ', num2str(length(my_ind)), ' spikes -',modality_name);
    
    sData = load(file_fullpath(sInputs(1).FileName),'SurfaceFile');
    sResult.SurfaceFile = sData.SurfaceFile;
    
    db_add(iStudy, sResult, 0);
    db_reload_studies(iStudy);
    panel_protocols('UpdateTree');
end

end

%% ===== HELPER FUNCTIONS =====
function nb_cluster = mojenaStopRule1(Z, modality_name)
% MOJENASTOPRULE1 Applies Mojena's Stopping Rule 1 and plots fusion levels.
if nargin < 2
    modality_name = 'Clustering';
end

nc = size(Z, 1);

% Flip the Z matrix
Zf = flipud(Z);

% Preallocate vector memory
abar = zeros(1, nc);
astd = zeros(1, nc);

% Calculate vectors of means and standard deviations
for i = 1:nc
    abar(i) = mean(Zf(i:end, 3));
    astd(i) = std(Zf(i:end, 3));
end

% Get y values for standard score plotting
yv = (Zf(1:nc, 3) - abar(:)) ./ astd(:);
xv = 1:nc;

% Create visualization figure
hFig = figure('Name', 'Mojena Stopping Rule');

plot(1:nc, Zf(1:nc, 3), 'o-', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
title(' Thresholding plot (Elbow)');
xlabel('Number of clusters');
ylabel('Standardized cluster linkage');
grid on;

% Prompt user for number of clusters using Brainstorm-friendly dialog box
res = java_dialog('input', 'Select the required number of clusters:', 'Mojena Stopping Rule', [], '2');

if ~isempty(res)
    nb_cluster = str2double(res);
else
    nb_cluster = 1; % Default fallback if cancelled
end

% Close figure window after input selection
if ishandle(hFig)
    close(hFig);
end
end