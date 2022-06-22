% Created by Maxime Volery & Eduardo José González Coll 
% Date: 06.06.2022

%The function get_parameter() has a theta (θ) set by default. This function retrieves the
%three parameters from the impedance and then provides the pressure factor. It also rectifies
%the velocity of the membrane measured from the side with a correction
%factor.

function [Rss, f0, Qms, F] = get_parameters(idx)

theta0 = -1e-3; % control transfer function in [A/Pa]
f1 = 150; 
f2 = 300;

corr_v = 1/sqrt((175/280)^2 + 1); % correction factor for velocity

%% get data
file_zss = sprintf('measurements/sp%d/Zss.txt', idx);
file_zsa = sprintf('measurements/sp%d/Zsa_n1m.txt', idx);
[f, zss] = read_pulse(file_zss);
if exist(file_zsa, 'file')
    [~, zsa] = read_pulse(file_zsa);
else
    zsa = NaN(size(f));
end
mask = f >= f1 & f <= f2;
zss = zss(mask)*corr_v;
zsa = zsa(mask)*corr_v;
f = f(mask);

%% fit data
w= 2*pi*f; 

b = [real(zss);imag(zss)];
A = [zeros(size(f)), ones(size(f)),zeros(size(f)); ...
    w,zeros(size(f)), -1./w ];
x = A\b;
F = (1 - mean(real(zss./zsa)))/theta0;

f0 = sqrt(x(3)/x(1))/(2*pi);
Qms = sqrt(x(1)*x(3))/x(2);
Rss = x(2);



%% Display
fprintf('f0 = %.2f [Hz]\n', f0);
fprintf('Qms = %.2f\n', Qms);
fprintf('Rss = %.2f [Pa*s/m]\n', Rss);
fprintf('Bl/Sd = %.2f [Pa/A]\n', F);

figure();
subplot(2, 1, 1);
loglog(f, abs(zss), 'DisplayName', 'Measured Z_{ss}');
hold on;
loglog(f, abs(2i*pi*f*x(1) + x(2) + x(3)./(2i*pi*f)), 'DisplayName', 'Fitted Z_{ss}');
grid on;
grid minor;
xlabel('freq (hz)');
ylabel('Z (Pa*s/m)');
legend show;
title(sprintf('Speaker #%d', idx));

subplot(2, 1, 2);
semilogx(f, angle(zss)/pi, 'DisplayName', 'Measured Z_{ss}');
hold on;
semilogx(f, angle(2i*pi*f*x(1) + x(2) + x(3)./(2i*pi*f))/pi, 'DisplayName', 'Fitted Z_{ss}');
grid on;
grid minor;
xlabel('freq (hz)');
ylabel('angle (rad/pi)');
legend show;

end
