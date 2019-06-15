%% Evaluate estimator performance
% divide the cells in n_parts_sram subsets of equal size
% use n_modelobs for the model construction for estimator
% use n_estimateobs for the evaluation of temperature
% we avg the performance over time and get Pe as function of the moment of
% model selection, number of sram cells, correct temperature
% use n_estimateobs observations for estimation
% NOTE: there may be good and bad performing parts of SRAM. In the current
% set-up we average over all parts, so we cannot distinguish those. This is
% something to look into at a later stage.
clear all
close all

%% settings:
n_modelobs = 20; % number of observations per model
n_estimateobs = 4;
n_parts_sram = 2^10; % number of parts to divide the sram (at most)
[files_in,path_in] = uigetfile('*.mat', ...
            'select .mat files to generate models',...
            '00.mat','MultiSelect', 'on');
path_in
[file_out, path_out] = uiputfile('*.mat', 'Save results as');

%% start function
%function f_evaluate_estimator_performance(n_modelobs,n_parts_sram,files_in,path_in,file_out,path_out)
if ~iscell(files_in) % if only one file
    files_in = {files_in};
end
n_list = length(files_in);

%% first open all the files and prepare the models
% first decide n_models
temperatures = zeros(n_list,1);
n_obs = zeros(n_list,1);
n_cells = zeros(n_list,1);
for i_file = 1:n_list
    filename = fullfile(path_in,files_in{i_file});
    input = load(filename);
    temperatures(i_file) = input.temperature;
    n_obs(i_file) = input.n_obs;
    n_cells(i_file) = input.n_cells;
end
max_obs = max(n_obs);
n_models = min(floor(n_obs/n_modelobs)); % how many models to create
n_test = min(n_obs-n_modelobs); % number of test observations
if sum(abs(diff(n_cells)))>0
    disp(' ERROR the files have different numbers of cells?')
    n_cells
    return
end
n_cells = n_cells(1);
% now define models
n_list = length(files_in);
model.LL0 = zeros(n_list,n_cells);
model.LL1 = zeros(n_list,n_cells);
model.obsidx = zeros(1,n_modelobs); % time idx of model observations
models = repmat(model,n_models,1);
% first generate observation index
for i_model = 1:n_models
    idx = (i_model-1)*n_modelobs+(1:n_modelobs);
    models(i_model).obsidx = idx;
end
% and generate models
for i_file = 1:n_list
    filename = fullfile(path_in,files_in{i_file});
    input = load(filename);
    for i_model = 1:n_models
        data = input.bindata(models(i_model).obsidx,:);
        [LL0,LL1] = makemodel(sum(data,1),n_modelobs);
        models(i_model).LL0(i_file,:) = LL0;
        models(i_model).LL1(i_file,:) = LL1;
    end
end
    
%% Then evaluate the models and store estimator performance
% first prepare output variables
Pe.mean = zeros(n_list,n_models);
Pe.var = zeros(n_list,n_models);
Pe.n_sramcells = 0;
n_repeats_parts = log2(n_parts_sram)+1; % how many different subdivisions
Pe = repmat(Pe,n_repeats_parts,1);
% copy settings
settings.temperatures = temperatures;
settings.n_modelobs = n_modelobs;
settings.n_estimateobs = n_estimateobs;
settings.n_cells = n_cells;
% set # sramcells
n_cells_part = n_cells/n_parts_sram; % number of cells per part
for i_p = 1:n_repeats_parts
    Pe(i_p).n_sramcells = n_cells_part;
    n_cells_part = n_cells_part*2;
end

