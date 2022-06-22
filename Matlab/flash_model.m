% Created by Maxime Volery & Eduardo José González Coll 
% Date: 06.06.2022
function tg = flash_model()
    MDL = 'Main'; % simulink model to flash
    tg = slrt('Baseline');
    tg.ShowParameters = 'on';
    
    %% Build model
    fprintf('Starting building Simulink model...\n');
    create_build_dir(); % put the build files somewhere else
    load_system(MDL);
    set_param(MDL, 'TLCOptions', ...
        ['-axPCMaxOverloads=1000 ', ... Number of acceptable overloads
        '-axPCOverLoadLen=1 ', ... number of acceptable consecutive overloads
        '-axPCStartupFlag=5']); % number of frames to ignore at start
    fprintf('\b');
    rtwbuild(MDL);
    if strcmpi(get_param(MDL, 'shown'), 'off')
        % if system GUI is not shown, close it
        close_system(MDL, 0);
    end
    fprintf('\t[DONE]\n');

    %% Load and run model
    fprintf('Uploading built model to target...\n');
    load(tg, fullfile(get_param(0, 'CodegenFolder'), MDL));
    fprintf('\tModel %s loaded.\n', fullfile(get_param(0, 'CodegenFolder'), MDL))
    tg.start();
    fprintf('\tTarget running\n')
    fprintf('\t[DONE]\n');
end
    