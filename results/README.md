# results

This folder and subfolders contain results produced by the code, such as figures and tables, and other files.

Folders:

A special folder for large files exists. This folder is set in .gitignore to be ignored when pushing/pulling. See the readme in that folder for details.

figures - all figures that are used in the products

large-files - files that are too large to be uploaded into GitHub (have gitignore function)

output - this has many of the outputs from throughout the analysis, especially modeling steps and intermediate RDS products that are saved. There are subfolders within output for eda, processing and statistical analysis, which have the intermediate/RDS products from those documents.
However, most of the modelling products are saved directly to the output folder and not in a subfolder.
