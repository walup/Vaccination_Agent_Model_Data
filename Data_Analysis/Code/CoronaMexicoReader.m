
classdef CoronaMexicoReader
    
    properties
        mexicoIndexNew;
        mexicoIndexDeaths;
        mexicoIndexRecovered;
        mexicoOffices;
        mexicoHouses;
        mexicoHospitals;
        
        
    end
    
    
    methods
        
        function obj = CoronaMexicoReader()
           obj.mexicoIndexNew = 187-1; 
           obj.mexicoIndexDeaths = 187-1;
           obj.mexicoIndexRecovered = 172 - 1;
        end
        
        function [newCases, deathsNewCases, recoveredCases, info] = readMexicoDataTable(obj)
            %New cases
            fileName = 'time_series_covid19_confirmed_global.csv';
            if ~isfile(fileName)
                url = "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv";
                fileName = websave(fileName, url);
            end
            data = importdata(fileName);
            colheaders = data.textdata(1,:);
            info = "New cases data gathered from "+string(colheaders{5}) + " to "+string(colheaders{length(colheaders)}) + newline;
            data = data.data;
            cumulativeCases = data(obj.mexicoIndexNew, 5:size(data,2));
            newCases = zeros(length(cumulativeCases),1);
            newCases(1) = cumulativeCases(1);
            for i = 2:length(cumulativeCases)
               newCases(i) = cumulativeCases(i) - cumulativeCases(i-1); 
            end
            
            %Death cases
            %Si no existe el archivo de muertes lo escribimos
            fileName = "time_series_covid19_deaths_global.csv";
            if(~isfile(fileName))
               url = "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv";
               fileName = websave(fileName, url);
            end
            data = importdata(fileName);
            colheaders = data.textdata(1,:);
            info = info + "Death cases data gathered from "+string(colheaders{5}) + " to "+string(colheaders{length(colheaders)}) + newline;
            data = data.data;
            cumulativeDeaths = data(obj.mexicoIndexDeaths,5:size(data,2));
            deathsNewCases = zeros(length(cumulativeDeaths), 1);
            deathsNewCases(1) = cumulativeDeaths(1);
            
            for i = 2:length(cumulativeDeaths)
                deathsNewCases(i) = cumulativeDeaths(i) - cumulativeDeaths(i-1);
            end
            
            %Recovered cases
            fileName = "time_series_covid19_recovered_global.csv";
            if(~isfile(fileName))
               url = "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv";
               fileName = websave(fileName, url);
            end
            data = importdata(fileName);
            colheaders = data.textdata(1,:);
            info = info + "Recovered cases data gathered from "+string(colheaders{5}) + " to "+string(colheaders{length(colheaders)}) + newline;
            data = data.data;
            recoveredCases = data(obj.mexicoIndexRecovered,5:size(data,2))';
         
        end
        
        function [placeNames, placeData]  = readFullMobilityData(obj, yearsDataPaths, rowCuts, columnsToConsider)
            placeNames = [];
            placeData = [];
            
            %We first get the names of the places
            firstPath = yearsDataPaths(1);
            data = importdata(firstPath);
            colNames = data.textdata(1,columnsToConsider);

            for i = 1:length(columnsToConsider)
               placeNames = [placeNames,string(colNames{i})]; 
            end
            
            for i = 1:size(rowCuts, 1)
               %Open the relevant year data
               data = importdata(yearsDataPaths(i)).data;
               rowCut = rowCuts(i,:);
               placeData = [placeData; data(rowCut(1):rowCut(2), 1:length(columnsToConsider))];
               
            end
            
            %Let's filter the time series a little bit 
            filterer = Filterer();
            nDaysToAverage = 14;
            filterCoefficients = ones(1,nDaysToAverage)*(1/nDaysToAverage);
            
            for i = 1:size(placeData,2)
               placeData(:,i) = filterer.applyFIRFilter(placeData(:,i), filterCoefficients); 
            end
            
        end
        
    end
    
    
    
    
    
    
end