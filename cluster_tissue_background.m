function cluster_tissue_background(input_file, distance, k, max_peaks, sa_path)
  
  disp('Loading the data')
  % Load the dataacube
  load(input_file);
  
  % Calculate the mean spectrum
  disp('Calculate mean spectrum')
  mean_intensity_all = mean(data);
  
  % Make a smaller datacube of the topk peaks
  disp('Making small datacube')
  [~, top_peaks_idx] = maxk([mean_intensity_all], max_peaks);
  small_data = data(:,top_peaks_idx);

  disp('Running k-means clustering')
  [kmeans_idx, ~, ~ ] = kmeans(small_data, k, 'distance', distance);

  %% Make mean spectrum
disp('Calculate cluster mean spectra')
  data_k1 = data(kmeans_idx == 1,:);
  data_k2 = data(kmeans_idx == 2,:);

  mean_intensity_k1 = mean(data_k1);
  mean_intensity_k2 = mean(data_k2); 
  
  clear data_k1
  clear data_k2
  clear small_data
  
  
  % Find the edge pixels
  edges = find(...
  (pixels(:,1) == max(pixels(:,1)))|...
  (pixels(:,1) == min(pixels(:,1)))|...
  (pixels(:,2) == max(pixels(:,1)))|...
  (pixels(:,2) == min(pixels(:,2)))...
  );
  
  edge_clusters = kmeans_idx(edges,:);
  
  % Select the BG cluster as having the most edge pixels
  
  bg_cluster = mode(edge_clusters);
  
  % Assign the clusters
  if bg_cluster == 1 
    tissue_cluster = 2;
    mean_intensity_tissue = mean_intensity_k2;
    mean_intensity_bg = mean_intensity_k1;
  else
    tissue_cluster = 1;
    mean_intensity_tissue = mean_intensity_k1;
    mean_intensity_bg = mean_intensity_k2;
  end
  
  % Use log2 tissue background ratio to fund peaks that are tissue localised
  tb_ratio = log2(mean_intensity_tissue./mean_intensity_bg);
  tissue_peak_idx = find(tb_ratio > 0);
  tissue_spectralChannels = spectralChannels(tissue_peak_idx);
  
  % Get the index of the tissue pixels
  tissue_pixel_idx = find(kmeans_idx == tissue_cluster);
  
  % Make a datacube just of tissue data and tissue pixels
  %tissue_data = data(tissue_pixel_idx,tissue_peak_idx);
  %tissue_pixels = pixels(tissue_pixel_idx);
  
  % Write into the mat file
  disp(['Saving workspace to: ' name(1) '.mat'])
  save('clustered_datacube.mat', '-v7.3');

  
 end
