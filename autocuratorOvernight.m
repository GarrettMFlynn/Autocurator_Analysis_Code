% Code to use the autocurator on many sessions at once

directory = createDirectoryStructure();

for i = 1:(length(fieldnames(directory)))
fprintf(['Now Processing Session ' num2str(i) 'of' num2str(length(directory))]);
    fields = fieldnames(directory);
    video = directory.(fields{i}).video;
    whiskers = directory.(fields{i}).whiskers;
    objname = directory.(fields{i}).objname;
    jobname = directory.(fields{i}).jobname;
    process = directory.(fields{i}).processdir;
    cloudprocess = directory.(fields{i}).clouddir;
    
    
%% PARAMETERS
videoDirectory = [video]; % Location of your video files
dataObject = []; % Path or variable name of data object, leave empty to build
dataTarget = [whiskers]; % Directory of whisker files from tracker to build data object, leave blank if built
outputFileName = objname; % Name to use when saving output file
processDirectory = process; % Directory to use when creating and processing numpy files (can be same as video directory)
cloudProcessDirectory = cloudprocess; % Directory on cloud to transfer data to
model = 'General_Model_R3.h5'; % Name of desired model to use
modelROI = [81,81];
jobName = jobname; % Name of cloud job (must be different each time)
ffmpegDir = ['C:\Users\shires\Documents\Code\ffmpeg-3.3\bin']; % Location of ffmpeg executables (specifically need ffprobe)

%% SECTION CONTROL
% Use this to turn sections on and off, good for debugging without
% re-running time-consuming sections. Note that the full autocuration
% pipeline requires running through each section at least once.
PREPROCESS =            1;
NUMPY_CONVERT =         1;
UPLOAD =                1;
PROCESS =               1;
DOWNLOAD =              1;
WRITE_CONTACTS =        0;
CLEAR_DIRECTORIES =     0;

%% Load base settings
% Extract out information about the location of various scripts
pathSettings = return_path_settings();
cloudSettings = cloud_config;

%% Input checks

%% Build data object (if needed)
% This is an optional section that will package your whisker tracker data
% together into a single object for ease of use.
if isempty(dataObject)
    dataObject = package_sessionparfor(videoDirectory, dataTarget, ffmpegDir);
    % Save packaged files to avoid long reloading time
    packaged_filename = [processDirectory filesep 'Data_Package_' jobName '.mat'];
    save(packaged_filename, 'dataObject');
else
    dataObject = load(dataObject);
    dataObject = dataObject.dataObject;
end

%% Preprocess data
% Use this section to preprocess data, especially useful for telling the
% autocurator to ignore certain frames that cannot possibly be contacts
if PREPROCESS == 1
    tempContacts = preprocess_data(dataObject);
end

%% Convert to numpy
% Each video in a session is converted to a numpy file storing relevant
% frames. This format is needed to be read into the python Tensorflow
% script
if NUMPY_CONVERT == 1
    videos_to_numpy(tempContacts, processDirectory, modelROI);
end

%% Upload to cloud
if UPLOAD == 1
    npyDataPath = [processDirectory '/*.npy'] ;
    % Uses gsutil command tool
    gsutilUpCmd = sprintf('gsutil -m cp %s %s',...
        npyDataPath, cloudProcessDirectory);
    system(gsutilUpCmd)
end

