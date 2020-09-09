function make_datacube(input_imzml, input_peaks, sa_path)

addpath(genpath(sa_path));
addJARsToClassPath();

parser = ImzMLParser(input_imzml);
parser.parse;
data = DataOnDisk(parser);

load(input_peaks);

spectralChannels = [peaks.centroid];

%% Make datacube
disp(['! Generating data cube with ' num2str(length(spectralChannels)) ' peaks...'])

% If peakTolerance < 0 then the detected peak width is used
peakTolerance = -1;

reduction = DatacubeReduction(peakTolerance);
reduction.setPeakList(peaks);

% Inform the user whether we are using fast methods for processing (i.e. Java methods)
addlistener(reduction, 'FastMethods', @(src, canUseFastMethods)disp(['! Using fast Methods?   ' num2str(canUseFastMethods.bool)]));

dataRepresentationList = reduction.process(data);

disp('Data cube generated')

% We only requested one data representation, the entire dataset so extract that from the list
dataRepresentation = dataRepresentationList.get(1);
% Convert class to struct so that if SpectralAnalysis changes the DataRepresentation class, the data can still be loaded in

disp('Structure prepared')
dataRepresentation_struct = dataRepresentation.saveobj();

%% Save all
disp('Saving structure')
save('datacube.mat', '-struct', 'dataRepresentation_struct', '-v7.3')
disp('Complete')

end
