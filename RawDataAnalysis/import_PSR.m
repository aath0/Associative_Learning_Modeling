function [] = import_PSR(data_path, subj)

% Function that loops over participants and imports their eyetracker
% data based on pspm.
% data_path: the path where data for all participants are stored
% subj: an 1 x n array of participant IDs, n = number of participants

scr_init
b = [1 2];
SOA = 3.5;
for p = 1:length(subj) % participants
    s_id = num2str(subj(p));
    for block = 1:length(b) % blocks
        b_id = num2str(b(block));
        filep = [data_path];
        % import raw data:
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.eyelink.datafile = {[filep, 'pu', s_id, 'b', b_id, '.asc']};
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.eyelink.importtype{1}.pupil_l.chan_nr.chan_nr_spec = 1;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.eyelink.importtype{2}.pupil_r.chan_nr.chan_nr_spec = 2;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.eyelink.importtype{3}.gaze_x_l.chan_nr.chan_nr_spec = 3;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.eyelink.importtype{4}.gaze_y_l.chan_nr.chan_nr_spec = 4;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.eyelink.importtype{5}.gaze_x_r.chan_nr.chan_nr_spec = 5;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.eyelink.importtype{6}.gaze_y_r.chan_nr.chan_nr_spec = 6;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.eyelink.importtype{7}.blink_l.chan_nr.chan_nr_spec = 7;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.eyelink.importtype{8}.blink_r.chan_nr.chan_nr_spec = 8;
        matlabbatch{1}.pspm{1}.prep{1}.import.datatype.eyelink.importtype{9}.marker.chan_nr.chan_nr_def = 0;
        matlabbatch{1}.pspm{1}.prep{1}.import.overwrite = true;
        % prep and tirm:
        matlabbatch{2}.pspm{1}.prep{1}.trim.datafile = {[filep, 'scr_pu', s_id, 'b', b_id, '.mat']};
        matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk.from = 0;
        matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk.to = 12;
        matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk.mrk_chan.chan_def = 0;
        matlabbatch{2}.pspm{1}.prep{1}.trim.overwrite = true;                          
        matlabbatch{3}.pspm{1}.tools{1}.interpolate.datafiles = {[filep, '\tscr_pu', s_id, 'b', b_id, '.mat']};
        matlabbatch{3}.pspm{1}.tools{1}.interpolate.extrapolate = true;
        matlabbatch{3}.pspm{1}.tools{1}.interpolate.mode.file.overwrite = true;
        % run batch
        cfg_util('initjob', matlabbatch);
        cfg_util('run', matlabbatch);
        cfg_util('deljob', matlabbatch);
        clear matlabbatch
    end
end

function [] = interpolate_PSR(data_path, output_path, subj)

% Function that loops over imported PSR data
% and interpolates missing points, e.g., due to eye blinks
% data_path: the path with data for all participants
% output_path: the path where data for all participants are stored
% subj: an 1 x n array of participant IDs, n = number of participants

for p = 1:length(subj)              
    s_id = num2str(subj(p));
    for q = 1:length(day)         
        d_id = num2str(day(q));
        file = [data_path, 'tscr_pu', s_id, 'b', d_id, '.mat'];
        [~, name, ~] = fileparts(file);
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.datafile = {file};
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.eyes = 'all';
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.validate_fixations.enable_fixation_validation.box_degree = 5;
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.validate_fixations.enable_fixation_validation.distance = 700;
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.validate_fixations.enable_fixation_validation.screen_settings.aspect_actual = [16 9];
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.validate_fixations.enable_fixation_validation.screen_settings.aspect_used = [16 9];
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.validate_fixations.enable_fixation_validation.screen_settings.screen_size = [21];
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.validate_fixations.enable_fixation_validation.fixation_point.default = 1;
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.channels = 'pupil';
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.interpolate.enable_interpolation = 1;
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.missing.enable_missing = 1;
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.output_settings.file_output.new_file.file_path = {output_path};
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.output_settings.file_output.new_file.file_name = ['fi', name,'.mat'];
        matlabbatch{1}.pspm{1}.data_preprocessing{1}.pp_pupil{1}.find_valid_fixations.output_settings.channel_output.add_channel = 0;
        cfg_util('initjob', matlabbatch);
        cfg_util('run', matlabbatch);
        cfg_util('deljob', matlabbatch);
        clear matlabbatch
    end
end