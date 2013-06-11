function out = CO_stickangles(y,method)
% Analyzes the set of line-of-sight angles between time series points, by
% treating each data point as a stick protruding from a opaque baseline
% Ben Fulcher, September 2009


doplot = 0; % can plot to see

N = length(y);

ix = cell(2,1); %indicies for positive(1) and negative(2) entries of time series vector
n = zeros(2,1);
ix{1} = find(y>=0); % bias here -- 'look up' if on 'ground'
ix{2} = find(y<0);
n(1) = length(ix{1})-1; % minus one because the last point has no next one to compare to
n(2) = length(ix{2})-1; % minus one for same reason

angles = cell(2,1); % stores the angles
angles{1} = zeros(n(1),1); % positives (above axis)
angles{2} = zeros(n(2),1); % negatives (below axis)

% first positive time points: store in angles_p
for j = 1:2
    for i = 1:n(j)
        % find the next time series point with the same sign as the current
        % one:
        angles{j}(i) = (y(ix{j}(i+1))-y(ix{j}(i)))/(ix{j}(i+1)-ix{j}(i));
    end
    angles{j} = atan(angles{j});
end
allangles = vertcat(angles{:});

if doplot
    figure('color','w')
    % A few options of what to plot:
    hold off; plot(angles{1},'.k'); hold on
    plot(angles{2},'.r')
    hold off; [yp xp] = ksdensity(angles{1});
    [yn xn] = ksdensity(angles{2});
    plot(xp,yp,'r'); hold on; plot(xn,yn,'b');
    hist(angles{1},50);
end


% quite interesting
%% Basic stats?
% on raw values
out.std_p = std(angles{1});
out.mean_p = mean(angles{1});
out.median_p = median(angles{1});

out.std_n = std(angles{2});
out.mean_n = mean(angles{2});
out.median_n = median(angles{2});

out.std = std(allangles);
out.mean = mean(allangles);
out.median = median(allangles);



%% Difference between positive and negative angles
% Return difference in densities
ksx=linspace(min(allangles),max(allangles),200);
if ~isempty(angles{1}) && ~isempty(angles{2})
    ksy1 = ksdensity(angles{1},ksx); % spans the range of full extent (of both positive and negative angles)
    ksy2 = ksdensity(angles{2},ksx); % spans the range of full extent (of both positive and negative angles)
    out.pnsumabsdiff = sum(abs(ksy1-ksy2));
else
    out.pnsumabsdiff = NaN;
end


%% How symmetric is the distribution of angles?
% on raw outputs
% difference between ksdensities of positive and negative portions
if ~isempty(angles{1});
    maxdev=max(abs(angles{1}));
    ksy1 = ksdensity(angles{1},linspace(-maxdev,maxdev,201));
    out.symks_p = sum(abs(ksy1(1:100)-fliplr(ksy1(102:end))));
    out.ratmean_p = mean(angles{1}(angles{1}>0))/mean(angles{1}(angles{1}<0));
else
    out.symks_p = NaN; out.ratmean_p = NaN;
end

if ~isempty(angles{2})
    maxdev=max(abs(angles{2}));
    ksy2 = ksdensity(angles{2},linspace(-maxdev,maxdev,201));
    out.symks_n = sum(abs(ksy2(1:100)-fliplr(ksy2(102:end))));
    out.ratmean_n = mean(angles{2}(angles{2}>0))/mean(angles{2}(angles{2}<0));
else
    out.symks_n = NaN; out.ratmean_n = NaN;
end


%% z-score
zangles = cell(2,1);
zangles{1} = zscore(angles{1}); zangles{2} = zscore(angles{2}); zallangles = zscore(allangles);

%% how stationary are the angle sets?
% Do simple StatAvs for mean and std:
% ap_buff_2 = buffer(angles{1},floor(n(1)/2));
% if size(ap_buff_2,2)>2,ap_buff_2 = ap_buff_2(:,1:2);end % lose last point

% There are positive angles
if ~isempty(zangles{1});
    % StatAv2
    [statav_m statav_s] = sub_statav(zangles{1},2);
    out.statav2_p_m = statav_m;
    out.statav2_p_s = statav_s;
    
    % StatAv3
    [statav_m statav_s] = sub_statav(zangles{1},3);
    out.statav3_p_m = statav_m;
    out.statav3_p_s = statav_s;
    
    % StatAv 4
    [statav_m statav_s] = sub_statav(zangles{1},4);
    out.statav4_p_m = statav_m;
    out.statav4_p_s = statav_s;
    
    % StatAv 5
    [statav_m statav_s] = sub_statav(zangles{1},5);
    out.statav5_p_m = statav_m;
    out.statav5_p_s = statav_s;
    
else
    out.statav2_p_m = NaN; out.statav2_p_s = NaN;
    out.statav3_p_m = NaN; out.statav3_p_s = NaN;
    out.statav4_p_m = NaN; out.statav4_p_s = NaN;
    out.statav5_p_m = NaN; out.statav5_p_s = NaN;
