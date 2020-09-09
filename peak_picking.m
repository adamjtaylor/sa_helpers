function peak_picking(input_file, sa_path)

%% initialise
addpath(genpath(sa_path));
addJARsToClassPath();

load(input_file);

spectrum <- SpectralData(spectralChannels, intensities)

medianPeakFilter = PeakThresholdFilterMedian(1, 3);
peakPicking.addPeakFilter(medianPeakFilter);

peaks = peakPicking.process(combinedSpectrum);

save('picked_peaks.mat', 'peaks', '-v7.3);

end