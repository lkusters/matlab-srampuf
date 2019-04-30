function data = f_openbinaryfile(file_in,path_in)
    % input: inputfile, path
    % if inputfile is undefined, it will be prompted for
    % return: data with dimensions [n_obs , n_cells]
    if isempty(file_in)
        [file_in,path_in] = selectbinaryfile();
    end
    FID = fopen(fullfile(path_in,file_in),'r');
    readtxt = textscan(FID, '%s');% read data string
    fclose(FID);
    readtxt = readtxt{1};
    n_obs = length(readtxt);n_cells = length( str2num(readtxt{1}));
    data = logical(zeros(n_obs,n_cells));
    h = waitbar(0,'data conversion (string to binary)');
    for obs = 1:n_obs
        waitbar(obs/n_obs,h);
        data(obs,:) = str2num(readtxt{obs});
    end
    close(h)
end

function [file_in,path_in] = selectbinaryfile()
    %% binary input file
    [file_in,path_in] = uigetfile('*.txt_binary.txt', 'select the file that has the binary SRAM-PUF measurements','20_deg.txt_binary.txt');
end