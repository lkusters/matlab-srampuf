function HD = f_calc_HD_inter(bindata1,bindata2)
    % calculate HD between two datasets
    % HD(i,j) is HD of i^th obs of bindata1 to j^th obs of bindata 2
    n_obs1 = size(bindata1,1);n_obs2 = size(bindata2,1);
    HD = zeros(n_obs1,n_obs2);
    h = waitbar(0,'calculate inter distance');
    for i = 1:n_obs2
        waitbar((i-.5)/n_obs2,h);
        reference = repmat(bindata2(i,:),n_obs1,1);
        HD(:,i) = sum(abs(bindata1-reference),2);
    end
    close(h)
end