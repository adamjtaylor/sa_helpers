calc_spatial_chaos <- function(input_file) {

library(tidyverse)
library(hdf5r)
library(SPUTNIK)

h5_file <- hdf5r::h5file(input_file, mode = "r")

pixels <- h5_file[["pixels"]]$read() %>% as_tibble() %>% rename(x=V1, y = V2)
mz <- h5_file[["spectralChannels"]]$read()
tb_ratio <- h5_file[["tb_ratio"]]$read()
datacube <- h5_file[["data"]]$read()

h5_file$close_all()

max_x <- max(pixels$x)
max_y <- max(pixels$y)

calc_s_chaos <- function(index){
  datacube[,index] %>% matrix(max_y, max_x) %>% spatial.chaos()
}

tibble(
  mz = mz,
  index = 1:length(mz),
  tb_ratio = tb_ratio
  ) %>%
  filter(tb_ratio > 0) %>%
  mutate(
    s_chaos = map_dbl(index, calc_s_chaos)
    ) %>%
  write_csv("spatial_chaos_tissue.csv")

h5_file$close_all()
  
}
