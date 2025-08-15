%% Instructions to get CA~90, CMC, droplet_opening, droplet_closing HC surfactant concentrations
clc; clear all; close all;

gradient_y = [];
y_fitted = {};
x_fitted = {};


%% Input excel data

HCsurf = 'SDBS'; % Triton, SDBS, SDS, AOT, Brij58, TergitolNP-9
filePath = 'D:\Codes\Curve feature extration\CAcurve\CMC Commerical waters\'; % Replace with the actual path to your Excel file
filename = [filePath, HCsurf, '-Capstone-Analytes-CAnormalized.xlsx']; % Construct the filename dynamically
sheetName = 'Sheet1'; % Assuming the sheet name is always 'Sheet1'
Analyte = 'Vio'; % MilliQ, Volvic, Evian, Aquamia, Gerolsteiner, Adelholzener, Spree, BrandenburgerQuell, Vio

% Construct the column names dynamically based on HCsurf
x_column = ['f_', HCsurf]; % e.g., 'f_Triton'
y_column = Analyte; % Assuming the y column name remains constant

% Read the data from the Excel file
Table = readtable(filename, 'Sheet', sheetName);

% Extract the data from the appropriate columns
x = Table.(x_column); % Get the x data
y = Table.(y_column); % Get the y data

% Read the data from the Excel file
data = readmatrix(filename, 'Sheet', sheetName);

% Export file name define
export_filename = [HCsurf,'-Capstone-',Analyte,'-CAnormalized'];


%% Define the actual x values where the linear regions start and end, we may need to adjust these indices based on data

% HCsurf-Capstone
transition_x1_start = 0.02; % Actual x value where the first linear region starts
transition_x1_end = 0.04; % Actual x value where the first linear region ends
transition_x2_start = 0.06; % Actual x value where the second linear region starts
transition_x2_end = 0.3; % Actual x value where the second linear region ends


%% Plot original curve
figure;
plot(x,y);
title('Original curve'); 
xlabel(sprintf('f(%s)', HCsurf)); % Dynamically setting the x-axis label
ylabel('Contact angle');

% Plot fitted curve
fit_curve = fit(x,y,'smoothingspline'); %,'Exclude',exclude2,'Exclude',exclude1); % 'linearinterp','poly1','poly2','cubicinterp','smoothingspline'
figure;
plot(fit_curve);
title('Fitted curve');
xlabel(sprintf('f(%s)', HCsurf)); ylabel('Contact angle');
coeffvalues_fit_curve = coeffvalues(fit_curve);
x_fitted = 0:0.001:0.4; % Define x_fitted values for which you want to calculate y_fitted values
y_fitted = feval(fit_curve, x_fitted); % Calculate y_fitted values for the defined x_fitted values using the fitted curve


%% Get results of Features

