function instr = init_instr(instruments,h_wb)

V1driver = GetDriverName(instruments.dc1);
I1driver = GetDriverName(instruments.dcmeas1);
V2driver = GetDriverName(instruments.dc2);
I2driver = GetDriverName(instruments.dcmeas2);
VNAdriver = GetDriverName(instruments.vna);

%% Bias 
% update progressbar
waitbar(0, h_wb, 'Initializing Bias. Pleas Wait.');

% INPUT VOLTAGE SUPPLY
if ~strcmp(V1driver,'none')
    instr.measure_dc1 = 1;
    if (strcmp(V1driver,'agilent_4156_dc.mdd') || strcmp(V1driver,'agilent_662x.mdd') || strcmp(V1driver,'hameg_hmp4040.mdd') || strcmp(V1driver,'keithley_2602A_dc.mdd'))
        g_dc1 = visa('ni', instruments.dc1_gpib);
        instr.dc1multi = icdevice(V1driver,g_dc1);
        connect(instr.dc1multi);
        SMU = get(instr.dc1multi,'Smu');
        instr.dc1 = SMU(instruments.dc1_channel);
        if strcmp(V1driver,'keithley_2602A_dc.mdd')
            set(instr.dc1,'HighCapacitanceMode',1);
        end
    elseif strcmp(V1driver,'agilent_u2722a.mdd')
        g_dc1 = visa('agilent', instruments.dc1_gpib);
        instr.dc1multi = icdevice(V1driver,g_dc1);
        connect(instr.dc1multi);
        SMU = get(instr.dc1multi,'Smu');
        instr.dc1 = SMU(instruments.dc1_channel);
    else
        g_dc1 = visa('ni', instruments.dc1_gpib);
        instr.dc1 = icdevice(V1driver, g_dc1);
        connect(instr.dc1);
    end

    % INPUT CURRENT METER
    if strcmp(instruments.dc1_gpib, instruments.dcmeas1_gpib)
        instr.i1 = instr.dc1;
    elseif strcmp(I1driver, 'voltagesupply')
        instr.i1 = instr.dc1;
    elseif strcmp(I1driver, 'none')
        instr.i1 = instr.dc1;
    else
        g_i1 = visa('ni', instruments.dcmeas1_gpib);
        instr.i1 = icdevice(I1driver, g_i1);
        connect(instr.i1);
    end

    % INPUT VOLTAGE METER
    instr.v1 = instr.dc1;
else
    instr.measure_dc1 = 0;
end

% update progressbar
waitbar(0.2, h_wb, 'Initializing Bias. Please wait.');

% OUTPUT VOLTAGE SUPPLY
if ~strcmp(V2driver,'none')
    instr.measure_dc2 = 1;
    if strcmp(instruments.dc1_gpib, instruments.dc2_gpib)
        instr.dc2 = SMU(instruments.dc2_channel);
        if strcmp(V2driver,'keithley_2602A_dc.mdd')
            set(instr.dc2,'HighCapacitanceMode',1);
        end
    else    
        if (strcmp(V2driver,'agilent_4156_dc.mdd') || strcmp(V2driver,'agilent_66xx.mdd') || strcmp(V2driver,'hameg_hmp4040.mdd') || strcmp(V2driver,'keithley_2602A_dc.mdd'))
            g_dc2 = visa('ni', instruments.dc2_gpib);
            instr.dc2multi = icdevice(V2driver,g_dc2);
            connect(instr.dc2multi);
            SMU = get(instr.dc2multi,'Smu');
            instr.dc2 = SMU(instruments.dc2_channel);
            if strcmp(V2driver,'keithley_2602A_dc.mdd')
                set(instr.dc2,'HighCapacitanceMode',1);
            end
        elseif strcmp(V2driver,'agilent_u2722a.mdd')
            g_dc2 = visa('agilent',instruments.dc2_gpib);
            instr.dc2multi = icdevice(V2driver,g_dc2);
            connect(instr.dc2multi);
            SMU = get(instr.dc2multi,'Smu');
            instr.dc2 = SMU(instruments.dc2_channel);
        else
            g_dc2 = visa('ni', instruments.dc2_gpib);
            instr.dc2 = icdevice(V2driver, g_dc2);
            connect(instr.dc2);
        end
    end

    % OUTPUT CURRENT METER
    if strcmp(instruments.dc2_gpib, instruments.dcmeas2_gpib)
        instr.i2 = instr.dc2;
    elseif strcmp(I2driver, 'voltagesupply')
        instr.i2 = instr.dc2;
    elseif strcmp(I2driver, 'none')
        instr.i2 = instr.dc2;
    else
        g_i2 = visa('ni', instruments.dcmeas2_gpib);
        instr.i2 = icdevice(I2driver, g_i2);
        connect(instr.i2);    
    end

    % OUTPUT VOLTAGE METER
    instr.v2 = instr.dc2;
