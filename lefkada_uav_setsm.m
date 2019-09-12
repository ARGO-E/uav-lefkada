import functions;

%sheets must be prefixed by "Site_"%
filenameUav = 'dataset/2019-09-06_Lefkada_Volume-Calculation_v206_UAV-APR-2017_DEM2009.xlsx';
filenameSetsm = 'dataset/2019-09-06_Lefkada_Volume-Calculation_v206_SETSM-DEC-2015_DEM2009.xlsx';
columnLabel = 'Volume';
columnIndex = 3; %the desired column. e.g. Volume is column 3%

%column indexes%
codeColumnIndex = 5;
landslideColumnIndex = 7;
confidenceColumnIndex = 12;
demQualityColumnIndex = 13;
droneAreaColumnIndex = 8;
droneArea2ColumnIndex = 9;

sites = functions.getSites(filenameUav);
setsmSheets = functions.getExcelSheets(filenameSetsm);

for i=1:numel(sites)
    site = sites{i};
    uavSiteData = functions.getRawExcelData(filenameUav, strcat('Site_', site));
    landslidesX = {};
    confidencesX = {};
    demQualitiesX = {};
    x = {};
    for j=2:length(uavSiteData)
        code = uavSiteData{j,codeColumnIndex};
        droneArea = uavSiteData{j,droneAreaColumnIndex};
        droneArea2 = uavSiteData{j,droneArea2ColumnIndex};
        demQuality = uavSiteData{j,demQualityColumnIndex};
        landslide = uavSiteData{j,landslideColumnIndex};
       
        % ignore positive code
        if code > 0
            disp(strcat('UAV data for landslide ID:', num2str(landslide), ' ignored => Code > 0.'));
            continue;
        end
        
        if strcmp(droneArea, 'n/a') == 1
            if strcmp(droneArea2, 'n/a') == 1
                disp(strcat('UAV data for landslide ID:', num2str(landslide), ' ignored => N/A drone Area'));
                continue;
            end
        end
        
        if strcmp(demQuality, 'Critical Error') == 1
            disp(strcat('UAV data for landslide ID:', num2str(landslide), ' ignored => Critical Error DEM quality'));
            continue;
        end 
       
        value = uavSiteData{j,columnIndex};
        confidence = uavSiteData{j,confidenceColumnIndex};
        demQuality = uavSiteData{j,demQualityColumnIndex};
        if ~functions.arrayContains(landslidesX, landslide)
            landslidesX = [landslidesX landslide];
            x = [x, 0];
            confidencesX = [confidencesX, ''];
            demQualitiesX = [demQualitiesX, ''];
        end
        landslideIndex = functions.getArrayElementIndex(landslidesX, landslide);
        x{landslideIndex} = x{landslideIndex} + value;
        confidencesX{landslideIndex} = confidence;
        demQualitiesX{landslideIndex} = demQuality;
    end
    
    for j=1:numel(setsmSheets)
        setsmSheetData = functions.getRawExcelData(filenameSetsm, setsmSheets{j});
        landslidesY = {};
        confidencesY = {};
        demQualitiesY = {};
        y = {};
        for k=2:length(setsmSheetData)
            code = setsmSheetData{k,codeColumnIndex};
            droneArea = setsmSheetData{k,droneAreaColumnIndex};
            droneArea2 = setsmSheetData{k,droneArea2ColumnIndex};
            landslide = setsmSheetData{k,landslideColumnIndex};
            
            if code > 0
                disp(strcat('SETSM data for landslide ID:', num2str(landslide), ' ignored => Code > 0.'));
                continue;
            end
            
            if strcmp(droneArea, site) == 0
                if strcmp(droneArea2, site) == 0
                    disp(strcat('SETSM data for landslide ID:', num2str(landslide), ' ignored => N/A drone Area'));
                    continue;
                end
            end
            
            if ~functions.arrayContains(landslidesX, landslide)
                disp(strcat('SETSM data for landslide ID:', num2str(landslide), ' ignored => ID not in UAV dataset'));
                continue;
            end
            
            value = setsmSheetData{k,columnIndex};
            confidence = setsmSheetData{k,confidenceColumnIndex};
            demQuality = setsmSheetData{k,demQualityColumnIndex};
            if ~functions.arrayContains(landslidesY, landslide)
                landslidesY = [landslidesY landslide];
                y = [y, 0];
                confidencesY = [confidencesY, ''];
                demQualitiesY = [demQualitiesY, ''];
            end
            landslideIndex = functions.getArrayElementIndex(landslidesY, landslide);
            y{landslideIndex} = y{landslideIndex} + value;
            confidencesY{landslideIndex} = confidence;
            demQualitiesY{landslideIndex} = demQuality;
            
        end
        
        plotX = {};
        plotY = {};
        
        for k=1:numel(landslidesY)
            if functions.arrayContains(landslidesX, landslidesY{k})
                indexX = functions.getArrayElementIndex(landslidesX, landslidesY{k})
                indexY = functions.getArrayElementIndex(landslidesY, landslidesY{k})
                plotX{k} = x{indexX};
                plotY{k} = y{indexY}
            else
                disp(strcat('SETSM data for landslide ID:', num2str(landslidesY{k}), ' ignored => ID not in UAV dataset'));
            end
            
        end
        
        if isempty(plotX)
            disp(['No data between UAV ' site ' and ' strrep(num2str(setsmSheets{j}),'_', ' ')]);
            continue;
        end
        
        scatter(cell2mat(plotX), cell2mat(plotY));
        refline;
        
        hold on
        lineX = 1:max(cell2mat(plotX));
        lineY = lineX;
        plot(lineX,lineY)
        hold off
   
        plotTitle = ['UAV Site ' site ' ' strrep(num2str(setsmSheets{j}),'_', ' ')];
        title(plotTitle);
        ylabel([strrep(num2str(setsmSheets{j}),'_', ' ') ' ' columnLabel]);
        xlabel([site ' ' columnLabel]);
        saveas(gcf, ['plots/' plotTitle,'.png']);
        
    end
end 