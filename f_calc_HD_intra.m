function HD = f_calc_HD_intra(bindata)
    % calculate HD between dataset itself
    % HD(i,j) is HD between obs(i) and obs(j)
    % note that it results in a triu(X,1) matrix
    % however it is returned in form of a list
    % use f_convert_HDlist2triu(HDlist,n_obs1,n_obs2) to convert it back
    % this function is connected to f_convert_HDlist2triu(HDlist,n_obs1,n_obs2)
    n_obs = size(bindata,1);
    HD = zeros(n_obs);
    h = waitbar(0,'calculate intra distance');
    for i = 1:n_obs-1
        waitbar((i-.5)/(n_obs-1),h);
        reference = repmat(bindata(i,:),n_obs-i,1);
        HD(i,(i+1):end) = sum(abs(bindata((i+1):end,:)-reference),2)';
    end
    close(h)
    % now we convert it to a list
    %BOOL = triu(logical(ones(size(HD))),1);
    %HD = HD(BOOL);
end

