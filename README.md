# Mares_etal_Cortex_2022
Mares I, Ewing L, Papasavva E, Ducrocq E, Smith FW, Smith MLS (in press).
Face recognition ability is manifest in early dynamic decoding of face-orientation
selectivity – evidence from multi-variate pattern analysis of the neural
response. Cortex.

## Description
This code performs linear SVM decoding analyses of EEG data using either time windows or sample by sample approach.

## Requirements
You need LIBSVM (see https://www.csie.ntu.edu.tw/~cjlin/libsvm/, we used version 3.20), and Matlab.

## Authors
The code was originally created by Fraser W. Smith and was adapted to this project by Ines Mares and Fraser W Smith.

## Main Citation
Mares I, Ewing L, Papasavva E, Ducrocq E, Smith FW, Smith MLS (in press).
Face recognition ability is manifest in early dynamic decoding of face-orientation
selectivity – evidence from multi-variate pattern analysis of the neural
response. Cortex.

## Code Citations
Smith, F.W. & Smith M.L.S. (2019). Decoding the dynamic representation of facial expressions of 
emotion in explicit and incidental tasks. Neuroimage, 195, 261-271.

## Main Files

create_classifiers.m - first code to run to generate classifiers.
To change the channels used please edit filterSubElecs.m

computeClassParallel.m - computes linear SVM decoding accuracies from the EEG signal either using time windows OR sample by sample

create_matrices.m - organises the classifiers accuracies generated in matrices organised per group  (high vs low CFMT) for ease of plotting.

plotgroupclassifiers.m - generates plots (and group stats) to visually compare classifier accuracy between groups.

individualstatsandgraphs.m - generates individual level stats and plots.
