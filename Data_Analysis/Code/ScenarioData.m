classdef ScenarioData
    
    properties
       susceptibleSeries;
       exposedSeries;
       infectedSeries;
       recoveredSeries;
       deathSeries;
       newCasesSeries;
       newDeathsSeries;
       tArraySEIRD;
       tArrayPlaces;
       placesData;
       hospitalData;
       FsSEIRD;
       FsPlaces;
       recreationalData;
       workplaceData;
       residentialData;
       stoplightData;
    end
    
   
    methods
        
        function obj = ScenarioData(pathSEIRD, pathPlaces, FsSEIRD, FsPlaces)
            
            obj.FsSEIRD = FsSEIRD;
            obj.FsPlaces = FsPlaces;
            
            dataSEIRD = importdata(pathSEIRD).data;
            dataPlaces = importdata(pathPlaces).data;
            nPopulation = sum(dataSEIRD(1,:));
            filterSEIRDCoeffs = ones(FsSEIRD*14,1)*(1/14);
            filterer = Filterer();
            
            obj.susceptibleSeries =filterer.applyFIRFilter(dataSEIRD(:,1)/nPopulation, filterSEIRDCoeffs);
            obj.exposedSeries = filterer.applyFIRFilter(dataSEIRD(:,4)/nPopulation, filterSEIRDCoeffs);
            obj.infectedSeries = filterer.applyFIRFilter(dataSEIRD(:,5)/nPopulation, filterSEIRDCoeffs);
            obj.recoveredSeries = filterer.applyFIRFilter(dataSEIRD(:,2)/nPopulation, filterSEIRDCoeffs);
            obj.deathSeries = filterer.applyFIRFilter(dataSEIRD(:,3)/nPopulation, filterSEIRDCoeffs);
            
            %Obtenemos la serie de tiempo de nuevos casos
            susceptibleSeries = dataSEIRD(:,1);
            recoveredSeries = dataSEIRD(:,2);
            deathSeries = dataSEIRD(:,3);
            infectedSeries = dataSEIRD(:,5);
            
            obj.newCasesSeries = zeros(length(susceptibleSeries),1);
            obj.newCasesSeries(1) = infectedSeries(1);
            for i = 2:length(obj.newCasesSeries)
                
                if((infectedSeries(i) - infectedSeries(i-1)) + (recoveredSeries(i) - recoveredSeries(i-1)) + (deathSeries(i) - deathSeries(i-1)) >= 0)
                    obj.newCasesSeries(i) = (infectedSeries(i) - infectedSeries(i-1)) + (recoveredSeries(i) - recoveredSeries(i-1)) + (deathSeries(i) - deathSeries(i-1));
                end
                
            end
            obj.newCasesSeries = filterer.applyFIRFilter(obj.newCasesSeries/nPopulation, filterSEIRDCoeffs);
            
            
            %Obtenemos la serie de tiempo de nuevos fallecimientos
            obj.newDeathsSeries = zeros(length(deathSeries),1);
            obj.newDeathsSeries(1) = deathSeries(1);
            for i = 2:length(obj.newDeathsSeries)
               obj.newDeathsSeries(i) = deathSeries(i) - deathSeries(i-1); 
            end
            
            obj.newDeathsSeries = filterer.applyFIRFilter(obj.newDeathsSeries/nPopulation, filterSEIRDCoeffs);
            obj.placesData = dataPlaces;
            filterPlacesCoeffs = ones(FsPlaces*1*24, 1)*(1/(FsPlaces*1*24)); 
            
            for i = 1:size(obj.placesData,2)-1
                obj.placesData(:,i) = filterer.applyFIRFilter(obj.placesData(:,i)/nPopulation, filterPlacesCoeffs);
            end
            
            obj.hospitalData = obj.placesData(:,4);
            %Sum the restaurant, parks and mall occupation
            obj.recreationalData = obj.placesData(:,6) + obj.placesData(:,7) + obj.placesData(:,8) + obj.placesData(:,1);
            obj.workplaceData = obj.placesData(:,2);
            obj.residentialData = obj.placesData(:,3);
            obj.stoplightData = obj.placesData(:,9);
            
            obj.tArraySEIRD = (1:length(obj.susceptibleSeries))*(1/FsSEIRD);
            obj.tArrayPlaces = (1:length(obj.workplaceData))*(1/FsPlaces);
        end
        
        function plotNewCases(obj)
            plot(obj.tArraySEIRD, obj.newCasesSeries, 'Color', "#e32b5c");
        end
        
        function plotNewDeaths(obj)
            plot(obj.tArraySEIRD, obj.newDeathsSeries, 'Color', "#595959");
        end
        
        function plotRecoveredCases(obj)
           plot(obj.tArraySEIRD, obj.newDeathsSeries, 'Color', '#4de645'); 
        end
        
    end
    
    
    
end