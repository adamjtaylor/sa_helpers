function total_spectrum_together(input_folder, input_sap, sa_path)

%% initialise
addpath(genpath(sa_path));
addJARsToClassPath();
nzm_multiple = 3;

files_to_process = dir([input_folder filesep '*.imzML']); %gets all imzML files in folder

% Generate preprocessing workflow
preprocessing = PreprocessingWorkflow();
preprocessing.loadWorkflow(input_sap);

peakPicking = GradientPeakDetection();
medianPeakFilter = PeakThresholdFilterMedian(1, nzm_multiple);
peakPicking.addPeakFilter(medianPeakFilter);

intensities = cell(length(files_to_process),1);

%% make spectra from each dataset

for i = 1:length(files_to_process)

% obtain total spectrum
parser = ImzMLParser([files_to_process(i).folder filesep files_to_process(i).name]);  
parser.parse;
data = DataOnDisk(parser);

spectrumGeneration = TotalSpectrum();
spectrumGeneration.setPreprocessingWorkflow(preprocessing);

totalSpectrum = spectrumGeneration.process(data);
totalSpectrum = totalSpectrum.get(1);

intensities{i} = totalSpectrum.intensities;
spectralChannels = totalSpectrum.spectralChannels;

end

%% combine intensities

combined_intensities = intensities{1};
for i = 2:length(intensities)
    combined_intensities = combined_intensities + intensities{i};
end


save('mean_spectrum_together.mat', 'spectralChannels', 'intensities', 'input_folder', 'input_sap', '-v7.3')
