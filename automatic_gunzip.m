
%Scrip pour gunzip automatique

addpath(genpath('/export/data/opt/CENIR/matvol'));
 
root = {'/export/dataCENIR/users/gizem.temiz/OPTIDBS/data_Sophie'};
suj = get_subdir_regex(root, {'^2016','^2017'});

root_DWI=get_subdir_regex(suj,{'^MS$'});
root_NODDI=get_subdir_regex(root_DWI,{'NODDI'});
NODDI=get_subdir_regex(root_NODDI,{'NODDI_gizem'});
DWI=get_subdir_regex_files(root_DWI,{'^4D_diff_corrected.nii.gz$'});
mask=get_subdir_regex_files(root_DWI,{'^nodif_brain_mask.nii.gz$'});
bvecf = get_subdir_regex_files(root_DWI, '^bvecs_eddycor$',1);
bvalf = get_subdir_regex_files(root_DWI, '^bvals_eddycor$',1);





%gunzip et créer un NODDI folder, cp les format .nii dans NODDI
n=length(suj);
  cmd='';
for k=2:n
   
    
    %cmd=sprintf('%s\nmkdir %sNODDI;',cmd,root_DWI{k});
    cmd =  sprintf('%s\ncp %s %s;',cmd,DWI{k},NODDI{k});
    cmd =  sprintf('%s\ncp %s %s ;',cmd,mask{k},NODDI{k});
    cmd =  sprintf('%s\ncd %s ;',cmd,NODDI{k});
    cmd =  sprintf('%s\ngunzip 4D_diff_corrected.nii.gz ;',cmd);
    cmd =  sprintf('%s\ngunzip nodif_brain_mask.nii.gz ;',cmd);
   
        
    job{k} = cmd;
    
end

% Création job
if ~exist('par'),par ='';end
if ~exist('jobappend','var'), jobappend ='';end
defpar.sge=6;
defpar.jobname='gunzip_noddi'; % A modifier
defpar.walltime='288:00:00';
defpar.sge_queu='veryshort';
par.sge_nb_coeur=1;
par.mem = 32000;
par = complet_struct(par,defpar);
job = do_cmd_sge(job,par,jobappend);