end

% There are negative angles
if ~isempty(zangles{2});
    % StatAv2
    [statav_m statav_s] = sub_statav(zangles{2},2);
    out.statav2_n_m = statav_m;
    out.statav2_n_s = statav_s;
    
    % StatAv3
    [statav_m statav_s] = sub_statav(zangles{2},3);
    out.statav3_n_m = statav_m;
    out.statav3_n_s = statav_s;
    
    % StatAv4
    [statav_m statav_s] = sub_statav(zangles{2},4);
    out.statav4_n_m = statav_m;
    out.statav4_n_s = statav_s;
    
    % StatAv5
    [statav_m statav_s] = sub_statav(zangles{2},5);
    out.statav5_n_m = statav_m;
    out.statav5_n_s = statav_s;
else
    out.statav2_n_m = NaN; out.statav2_n_s = NaN;
    out.statav3_n_m = NaN; out.statav3_n_s = NaN;
    out.statav4_n_m = NaN; out.statav4_n_s = NaN;
    out.statav5_n_m = NaN; out.statav5_n_s = NaN;
end

% All angles:

% StatAv2
[statav_m statav_s] = sub_statav(zallangles,2);
out.statav2_all_m = statav_m;
out.statav2_all_s = statav_s;

% StatAv3
[statav_m statav_s] = sub_statav(zallangles,3);
out.statav3_all_m = statav_m;
out.statav3_all_s = statav_s;

% StatAv4
[statav_m statav_s] = sub_statav(zallangles,4);
out.statav4_all_m = statav_m;
out.statav4_all_s = statav_s;

% StatAv5
[statav_m statav_s] = sub_statav(zallangles,5);
out.statav5_all_m = statav_m;
out.statav5_all_s = statav_s;

%% correlations?
if ~isempty(zangles{1});
    out.tau_p = CO_fzcac(zangles{1});
    out.ac1_p = CO_autocorr(zangles{1},1);
    out.ac2_p = CO_autocorr(zangles{1},2);
else
    out.tau_p = NaN; out.ac1_p = NaN; out.ac2_p = NaN;
end

if ~isempty(zangles{2});
    out.tau_n = CO_fzcac(zangles{2});
    out.ac1_n = CO_autocorr(zangles{2},1);
    out.ac2_n = CO_autocorr(zangles{2},2);
else
    out.tau_n=NaN; out.ac1_n = NaN; out.ac2_n = NaN;
end

out.tau_all = CO_fzcac(zallangles);
out.ac1_all = CO_autocorr(zallangles,1);
out.ac2_all = CO_autocorr(zallangles,2);

%% What does the distribution look like?
% Some quantiles and moments
if ~isempty(zangles{1});
    out.q1_p = quantile(zangles{1},0.01);
    out.q10_p = quantile(zangles{1},0.1);
    out.q90_p = quantile(zangles{1},0.9);
    out.q99_p = quantile(zangles{1},0.99);
    out.skewness_p = skewness(angles{1});
    out.kurtosis_p = kurtosis(angles{1});
else
    out.q1_p = NaN; out.q10_p = NaN;
    out.q90_p = NaN; out.q99_p = NaN;
    out.skewness_p = NaN; out.kurtosis_p = NaN;
end

if ~isempty(zangles{2});
    out.q1_n = quantile(zangles{2},0.01);
    out.q10_n = quantile(zangles{2},0.1);
    out.q90_n = quantile(zangles{2},0.9);
    out.q99_n = quantile(zangles{2},0.99);
    out.skewness_n = skewness(angles{2});
    out.kurtosis_n = kurtosis(angles{2});
else
    out.q1_n = NaN; out.q10_n = NaN;
    out.q90_n = NaN; out.q99_n = NaN;
    out.skewness_n = NaN; out.kurtosis_n = NaN;
end

out.q1_all = quantile(zallangles,0.01);
out.q10_all = quantile(zallangles,0.1);
out.q90_all = quantile(zallangles,0.9);
out.q99_all = quantile(zallangles,0.99);
out.skewness_all = skewness(allangles);
out.kurtosis_all = kurtosis(allangles);

%% Outliers?
% forget about this, I think.

    function [statavmean statavstd] = sub_statav(x,n)
        % Does a n-partition statav.
        % Require 2*n points (i.e., minimum of 2 in each partition) to do a
        % statav that even has a chance of being meaningful.
        NN = length(x);
        if NN<2*n % not long enough
            statavmean = NaN; statavstd = NaN;
            return
        end
        
        x_buff = buffer(x,floor(NN/n));
        if size(x_buff,2) > n, x_buff = x_buff(:,1:n); end % lose last point
        statavmean = std(mean(x_buff))/std(x);
        statavstd = std(std(x_buff))/std(x);
    end


end