# matlab-srampuf

MATLAB project for analysing the SRAM-PUF data.
Included functions:

- f_openbinaryfile.m : open binary source file and convert to binary matrix (n_observations x n_cells).
- f_openhexfile.m : open hexadecimal source file (n_observations x n_cells).
- f_showstats_bindata.m : show some basic properties of bindata matrix (e.g. HD, reference observation, one probabilities).
- f_calc_HD_intra.m : calculate the Hamming distances between all observations in the bindata matrix (output list version of upper triangular matrix).
- f_calc_HD_inter.m : calculate the Hamming distances between all observations in two bindata matrices.
