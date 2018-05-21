function [] = compute_glm(data_path, glm_path, pupil_path, subj, which_eye)
% Function that loops over participants and computes single-trial
% glms based on PSRs.
% data_path: the path where behavioral data for all participants are stored
% pupil_path: the path where pupil data for all participants are stored
% glm_path: the folder where glm data will be saved
% subj: an 1 x n array of participant IDs, n = number of participants
% which_eye: the path to a .mat file containing left/right eye information per
% participant, stored in a 'REV_a' matrix

load(which_eye)
scr_init
eye2use = REV_e(:,2);
SOA = 3.5;
total_trials = 160;
for p = 1:length(subj)
    s_id = num2str(subj((p)));
    filep = [data_path, 'S', s_id,'\'];
    give_indexes_block_pupil_PubFe(subj((p)),filep);
    give_condition_pupil_PubFe(subj((p)), SOA,filep);
    for tt = 1:total_trials
        if tt < total_trials/2+1 %Block 1:
            bl = 1;
            tb = tt;
            load([filep,'event_timings3_s', s_id,'_b',num2str(bl),'.mat'])
            onsets = events1{1,1};
        else
            bl = 2;
            tb = tt-total_trials/2;
            load([filep,'event_timings3_s', s_id,'_b',num2str(bl),'.mat'])
            onsets = events2{1,1};
        end
        load([filep,'PubFe_', s_id, '_Session1.mat'])  
        indata = PubFe{1, bl}.indata;
        clear PubFe
        %retrieve condition:
        if indata(tb,2) == 1 %cs+
            if indata(tb,3) == 1 %us+
                name = 'CS+US+';
            else
                name = 'CS+US-';
            end
        else
            name = 'CS-';
        end
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.modelfile = ['glm_pupil_RFC1_s', s_id, '_trial', num2str(tt),'_new'];
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.outdir = {[glm_path]};
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.chan.chan_nr = eye2use((p));
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.timeunits.seconds = 'seconds';
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session(1).datafile = {[pupil_path, '\fitscr_pu', s_id, 'b', num2str(bl),'.mat']};
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session(1).missing.no_epochs = 0;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition.name = name;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition.onsets = onsets(tb);
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition.durations = 0;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.data_design.condition.pmod = struct('name', {}, 'poly', {}, 'param', {});
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.session.nuisancefile = {''};
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.bf.psrf_fc1 = 1; % response function
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.norm = true;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.filter.def = 0;
        matlabbatch{1}.pspm{1}.first_level{1}.ps{1}.glm_ps_fc.overwrite = true;
        % run batch
        cfg_util('initjob', matlabbatch);
        cfg_util('run', matlabbatch);
        cfg_util('deljob', matlabbatch);
        clear matlabbatch
    end
        
end

