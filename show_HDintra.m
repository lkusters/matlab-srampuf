%% plot intra Hamming distance for given input file(s)
function show_HDintra()
    % first select the .mat file that has HDintra
    [files_in,path_in] = uigetfile('*.mat', ...
            'select .mat files to show HD intra',...
            '00.mat','MultiSelect', 'on');
    if ~iscell(files_in) % if only one file
        files_in = {files_in};
    end
    %% loop files
    fig1 = figure;fig2 = figure;fig3 = figure;
    n_list = length(files_in);
    temperatures = zeros(n_list,1);
    for i_file = 1:n_list
        filename = fullfile(path_in,files_in{i_file});
        reference = load(filename);
%         HD = f_convert_HDlist2triu(reference.HDintra,reference.n_obs);
        HD = reference.HDintra; % change when all converted
        temperatures(i_file)=reference.temperature;
        % plot histogram
        figure(fig1);
        histogram(HD(HD>0),...
            'Normalization','probability','DisplayStyle','stairs','BinWidth',100);
        hold on;
        % plot as function of time difference
        figure(fig2);
        plotHDintra_timestep(HD)
        % plot as function of time
        figure(fig3);
        plotHDintra_time(HD)
    end
    figure(fig1);
    title('Hamming distance between obs. at constant temperature');xlabel('Hamming distance');ylabel('probability');
    legend(num2str(temperatures));
    figure(fig2);
    xlabel('index difference (i-j)');ylabel('\mu , \sigma');
    title('Hamming distance as function of time difference')
    legend(num2str(temperatures));
    figure(fig3);
    xlabel('time index i');ylabel('\mu , \sigma');
    title('Hamming distance as function of time')
    legend(num2str(temperatures));
end 

function plotHDintra_timestep(HDintra)
% plot HD intra as function of time difference
n_steps = size(HDintra,1)-1;
avgs = zeros(n_steps,1);
errors = zeros(n_steps,1);
for k = 1:n_steps
    x = diag(HDintra,k);
    avgs(k) = mean(x);
    errors(k) = std(x);
end
errorbar(1:n_steps,avgs,errors);hold on;

end
function plotHDintra_time(HDintra)
% plot HD intra as function of time
n_steps = size(HDintra,1);
avgs = zeros(n_steps,1);
errors = zeros(n_steps,1);
HD = HDintra + HDintra';
for k = 1:n_steps
    x = HD(k,:);x(k)=[];
    avgs(k) = mean(x);
    errors(k) = std(x);
end
errorbar(1:n_steps,avgs,errors);hold on;

end