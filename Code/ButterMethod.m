%% Reading raw data
fname = 'phi_raw_data.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);

data = cell2mat(struct2cell(val.Measurement));
t = cell2mat(struct2cell(val.Time));
%% Unpacking data
clear data
time = t(1:2:200);
dt = time(2) - time(1); %hours
y = data(1:2:end); y = reshape(y,100,[]);
B = data(2:2:end); B = reshape(B,100,[]);
%% Processing
for i = 1:size(y,2)
    y_i = y(:,i);
    B_i = B(:,i);
    phi(i,:) = (butter_filt_derivative(y_i, dt)) ./ B_i;
end
%% Classifying results
% NSR = 0, Brownian
phi_nsr_0 = phi(1:100,:);
% NSR = 1e-4, Brownian
phi_nsr_1 = phi(1+300:100+300,:);
% NSR = 1e-3, Brownian
phi_nsr_2 = phi(1+600:100+600,:);
save ResultsPhi.mat phi_nsr_0 phi_nsr_1 phi_nsr_2
%% Plot results
i = 3;
figure;
subplot 131, plot(y(:,i)), title("y")
subplot 132, plot(B(:,i)), title("B")
subplot 133, plot(phi(i,:)), title("phi")
%% Butter
function y_smooth = butter_filt_derivative(y,dt)
    dydt = (y(2:end)-y(1:end-1))/dt;
    dydt = [dydt; dydt(end)];
    [b,a] = butter(2,4/33);
    y_smooth = filtfilt(b,a,dydt);
end