%% Process on cloud
% This script uses the training job submission script for Google's cloudML,
% although this is not a training job, the script is still effective for
% curating on the cloud and will not use cloud resources (i.e. your money)
% once the job is completed.
if PROCESS == 1
    gcloudCmd = sprintf([...
        'gcloud ml-engine jobs submit training %s ^'...
        '--staging-bucket %s ^'...
        '--job-dir %s ^'...
        '--runtime-version %.01f ^'...
        '--package-path %s ^'...
        '--module-name %s ^'...
        '--region %s ^'...
        '--config=%s ^'...
        '-- ^'...
        '--cloud_data_path %s '...
        '--s_model_path %s '...
        '--job_name %s '],...
        jobName,...
        cloudSettings.mainBucket,... % Location of files on cloud
        cloudSettings.logDir,... % Place to store log files
        cloudSettings.runVersion,... % Runtime version
        pathSettings.cloudCurationScript,... % Path to application package
        ['cloud.cnn_curator_cloud'],... % Name of python module and directory in special dot notation
        cloudSettings.region,... % Datacenter to use (see README)
        pathSettings.curateConfigFile,... % Config file that requests GPU from cloud
        cloudProcessDirectory,...
        [cloudSettings.models '/' model],... % Path to desired model (please upload new models to same path)
        jobName);

    system(gcloudCmd)
    pause(1200) % gCloud doesn't have an automatic means of notifying
    % MATLAB when it is done, as a result, the best way to let the code run
    % automatically is to put in a pause command that exceeds the estimated
    % time needed by the cloud curation script. Unfortunately, this will
    % change based on the size of the dataset being curated, so
    % experimental benchmarking will be needed to determine appropriate
    % numbers

end

%% Download from cloud
% The files will be downloaded to the same directory but will have
% '_curated' appended to the name differentiate them.
if DOWNLOAD == 1
    downloadName = [cloudProcessDirectory '/curated/*.npy'];
    gsutilDownCmd = sprintf('gsutil -m cp %s%s %s',...
        cloudProcessDirectory, downloadName, processDirectory);
    system(gsutilDownCmd)
end

%% Convert to output matrix
% Your contacts will be saved as a .mat file containing the contact points
% for each trial as well as the confidence percentage of the autocurators
% classification. This script can also be used for post-processing.
if WRITE_CONTACTS == 1
    outputMat = write_to_contact_array(tempContacts, processDirectory);
    save(outPutFileName, 'outputMat')
end

%% Clear directories
% Deletes the numpy files created by clearing processing directories.
% Please ensure no downstream errors occured before using this as
% re-running the code will be much faster without having to regenerate the
% numpy files.
if CLEAR_DIRECTORIES == 1
    system(['del /q ' processDir])
    system(['gsutil -m rm -rf ' cloudProcessDirectory])
end




end

function [directory] = createDirectoryStructure
number = input('How many sessions would you like to process?');
directory = struct();

for j = 1:number
    %directory{j}.(mouseID).jobname = input(['Session ' num2str(j) ': What JOB NAME would you like for this session?\nJob Name: '],'s');
    mouseName = input(['Session ' num2str(j) ': What''s the mouse ID for this session (without AH)?\nMouseID: '],'s')
    mouseID = ['AH0' mouseName];
    directory.(mouseID).mousename = mouseName;
    directory.(mouseID).jobname = mouseID;
    directory.(mouseID).video = input(['Session ' num2str(j) ': What is the VIDEO directory for this session (no apostrophes)?\nVideo Directory: '],'s');
    %directory.(mouseID).whiskers = input(['Session ' num2str(j) ': What is the WHISKER directory for this session?\nWhisker Directory: '],'s');
    directory.(mouseID).whiskers = directory.(mouseID).video;
    %directory.(mouseID).objname = input(['Session ' num2str(j) ': What would you like to name the DATA OBJECT for this session?\nData Object Name: '],'s');
    directory.(mouseID).objname = [mouseID '.mat']
    %directory.(mouseID).processdir = input(['Session ' num2str(j) ': Where should the numpy DATASET be stored for this session?\nProcess Directory: '],'s');
    directory.(mouseID).processdir = ['C:\SuperUser\CNN_Projects\New_Autocurator_Test\NEW_MODEL_RESULTS\' directory.(mouseID).mousename '\Datasets'];
    %folder = input(['Session ' num2str(j) ': Where on the CLOUD do you want the numpy dataset uploaded/processed?\nCloud Directory: gs://whisker-autocurator-data/Data/'],'s');
    %directory.(mouseID).clouddir = ['gs://whisker-autocurator-data/Data/' folder]
    directory.(mouseID).clouddir = ['gs://whisker-autocurator-data/Data/Final_Test/' directory.(mouseID).mousename];
    fprintf(['Session ' num2str(j) ' finished.\nNow filling in info for Session' num2str(j+1) '\n']);
end
fprintf('Done logging sessions. Autocuration will now begin.');
end
