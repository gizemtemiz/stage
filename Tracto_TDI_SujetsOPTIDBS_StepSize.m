% SCRIPT 
%
clc; close all; clear all;
% addpath('/home/sebille/Fonctions_matlab')

%% Recupération des adresses dossiers 
%root = {'/home/gizem.temiz/data'};
root={'/export/dataCENIR/users/sebille/espace_Gizem'};

OPTIDBS= get_subdir_regex(root,{'^OPTIDBS$'});
data_Sophie=get_subdir_regex(OPTIDBS,{'data_Sophie'});


suj = get_subdir_regex(data_Sophie, {'^201'});

MS = get_subdir_regex(suj,'^MS');

T1w = get_subdir_regex_files(suj, '_INV2.nii.gz$');

WM_FODsdhollander=get_subdir_regex_files(MS,'WM_FODsdhollander.nii.gz');





%%  Whole brain tractography & TDI
cmd = '';
n = length(suj);

% different step sizes to generate the tractograms
step_size=;
for k = 1:n
    
     cmd =  sprintf('%s\ncd %s ;', cmd, MS{k});    
        
     cmd =  sprintf('%s \ntckgen -force %s whole_brain_10M_%f_stepsize_%f.tck -seed_dynamic %s -maxlength 250 -number 10000000 -cutoff 0.1 -step %f;', cmd,WM_FODsdhollander{k},step_size,WM_FODsdhollander{k},step_size);    
     cmd =  sprintf('%s \ntcksift -force whole_brain_10M_%f_stepsize_%f.tck %s whole_brain_1M_SIFT_%f_stepsize.tck -term_number 1000000;', cmd,step_size,WM_FODsdhollander{k},step_size);    
     cmd =  sprintf('%s \ntckmap -template %s  -vox %f  whole_brain_1M_SIFT_%f_stepsize.tck  whole_brain_1M_SIFT_tdi_%f_step_size_%f.nii.gz -force;', cmd, T1w{k},0.2,step_size,0.2,step_size);    
    job{k} = cmd;
    
    
end

% Création job
if ~exist('par'),par ='';end
if ~exist('jobappend','var'), jobappend ='';end
defpar.sge=6;
defpar.jobname='Tracto_tdi_Step_Size_'; % A modifier
defpar.walltime='24:00:00';
par.sge_nb_coeur=6;
par.mem = 128000;
par = complet_struct(par,defpar);
job = do_cmd_sge(job,par,jobappend);


%% FIN
