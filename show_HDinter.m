%% plot inter Hamming distance
function show_HDinter()
    % first select the .mat file that has HDinter
    [file_in,path_in] = uigetfile('*.mat', ...
            'select file that has HD inter','HDinter.mat');
    filename = fullfile(path_in,file_in);
    input = load(filename);
    % plot HD inter for given temperatures
    fig1 = figure;
    fig2 = figure;
    t = round(linspace(1,length(input.list_HDinter),4));
    count=1;
    for i = t
        figure(fig1);
        pl=subplot(2,2,count);count=count+1;
        [avgs,sigmas] = plotHDinter_T(input.list_HDinter,i,input.temperatures,pl);
        figure(fig2);
        errorbar(input.temperatures,avgs,sigmas);hold on;
    end
    legend(num2str(input.temperatures(t)));xlabel('temperature compare');
    ylabel('\mu, \sigma');
    title('Hamming distance w.r.t. other temperatures');
end 
function [avgs,sigmas] = plotHDinter_T(list_HDinter,idx,temperatures,pl)
    %% plot HD inter for given temperature
    % pl gives handle to subplot;
    if(isempty(pl))
        figure;pl = gca;
    end
    n_list = length(list_HDinter);
    avgs = zeros(n_list,1);
    sigmas = zeros(n_list,1);
    LEGEND = {};
    for i_list = 1:n_list
        if idx <= i_list
            HD = list_HDinter{idx,i_list};
            if idx == i_list
                HD = HD(triu(ones(size(HD)),1)>0); % only select difference
            end
        else % idx>i_list
            HD = list_HDinter{i_list,idx};
        end
        avgs(i_list)=mean(HD(:));
        sigmas(i_list) = std(HD(:));
        h = histogram(pl,HD,...
            'Normalization','probability','DisplayStyle','stairs','BinWidth',100);hold on;
        if idx == i_list
            set(h,'LineWidth',2)
        end
        LEGEND{i_list} = sprintf('%d - %d',temperatures(idx),temperatures(i_list));
    end
    xlabel(pl,'Hamming distance');ylabel(pl,'probability');
    title(pl,'HD inter');
    legend(pl,LEGEND);
end