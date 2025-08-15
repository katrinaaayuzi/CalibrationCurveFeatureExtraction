%% Instructions to get CA~90, CMC, droplet_opening, droplet_closing HC surfactant concentrations
clc; clear all; close all;

gradient_y = [];
y_fitted = {};
x_fitted = {};


%% Input excel data

HCsurf = 'SDBS'; % Triton, SDBS, SDS, AOT, Brij58, TergitolNP_9, TritonX_100
filePath = 'D:\Codes\Curve feature extration\VRcurve\'; % Replace with the actual path to your Excel file
filename = [filePath, 'HCsurf-Capstone-MilliQ-VRn.xlsx']; % Construct the filename dynamically
sheetName = 'Sheet1'; % Assuming the sheet name is always 'Sheet1'

% Construct the column names dynamically based on HCsurf
x_column = ['c_conc']; % e.g., 'f_Triton'

% Read the data from the Excel file
Table = readtable(filename, 'Sheet', sheetName);

% Extract the x data
x = Table.(x_column); % Get the x data

% Get all the analyte column names (excluding the x column)
analyte_columns = Table.Properties.VariableNames;
analyte_columns(strcmp(analyte_columns, x_column)) = []; % Remove x_column from the list

% Export file name define
export_filename = ['HCsurf-Capstone-MilliQ-VRn'];

% Initialize a cell array to store all results
all_results = {};

% Loop through each analyte column
for i = 1:length(analyte_columns)
    y_column = analyte_columns{i}; % Current y column (Analyte)
    y = Table.(y_column); % Get the y data
    
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
    plot(x_valid, y_valid);
    title(['Original curve - ', y_column]); 
    xlabel(sprintf('c(%s)', HCsurf)); % Dynamically setting the x-axis label
    ylabel('Volume ratio normalized');

    % Plot fitted curve
    fit_curve = fit(x_valid, y_valid, 'smoothingspline'); 
    figure;
    plot(fit_curve);
    title(['Fitted curve - ', y_column]);
    xlabel(sprintf('c(%s)', HCsurf)); ylabel('Volume ratio normalized');
    x_fitted = 0:0.001:0.4; % Define x_fitted values for which you want to calculate y_fitted values
    y_fitted = feval(fit_curve, x_fitted); % Calculate y_fitted values for the defined x_fitted values using the fitted curve

    %% Get results of Features

    % Feature #1 Minimum peak point, based on original curve
    [y_min, idx_min] = min(y_valid); % Get the minimum y value and the corresponding index
    x_min = x_valid(idx_min); % Get the corresponding x value

    % Feature #2 Maximum peak point, based on original curve
    [y_max, idx_max] = max(y_valid); % Get the maximum y value and the corresponding index
    x_max = x_valid(idx_max); % Get the corresponding x value

    % Feature #3 Difference between maximum and minimum point, based on original curve
    y_diff = y_max - y_min;
    x_diff = x_min - x_max; % x_diff = x_max - x_min;

    % Store the results in the cell array
    all_results = [all_results; {y_column, x_min, y_min, x_max, y_max, x_diff, y_diff}];
end

%% Export all extracted features into excel

% Define headers
headers = {'Analyte', 'Min Concentration', 'Min Volume ratio nor', 'Max Concentration', 'Max Volume ratio nor', 'Concentration Difference', 'Volume ratio nor Difference'};

% Combine headers and data
export_data = [headers; all_results];

% Write the data and headers to an Excel file
filename = ['Feature-summary-', export_filename, '.xlsx'];
writecell(export_data, filename, 'Sheet', 'Summary');

% Display a confirmation message
disp(['Summary data has been exported to ', filename]);
