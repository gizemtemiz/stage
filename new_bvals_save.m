%cearvars, clearvars -global, clc
root = {'/export/dataCENIR/users/gizem.temiz/HCP/connectomeV3'};
suj = get_subdir_regex(root, {'^2016','^2017'});
NGC=get_subdir_regex(suj,{'^NGC$'});
NODDI=get_subdir_regex(NGC,{'^NODDI$'});
T1w=get_subdir_regex(suj,{'^T1w$'});
root_DWI=get_subdir_regex(T1w,{'^Diffusion$'});

fdti=get_subdir_regex_files(NODDI,{'^data.nii$'});
fm=get_subdir_regex_files(NODDI,{'^nodif_brain_mask.nii$'});

bvecf = get_subdir_regex_files(root_DWI, '^bvecs$',1);
bvalf = get_subdir_regex_files(root_DWI, '^bvals$',1);



n=length(suj);
%n=1;

for ind=1:n
    bvals=load(bvalf{ind});
    l=length(bvals);
    new_bvals=[];
    
    for ind2=1:l
        if bvals(ind2)<500
        new_bvals(ind2)=0;
        else
        new_bvals(ind2)=bvals(ind2);
        end
        
    file_name=sprintf('new_bvals.txt');
    filepath=sprintf('%s',NODDI{ind});
    save(fullfile(filepath,file_name), 'new_bvals','-ascii');       
    
%    cd(sprintf(NODDI{ind}));
    fid = fopen('new_bvals.txt','w');
    fprintf(fid,'%6d',new_bvals);
    fclose(fid);
    
    end

end
