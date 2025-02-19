function [VOI_file,output_vol] = SEEG_to_mask(subject_name, channel_file, contact_name, radius, output_name)
%SEEG_TO_MASK This function convert a SEEEG channel file to a 3D binary
% mask.

    VOI_file     = '';
    output_vol   = [];

    sChannel = in_bst_channel(channel_file);
    
    % Load SEEG contacts
    unique_contacts = unique({contact_name{:}});
    [iChannels, ~]  = channel_find(sChannel.Channel, unique_contacts);
    if length(iChannels) < length(unique_contacts)
        not_found = setdiff(unique_contacts,{sChannel.Channel(iChannels).Name});
        error('Some contacts were not find in the channels fille. \nContact not found: %s', strjoin(not_found,', '))
    end
    contacts        = sChannel.Channel(iChannels);


    % Load subject MRI
    [sSubject, iSubject] = bst_get('Subject', subject_name);
    sMri = in_mri_bst(sSubject.Anatomy(sSubject.iAnatomy).FileName);

    contacts_loc    = [contacts.Loc]';
    contacts_loc_mri = cs_convert(sMri, 'scs', 'voxel', contacts_loc);

    % Compute sphere
    if all(radius > sMri.Voxsize)
        % Get sphere dimensions in voxels
        sphSize = ceil(radius .* sMri.Voxsize);
        % Grid of all voxel coordinates in the sphere
        [sphX, sphY, sphZ] = meshgrid(-sphSize(1):sphSize(1), -sphSize(2):sphSize(2), -sphSize(3):sphSize(3));
        % Keep only the voxels inside the sphere
        iInside = (sqrt(((sphX(:) .* sMri.Voxsize(1)) .^ 2) + ((sphY(:) .* sMri.Voxsize(2)) .^ 2) + ((sphZ(:) .* sMri.Voxsize(3)) .^ 2)) < radius);
        sphXYZ = [sphX(iInside), sphY(iInside), sphZ(iInside)];
        disp(sprintf('BST> Sphere mask: [%dx%dx%d] voxels, with %d voxels selected.', sphSize*2+1, size(sphXYZ,1)));
    else
        sphSize = [1 1 1];
        sphXYZ = [0 0 0];
        disp('BST> Volume atlas: Selecting closest voxel only.');
    end
    
    massk = zeros(size(sMri.Cube));

    for iChan = 1:size(contacts_loc_mri,1)
        % Coordinates of the closest voxel
        C = round(contacts_loc_mri(iChan,:));
        % If there are multiple voxels
        if (size(sphXYZ, 1) > 1)
            % Exclude contacts too close to the border of the MRI
            if (C(1) - sphSize(1) <= 0) || (C(1) + sphSize(1) > size(sMri.Cube,1)) || ...
               (C(2) - sphSize(2) <= 0) || (C(2) + sphSize(2) > size(sMri.Cube,2)) || ...
               (C(3) - sphSize(3) <= 0) || (C(3) + sphSize(3) > size(sMri.Cube,3))
                disp(['BST> Error: Contact "' contacts(iChan).Name '" is outside of the volume.']);
                continue;
            end
            % Indices of all the voxels within the sphere, around the contact
            voxInd = sub2ind(size(sMri.Cube), C(1)+sphXYZ(:,1), C(2)+sphXYZ(:,2), C(3)+sphXYZ(:,3));
            
            % Update the mask with 1
            massk(voxInd) = 1;

        else

            % Exclude contacts outside of the MRI
            if any(C <= 0) || any(C > size(sMri.Cube))
                disp(['BST> Error: Contact "' contacts(iChan).Name '" is outside of the volume.']);
                continue;
            end
            % Indices of all the voxels within the sphere, around the contact
            voxInd = [C(1), C(2), C(3)];

            % Update the mask with 1
            massk(voxInd) = 1;

        end
    end

    disp('BST> Saving to Brainstorm database');
    
    output_vol = sMri;
    output_vol.Cube = massk;
    output_vol.Comment = output_name;

    output_vol.Histogram = [];

    output_vol.Labels  = { 0, 'Background', [0, 0, 0] };
    output_vol.Labels(2,:) = { 1, 'Contact', [102, 102, 255] };

    TmpDir = bst_get('BrainstormTmpDir', 0, 'importmri');
    output_file = fullfile(TmpDir, [protect_fn_str(output_name) '.nii']);

    % Save new MRI in Brainstorm format
    out_mri_nii(output_vol, output_file);
    import_mri(iSubject, output_file,  'ALL-ATLAS', 0, 0, file_unique(output_name, {sSubject.Anatomy.Comment}), output_vol.Labels);
    
    disp('BST> Done');

end

function sfn = protect_fn_str(sfn)
    sfn = strrep(sfn, ' ', '_');
    sfn = strrep(sfn, '|','');
    sfn = strrep(sfn, ':', '_');
end
