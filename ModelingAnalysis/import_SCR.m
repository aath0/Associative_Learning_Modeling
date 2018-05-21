function [] = import_SCR(data_path, subj)

% Function that loops over participants and imports their physiological
% .WDQ data, based on pspm
% data_path: the path where data for all participants are stored
% subj: an 1 x n array of participant IDs, n = number of participants
%

% initiate PsPM
scr_init;
for p = 1:length(subj)
    s_id = num2str(subj(p))
    % set up batch files for importing and trimming data:
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.windaq.datafile = {[data_path, 'S',s_id '_s1\S', s_id, '_s1.WDQ']};
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.windaq.importtype{1}.scr.chan_nr.chan_nr_spec = 1; % SCR channel
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.windaq.importtype{1}.scr.transfer.none = true;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.windaq.importtype{2}.ecg.chan_nr.chan_nr_spec = 2; % ECG channel
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.windaq.importtype{3}.ecg.chan_nr.chan_nr_spec = 3;
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.windaq.importtype{4}.resp.chan_nr.chan_nr_spec = 4; % respiration channel
    matlabbatch{1}.pspm{1}.prep{1}.import.datatype.windaq.importtype{5}.marker.chan_nr.chan_nr_spec = 5; % triggers
    matlabbatch{1}.pspm{1}.prep{1}.import.overwrite = false;
    matlabbatch{2}.pspm{1}.prep{1}.trim.datafile(1) = cfg_dep('Import: Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{':'}));
    matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk.from = -20;
    matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk.to = 20;
    matlabbatch{2}.pspm{1}.prep{1}.trim.ref.ref_mrk.mrk_chan.chan_def = 0;
    matlabbatch{2}.pspm{1}.prep{1}.trim.overwrite = false;
    % run batch
    cfg_util('initjob', matlabbatch);
    cfg_util('run', matlabbatch);
    cfg_util('deljob', matlabbatch);
    clear cspusp cspusm csm matlabbatch
end
