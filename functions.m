classdef functions
    methods(Static)
        function c = arrayContains(array, value)
            c = 0;
            for i=1:numel(array)
                if array{i} == value
                    c = 1;
                    break;
                end
            end
        end

        function index = getArrayElementIndex(array, value)
            for i=1:numel(array)
                if array{i} == value
                    index = i;
                    break;
                end
            end
        end

        function index = getHeaderColumnIndex(column, headerMatrix)
             for i=1:numel(headerMatrix)
                if strcmp(headerMatrix{i}, column) == 1
                    index = i;
                    break;
                end
            end
        end

        function header = getHeader(rawData)
            header = rawData(1,:);
        end

        function sites = getSites(filenameUav)
            sheets = functions.getExcelSheets(filenameUav);
            sites = {};
            for i=1:numel(sheets)
                sheet = strrep(sheets{i},'Site_','');
                sites = [sites, sheet];
            end
        end

        function y = getExcelSheets(filename)
            [~,sheet_name]=xlsfinfo(filename);
            y = sheet_name;
        end

        function y = getRawExcelData(filename, sheet)
            [num,txt,raw] = xlsread(filename, sheet);
            y = raw;
        end
    end
end