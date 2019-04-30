%% Show stats of bindata matrix
% with bindata = (n_obs,n_cells)
% select the data file (or give the path as input)
% - show reference observation ref_obs
% - show one-probability of the cells
% - show Hamming distance for consecutive observations
function f_showstats_bindata(bindata)
    ref_obs = 25; % reference observation
    % open file
    if isempty(bindata)
        [file_in,path_in] = uigetfile('*.mat', 'select file that has bindata matrix','00.mat');
        load(fullfile(path_in,file_in),'bindata');
    end
    n_obs = size(bindata,1);
    n_cells = size(bindata,2);
    %% reference observation
    figure;
    imagesc(reshape(bindata(ref_obs,:),2^10,[]));
    title(sprintf('reference observation %d',ref_obs));
    n_ones = sum(bindata(ref_obs,:));
    annotation('textbox', [0.02, 0.01, 0.5, 0.06], 'String',...
    sprintf("%d of the %d cells are one, that is %0.1f %%.",...
    n_ones,n_cells,100*n_ones/n_cells))
    %% one-probability
    figure;
    oneprob = sum(bindata,1)/size(bindata,1);
    imagesc(reshape(oneprob,2^10,[]));
    title('one probability for each cell');
    n_stable = sum(oneprob > 0.98 |oneprob < 0.02 );
    annotation('textbox', [0.02, 0.01, 0.5, 0.06], 'String',...
    sprintf("%d of the cells are (more than 98 %%) stable, that is %0.1f %%.",...
    n_stable,100*n_stable/n_cells ) )
    colorbar
    %% Hamming distance
    figure;
    HD = sum(abs(diff(bindata,1,1)),2);
    plot(2:size(bindata,1),HD);
    title('Hamming distance w.r.t. previous observation');
    xlabel('obs.');ylabel('HD');
    hold on;refline(0,mean(HD));
    refline(0,mean(HD)+3*std(HD));refline(0,mean(HD)-3*std(HD))
    %% Difference w.r.t. reference
    figure;
    HD = sum(abs(bindata-bindata(ref_obs,:)),2);
    plot(HD);HD(ref_obs)=[];Ylims = ylim;Ymin = min(HD);
    ylim([Ymin,Ylims(2)])
    title(sprintf('Hamming distance w.r.t. reference observation %d',...
        ref_obs));
    xlabel('obs.');ylabel('HD')
    %% Average Hamming distance as function of time difference
    timedif = 1:2:30;
    HD_td = zeros(1,length(timedif));
    for i_timedif = 1:length(timedif)
        td = timedif(i_timedif);
        avgHD = 0;
        if td == 1
            seldata = bindata;
            HD = sum(abs(diff(seldata,1)),2);
            avgHD = avgHD+sum(HD)/size(seldata,1);
        else
            for i = 1:td-1
                seldata = bindata(i:td:end,:);
                HD = sum(abs(diff(seldata,1)),2);
                avgHD = avgHD+sum(HD)/size(seldata,1);
            end
        end
        HD_td(i_timedif) = avgHD;
    end
    plot(timedif,HD_td);
    xlabel('time difference i-j');ylabel('average HD(obs_i,obs_j)');
    title('Hamming distance for non-consecutive obs.')
end
