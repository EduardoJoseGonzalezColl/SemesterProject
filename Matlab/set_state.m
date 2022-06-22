% Created by Maxime Volery & Eduardo José González Coll 
% Date: 06.06.2022
%To assess the states (On/Off) of the absorbers, the function set_state() provides the abil-
%ity to enable, independently or synchronously, the absorbers. 
% In Simulink, this is represented with a Switch.

function set_state(enabled)
tg = slrt('Baseline');
tg.setparam('enable1', 'Value', enabled(1));
tg.setparam('enable2', 'Value', enabled(2));
tg.setparam('enable3', 'Value', enabled(3));
tg.setparam('enable4', 'Value', enabled(4));

readback = get_state();
fprintf('readback:\n\t%s\n', mat2str(readback));
end
