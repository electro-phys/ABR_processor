function varargout = abr_processor(varargin)
% ABR_PROCESSOR MATLAB code for abr_processor.fig
%      ABR_PROCESSOR, by itself, creates a new ABR_PROCESSOR or raises the existing
%      singleton*.
%
%      H = ABR_PROCESSOR returns the handle to a new ABR_PROCESSOR or the handle to
%      the existing singleton*.
%
%      ABR_PROCESSOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ABR_PROCESSOR.M with the given input arguments.
%
%      ABR_PROCESSOR('Property','Value',...) creates a new ABR_PROCESSOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before abr_processor_OpeningFcn gets called.  An
%      unrecognized pperty name or invalid value makes property application
%      stop.  All inputs are passed to abr_processor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help abr_processor

% Last Modified by GUIDE v2.5 14-Oct-2022 13:57:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @abr_processor_OpeningFcn, ...
                   'gui_OutputFcn',  @abr_processor_OutputFcn, ...
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


% --- Executes just before abr_processor is made visible.
function abr_processor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to abr_processor (see VARARGIN)

% Choose default command line output for abr_processor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes abr_processor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = abr_processor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browse_btn.
function browse_btn_Callback(hObject, eventdata, handles)
% hObject    handle to browse_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %clear all; clc

    [abr_files, filepattern] = uigetfile('.mat','Grab the files you want to process','MultiSelect','on');

    if iscell(abr_files) == 0
        abr_files = (abr_files);
    end


%% search parameters

% no pass 2 on some of these so we need a way to get pass1s if no pass2s
% are present
    if  exist('abr_csv_list_big','var') ~= 1
        abr_csv_list_big = array2table(zeros(0,7)); % make mnaster table
        abr_csv_list_big.Properties.VariableNames = {'Wave_amp','Wave_lat', 'current_inten', 'current_freq' ...
            ,'current_ear','current_wave','current_rms'}; % deifne column names
    end
    for i = 1:(length(abr_files))
        filename = abr_files{i};
        load(filename)
        fprintf(1, 'Now Loading :  %s\n', filename);
        wave_data = wave_detail_list;
        fprintf(1, 'Wave Data: %s\n', filename);
    
        for a = 1:height(wave_data)
            for b = 1:width(wave_data)

            % each row of big cell array corresponds to value in intensity
            % list
            % each column is which ear
            % all same intensity 
                column_1_2 = wave_data{a,b}(:,1:2); % gets the 5 waves and their amp and latency for an intensity
                tf = cellfun('isempty',column_1_2); % true for empty cells
                column_1_2(tf) = {0};               % replace by a cell with a zero

                Wave_lat = column_1_2(:,1);
                Wave_amp = column_1_2(:,2);
                column_1_2 = cell2mat(column_1_2); % making into normal array
            
                
            

%                 inten = stim.stim.inten; % get an intensity list for the file
                inten = stim.stim.input.inten;
                current_inten = inten(a); % get intensity for given row
            %current_inten = current_inten*ones(5,1);

%                 freq = stim.stim.freq; % get an intensity list for the file
                freq = stim.stim.input.freq;
%                 current_freq = freq(a); % get intensity for given row
                current_freq = freq;
            %current_freq = current_freq*ones(5,1);

                ear_list = [1, 2];
                current_ear = ear_list(b); % column number corresponds to ear column 2 is left column 1 is right
            %current_ear = current_ear*ones(5,1);

                wave_list = [1,2,3,4,5]; % wave options 1-5

                
                current_rms = trace_rms(a,b);
            
            
                for x = 1:height(column_1_2) % loop through rows which correspond to each wave

                    current_wave = wave_list(x);

                    Wave_amp = column_1_2(x,2);
                    Wave_lat = column_1_2(x,1);
                    abr_csv_list_current = table(Wave_amp,Wave_lat, current_inten, current_freq,current_ear,current_wave,current_rms);
                    abr_csv_list_big = [abr_csv_list_big; abr_csv_list_current];
                    colnames = [Wave_amp,Wave_lat, current_inten, current_freq,current_ear,current_wave, current_rms];
          
                    assignin('base','abr_csv_list_big',abr_csv_list_big) % save table to workspace
        
                end


            end

        end

    end

  
    a = abr_csv_list_big;
    
    handles.a = a;
    
    guidata(hObject, handles);

 

% --- Executes on button press in prcs_btn.
function prcs_btn_Callback(hObject, eventdata, handles)
    
% hObject    handle to prcs_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uitable2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over browse_btn.
function browse_btn_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to browse_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_btn.
function save_btn_Callback(hObject, eventdata, handles)
    J = handles.a;
%      uisave('J','test')

% hObject    handle to save_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
