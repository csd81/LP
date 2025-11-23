Tutorial for Operations Research - Modeling in GNU MathProg
(Supplementary material for the main document.)

This pack contains GNU MathProg source codes and results mentioned in the tutorial. Each model, data or result mentioned or referred to in the tutorial can be found here.

The main directories correspond to chapters of the document, in the order 'gnump', 'eqsystem', 'production', 'transportation' and 'milp'. Subdirectories represent sections, numbering refers to order. Files are mostly the following: GNU MathProg model files (.mod), corresponding data files (.dat), and logs of solver GLPSOL (.log). All are regular text files.

All model files are either runnable on their own or have corresponding data files in the same subdirectory. Run should cause no errors, unless the word 'ERROR' is mentioned in the file name. Run should use minimal memory, and take moments on modern computers, with the exception of a few cases mentioned in the tutorial. Each '.log' file corresponds to a run of a model and - if needed - one corresponding data file.

The script 'testrun.sh' runs ALL models stored, reproducing and overwriting all '.log' files already there. Time limits are applied in some large cases. Note that results might be slightly different than the original, especially for different GLPSOL versions or machines, but the reported optimal solutions - if found - should always have the same objective, and same solution (in a few cases, alternative optimal solutions with the same objective might theoretically be reported).

Note that 'testrun.sh' requires (tested on) Linux OS, with GLPSOL already installed as available through the 'glpsol' CLI command. Run should take ~3 minutes, might be more depending on the system.

The 'descriptions.txt' file explains in brief what each subdirectory contains, and how data files are related to each other across different subdirectories, as in many cases almost identical data files are used for several different models.

In case of any question, please contact:

András Éles
University of Pannonia, Veszprém, Hungary
eles@dcs.uni-pannon.hu