else
    instr.measure_dc2 = 0;
end

% update progressbar
waitbar(0.4, h_wb, 'Initializing VNA/LSNA. Please wait.');

%% S-parameter
% VNA
if strcmp(VNAdriver, 'none')
    instr.measure_sp = 0; % deactivate s-parameter measurement
    instr.measure_lsna = 0; % deactivate lsna measurement
elseif strcmp(VNAdriver, 'LSNA')
    instr.measure_sp = 0; % deactivate s-parameter measurement
    instr.measure_lsna = 1; % activate lsna measurement
    
    % initilize lsna
    loadlibrary('c:\Lsna_v1_1_1\lib\lsnaapi.dll','C:\Lsna_v1_1_1\api\include\lsnaapi.h');
    hlsna = calllib('lsnaapi','LSNAopen');
    lsna_vers = calllib('lsnaapi','LSNAgetVersionString');
    hlsna = calllib('lsnaapi','LSNAmeasure');
    
    % initilize input synthesizer
    instr.hsrc = visa('ni',0,instruments.synt_gpib);
    fopen(instr.hsrc);
    % Apply a safe level to source
    pset = -60;
    src_power(instr.hsrc, pset);
else
    instr.measure_sp = 1; % activate s-parameter measurement
    instr.measure_lsna = 0; % deactivate lsna measurement
    
    % initilize vna
    if strcmp(VNAdriver, 'agilent_e5061b.mdd')
        if (instruments.vna_gpib == instruments.dc1_gpib)
            instr.vna = instr.dc1;
        elseif (instruments.vna_gpib == instruments.dc2_gpib)
            instr.vna = instr.dc2;
        else
            g_vna = visa('ni', instruments.vna_gpib);
            instr.vna = icdevice(VNAdriver, g_vna);
            connect(instr.vna);
        end
    else
        g_vna = visa('ni', instruments.vna_gpib);
        instr.vna = icdevice(VNAdriver, g_vna);
        connect(instr.vna);
    end
end

% update progressbar
waitbar(0.6, h_wb, 'Initializing AO. Please wait.');

%% Analog output
% set number of analog outputs, index start at 0
if (instruments.ao > 0) && strcmp(VNAdriver, 'LSNA')
    instr.ao = analogoutput('nidaq','Dev2');
    chanIx = (0:1:(instruments.ao-1));
    chan = addchannel(instr.ao,chanIx);
end
% update progressbar
waitbar(0.8, h_wb, 'Initializing DIO. Please wait.');

%% Digital output
% Initiate the dio96 card
% if instruments.dio > 0
%     instr.dio = digitalio('nidaq','Dev1');
%     hwinfo = daqhwinfo(instr.dio);
%     NumPorts = length(hwinfo.Port)-1;
%     for Idx = 0:NumPorts
%         addline(instr.dio,0:7,Idx,'out');
%     end
% end
instr.dio = 0;
% update progressbar
waitbar(1, h_wb, 'Done.');

function driver = GetDriverName(instr)
% Get the driver filename from the name of the instrument
% instr is the name of the instrument and driver is 
% the corresponding driver filename

switch char(instr)
    case 'Agilent 4156 Analyzer'
        driver = 'agilent_4156_analyzer.mdd';
    case 'Agilent 4156 DC'
        driver = 'agilent_4156_dc.mdd';
    case 'Agilent 662x multi'
        driver = 'agilent_662x.mdd';
    case 'Agilent 66xx single'
        driver = 'agilent_66xx_single.mdd';
    case 'Agilent U2722A'
        driver = 'agilent_u2722a.mdd';
    case 'Keithley 24xx single'
        driver = 'keithley_24xx_single.mdd';
    case 'Keithley 2600 dual'
        driver = 'keithley_2602A_dc.mdd';
    case 'HAMEG HMP4040'
        driver = 'hameg_hmp4040.mdd';
    case 'Agilent 34401A'
        driver = 'agilent_34401A.mdd';
    case 'Use voltage supply'
        driver = 'voltagesupply';
    case 'Agilent PNA'
        driver = 'agilent_pna.mdd';
    case 'Agilent 8510'
        driver = 'agilent_8510C.mdd';
    case 'Anritsu 37xxx'
        driver = 'anritsu_37xxx.mdd';
    case 'Maury/NMDG LSNA'
        driver = 'LSNA';
    case 'Agilent E5061B'
        driver = 'agilent_e5061b.mdd';
    case 'none'
        driver = 'none';
    otherwise
        driver = 'unknown';
end