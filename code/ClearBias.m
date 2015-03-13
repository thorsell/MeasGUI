function handles = ClearBias(handles)

% reset constants
handles.num_regions = 0;
handles.numBIAS = 0;
handles.numMEAS = handles.numGL;
clear handles.bias;

% % update the bias region information
% set(handles.v1start,'String','0');
% set(handles.v1stop,'String','0');
% set(handles.v1step,'String','0');
% set(handles.i1comp,'String','0');
% set(handles.p1comp,'String','0');
% set(handles.v2start,'String','0');
% set(handles.v2stop,'String','0');
% set(handles.v2step,'String','0');
% set(handles.i2comp,'String','0');
% set(handles.p2comp,'String','0');

% reset bias grid
set(handles.biasgrid,'String','');

try
    % update counter text
    ctext = sprintf('Point 0 out of %s',num2str(handles.numMEAS));
    set(handles.countertext,'String',ctext);
catch
end