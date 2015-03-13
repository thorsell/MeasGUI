function varargout = MeasIV(varargin)
% MEASIV M-file for MeasIV.fig
%      MEASIV, by itself, creates a new MEASIV or raises the existing
%      singleton*.
%
%      H = MEASIV returns the handle to a new MEASIV or the handle to
%      the existing singleton*.
%
%      MEASIV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEASIV.M with the given input arguments.
%
%      MEASIV('Property','Value',...) creates a new MEASIV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MeasIV_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MeasIV_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MeasIV

% Last Modified by GUIDE v2.5 17-Aug-2009 14:06:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MeasIV_OpeningFcn, ...
                   'gui_OutputFcn',  @MeasIV_OutputFcn, ...
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


% --- Executes just before MeasIV is made visible.
function MeasIV_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MeasIV (see VARARGIN)

% Choose default command line output for MeasIV
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

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MeasIV wait for user response (see UIRESUME)
uiwait(handles.figure);


function varargout = MeasIV_OutputFcn(hObject, eventdata, handles) 
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

    % measure
    swp = MeasureIV(handles.instr,BIAS,handles);

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
SaveSetup(handles,'IV');

function loadsetup_Callback(hObject, eventdata, handles)
% load bias
handles = LoadSetup(handles,'IV');
% Update handles structure
guidata(hObject, handles);

function figure_CloseRequestFcn(hObject, eventdata, handles)
uiresume(handles.figure); % close and resume

function stop_Callback(hObject, eventdata, handles)
global MEAS_CANCEL; % global variable for canceling measurement
MEAS_CANCEL = true; % cancel measurement