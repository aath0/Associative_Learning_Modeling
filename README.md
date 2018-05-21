# Modeling Associative Learning through physiological responses
Functions to analyze and model skin conductance and pupil size response data during fear conditioning experiments.

### Analysis of skin conductance & pupil size responses (SCR & PSR)
* SCR and PSR data can be imported in matlab using [PsPM](http://pspm.sourceforge.net/) and functions that can be found [here](/RawDataAnalysis/import_SCR.m) for SCR and [here](/RawDataAnalysis/import_PSR.m) for PSR.

* Extraction of anticipatory amplitude of SCR is based on dynamic causal models (DCMs), and the code for that can be found [here](/RawDataAnalysis/compute_dcm.m). 

* The anticipatory amplitude of PSR was estimated using single-trial general linear models (GLMs), with code that can be found [here](/RawDataAnalysis/compute_glm.m).

### Modeling single-trial SCR & PSR
* Trial-by-trial changes in anticipatory SCR & PSR can be modeled with several reinforcement learning and null models. The code for that can be found [here](/ModelingAnalysis/model_estimates.m).
