function peak_picking(input_file, nzm_multiple, sa_path)

%% Input is a mat file containing spectralChannels and intensities vectors

%% initialise
addpath(genpath(sa_path));
addJARsToClassPath();

load(input_file);

spectrum = SpectralData(spectralChannels, intensities)

peakPicking = GradientPeakDetection();
medianPeakFilter = PeakThresholdFilterMedian(1, nzm_multiple);
peakPicking.addPeakFilter(medianPeakFilter);


peakPicking.addPeakFilter(medianPeakFilter);

peaks = peakPicking.process(spectrum);

save('picked_peaks.mat', 'peaks', '-v7.3');

end
