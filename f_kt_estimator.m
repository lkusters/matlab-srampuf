function oneprobabilities = f_kt_estimator(k_ones,n_obs)
%F_KT_ESTIMATOR calculate one probabilities for input k_ones ones and
% n_obs observations
% use KT estimator
oneprobabilities = (k_ones+1/2)./(n_obs+1);
end

