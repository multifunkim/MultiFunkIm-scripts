
% Input definition
subject_name = 'PA65-P';
channel_file = 'PA65-P/PA65S2/channel.mat';
contact_name = {'RH4', 'RH5', 'RH8'};
radius       = 3;

% Output definition
output_name = 'SEEG_VOI';

[VOI_file,output_vol] = SEEG_to_mask(subject_name, channel_file, contact_name, radius, output_name);

