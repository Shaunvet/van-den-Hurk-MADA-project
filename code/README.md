# code

This folder and sub-folders should contain all the code. These are Quarto files. 

There are 3 sub-folders that do different parts of the analysis. Processing, EDA and Statistical analysis


To replicate this analysis, run the scripts within the code folder in the following order:

1 - processing-code/processingfile-v1.qmd - Processes raw data and performs initial cleaning.

2 - eda-code/eda.qmd - Performs EDA steps and some basic evaluations of the data. Some outputs are produced.

3 - analysis-code/statistical-analysis-v2-slim - The biggest component - full analysis and modeling steps are run here as well as generation of most outputs.
(Note: This is a large script and will take some time and processing power to run. The script uses loops to load saved data to reduce computation but expect it to take about 15 minutes to run the full script even with those steps.)


^^Note: processing-code/processing-code.qmd - This file will not run as the Excel CSV file is not in the repository due to size limitations. It was included purely to demonstrate processing steps. You can contact the author to get it or download the file directly from the CDC website if you wish to run this yourself.
