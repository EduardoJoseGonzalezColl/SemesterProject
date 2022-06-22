% Created by Maxime Volery & Eduardo José González Coll 
% Date: 06.06.2022
function varargout = read_pulse(filename)
    % READ_PULSE Reads the frequency content of a pulse text file
    % * filename:   Pulse .txt file name
    % * varargout:  either [frd], [f_, x_] or [f_, x_, x_units] depending
    %               on the number of output parameters.
    % * frd:        frd system object containing the data.
    % * f_:         Frequency vector of the read data
    % * x_:         Read data (same size as f), can be complex or real
    %               depending on the nature of the loaded data.
    % * x_unit:     Unit of the x amplitude signal
    
    % Read file as strings
    fileID = fopen(filename,'r');
    dataStr = textscan(fileID, '%s', 'Delimiter','\n');
    fclose(fileID);
    dataStr = dataStr{1};
    
    % Get header size
    idx = find(contains(dataStr, 'Header Size:'), 1);
    tmp = textscan(dataStr{idx}, '%s %f', 'Delimiter', ':');
    header_lines = tmp{2} + 5; % 5 additional lines
    
    % Get number of samples
    idx = find(contains(dataStr, 'X-Axis size:'), 1);
    tmp = textscan(dataStr{idx}, '%s %f', 'Delimiter', ':');
    data_lines = tmp{2};
    
    % Get amplitude units
    idx = find(contains(dataStr, 'AmplitudeUnit:'), 1);
    tmp = textscan(dataStr{idx}, '%s %s', 'Delimiter', ':');
    x_unit = strtrim(tmp{2}{1});
    
    % Get data type
    idx = find(contains(dataStr, 'Data Type:'), 1);
    tmp = textscan(dataStr{idx}, '%s %s', 'Delimiter', ':');
    is_complex = contains(tmp{2}{1}, 'Complex');
    
    % Scan each data line until no more data is available
    f_ = zeros(data_lines, 1);
    x_ = zeros(data_lines, 1);
    if is_complex
        formatSpec = '%f %f %f %f';
    else
        formatSpec = '%f %f %f';
    end
    for idx = 1:data_lines
        tmp = textscan(dataStr{header_lines + idx}, formatSpec);
        f_(idx) = tmp{2};
        if is_complex
            x_(idx) = tmp{3} + 1i*tmp{4};
        else
            x_(idx) = tmp{3};
        end
    end
    
    switch nargout
        case 0
            varargout = {};
        case 1
            varargout = {frd(x_, 2*pi*f_)};
        case 2
            varargout = {f_, x_};
        case 3
            varargout = {f_, x_, x_unit};
        otherwise
            error('Too much output arguments.');
    end
end
