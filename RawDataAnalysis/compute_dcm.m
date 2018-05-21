function [] = compute_dcm(data_path, subj)

% Function that loops over participants and computes DCMs for their SCR
% data, based on pspm
% data_path: the path where data for all participants are stored
% subj: an 1 x n array of participant IDs, n = number of participants
% 

session = 1;
% initiate PsPM
scr_init
for p = 1:length(subj)
    % retrieve timing and trial index information:
    s_id = num2str(subj(p));
    filep_s = [data_path, 'S', s_id, '_s1\'];
    give_timing_pspm_evoked(subj(p),session,[filep_s, num2str(session),'\']);
    load([filep_s, 'indexes_cspusp_S', s_id, '_s1'])
    load([filep_s, 'indexes_cspusm_S', s_id, '_s1'])
    load([filep_s, 'indexes_csm_S', s_id, '_s1'])
    % create batch file:
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.modelfile = ['dcm_S',s_id,'_s1_pspm_evoked'];
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.outdir = {filep_s};
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.chan.chan_nr = 1;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.session.datafile = {[filep_s,'tscr_S',s_id,'_s1.mat']};
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.session.timing.timingfile = {[filep_s,'event_timings_pspm_s',s_id,'_evoked.mat']};
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(1).name = 'CSpUSp';
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(1).index = cspusp;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(2).name = 'CSpUSm';
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(2).index = cspusm;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(3).name = 'CSm';
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.session.condition(3).index = csm;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.data_options.norm = 1;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.data_options.filter.def = 0;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.resp_options.crfupdate = 0;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.resp_options.indrf = 0;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.resp_options.getrf = 0;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.resp_options.rf = 0;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.depth = 2;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.sfpre = 2;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.sfpost = 5;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.sffreq = 0.5;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.sclpre = 2;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.sclpost = 5;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.inv_options.ascr_sigma_offset = 0.1;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.disp_options.dispwin = 0;
    matlabbatch{1}.pspm{1}.first_level{1}.scr{1}.dcm.disp_options.dispsmallwin = 0;
    % run batch
    cfg_util('initjob', matlabbatch);
    cfg_util('run', matlabbatch);
    cfg_util('deljob', matlabbatch);
    clear cspusp cspusm csm matlabbatch
end
end

function [] = give_timing_pspm_evoked(subj,session,data_path)

% Function that creates timing information files for 0 s dcm windows

s_id = num2str(subj);
SOA = 3.5;
[~, ~, data, ~] = scr_load_data([data_path,'\tscr_s', s_id,'_s',num2str(session),'.mat'],'events');
CS_onset = data{1, 1}.data;       % recorded triggers of CS onset in seconds
US_onset = data{1, 1}.data + SOA; % US starts 3.5 seconds after CS
events{1} = [CS_onset]; 
events{2} = US_onset;

save(fullfile(data_path,sprintf('event_timings_pspm_s%i_evoked.mat',subj)),'events')
end