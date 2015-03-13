function handles = AddBias(handles)
% resave measurement info
DC1 = handles.instr.measure_dc1;
DC2 = handles.instr.measure_dc2;

% update bias region
region = handles.num_regions + 1;

% Read out data from "Bias condition"
if DC1
    v11 = get(handles.v1start,'String');
    v12 = get(handles.v1stop,'String');
    v13 = get(handles.v1step,'String');
    
    % get bias vector
    if strcmp(v11,v12) || strcmp(v13,'0') % check if constant or 0 step
        v1 = str2double(v11);
    else
        v1 = str2double(v11):str2double(v13):str2double(v12);
    end
    
    % read out current and power compliance
    i1 = str2double(get(handles.i1comp,'String'));
    p1 = str2double(get(handles.p1comp,'String'));
    
    % store bias info
    handles.bias.v1{region} = v1;
    handles.bias.i1{region} = i1;
    handles.bias.p1{region} = p1;    
end

if DC2
    v21 = get(handles.v2start,'String');
    v22 = get(handles.v2stop,'String');
    v23 = get(handles.v2step,'String');
    
    % get bias vector
    if strcmp(v21,v22) || strcmp(v23,'0') % check if constant or 0 step
        v2 = str2double(v21);
    else
        v2 = str2double(v21):str2double(v23):str2double(v22);
    end 
    
    % read out current and power compliance
    i2 = str2double(get(handles.i2comp,'String'));
    p2 = str2double(get(handles.p2comp,'String'));

    % store bias info
    handles.bias.v2{region} = v2;
    handles.bias.i2{region} = i2;
    handles.bias.p2{region} = p2;
end

% update list in "Measurement regions"
oldbias = handles.numBIAS; % get old number of bias points

if DC1 && DC2
    % get bias grid
    [V1 V2] = meshgrid(v1,v2);
    V1 = V1(:); V2 = V2(:);
    
    newbias = length(V1);
    
    write_str = get(handles.biasgrid,'String'); % read old list
    bIdx = (oldbias+1):(newbias+oldbias);
    
    % generate new list
    for ix = 1:length(bIdx)
        write_str{bIdx(ix)} = sprintf('%d: %3.2f | %3.2f', bIdx(ix), V1(ix), V2(ix));
    end

    set(handles.biasgrid,'String',write_str); % write list
    set(handles.biasgrid,'Value',newbias+oldbias); % change selected region
    
elseif DC1 && ~DC2
    V1 = v1(:);
    
    newbias = length(V1);

    write_str = get(handles.biasgrid,'String'); % read old list
    bIdx = (oldbias+1):(newbias+oldbias);
    
    % generate new list
    for ix = 1:length(bIdx)
        write_str{bIdx(ix)} = sprintf('%d: %3.2f | ', bIdx(ix), V1(ix));
    end

    set(handles.biasgrid,'String',write_str); % write list
    set(handles.biasgrid,'Value',newbias+oldbias); % change selected region
    
elseif ~DC1 && DC2
    V2 = v2(:);
    
    newbias = length(V2);

    write_str = get(handles.biasgrid,'String'); % read old list
    bIdx = (oldbias+1):(newbias+oldbias);
    
    % generate new list
    for ix = 1:length(bIdx)
        write_str{bIdx(ix)} = sprintf('%d:  | %3.2f', bIdx(ix), V2(ix));
    end

    set(handles.biasgrid,'String',write_str); % write list
    set(handles.biasgrid,'Value',newbias+oldbias); % change selected region
end

% update number of bias points
handles.numBIAS = newbias + oldbias;

% update the numer of regions
handles.num_regions = region; 

try
    handles.numMEAS = handles.numBIAS;

    % update counter text
    ctext = sprintf('Point 0 out of %s',num2str(handles.numBIAS));
    set(handles.countertext,'String',ctext);
catch
end
