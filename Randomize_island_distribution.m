%%%%%%%%%%%%%%%
%%%% ABOUT %%%%
%%%%%%%%%%%%%%%

% This script provides the methodology used in Chapter 5.3.2 of L. Sanborn's doctoral thesis,
% "Null modeling of island distribution", dated 12 November 2025.

% The following methodology randomly generates synthetic islands, given the X and Y position
% of an atoll reef flat (supplied as a 10 m x 10 m grid).
% This script was used to test whether the planform distribution of island
% landmass correlates with reef flat area. 100 synthetic simulations were
% performed for each atoll included in the study, and results were
% aggregated. Full methodology is described in the thesis, found here:
% https://hdl.handle.net/1721.1/165508

%%

clear

% Set working directory:
% cd("")

% First, load .mat files which contain distributions of observed characteristics of Pacific atolls:
% - number of islands
% - island (landmass) area, in km^2
% Each observed set of characteristics is binned according to the reef flat
% diameter (in km) of the corresponding atoll. Binned groups are:
% 0-5, 5-10, 10-15, 15-20, 20-30, 30-50, 50-70, and >70 km diameter.
% We will randomly sample from these distributions to generate synthetic islands.

load('dist_isl_num.mat') %number of observed islands
load('dist_isl_area.mat') %island area

% Load a hypothetical reef flat shape, as an example.

load('hypothetical_atoll_reef_xy.mat')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% RANDOMIZED ISLAND SIMULATION %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the number of desired simulations.
num_sims = 1;
% Set plot_flag = 1 to plot results for each output.
plot_flag = 1;

% Supply a table with columns "Atoll_name" and "Diameter_km" for each atoll
% on which to randomly simulate island landmass.
% For example purposes, create a table here:
atoll_list = table("hypothetical_atoll", 15, 'VariableNames', {'Atoll_name', 'Diameter_km'});

