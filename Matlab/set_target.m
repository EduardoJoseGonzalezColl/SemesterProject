% Created by Maxime Volery & Eduardo José González Coll 
% Date: 06.06.2022
%When using the function set_target(), in order to actively control the impedance, 
%the parameters must be changed manually. Otherwise, it has a default theta. 
%When the targeted parameters fs , Qms and Rss are manually set, the transfer 
%function theta is converted from continuous to discrete. 
%Then, it computes the transfer function coefficients that the system will
%later use.

sen_p = -50e-3; % V/Pa
G_src = -10e-3; % current source gain in A/V

manual_theta = false;

% target impedance parameters
Rst = 50; 
ft = 450; 
Qt =11;

Zs_list = {};

for idx = 1:4
    if manual_theta
        warning('Theta is manually set to -1mA/Pa');
        theta = zpk(-1e-3);
    else
        fprintf('\n===== Speaker #%d =====\n', idx);
        
        % passive impedance
        [Rss, f0, Qms, F] = get_parameters(idx);
        % [Rss, f0, Qms, F] = get_parameters(4);
        Zs = Rss*(zpk('s')^2 + zpk('s')*2*pi*f0/Qms + (2*pi*f0)^2)/(zpk('s')*2*pi*f0/Qms);
        Zs_list{end + 1} = Zs;
        fprintf('Rst/Rss = %.3f\n', Rst/Rss);
        fprintf('ft/f0 = %.3f\n', ft/f0);
        fprintf('Qt/Qms= %.3f\n', Qt/Qms);
        
        % Target impedance
        Zt = Rst*(zpk('s')^2 + zpk('s')*2*pi*ft/Qt + (2*pi*ft)^2)/(zpk('s')*2*pi*ft/Qt);
        
        % transfer function
        theta = minreal(1 - Zs/Zt)/F;
    end
    
    theta = theta/(G_src*sen_p); % sensitivity to have [V/V]
    tg = slrt('Baseline');
    theta = c2d(minreal(theta), tg.SampleTime, 'tustin'); % convert to discrete model
    [b, a] = tfdata(theta, 'v');
    
    % make b and a 3x1 vectors (pad with zeros if too short)
    assert(a(1) == 1, 'a(1) must be 1');
    assert(numel(b) <= 3 && numel(a) <= 3, 'maximum order is 2');
    b = [b, zeros(1, 3 - numel(b))]; %#ok<AGROW>
    a = [a, zeros(1, 3 - numel(a))]; %#ok<AGROW>
    
    blk_a = sprintf('a%d', idx);
    blk_b = sprintf('b%d', idx);
    tg.setparam(blk_b, 'Value', b);
    tg.setparam(blk_a, 'Value', a);
    fprintf('readback:\n\tb%d = %s\n', idx, mat2str(tg.getparam(blk_b, 'Value')));
    fprintf('\ta%d = %s\n', idx, mat2str(tg.getparam(blk_a, 'Value')));
end

 %% Display
if ~manual_theta
    figure();
    plot_bode(logspace(1, 3, 1001), Zt, 'DisplayName', 'target');
    for i = 1:numel(Zs_list)
        plot_bode(logspace(1, 3, 1001), Zs_list{i}, 'DisplayName', sprintf('passive #%d', i));
    end
end


