% SCRIPT 
%
clc; close all; clear all;
% addpath('/home/sebille/Fonctions_matlab')


%% Recupération des adresses dossiers 
%root = {'/home/gizem.temiz/data/HCP/connectomeV3'};
root={'/export/dataCENIR/users/gizem.temiz/OPTIDBS/data_Sophie/JDD_Gizem_04'};


Template_FOD_OPTIDBS=get_subdir_regex(root,{'^Template_FOD_OPTIDBS$'});


%%  FOD Template from OPTIDBS data

n = length(Template_FOD_OPTIDBS);
% /export/dataCENIR/users/sebille/espace_Gizem/HCP/connectomeV3/

for k = 1:n
    cmd = '';
    cmd =  sprintf('%s\ncd %s ;', cmd, Template_FOD_OPTIDBS{k}); 
    cmd =  sprintf('%s \npopulation_template -force -nocleanup -linear_transformations_dir Template_FOD_OPTIDBS/Linear_Transformation_Matrix  -transformed_dir Template_FOD_OPTIDBS/Transformed_Images -warp_dir Template_FOD_OPTIDBS/Warp_Images  %s FOD_Template_Image_OPTIDBS.nii.gz ;',cmd,Template_FOD_OPTIDBS{1});    
    %cmd =  sprintf('%s \npopulation_template -force -linear_transformations_dir %s -transformed_dir %s  %s FOD_Template_Image.nii.gz ;',cmd,Template_FOD,Template_FOD,Template_FOD);    
    job{k} = cmd;
        
end

% Création job
if ~exist('par'),par ='';end
if ~exist('jobappend','var'), jobappend ='';end
defpar.sge=6;
defpar.jobname='Template_FOD_OPTIDBS_NoCleanUp_2'; % A modifier
defpar.walltime='48:00:00';
defpar.sge_queu='medium';
par.sge_nb_coeur=6;
par.mem = 128000;
par = complet_struct(par,defpar);
job = do_cmd_sge(job,par,jobappend);


%% FIN