%%
for i = 1:numel(atoll_list.Atoll_name) % Loop through each atoll stored in atoll_list.
    atoll = atoll_list.Atoll_name(i); % Store the atoll name.
    diameter_index = find(string(atoll_list.Atoll_name) == atoll);
    diameter = atoll_list.Diameter_km(diameter_index);  % Store the atoll diameter in km.

    % Select the appropriate distributions of island number and area to randomly sample from,
    % based on atoll diameter (in km):
    if diameter < 5
        num_isl = dist_isl_num{1};
        isl_area = dist_isl_area{1};
    elseif diameter > 5 && diameter <= 10
        num_isl = dist_isl_num{2};
        isl_area = dist_isl_area{2};
    elseif diameter > 10 && diameter <= 15
        num_isl = dist_isl_num{3};
        isl_area = dist_isl_area{3};
    elseif diameter > 15 && diameter <= 20
        num_isl = dist_isl_num{4};
        isl_area = dist_isl_area{4};
    elseif diameter > 20 && diameter <= 30
        num_isl = dist_isl_num{5};
        isl_area = dist_isl_area{5};
    elseif diameter > 30 && diameter <= 50
        num_isl = dist_isl_num{6};
        isl_area = dist_isl_area{6};
    elseif diameter > 50 && diameter <= 70
        num_isl = dist_isl_num{7};
        isl_area = dist_isl_area{7};
    elseif diameter > 70
        num_isl = dist_isl_num{8};
        isl_area = dist_isl_area{8};
    end

    % First, randomly draw the number of islands to place.
        [cdf,stats] = cdfplot(num_isl); % Create an empirical CDF based on the number of islands observed at atolls of a similar size.
        dist_x = cdf.XData; dist_y = cdf.YData; % Store x and y values of the CDF.
        rand_num = rand(1,1); % Randomly draw a number from a uniform distribution.
        rand_ind = (findclosest(rand_num, dist_y)); % Find the nearest y value of the CDF.
        rand_num_isl = dist_x(rand_ind(1)); % Return the corresponding x value of the CDF (the randomly selected number of islands for this synthetic run).
                if rand_num_isl == -Inf % Redo the random draw if the result is -Inf.
                    rand_num = rand(1,1);
                    rand_ind = findclosest(rand_num, dist_y);
                end
        clearvars cdf stats distx disty rand_ind
    % If the number of synthetic islands drawn was nonzero, for each island, randomly draw an island area in km^2.
            if rand_num_isl > 0
                rand_isl_area_km2 = zeros(rand_num_isl, 1); % Initialize an array that will be used to store island area.
                    for n = 1:rand_num_isl % For each synethic island, randomly draw an island area.
                        [cdf,stats] = cdfplot(isl_area); % Create an empirical CDF based on the area of islands observed at atolls of a similar size.
                        dist_x = cdf.XData; dist_y = cdf.YData; % Store x and y values of the CDF.
                        rand_num = rand(1,1); % Randomly draw a number from a uniform distribution.
                        rand_ind = (findclosest(rand_num, dist_y)); % Find the nearest y value of the CDF.
                        rand_isl_area_km2(n) = dist_x(rand_ind(1)); % Return the corresponding x value of the CDF (the randomly selected island area).
                    end
            else
                rand_isl_area_km2 = NaN;
            end
            clearvars cdf stats distx disty rand_rand_ind

      % Next, randomly place islands on the reef flat area, based on the
      % number and size of islands randomly drawn.

      % Loop through files containing x, y coordinates demarcating reef
      % flat area at each atoll.
      % reef_grid = readtable(strcat(atoll,"_reef_xy.csv"));
      % As written, this script uses the example file ("hypothetical_atoll_reef") loaded at the start of this script.
        reef_grid = hypothetical_atoll_reef
        reef_x_space = reef_grid.X; % Store x position of reef flat grid cells.
        reef_y_space = reef_grid.Y; % Store y position of reef flat grid cells.
        rand_isls_xy = [0,0]; % Initialize an array to store the x, y position of synthetic islands.

            if rand_num_isl > 0
            for n = 1:rand_num_isl
                    isl_area = rand_isl_area_km2(n); % Index the randomly generated area of island n.
                    isl_area_m2 = isl_area * 1e6; %Convert island area from km^2 to m^2.
                    num_cells_in_isl = round(isl_area_m2./100, 0, 'decimals'); % x-y grid is 10 m x 10 m (Each grid cell represents 100 m^2) area).

                    num_grid_cells = numel(reef_x_space); % Find the number of grid cells containing reef flat area.
                    rand_place_index = randsample(num_grid_cells,1); % Uniformly sample one reef flat grid cell at random.
                    rand_xy = [reef_x_space(rand_place_index), reef_y_space(rand_place_index)]; % Store the x and y location of the randomly sampled grid cell.

                % Designate the corresponding number of nearest cells as island area, based on the randomly drawn island size.
                if num_cells_in_isl < numel(reef_x_space) % Continue unless atoll is 100% covered by land.
                    [nearest_xy, nearest_ind] = num_nearest_points(num_cells_in_isl, rand_xy(1), rand_xy(2), reef_x_space, reef_y_space);
                    %this is a simulated island. remove these cells from the reef flat:
                     reef_x_space(nearest_ind) = []; % Remove x positions where landmass has been placed, so that it will not be randomly drawn again.
                     reef_y_space(nearest_ind) = []; % Repeat for y positions.
                    rand_isls_xy = [rand_isls_xy; nearest_xy]; % Store the x-y position of synthetic islands.
                else
                    rand_isls_xy = [reef_x_space, reef_y_space];
                end

            end
            end
            rand_isls_xy(1,:) = []; % Remove initialized row.
            clearvars ii

            % Visualize synthetic islands:
                if plot_flag == 1
                    scatter(reef_grid.X, reef_grid.Y, '.', 'MarkerFaceColor','#faeed2', 'MarkerEdgeColor','#faeed2')
                    hold on
                    scatter(rand_isls_xy(:,1), rand_isls_xy(:,2),'.','MarkerFaceColor', '#324f0c','MarkerEdgeColor', '#324f0c')
                    title(strcat("Random Simulation # ", string(num_sims)))
                    subtitle([strcat("Atoll Diameter: ", string(diameter), " km"), strcat("Number of Synthetic Islands: ", string(rand_num_isl))])
                    xlim([-1000 16000])
                    ylim([-1000 16000])
                    xticks([0:2500:15000])
                    yticks([0:2500:15000])
                    xlabel('X (m)')
                    ylabel('Y (m)')
                    hold off
                end

    %Export x,y position of synthetic islands:
    export_synthetic_island = table(rand_isls_xy(:,1), rand_isls_xy(:,2),'VariableNames',{'X','Y'});
    writetable(export_synthetic_island, strcat(atoll,"_synthetic_run_", string(num_sims), ".csv"));
    end

%%

%%%%%%%%%%%%%%%%%%%
%%%% FUNCTIONS %%%%
%%%%%%%%%%%%%%%%%%%

function closest_val_ind = findclosest(target_val, search_array)
    [~, closest_val_ind] = min(abs(search_array-target_val));
end

function [nearest_xy, nearest_ind] = num_nearest_points(num_points, x_ref, y_ref, x_array, y_array)
    dist_away = zeros(numel(x_array),1);
    for i = 1:numel(x_array)
        x_search = x_array(i);
        y_search = y_array(i);
        dist_away(i) = sqrt((x_search - x_ref).^2 + (y_search - y_ref).^2);
    end
        [~, ind] = sort(dist_away, 'ascend');
        nearest_xy = [x_array(ind(1:num_points)), y_array(ind(1:num_points))];
        nearest_ind = ind(1:num_points);
end
