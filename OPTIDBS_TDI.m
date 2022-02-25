% SCRIPT 
%
clc; close all; clear all;

%% Recupération des adresses dossiers 

root={'/export/dataCENIR/users/gizem.temiz/OPTIDBS/data_Sophie'};

suj = get_subdir_regex(root, {'^20' });

MS = get_subdir_regex(suj,{'^MS$'});


T1w = get_subdir_regex_files(suj,'^T1w_MP2RAGE_INV2.nii.gz$');

 



%% Whole Brain Tractography,SIFT,TDI
%   Tracktography param.: maxlength =250, cutoff=0.1, other params. are by  default
%   Input track number= 100M Output track number=10M , 
%   Super Resolution vox size= 0.2 iso

cmd = '';

n = length(suj);



for k = 1:n
    
    cmd = '';
 
    cmd=  sprintf('%s\ncd %s ;', cmd, MS{k});
    
    cmd =  sprintf('%s \ntckgen -force WM_FODsdhollander.nii.gz whole_brain_100M.tck -seed_dynamic WM_FODsdhollander.nii.gz -maxlength 250 -number 100000000 -cutoff 0.1 ;', cmd);   
    cmd=  sprintf('%s \ntcksift -force whole_brain_100M.tck WM_FODsdhollander.nii.gz whole_brain_10M_SIFT.tck -term_number 10000000;', cmd);    
    cmd=  sprintf('%s \ntckmap -template %s -dec -vox %f whole_brain_10M_SIFT.tck whole_brain_10M_SIFT.nii.gz -force;', cmd, T1w{k},0.2);    
    
    job{k} = cmd;
    
end


% Création job
if ~exist('par'),par ='';end
if ~exist('jobappend','var'), jobappend ='';end
defpar.sge=6;
defpar.jobname='OPTIDBS_4sujets_TDI'; % A modifier
defpar.walltime='48:00:00';
defpar.sge_queu='long';
par.sge_nb_coeur=6;
par.mem = 128000;
par = complet_struct(par,defpar);
job = do_cmd_sge(job,par,jobappend);


%% FIN
