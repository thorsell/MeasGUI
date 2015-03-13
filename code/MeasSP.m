function varargout = MeasSP(varargin)
% MEASSP M-file for MeasSP.fig
%      MEASSP, by itself, creates a new MEASSP or raises the existing
%      singleton*.
%
%      H = MEASSP returns the handle to a new MEASSP or the handle to
%      the existing singleton*.
%
%      MEASSP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEASSP.M with the given input arguments.
%
%      MEASSP('Property','Value',...) creates a new MEASSP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MeasSP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MeasSP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MeasSP

% Last Modified by GUIDE v2.5 17-Aug-2009 14:04:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MeasSP_OpeningFcn, ...
                   'gui_OutputFcn',  @MeasSP_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function MeasSP_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for MeasSP
handles.output = hObject;

% get instrument information
instruments = varargin{1};

% get settings
handles.SETUP = varargin{2};

% initiate instruments
h_wb = varargin{3};
if handles.SETUP.DEMO
    % DEMO measurement
    set(handles.measure,'Enable','Off');
    handles.SETUP.MEASTYPE = 'DEMO';
    handles.instr.measure_dc1 = 0;
    handles.instr.measure_dc2 = 0;
else
    handles.instr = init_instr(instruments,h_wb);
end
close(h_wb);

% initiate save path
handles.SavePath = 'data/*.mat';

% initiate number of meas points
handles.numGL = 0;
handles.numGL2 = 0;
handles.numBIAS = 0;
handles.numMEAS = 0;

% set number of bias regions to 0
handles.num_regions = 0;

% set axes labels
axes(handles.ax1);
xlabel('V_1');
ylabel('\midI_1\mid');
% hold on;

axes(handles.ax2);
xlabel('V_2');
ylabel('I_2');
% hold on;

% check number of bias supplies
if ~handles.instr.measure_dc1 % disable bias 1
    set(handles.v1start,'Enable','Off');
    set(handles.v1stop,'Enable','Off');
    set(handles.v1step,'Enable','Off');
    set(handles.i1comp,'Enable','Off');
    set(handles.p1comp,'Enable','Off');
end
if ~handles.instr.measure_dc2 % disable bias 2
    set(handles.v2start,'Enable','Off');
    set(handles.v2stop,'Enable','Off');
    set(handles.v2step,'Enable','Off');
    set(handles.i2comp,'Enable','Off');
    set(handles.p2comp,'Enable','Off');        
end
if ~handles.instr.measure_dc1 && ~handles.instr.measure_dc2
    % No bias, set number of measurements to 1
    handles.numBIAS = 1;
    handles.numMEAS = 1;
    
    % update counter text
    ctext = sprintf('Point 0 out of %s',num2str(handles.numBIAS));
    set(handles.countertext,'String',ctext);    
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MeasSP wait for user response (see UIRESUME)
uiwait(handles.figure);

function varargout = MeasSP_OutputFcn(hObject, eventdata, handles) 
delete(hObject);

function biasgrid_Callback(hObject, eventdata, handles)
function biasgrid_CreateFcn(hObject, eventdata, handles)
function v1start_Callback(hObject, eventdata, handles)
function v1start_CreateFcn(hObject, eventdata, handles)
function v1stop_Callback(hObject, eventdata, handles)
function v1stop_CreateFcn(hObject, eventdata, handles)
function v1step_Callback(hObject, eventdata, handles)
function v1step_CreateFcn(hObject, eventdata, handles)
function v2start_Callback(hObject, eventdata, handles)
function v2start_CreateFcn(hObject, eventdata, handles)
function v2stop_Callback(hObject, eventdata, handles)
function v2stop_CreateFcn(hObject, eventdata, handles)
function v2step_Callback(hObject, eventdata, handles)
function v2step_CreateFcn(hObject, eventdata, handles)

function addbias_Callback(hObject, eventdata, handles)
handles = AddBias(handles); % add bias grid
% Update handles structure
guidata(hObject, handles);

function clearbias_Callback(hObject, eventdata, handles)
handles = ClearBias(handles);
% Update handles structure
guidata(hObject, handles);

function i1comp_Callback(hObject, eventdata, handles)
function i1comp_CreateFcn(hObject, eventdata, handles)
function i2comp_Callback(hObject, eventdata, handles)
function i2comp_CreateFcn(hObject, eventdata, handles)
function p1comp_Callback(hObject, eventdata, handles)
function p1comp_CreateFcn(hObject, eventdata, handles)
function p2comp_Callback(hObject, eventdata, handles)
function p2comp_CreateFcn(hObject, eventdata, handles)

function measure_Callback(hObject, eventdata, handles)
% check if bias points are given
if handles.numBIAS == 0
    msgbox('No Bias Point is given. Please select at least one Bias Point!','Error','error');
else
    % disable measure button
    set(handles.measure,'Enable','Off'); 
    % enable stop button
    set(handles.stop,'Enable','On');
    
    global MEAS_CANCEL; % global variable for canceling measurement
    MEAS_CANCEL = false;  
    
    % Get the bias grid
    BIAS = GetBIAS(handles);

    % set axes scale
    if handles.instr.measure_dc1
        if min(BIAS.V1) ~= max(BIAS.V1)
            axes(handles.ax1);axis([min(BIAS.V1) max(BIAS.V1) 0 max(abs(BIAS.I1))]);
        end
    end
    if handles.instr.measure_dc2
        if min(BIAS.V2) ~= max(BIAS.V2)
            axes(handles.ax2);axis([min(BIAS.V2) max(BIAS.V2) 0 max(BIAS.I2)]);
        end
    end
    
    swp = MeasureSP(handles.instr,BIAS,handles);

    % disable stop button
    set(handles.stop,'Enable','Off');

    % save the measurement
    [file,path] = uiputfile(handles.SavePath,'Save measurement');
    save(fullfile(path,file), 'swp');
    
    if path ~= 0
        handles.SavePath = [path '*.mat'];
    end

    set(handles.measure,'Enable','On'); % enable measure button
    
    % Update handles structure
    guidata(hObject, handles);    
end


function figure_CreateFcn(hObject, eventdata, handles)
function mv1_Callback(hObject, eventdata, handles)
function mv1_CreateFcn(hObject, eventdata, handles)
function mi1_Callback(hObject, eventdata, handles)
function mi1_CreateFcn(hObject, eventdata, handles)
function mv2_Callback(hObject, eventdata, handles)
function mv2_CreateFcn(hObject, eventdata, handles)
function mi2_Callback(hObject, eventdata, handles)
function mi2_CreateFcn(hObject, eventdata, handles)

function exit_Callback(hObject, eventdata, handles)
if handles.SETUP.DEMO == 0
    instrreset;
end
uiresume(handles.figure);

function savesetup_Callback(hObject, eventdata, handles)
% save bias settings
SaveSetup(handles,'SP');

function loadsetup_Callback(hObject, eventdata, handles)
% load bias, power and load reflection settings
handles = LoadSetup(handles,'SP');
% Update handles structure
guidata(hObject, handles);

function figure_CloseRequestFcn(hObject, eventdata, handles)
uiresume(handles.figure);


function stop_Callback(hObject, eventdata, handles)
global MEAS_CANCEL; % global variable for canceling measurement
MEAS_CANCEL = true; % cancel measurement
