clc; clear all; close all;

% Initialize variables
gradient_y = [];
y_fitted = {};
x_fitted = {};

%% Input Excel data

HCsurf = 'SDBS'; % Define surfactant type: Triton, SDBS, SDS, AOT, Brij58, TergitolNP-9
filePath = 'D:\Codes\Curve feature extration\KS_158\'; % Define file path
filename = [filePath,'SDBS-Capstone-Analytes-CAn.xlsx']; % Construct the filename dynamically
sheetName = 'Sheet1'; % Define sheet name
export_filename = [HCsurf, '-Capstone-Analytes-CAn']; % Define export filename

% Extract the x data (assuming x is in the first column)
x_column = ['c_', HCsurf];

% Read the data from the Excel file
Table = readtable(filename, 'Sheet', sheetName);

x = Table.(x_column); % Get the x data

% Loop through all y columns (excluding the x column)
y_columns = Table.Properties.VariableNames;
y_columns(strcmp(y_columns, x_column)) = []; % Remove x column from y_columns

% Initialize a cell array to store results
export_data = {};

for i = 1:length(y_columns)
    y_column = y_columns{i};
    y = Table.(y_column); % Get the y data for the current analyte
    
    % Eliminate rows where y is NaN or empty
    valid_indices = ~isnan(y) & ~isempty(y); % Find indices where y is valid
    x_valid = x(valid_indices); % Keep only valid x values
    y_valid = y(valid_indices); % Keep only valid y values

    % Skip if no valid data points are found
    if isempty(y_valid)
        continue;
    end

    %% Plot original curve
    figure;
    plot(x, y);
    title(['Original curve for ', y_column]);
    xlabel(sprintf('c(%s)', HCsurf));
    ylabel('Contact angle');

    % Plot fitted curve
    fit_curve = fit(x, y, 'smoothingspline');
    figure;
    plot(fit_curve);
    title(['Fitted curve for ', y_column]);
    xlabel(sprintf('f(%s)', HCsurf));
    ylabel('Contact angle');

    % Define x_fitted values for calculations
    x_fitted = 0:0.001:0.4;
    y_fitted = feval(fit_curve, x_fitted); % Calculate y_fitted values for the defined x_fitted

    %% Feature #1: Find f(HCsurf) where CA = 90
    target_y_fitted = 90;
    [~, idx] = min(abs(y_fitted - target_y_fitted));
    closest_x_fitted_90 = x_fitted(idx);
    closest_y_fitted_90 = y_fitted(idx);

    %% Feature #2: Find f(HCsurf) where CA increases significantly
    gradient_y = gradient(y_fitted, x_fitted);
    threshold = 1000; % Define threshold to detect significant increase
    significant_increase_idx = find(gradient_y > threshold, 1, 'first');
    x_significant_increase = x_fitted(significant_increase_idx);
    y_significant_increase = y_fitted(significant_increase_idx);

    %% Feature #3: Find HC surf conc that has max gradient
    gradient_y2 = gradient(y_fitted);
    [max_max_gradient, max_max_gradient_idx] = max(gradient_y2);
    x_max_gradient = x_fitted(max_max_gradient_idx);
    y_max_gradient = y_fitted(max_max_gradient_idx);

    %% Feature #4: Find CMC of HC surf in the environment
    % Define linear regions for fitting
    transition_x1_start = 0.02;
    transition_x1_end = 0.06;
    transition_x2_start = 0.1;
    transition_x2_end = 0.36;

    % Find indices for linear regions
    idx1_start = find(x >= transition_x1_start, 1);
    idx1_end = find(x <= transition_x1_end, 1, 'last');
    idx2_start = find(x >= transition_x2_start, 1);
    idx2_end = find(x <= transition_x2_end, 1, 'last');

    % Fit lines to the linear regions
    linear_model_1 = fitlm(x(idx1_start:idx1_end), y(idx1_start:idx1_end));
    linear_model_2 = fitlm(x(idx2_start:idx2_end), y(idx2_start:idx2_end));

    % Predict y values for the fitted lines
    fit_line_1 = predict(linear_model_1, x_fitted');
    fit_line_2 = predict(linear_model_2, x_fitted');

    % Find intersection of the two lines
    slope1 = linear_model_1.Coefficients.Estimate(2);
    intercept1 = linear_model_1.Coefficients.Estimate(1);
    slope2 = linear_model_2.Coefficients.Estimate(2);
    intercept2 = linear_model_2.Coefficients.Estimate(1);
    intersection_x = (intercept2 - intercept1) / (slope1 - slope2);
    intersection_y = polyval([slope1, intercept1], intersection_x);
    intersection_y_original = interp1(x, y, intersection_x);

    %% Feature #5: Find HC surf conc where CA decreases significantly
    gradient_y3 = gradient(y_fitted, x_fitted);
    threshold = 200;
    filtered_indices = y_fitted > 90;
    x_fitted_filtered = x_fitted(filtered_indices);
    y_fitted_filtered = y_fitted(filtered_indices);
    gradient_y_filtered = gradient_y3(filtered_indices);
    significant_decrease_idx = find(gradient_y_filtered < threshold, 1, 'first');
    x_significant_decrease = x_fitted_filtered(significant_decrease_idx);
    y_significant_decrease = y_fitted_filtered(significant_decrease_idx);

    %% Feature #6: Find f(HCsurf) where CA = 165
    target_y_fitted_165 = 165;
    [~, idx] = min(abs(y_fitted - target_y_fitted_165));
    closest_x_fitted_165 = x_fitted(idx);
    closest_y_fitted_165 = y_fitted(idx);

    %% Export extracted features into the export_data cell array
    data = {closest_x_fitted_90, closest_y_fitted_90, x_significant_increase, y_significant_increase, ...
            x_max_gradient, y_max_gradient, intersection_x, intersection_y, ...
            x_significant_decrease, y_significant_decrease, closest_x_fitted_165, closest_y_fitted_165};

    % Add column header
    headers = {sprintf('f(%s) where CA = 90', y_column), 'CA', ...
               sprintf('f(%s) where CA increases significantly', y_column), 'CA', ...
               sprintf('f(%s) where max gradient occurs', y_column), 'CA', ...
               sprintf('f(%s) = CMC', y_column), 'CA', ...
               sprintf('f(%s) where CA decreases significantly', y_column), 'CA', ...
               sprintf('f(%s) where CA = 165', y_column), 'CA'};

    % Append results for this y column
    export_data = [export_data; headers; data];
end

%% Write the export_data to an Excel file
filename = ['Feature-summary-', export_filename, '-.xlsx'];
writecell(export_data, filename, 'Sheet', 'Summary');

% Display a confirmation message
disp(['Summary data has been exported to ', filename]);
