%%
% SCRIPT POUR CALCULER NODDI
%
addpath(genpath('/export/data/opt/CENIR/matvol'));
 

% #########################################################################
%% Path des donnees

%cearvars, clearvars -global, clc
root = {'/export/dataCENIR/users/gizem.temiz/OPTIDBS/data_Sophie'};
suj = get_subdir_regex(root, {'^2016','^2017'});
NGC=get_subdir_regex(suj,{'^NGC$'});
MS=get_subdir_regex(suj,{'MS'});


NODDI=get_subdir_regex(MS,{'^NODDI$'});

fdti=get_subdir_regex_files(NODDI,{'^data.nii$'});
fm=get_subdir_regex_files(NODDI,{'^nodif_brain_mask.nii$'});

bvecf = get_subdir_regex_files(root_DWI, '^bvecs$',1);
bvalf = get_subdir_regex_files(root_DWI, '^bvals$',1);

%--------------------------------------

%% Path pour NODDI tool

%addpath(genpath('/home/gizem.temiz/noddi/NODDI_toolbox_v0.10'),'-begin');
%addpath(genpath('/home/gizem.temiz/noddi/niftimatlib-1.2'),'-begin');
addpath(genpath('/export/dataCENIR/users/gizem.temiz/HCP/matlab/noddi/NODDI_toolbox_v0.10'),'-begin');
addpath(genpath('/export/dataCENIR/users/gizem.temiz/HCP/matlab/noddi/niftimatlib-1.2'),'-begin');
addpath(genpath('/export/dataCENIR/users/gizem.temiz/HCP/Scripts/noddi_script'));



% #########################################################################





%----------------------------------------------------------------------
% #1 Création de mask

par.jobname = 'noddi_optidbs'; 
par.sge_queu = 'short';
par.sge_nb_coeur = 1;
par.mem = 32000;

%n=length(suj);
n=1;
cmd = '';
% Convert the raw DWI volume into the required format 
for k = 1:n
    
  
    fo{k} = addsufixtofilenames(NODDI{k}, {'NODDI_ROI.mat'});
 
    cmd='CreateROI(fdti{k},fm{k},fo{k})';
    varfile = do_cmd_matlab_sge_mine({cmd}, par);
    save(varfile{1},'fdti','fm','fo','k');
    

end


%------------------------------------------------------------------------
% # NODDI Fitting

% Create the NODDI model structure
noddi = MakeModel('WatsonSHStickTortIsoV_B0'); % In-vivo

%n = length(fm0{1});
n=1;

par.jobname = 'single_noddi_fitting_HCP'; 
par.sge_queu = 'short';
par.sge_nb_coeur = 1;
par.mem = 32000;

cmd = '';

% Run the NODDI fitting 
for k = 1:n
    

    
    fo=get_subdir_regex_files(NODDI{k},{'NODDI_ROI.mat'});
    foparam{k} = addsufixtofilenames(NODDI{k}, {'FittedParams_TEST.mat'});
    protocol = FSL2Protocol(bvalf{k}, bvecf{k});
   
    % Convert the FSL bval/bvec files into the required format 
    cmd = 'batch_fitting_single(fo{k}, protocol, noddi, foparam{k})';
%   cmd = 'batch_fitting_mine(fo{k}, protocol, noddi, foparam{k})';
    varfile = do_cmd_matlab_sge_mine({cmd}, par);
    save(varfile{1},'fo','protocol','noddi','foparam','k')
end


%------------------------------------------------------------------------
% #3 Convert the estimated NODDI parameters into volumetric parameter maps

cmd = '';
n=1;
for k = 1:n
    
   
    
    fo=get_subdir_regex_files(NODDI{k},{'NODDI_ROI.mat'});
    foparam=get_subdir_regex_files(NODDI{k},{'FittedParams_TEST.mat'});
    fout{k} = addsufixtofilenames(NODDI{k}, {'NODDI'});
    
    cmd='SaveParamsAsNIfTI(foparam{k}, fo{k}, fm(k,:), fout{k})';
    varfile = do_cmd_matlab_sge_mine({cmd}, par);
    save(varfile{1},'fo','k','fout')
end

%-------------------------------------------------------------------------

%% FIN

