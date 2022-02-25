
% SCRIPT 
%
clc; close all; clear all;

%% Recupération des adresses dossiers 

root={'/export/dataCENIR/users/gizem.temiz/OPTIDBS/data_Sophie'};

suj = get_subdir_regex(root, {'^20' });

MS = get_subdir_regex(suj,{'^MS$'});

DW=get_subdir_regex_files(MS,{'^4D_diffVF.nii.gz$'});
bvecs = get_subdir_regex_files(MS, '^bvecs_eddycor$');
bvals = get_subdir_regex_files(MS, '^bvals_eddycor$');


root2= {'/export/dataCENIR/users/gizem.temiz/OPTIDBS/data_Sophie/JDD_Gizem_04/Template_FOD_OPTIDBS'};
FOD_template=get_subdir_regex_files(root2,{'^FOD_Template_Image_OPTIDBS.nii.gz$'});
warp_dir=get_subdir_regex(root2,{'^Warp_Images$'});
warp_suj_list=get_subdir_regex_files(warp_dir,{'^WM_FODsdhollander'});
warp_suj=warp_suj_list{1};

n = length(suj);



for k = 1:n
    
    cmd = '';
 
    cmd =  sprintf('%s\ncd %s ;', cmd, MS{k});
   
    cmd =  sprintf('%s \nmkdir fixel_analysis;', cmd);
    
    cmd =  sprintf('%s \ndwi2response -force dhollander 4D_diffVF.nii.gz /export/dataCENIR/users/gizem.temiz/HCP/connectomeV3/fixel_analysis/RF_WMdhollander_OPTIDBS_%d.txt /export/dataCENIR/users/gizem.temiz/HCP/connectomeV3/fixel_analysis/RF_GMdhollander_OPTIDBS_%d.txt /export/dataCENIR/users/gizem.temiz/HCP/connectomeV3/fixel_analysis/RF_CSFdhollander_OPTIDBS_%d.txt -fslgrad 4D_diffVF.nii.gz.eddy_rotated_bvecs bvals_eddycor;', cmd,k,k,k);    
    
    %Upsampling
    cmd =  sprintf('%s \nmrresize -force %s -vox 1.25 fixel_analysis/dwi_upsampled.nii.gz ;', cmd, DW{k});
    
    %Brain mask
    cmd =  sprintf('%s \ndwi2mask -force fixel_analysis/dwi_upsampled.nii.gz -fslgrad %s %s fixel_analysis/dwi_brain_mask.nii.gz ;', cmd, DW{k}, bvecs{k},bvals{k});   
    
    %FOD biased
    cmd =  sprintf('%s \nmtbin -force WM_FODsdhollander.nii.gz fixel_analysis/WM_FODsdhollander_biased.nii.gz GMdhollander.nii.gz fixel_analysis/GMdhollander_biased.nii.gz CSFdhollander.nii.gz  fixel_analysis/CSFdhollander_biased.nii.gz ;', cmd);   
  
    %Population template registration
    cmd =  sprintf('%s \nwarpconvert -force -type warpfull2deformation -template %s %s %s/Converted_Warps/subject2template_warp_%d.mif;', cmd, FOD_template{1},warp_suj(k,:),root2{1},k);   
    cmd =  sprintf('%s \nmrregister -force fixel_analysis/WM_FODsdhollander_biased.nii.gz -mask1 fixel_analysis/dwi_brain_mask.nii.gz %s -nl_warp %s/Converted_Warps/subject2template_warp_%d.mif %s/Converted_Warps/template2subject_warp_%d.mif ;', cmd, FOD_template{1},root2{1},k,root2{1},k);   
    
    %Mask in template space
    cmd =  sprintf('%s \nmrtransform -force fixel_analysis/dwi_brain_mask.nii.gz -warp %s/Converted_Warps/subject2template_warp_%d.mif -interp nearest fixel_analysis/dwi_brain_mask_in_template_space.nii.gz ;', cmd,root2{1},k);   
   % cmd =  sprintf('%s \nmrmath -force dwi_brain_mask_in_template_space.nii.gz -min mask_intersection.nii.gz ;', cmd);
        %set a "coord" 
    cmd =  sprintf('%s \nmrconvert -force %s -coord 3 0 fixel_analysis/voxel_mask.nii.gz ;', cmd, FOD_template{1});   
    cmd =  sprintf('%s \nmrthreshold -force fixel_analysis/voxel_mask.nii.gz fixel_analysis/voxel_mask.nii.gz ;', cmd);
    
    %Fixel mask
        %Set a fmls_peak_value
    cmd =  sprintf('%s \nfod2fixel -force -mask fixel_analysis/voxel_mask.nii.gz -fmls_peak_value 0.2  %s fixel_mask ;', cmd,FOD_template{1});
   
    %FOD reorientation
    cmd =  sprintf('%s \nmrtransform -force fixel_analysis/WM_FODsdhollander_biased.nii.gz -warp %s/Converted_Warps/subject2template_warp_%d.mif -noreorientation fixel_analysis/WM_FOD_in_template_space.nii.gz;', cmd,root2{1},k);   
    
    %Fixel image in template space
    cmd =  sprintf('%s \nfod2fixel -force fixel_analysis/WM_FOD_in_template_space.nii.gz -mask fixel_analysis/voxel_mask.nii.gz  fixel_in_template_space -afd fd.mif ;', cmd);   
    cmd =  sprintf('%s \nfixelreorient -force fixel_in_template_space %s/Converted_Warps/subject2template_warp_%d.mif fixel_in_template_space ;', cmd,root2{1},k);  
    
    %Fixel registration : fixel subject -> fixel template
    cmd = sprintf('%s \nfixelcorrespondence fixel_in_template_space/fd.mif fixel_mask %s/fd_%d PRE.mif ;', cmd,root2{1},k);
    
    %Fibre cross section metric
    cmd =  sprintf('%s \nwarp2metric -force %s/Converted_Warps/subject2template_warp_%d.mif -fc fixel_mask fc IN.mif;', cmd,root2{1},k); 
    cmd =  sprintf('%s \nmkdir log_fc;', cmd);
    cmd =  sprintf('%s \nmrcalc -force fc/IN.mif -log log_fc/IN.mif;', cmd);
    
    
    %Tracto
    cmd =  sprintf('%s \ntckgen -force fixel_analysis/WM_FODsdhollander_biased.nii.gz fixel_analysis/Fixel_based_whole_brain_100M.tck -seed_dynamic fixel_analysis/voxel_mask_thresholded.nii.gz -mask fixel_analysis/voxel_mask_thresholded.nii.gz -maxlength 250 -number 100000000 -cutoff 0.1 ;', cmd);   
    cmd =  sprintf('%s \ntcksift -force fixel_analysis/Fixel_based_whole_brain_100M.tck fixel_analysis/WM_FODsdhollander.nii.gz fixel_analysis/Fixel_based_whole_brain_10M_SIFT.tck -term_number 10000000;', cmd);    
   
    %Stats: fd,log_fc, fdc -> dans le fichier des templates
    
    job{k} = cmd;
end


% Création job
if ~exist('par'),par ='';end
if ~exist('jobappend','var'), jobappend ='';end
defpar.sge=6;
defpar.jobname='Fixel_Registration'; % A modifier
defpar.walltime='288:00:00';
defpar.sge_queu='veryshort';
par.sge_nb_coeur=6;
par.mem = 128000;
par = complet_struct(par,defpar);
job = do_cmd_sge(job,par,jobappend);


%% FIN
