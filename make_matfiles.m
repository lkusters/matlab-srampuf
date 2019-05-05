%% convert selected source files to .mat files
% function output
% bindata : matrix of binary observation vectors
% temperature : temperature of measurements
% HDintra : Hamming distance between observation vectors (upper triangular)
% n_obs : number of observation vectors (number of measurements)
% n_cells : length of observation vectors (number of cells)
% ----------------
% user is prompted to select the source files with obs. vectors to convert
% source files can be in binary or hexadecimal format
% results are stored in same directory as source files
function make_matfiles()
    %% select the source files
    [files_in,path_in,filetype] = uigetfile(...
        {'*_checked.txt','Hexadecimal source files (*_checked.txt)';...
        '*_deg.txt','Hexadecimal source files (*_deg.txt)';...
        '*.txt_binary.txt','Binary source files (*.txt_binary.txt)'}, ...
            'select source files that need converted',...
            '00_degrees_checked.txt','MultiSelect', 'on');
    if ~iscell(files_in) % if only one file
        files_in = {files_in};
    end
    % find filename format
    filename = files_in{1};
    parts = split(filename,'_');
    deg = length(parts{1}); % how many to remove
    filename(1:deg) = [];
    file_end = filename;
    n_list = length(files_in);
    h = waitbar(0,'overall progress');
    %% run loop
    for i_file = 1:n_list
        waitbar((i_file-.5)/n_list,h);
        file_in = files_in{i_file};
        if filetype == 1 || filetype == 2 % hex file
            alldata = f_openhexfile(file_in,path_in);
        elseif filetype == 3 % binary file
            alldata = f_openbinaryfile(file_in,path_in);
        else
            fprintf("ERROR: unknown filetype, skipping file %s\n",file_in)
            continue
        end
        if sum(sum(alldata~=0 & alldata~=1))>0
            fprintf('WARNING: alldata does have non-binary values (file: %s)\n',file_in);
        end
        % get properties
        bindata = logical(alldata);
        temperature = split(file_in,file_end);
        temperature = temperature{1};
        path_out = fullfile(path_in,[temperature,'.mat']);
        temperature = str2num(temperature);
        HDintra = f_calc_HD_intra(bindata);
        n_obs = size(bindata,1);n_cells = size(bindata,2);
        % and store
        save(path_out,'bindata','temperature','HDintra','n_obs','n_cells');

    end

    close(h)
end

