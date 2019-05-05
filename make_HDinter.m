%% Calculate Hamming distance between the obs. vectors in different files
% function output
% list_HDinter : cell-array with at {i,j} HD between bindata temperature i
%    vs bindata temperature j (note that it is upper triangular matrix)
%    with HD(k,l) : Hamming distance between obs k in {i} and l in {j}
% temperatures : list of temperatures
% files_in : list of source files
% ----------------
% user is prompted to select the .mat files with obs. vectors
% results are stored in HDinter in same folder as source files
function make_HDinter()
[files_in,path_in] = uigetfile('*.mat', ...
            'select source files to generate HDintra',...
            '00.mat','MultiSelect', 'on');
if ~iscell(files_in) % if only one file
    files_in = {files_in};
end
n_list = length(files_in);
list_HDinter = cell(n_list);
temperatures = zeros(n_list,1);
h = waitbar(0,'overall progress');
for i_file = 1:n_list
    waitbar((i_file-.5)/n_list,h);
    filename = fullfile(path_in,files_in{i_file});
    reference = load(filename);
    temperatures(i_file) = reference.temperature;
    for j_file = i_file:length(files_in)
        filename = fullfile(path_in,files_in{j_file});
        compare = load(filename,'bindata');
        list_HDinter{i_file,j_file} = f_calc_HD_inter(...
            reference.bindata,compare.bindata);
    end
end
close(h)
save(fullfile(path_in,'HDinter.mat'),'list_HDinter','temperatures','files_in')
end
