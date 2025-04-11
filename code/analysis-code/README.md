# analysis-code

This folder contains  a quarto document with modeling and statistical analysis. 
The correct file to use (in this folder is statistical-analysis-v2-slim)

This was originally done in a quarto document named statistical-analysis-v2 which used the full saved model files which were too large for GitHub (but is available if you wish).

Thus, I have made an amended version that creates and saves a slimmed down version of the model results to make it better suited to GitHub. The large model files are saved to the larg-files folder which does not upload to GitHub - please contact me if you would like these files.

The script uses "if" statements to check for saved files to save time in running the script and so save paths are important. Please be sure to be using the Here function and to laod all of the packages.

You can also toggle the function to run the reduced (slim)model saved files or the full model saved files. Be warned that the full RF and LASSO models are very intensive and each take over one hour to run on my system.