% Feature #1 HC surf conc on the fitted curve that CA = 90 (or closest to 90), based on original and fitted curve
target_y_fitted = 90;
[~, idx] = min(abs(y_fitted - target_y_fitted)); % So, ~ captures the minimum value (which we don't need), and idx captures the index of the minimum value (which we do need).
closest_x_fitted_90 = x_fitted(idx);
closest_y_fitted_90 = y_fitted(idx);

fprintf('For CA = 90, f(%s) = %f\n', HCsurf, closest_x_fitted_90); % Display the result
fprintf('The corresponding CA = %f\n', closest_y_fitted_90);

figure;
plot(x_fitted, y_fitted, 'b', 'DisplayName', 'Fitted Curve'); % Plot the fitted points and highlight the closest point
hold on;
plot(closest_x_fitted_90, closest_y_fitted_90, 'ro', 'MarkerSize', 8, 'DisplayName', 'Closest Point');
title('Fitted points with closest point to y=90 highlighted');
xlabel('x');
ylabel('y');
legend('show');


%% Feature #2 HC surf conc where CA increases significiantly, based on original and fitted curve
gradient_y = gradient(y_fitted, x_fitted);% Calculate the gradient of y_fitted with respect to x_fitted
threshold = 1000; % Define a threshold to detect significant increase in gradient, need to adjust this value based on specific data, 1000 for all, 500 for Brij58
significant_increase_idx = find(gradient_y > threshold, 1, 'first');% Find the index where the gradient significantly increases
x_significant_increase = x_fitted(significant_increase_idx);% Retrieve the corresponding x_fitted and y_fitted values
y_significant_increase = y_fitted(significant_increase_idx);

fprintf('For the CA curve where the gradient significantly increases f(%s)= %f\n', HCsurf, x_significant_increase);% Display the result
fprintf('The corresponding CA = %f\n', y_significant_increase);

figure;
plot(x_fitted, y_fitted, 'b', 'DisplayName', 'Fitted Curve'); % Plot the fitted points and highlight the point of significant increase
hold on;
plot(x_significant_increase, y_significant_increase, 'ro', 'MarkerSize', 8, 'DisplayName', 'Significant Increase Point');
title('Fitted points with significant increase highlighted');
xlabel('x');
ylabel('y');
legend('show');


% Plot gradident of original curve
% derivative = diff(y)/diff(x);
figure;
% plot(derivative);
plot(x, gradient(y,x));
title('Derivative of fitted curve');


% Plot fitted gradient curve
fit_derivative_curve = fit(x, gradient(y,x),'smoothingspline'); 
figure;
plot(fit_derivative_curve);
title('Fitted derivative curve');
xlabel(sprintf('f(%s)', HCsurf)); ylabel('Gradient of Contact angle');
gradient_y = gradient(y,x);
coeffvalues_fit_derivative_curve = coeffvalues(fit_derivative_curve);
x_fitted_derivative = 0:0.001:0.4; % Define x_fitted values for which you want to calculate y_fitted values
y_fitted_derivative = feval(fit_derivative_curve, x_fitted_derivative); % Calculate y_fitted values for the defined x_fitted values using the fitted curve
gradient_y_derivative = gradient(y_fitted_derivative,x_fitted_derivative);


%% Feature #3, find HC surf conc that has max gradient, based on gradient of fitted original curve
gradient_y2 = gradient(y_fitted); %./ gradient(x_fitted); % Calculate the gradient of y_fitted with respect to x_fitted
%[max_gradient, max_gradient_idx] = max(gradient_y2); % Find the maximum gradient points and its index
[max_max_gradient, max_max_gradient_idx] = max(gradient_y2); % Find the maximum of maximum gradient points and its index
x_max_gradient = x_fitted(max_max_gradient_idx); % Retrieve the corresponding x_fitted and y_fitted values
y_max_gradient = y_fitted(max_max_gradient_idx);

fprintf('The maximum gradient of f(%s) = %f\n', HCsurf, x_max_gradient); % Display the result
fprintf('The corresponding CA = %f\n', y_max_gradient);

figure;
plot(x_fitted, gradient_y2, 'b', 'DisplayName', 'Gradient of Fitted Curve'); % Plot the gradient of the curve
hold on;
plot(x_max_gradient, max_max_gradient, 'ro', 'MarkerSize', 8, 'DisplayName', 'Maximum Gradient Point');
title('Gradient of the Fitted Curve');
xlabel('x');
ylabel('Gradient');
legend('show');


%% Plot log curves of x,y based on the original cuvre

figure;
semilogx(x, y); % Use semilogx for logarithmic scaling on the x-axis
title('Original curve with Logarithmic Scale');
xlabel(sprintf('log(f(%s))', HCsurf)); % Adjust the x-axis label for logarithmic scale
ylabel('Contact angle'); % Keep the y-axis label unchanged

% % If you also want the y-axis to be logarithmic, use semilogy for both axes:
% semilogy(x, y); % Use semilogy for logarithmic scaling on the y-axis
% title('Original curve with Logarithmic Scale');
% xlabel('f(SDBS)'); % Keep the x-axis label unchanged
% ylabel('log(Contact angle)'); % Adjust the y-axis label for logarithmic scale

figure;
loglog(x, y); % Use loglog for logarithmic scaling on both axes
title('Original curve with Logarithmic Scale');
xlabel(sprintf('log(f(%s))', HCsurf)); % Adjust the x-axis label for logarithmic scale
ylabel('log(Contact angle)'); % Adjust the y-axis label for logarithmic scale


% Compute the gradient of the gradient
gradient_gradient_y = gradient(gradient_y_derivative, x(2) - x(1)); % Use the spacing of x values as the second argument
% Plot the gradient of the gradient
figure;
plot(x_fitted_derivative, gradient_gradient_y); % Exclude the first x value as the gradient is one element shorter
title('Gradient of the Gradient of Original Curve');
xlabel('x fitted derivative');
ylabel('Gradient of Gradient');


% Compute the second derivative
second_derivative_y = gradient(gradient_y_derivative, x(2) - x(1)); % Use the spacing of x values as the second argument
% Plot the second derivative
figure;
plot(x_fitted_derivative, second_derivative_y); % Exclude the first x value as the gradient is one element shorter
title('Second Derivative of Original Curve');
xlabel('x fitted derivative');
ylabel('Second Derivative');


%% Feature #4, find CMC of HC surf in the environment, now is able to find linear fitting curves with R square >0.98 of each linear line

% Define the actual x values where the linear regions start and end, we may need to adjust these indices based on data
% % SDBS-Capstone
% transition_x1_start = 0.05; % Actual x value where the first linear region starts
% transition_x1_end = 0.1; % Actual x value where the first linear region ends
% transition_x2_start = 0.1; % Actual x value where the second linear region starts
% transition_x2_end = 0.3; % Actual x value where the second linear region ends

% % Triton-Capstone
% transition_x1_start = 0.03; % Actual x value where the first linear region starts
% transition_x1_end = 0.07; % Actual x value where the first linear region ends
% transition_x2_start = 0.08; % Actual x value where the second linear region starts
% transition_x2_end = 0.3; % Actual x value where the second linear region ends

% % SDS-Capstone
% transition_x1_start = 0.11; % Actual x value where the first linear region starts
% transition_x1_end = 0.2; % Actual x value where the first linear region ends
% transition_x2_start = 0.2; % Actual x value where the second linear region starts
% transition_x2_end = 0.3; % Actual x value where the second linear region ends

% Find the indices in x that correspond to these x values
idx1_start = find(x >= transition_x1_start, 1);
idx1_end = find(x <= transition_x1_end, 1, 'last');
idx2_start = find(x >= transition_x2_start, 1);
idx2_end = find(x <= transition_x2_end, 1, 'last');

% Fit a straight line to each linear region
linear_model_1 = fitlm(x(idx1_start:idx1_end), y(idx1_start:idx1_end)); % First linear region
linear_model_2 = fitlm(x(idx2_start:idx2_end), y(idx2_start:idx2_end)); % Second linear region

% Predict y values for the fitted lines using x_fitted values
fit_line_1 = predict(linear_model_1, x_fitted');
fit_line_2 = predict(linear_model_2, x_fitted');

% Plot the original curve and the fitted lines
figure;
plot(x, y, 'b', 'DisplayName', 'Original Curve');
hold on;
plot(x_fitted, fit_line_1, 'r--', 'DisplayName', 'Fitted Line 1');
plot(x_fitted, fit_line_2, 'g--', 'DisplayName', 'Fitted Line 2');
title('Original Curve with Fitted Lines');
xlabel('x');
ylabel('y');
legend('show');

% Find the intersection point of the two fitted lines
slope1 = linear_model_1.Coefficients.Estimate(2); % slope of first line
intercept1 = linear_model_1.Coefficients.Estimate(1); % intercept of first line
slope2 = linear_model_2.Coefficients.Estimate(2); % slope of second line
intercept2 = linear_model_2.Coefficients.Estimate(1); % intercept of second line

intersection_x = (intercept2 - intercept1) / (slope1 - slope2);
intersection_y = polyval([slope1, intercept1], intersection_x);

% Find the corresponding y value on the original curve
intersection_y_original = interp1(x, y, intersection_x);

% Display the results
fprintf('The intersection point coordinates on the fitted is: (%f, %f)\n', intersection_x, intersection_y);
fprintf('y on fitted lines: %.4f\n', intersection_y);
fprintf('y on original curve: %.4f\n', intersection_y_original);

% Plot the intersection point on the original curve
plot(intersection_x, intersection_y_original, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Intersection Point');
legend('show');


%% Feature #5 HC surf conc where CA decreases significiantly, based on original and fitted curve

gradient_y3 = gradient(y_fitted, x_fitted); % Calculate the gradient of y_fitted with respect to x_fitted
threshold = 200; % Define a threshold to detect significant decrease in gradient, can tune this number refer to array gradient_y_filtered, 200

% Filter the data where y_fitted > 90
filtered_indices = y_fitted > 90;
x_fitted_filtered = x_fitted(filtered_indices);
y_fitted_filtered = y_fitted(filtered_indices);
gradient_y_filtered = gradient_y3(filtered_indices);

significant_decrease_idx = find(gradient_y_filtered < threshold, 1, 'first'); % Find the index where the gradient significantly decreases

x_significant_decrease = x_fitted_filtered(significant_decrease_idx); % Retrieve the corresponding x_fitted value
y_significant_decrease = y_fitted_filtered(significant_decrease_idx); % Retrieve the corresponding y_fitted value

fprintf('For the CA curve where the gradient significantly decreases f(%s)= %f\n', HCsurf, x_significant_decrease); % Display the result
fprintf('The corresponding CA = %f\n', y_significant_decrease);

figure;
plot(x_fitted, y_fitted, 'b', 'DisplayName', 'Fitted Curve'); % Plot the fitted points and highlight the point of significant decrease
hold on;
plot(x_significant_decrease, y_significant_decrease, 'ro', 'MarkerSize', 8, 'DisplayName', 'Significant Decrease Point');
title('Fitted points with significant decrease highlighted');
xlabel(sprintf('f(%s)', HCsurf));
ylabel('Contact angle');
legend('show');


%% Feature #6 HC surf conc on the fitted curve that CA reaches ~165, based on original and fitted curve

target_y_fitted_165 = 165;

[~, idx] = min(abs(y_fitted - target_y_fitted_165)); % So, ~ captures the minimum value (which we don't need), and idx captures the index of the minimum value (which we do need).
closest_x_fitted_165 = x_fitted(idx);
closest_y_fitted_165 = y_fitted(idx);

fprintf('For CA = 165, f(%s) = %f\n', HCsurf, closest_x_fitted_165); % Display the result
fprintf('The corresponding CA = %f\n', closest_y_fitted_165);

figure;
plot(x_fitted, y_fitted, 'b', 'DisplayName', 'Fitted Curve'); % Plot the fitted points and highlight the closest point
hold on;
plot(closest_x_fitted_165, closest_y_fitted_165, 'ro', 'MarkerSize', 8, 'DisplayName', 'Closest Point');
title('Fitted points with closest point to y=165 highlighted');
xlabel('x');
ylabel('y');
legend('show');

% % Find conc that CA > 15
% x_droplet_open = find(max(gradient_y));
% disp(x_droplet_open);
% 
% 
% % Find conc that CA > 165
% x_droplet_close = find(gradient_y==0);
% disp(x_droplet_close);


%% Export extracted features into excel

% Define the data to be exported
data = [closest_x_fitted_90, closest_y_fitted_90,x_significant_increase, y_significant_increase, x_max_gradient, y_max_gradient, intersection_x, intersection_y, x_significant_decrease, y_significant_decrease,closest_x_fitted_165, closest_y_fitted_165];
    
% Define corresponding headers     
headers = {sprintf('f(%s) where CA = 90', HCsurf), 'CA', ...
           sprintf('f(%s) where CA increases significantly', HCsurf), 'CA', ...
           sprintf('f(%s) where first derivative max locates', HCsurf), 'CA', ...
           sprintf('f(%s) = CMC', HCsurf), 'CA',...
           sprintf('f(%s) where CA decreases significantly', HCsurf), 'CA'...
           sprintf('f(%s) where CA = 165', HCsurf), 'CA',};      
       
% Combine data and headers into one cell array
export_data = [headers; num2cell(data)];

% Write the data and headers to an Excel file
% filename = 'Feature_summary.xlsx'; % Specify the filename
filename = ['Feature-summary-',export_filename,'-.xlsx'];
writecell(export_data, filename, 'Sheet', 'Summary'); %, 'Range', 'A1');

% Display a confirmation message
disp('Summary data has been exported to Feature_summary.xlsx');





