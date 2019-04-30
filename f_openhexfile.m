function data = f_openhexfile(file_in,path_in)
    % input: inputfile, path
    % if inputfile is undefined, it will be prompted for
    % return: data with dimensions [n_obs , n_cells]
    if isempty(file_in)
        [file_in,path_in] = selecthexfile();
    end
    FID = fopen(fullfile(path_in,file_in),'r');
    readtxt = textscan(FID, '%s');% read data string
    fclose(FID);
    readtxt = readtxt{1};
    n_obs = length(readtxt);n_cells = length( readtxt{1})*4;
    data = logical(zeros(n_obs,n_cells));
    h = waitbar(0,'data conversion (hex to binary)');
    for obs = 1:n_obs
        waitbar(obs/n_obs,h);
        vector = hexToBinaryVector(readtxt{obs}',4,'LSBFirst'); % .. x 4
        vector = vector'; % 4 x ..
        data(obs,:) = vector(:);
    end
    close(h)
end

function [file_in,path_in] = selecthexfile()
    %% binary input file
    [file_in,path_in] = uigetfile('*.txt', 'select the file that has the hexadecimal SRAM-PUF measurements','00_degrees_checked.txt');
end