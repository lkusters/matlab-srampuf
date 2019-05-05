# matlab-srampuf

MATLAB project for analysing the SRAM-PUF data.

Included functions:

/high-level functions
- make_HDinter.m : generate HDinter.mat (inter Hamming distance between selected files).
- make_matfiles.m : generate .mat files (convert selected hex/binary files to bindata and HDintra).
- show_HDinter.m : visualize HDinter.mat (select file, show Hamming distance as function of temperature difference etc.).
- show_HDintra.m : visualize intra Hamming distance of selected files (e.g. as function of time or time difference).

/low-level funcions used by high-level functions
- f_openbinaryfile.m : open binary source file and convert to binary matrix (n_observations x n_cells).
- f_openhexfile.m : open hexadecimal source file (n_observations x n_cells).
- f_calc_HD_intra.m : calculate the Hamming distances between all observations in the bindata matrix (output is upper triangular matrix).
- f_calc_HD_inter.m : calculate the Hamming distances between all observations in two bindata matrices.

/old function (keep for reference)
- f_showstats_bindata.m : show some basic properties of bindata matrix (e.g. HD, reference observation, one probabilities).
