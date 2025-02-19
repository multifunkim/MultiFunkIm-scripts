
% Input definition
subject_name = 'PA65-P';
channel_file = 'PA65-P/PA65S2/channel.mat';
radius       = 5;

% Bipolar montage: the sphere is put in the middle of the two contacts
contact_name    = { 'ROF3','ROF4'; ...
                    'ROF7','ROF8'; ...
                    'RH10', 'RA10'};
output_name     = 'SEEG_VOI_bipolar_5mm';
SEEG_to_mask(subject_name, channel_file, contact_name, radius, output_name);

% Monopolar montage: the sphere is put at the center of each contacts
contact_name    = {'ROF3';'ROF4' ; 'ROF7'; 'ROF8'; 'RH10'; 'RA10'};
output_name     = 'SEEG_VOI_monopolar_5mm';
SEEG_to_mask(subject_name, channel_file, contact_name, radius, output_name);

