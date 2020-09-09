function total_spectrum(input_imzml, input_sap, sa_path)

%% initialise
addpath(genpath(sa_path));
addJARsToClassPath();
nzm_multiple = 3;

[filepath,name,ext] = fileparts(input_imzml);


% Generate preprocessing workflow
preprocessing = PreprocessingWorkflow();
preprocessing.loadWorkflow(input_sap);


peakPicking = GradientPeakDetection();
medianPeakFilter = PeakThresholdFilterMedian(1, nzm_multiple);
peakPicking.addPeakFilter(medianPeakFilter);

%% make datacubes from each dataset

% obtain total spectrum
disp(['Generating Total Spectrum for ' ,input_imzml]);
parser = ImzMLParser(input_imzml);
parser.parse;
data = DataOnDisk(parser);

spectrumGeneration = TotalSpectrum();
spectrumGeneration.setPreprocessingWorkflow(preprocessing);

totalSpectrum = spectrumGeneration.process(data);
totalSpectrum = totalSpectrum.get(1);

spectralChannels = totalSpectrum.spectralChannels;
intensities = totalSpectrum.intensities;

save('mean_spectrum.mat', 'totalSpectrum', 'spectralChannels', 'intensities', 'input_imzml', '-v7.3')
