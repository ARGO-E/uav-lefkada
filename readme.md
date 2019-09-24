# UAV Lefkada 

Calculations Prequake – UAV/SETSM

## Comparison Charts UAV/SETSM
The file ``lefkada_uav_setsm.m`` calculates comparison charts between UAV and SETSM. 
**Input**: Excel files for SETSM and UAV (both must be under dataset directory), column to check against
```m
% To calculate comparison chart for volume: %
filenameSetsm = '/dataset/SETSM_EXCEL_FILE.xls';
filenameUav = '/dataset/UAV_EXCEL_FILE.xls';
columnLabel = 'Volume'; % as written on the excel file
columnIndex = 3; % the index of the column to check against in the excel files
```
**Output**: The comparison charts under plots directory, and a log on the console of points that were ignored with reasoning.

## Comparison Charts SETSM-SETSM Overlapping Areas 
The file ``lefkada_setsm.m`` calculates comparison charts between overlapping areas of SETSM. 
**Input**: Excel file for SETSM (must be under dataset directory), and column to check against
```m
% To calculate comparison chart for volume: %
filenameSetsm = '/dataset/SETSM_EXCEL_FILE.xls';
columnLabel = 'Volume'; % as written on the excel file
columnIndex = 3; % the index of the column to check against in the excel files
```
**Output**: The comparison charts under plots directory, and a log on the console of points that were ignored with reasoning.