% now evaluate the models
for i_file = 1:n_list
    filename = fullfile(path_in,files_in{i_file});
    input = load(filename);
    for i_model = 1:n_models
        data = input.bindata;
        % first remove the data that was used for the model
        data(models(i_model).obsidx,:) = [];
        % then loop through time
        n_parts_est = floor(size(data,1)/n_estimateobs);
        n_correct = zeros(n_repeats_parts,n_parts_sram);
        for i_obs = 1:n_parts_est
            estidx = (i_obs-1)*n_estimateobs+(1:n_estimateobs);
            % estimate
            I_est = makeestimate(models(i_model).LL0,models(i_model).LL1,...
                sum(data(estidx,:),1),n_estimateobs,n_parts_sram);
            % correct ?
            n_correct = double(I_est==i_file)+n_correct;
            n_correct(isnan(I_est)) = NaN; % set invalid values to NaN
        end
        Pr_e = 1-(n_correct/n_parts_est);
        % now for each number of parts we calculate avg + sigma Pe
        for i_p = 1:n_repeats_parts
            Pevalid = Pr_e(i_p,:);Pevalid(isnan(Pevalid))=[]; %remove invalids
            Pe(i_p).mean(i_file,i_model) = mean(Pevalid);
            Pe(i_p).var(i_file,i_model) = var(Pevalid);
        end
    end
end
%% Finally we store the result
% Pe gives average error-prob for each SRAM size at each temperature and
% for different timeslots for the model 
save(fullfile(path_out,file_out),...
    'settings','Pe','files_in','path_in')

%% plot function
function plot()
%% just open the result, and run the below code
[files_in1,path_in1] = uigetfile('*.mat', ...
            'select .mat files to generate plots',...
            '00.mat','MultiSelect', 'on');
%for i = [1,2,4,7] % number of cells
for srami = 1:2
    figure;
    count = 0;
for i = [1,2,4,7] % number of cells
%for srami = 1:4
    count = count+1;
    load([path_in1,files_in1{srami}])
    n_models = size(Pe(i).mean,2);
    subplot(2,2,count);
    errorbar(repmat(settings.temperatures,1,n_models),Pe(i).mean,Pe(i).var);
    title(sprintf('Pe for (cells,m_{obs},m_{est}) = (%d,%d,%d)',...
        Pe(i).n_sramcells,settings.n_modelobs,settings.n_estimateobs));
    xlabel('t_0');ylabel('P_e (mean, \sigma^2)');
    %leg = legend(num2str((1:n_models)'));
    set(gca, 'YScale', 'log');ylim([10^-4,0.5]);grid on;
    %title(leg,'model obs. set');
end
end
end

function I_est = makeestimate(LL0,LL1,k_ones,n_obs,n_parts)
% we divide the SRAM cells in subsets and calculate LLs for all 
% n_parts given LL0,LL1,obsvectors then we find I_est (idx of max
% likelihood) for each part and repeat it for combinations of subsets
% obsvectors is vector n_obs x n_cells
% LL0 and LL1 are loglikelihood for each cell and temperature to be 0 or 1
% respectively
% n_parts is number of subsets (should be power of 2)
n_options = size(LL0,1); % number of choices for best fit
LLhoods = LL1.*repmat(k_ones,n_options,1)+...
            LL0.*repmat(n_obs-k_ones,n_options,1);
minsetsize = floor(size(LL0,2)/n_parts);
n_repeats = log2(n_parts)+1;
I_est = NaN(n_repeats,n_parts);
for j = 1:n_repeats
    LLS = zeros(n_options,n_parts);
    for i = 1:n_parts
        LLS(:,i) = sum(LLhoods(:,(i-1)*minsetsize+(1:minsetsize)),2);
    end
    [~,I] = max(LLS,[],1);
    I_est(j,1:length(I)) = I;
    LLhoods = LLS;
    n_parts = n_parts/2;
    minsetsize=2;
end

end
function [LL0,LL1] = makemodel(k_ones,n_obs)
% return loglikelihoods 
% k_ones is number of ones, should be a row-vector of length n_cells
% n_obs is number of observations [1 x 1]
% the LL0 and LL1 are row vectors

oneprob = f_kt_estimator(k_ones,n_obs);
LL1 = log10(oneprob);
LL0 = log10(1-oneprob);
end