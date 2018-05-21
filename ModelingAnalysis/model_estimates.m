function [] = model_estimates(DataPath,Experiment)

% function that models trial-by-trial phyiological estimates 
% according to reinforcement learning and null models.
% DataPath: the folder where data are stored
% Experiment: a string with the experiment identifier that we want to
% analyse

ExperimentPath = [DataPath,Experiment,filesep];
OutPath = [DataPath,'Estimates2Release',filesep];
ParticipantInfo = dir([DataPath,filesep,Experiment,filesep,'S*.prep*']);
disp(['Found data for ', num2str(size(ParticipantInfo,1)), ' participants'])
incl_us = 0;
load([DataPath, filesep,'CleanCode', filesep, 'OptParam.mat']) %fmincon parameters
param = zeros(6,length(ModParam.mm),length(ParticipantInfo));
numtr = 160;
xdatal = zeros(numtr,length(ParticipantInfo),size(ModParam.mm,1));
ydatal = zeros(numtr,length(ParticipantInfo),size(ModParam.mm,1));

for kk = 1:size(ModParam.mm,2)
    
    model = char(ModParam.mm(kk));
    disp(['Model ', num2str(kk), ' out of ' num2str(length(ModParam.mm))])
    for pp =1:length(ParticipantInfo)
        clear indata x Data Header ls_m post resp output us cs xdata ydata block fval f
        % retrieve information about experimental conditions:
        switch Experiment
            
            case 'FR'
                p_id = ParticipantInfo(pp,1).name(2:4);
                % Block 1:
                f1 = dir([ExperimentPath,'FR_',p_id,'*1.mat']);
                load([ExperimentPath, f1.name])
                indata1 = indata;
                clear indata f1
                % Block 2:
                f2 = dir([ExperimentPath,'FR_',p_id,'*2.mat']);
                load([ExperimentPath, f2.name])
                indata2 = indata;
                clear indata
                indata = [indata1; indata2]; %trial informatio for both blocks.
                clear indata1 indata2
                %load ANS estimates:
                f1 = dir([ExperimentPath,'S',p_id,'*dcm0_a.mat']);
                load([ExperimentPath, f1.name])
            
            case 'TC'
                p_id = ParticipantInfo(pp,1).name(2:3);
                %load experiment files:
                f1 = dir([ExperimentPath,'TC_',p_id,'*1.mat']);
                load([ExperimentPath, f1.name])
                indata1 = indata;
                clear indata f1
                f2 = dir([ExperimentPath,'TC_',p_id,'*2.mat']);
                load([ExperimentPath, f2.name])
                indata2 = indata;
                clear indata
                indata = [indata1; indata2]; %trial informatio for both blocks.
                clear indata1 indata2
                %load ANS estimates:
                f1 = dir([ExperimentPath,'S',p_id,'*dcm0_a.mat']);
                load([ExperimentPath, f1.name])
            
            case 'PubFe_PSR'
                indxp = strfind(ParticipantInfo(pp,1).name, '.');
                p_id = ParticipantInfo(pp,1).name(2:indxp(1)-1);
                %load experiment files:
                f1 = dir([ExperimentPath,'PubFe_',p_id,'_Session1*.mat']);
                load([ExperimentPath, f1.name])
                indata = [PubFe{1, 1}.indata; PubFe{1, 2}.indata]; %trial information for both blocks.
                %load ANS estimates:
                f1 = dir([ExperimentPath,'S',p_id,'.*glm_a.mat']);
                load([ExperimentPath, f1.name])
            
            case 'PubFe_SCR'
                indxp = strfind(ParticipantInfo(pp,1).name, '.');
                p_id = ParticipantInfo(pp,1).name(2:indxp(1)-1);
                %load experiment files:
                f1 = dir([ExperimentPath,'PubFe_',p_id,'_Session1*.mat']);
                load([ExperimentPath, f1.name])
                indata = [PubFe{1, 1}.indata; PubFe{1, 2}.indata]; %trial information for both blocks.
                %load ANS estimates:
                f1 = dir([ExperimentPath,'S',p_id,'.*dcm0_a.mat']);
                load([ExperimentPath, f1.name])
        end
        
        us = indata(:,3);
        cs = indata(:,2);
        indx(pp).us = us;
        indx(pp).cs = cs;
        
        %mapping function and parameters:
        out_f = 'li2';
        x0(1) = 1;
        x0(2) = 0;
        low_lim = [-100 -100];
        upp_lim = [100 100];
        
        f = @(x)model_interface(x,cs,us,xdata,model,out_f,incl_us);
        switch model
            case 'NL0'
                % no parameters
            case 'RW1'
                x0 = [x0 1];
                low_lim = [low_lim 0];
                upp_lim = [upp_lim 1];
            case 'BM0'
                % no parameters
            case 'UN0'
                % no parameters
            case 'BH1'
                % no parameters
            case 'HM1'
                x0 = [x0 0.5];
                low_lim = [low_lim 0];
                upp_lim = [upp_lim 1];
            case 'HM2'
                x0 = [x0 0.5];
                low_lim = [low_lim 0];
                upp_lim = [upp_lim 1];
        end
        
        %Optimize the actual model and compute parameters:
        [x] = fmincon(f,x0,[],[],consparam.Aeq,consparam.beq,low_lim,upp_lim,consparam.nonlcon,optparam);
        [MLS,ydata,xdata] = model_interface(x,cs,us,xdata,model,out_f,incl_us);
        
        % store parameters/likelihood/BIC/Explained Variance:
        param(1:length(x),kk,pp) = x;
        likel(kk,pp) = MLS/length(find(us==0));
        BIC(kk,pp) = BIC_f(MLS,length(x0),length(find(us == 0)));
        
        %exclude us trials before computing Explained Variance:
        xd = xdata(find(us == 0));
        yd = ydata(find(us == 0));
        EV(kk,pp) = exvar(xd,yd);
        clear x x0 MLS
        xdatal(:,pp,kk) = xdata;
        ydatal(:,pp,kk) = ydata;
        clear yd xd Data Header indata ydata xdata low_lim upp_lim Q1 Q2 cs us tr2keep x x0 MLS
    
    end
end
save([OutPath, Experiment, '_Estimates.mat'], 'xdatal', 'ydatal','likel', 'param', 'ModParam','BIC','EV','indx')
end

function [BIC] = BIC_f(RSS,k,n)

BIC = k*log(n) + n*log(RSS/n);
end

function [EV] = exvar(y, yhat)

SSerr = sum((y-yhat).^2);
EV = 1-SSerr/length(y)/var(y);
end
