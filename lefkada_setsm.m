import functions;

%sheets must be prefixed by "SETSM_"%
filenameSetsm = 'dataset/2019-09-06_Lefkada_Volume-Calculation_v206_SETSM-DEC-2015_DEM2009.xlsx';
columnLabel = 'Volume';
columnIndex = 3; %the desired column. e.g. Volume is column 3%

%column indexes%
codeColumnIndex = 5;
landslideColumnIndex = 7;
confidenceColumnIndex = 12;
demQualityColumnIndex = 13;
setsmAreaColumnIndex = 10;
setsmArea2ColumnIndex = 11;

sheets = functions.getExcelSheets(filenameSetsm);

for i=1:1%numel(sheets)-1
    sheet1 = sheets{i};
    sheet2 = sheets{i+1};
    
    area1 = strrep(sheet1, 'SETSM_', '');
    area2 = strrep(sheet2, 'SETSM_', '');
    
    area1Data = functions.getRawExcelData(filenameSetsm, sheet1);
    area2Data = functions.getRawExcelData(filenameSetsm, sheet2);
    
    landslidesX = {};
    confidencesX = {};
    demQualitiesX = {};
    x = {};
    
    for j=2:length(area1Data)
        code = area1Data{j,codeColumnIndex};
        setsmArea = area1Data{j,setsmAreaColumnIndex};
        setsmArea2 = area1Data{j,setsmArea2ColumnIndex};
        landslide = area1Data{j,landslideColumnIndex};
        demQuality = area1Data{j,demQualityColumnIndex};
        confidence = area1Data{j,confidenceColumnIndex};
        value = area1Data{j,columnIndex};
        
        if ~isequal(setsmArea,area1) && ~isequal(setsmArea,area2)
            continue;
        end
        
        if ~isequal(setsmArea2,area1) && ~isequal(setsmArea2,area2)
            continue;
        end
        
        % ignore positive code
        if code > 0
            disp(strcat('data for landslide ID:', num2str(landslide), ' ignored => Code > 0.'));
            continue;
        end
        
        if strcmp(demQuality, 'Critical Error') == 1
            disp(strcat('data for landslide ID:', num2str(landslide), ' ignored => Critical Error DEM quality'));
            continue;
        end
        
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
    
    landslidesY = {};
    confidencesY = {};
    demQualitiesY = {};
    y = {};
    
    for j=2:length(area2Data)
        code = area2Data{j,codeColumnIndex};
        setsmArea = area2Data{j,setsmAreaColumnIndex};
        setsmArea2 = area2Data{j,setsmArea2ColumnIndex};
        landslide = area2Data{j,landslideColumnIndex};
        demQuality = area2Data{j,demQualityColumnIndex};
        confidence = area2Data{j,confidenceColumnIndex};
        value = area2Data{j,columnIndex};
        
        if ~isequal(setsmArea,area1) && ~isequal(setsmArea,area2)
            continue;
        end
        
        if ~isequal(setsmArea2,area1) && ~isequal(setsmArea2,area2)
            continue;
        end
        
        % ignore positive code
        if code > 0
            disp(strcat('data for landslide ID:', num2str(landslide), ' ignored => Code > 0.'));
            continue;
        end
        
        if strcmp(demQuality, 'Critical Error') == 1
            disp(strcat('data for landslide ID:', num2str(landslide), ' ignored => Critical Error DEM quality'));
            continue;
        end
        
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
        disp(['No data between areas ' strrep(num2str(setsmSheets{j}),'_', ' ')]);
        continue;
    end

    scatter(cell2mat(plotX), cell2mat(plotY));
    refline;
    
    hold on
    lineX = 1:max(cell2mat(plotX));
    lineY = lineX;
    plot(lineX,lineY)
    hold off
    
    plotTitle = [strrep(num2str(sheet1),'_', ' ') ' - ' strrep(num2str(sheet2),'_', ' ')];
    title(plotTitle);
    ylabel([strrep(num2str(sheet1),'_', ' '), '  ', columnLabel]);
    xlabel([strrep(num2str(sheet2),'_', ' '), '  ', columnLabel]);
    saveas(gcf, ['plots/' plotTitle,'.png']);
    
end