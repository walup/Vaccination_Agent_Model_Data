classdef TimeSeriesMatcher
    
    methods
        %We are going to assume that bounds for the tArrays of the two
        %series are the same, that is, they were recorded in exactly the
        %same time interval.
        function [matchedTimeArray, matchedTimeSeries1, matchedTimeSeries2]  = matchTimeSeries(obj,tArray1, tArray2, timeSeries1, timeSeries2)
            %Vamos a interpolar linealmente, se que quizás no es lo más
            %apropiado pero es la solución que se me ocurre justo ahora
            nTimeSeries1 = length(timeSeries1);
            nTimeSeries2 = length(timeSeries2);
            Fs1 = floor(1/(tArray1(2) - tArray1(1)));
            Fs2 = floor(1/(tArray2(2) - tArray2(1)));
          
            if(nTimeSeries1 < nTimeSeries2)
                nTimeSeries = nTimeSeries2;
                initialDeltaT = tArray1(2) - tArray1(1);
                disp(initialDeltaT*Fs2);
                nPointsInInterval = round(initialDeltaT*Fs2);
                
                numberOfIntervals = length(timeSeries1) - 1;
                newTimeSeries = zeros(nTimeSeries,1);
                
                for i = 1:numberOfIntervals - 1
                   leftBound = timeSeries1(i);
                   rightBound = timeSeries1(i+1);
                   
                   xArray = linspace(0,1,nPointsInInterval);
                   interpolatedPoints = leftBound + (rightBound - leftBound)*xArray;

                   newTimeSeries((i-1)*nPointsInInterval + 1:(i-1)*nPointsInInterval + nPointsInInterval) = interpolatedPoints;
                 
                end
                
                matchedTimeArray = tArray2;
                disp(length(tArray2));
                disp(length((tArray1)));
                matchedTimeSeries1 = newTimeSeries(1:length(timeSeries2));
                matchedTimeSeries2 = timeSeries2;
                
            else
                nTimeSeries = nTimeSeries1;
                initialDeltaT = tArray2(2) - tArray2(1);
                nPointsInInterval = round(initialDeltaT*Fs1);
                numberOfIntervals = length(length(timeSeries2)) - 1;
                newTimeSeries = zeros(nTimeSeries,1);
                
                for i = 1:numberOfIntervals
                    leftBound = timeSeries2(i);
                    rightBound = timeSeries2(i+1);
                    xArray = linspace(0,1,nPointsInInterval);
                    interpolatedPoints = leftBound + (rightBound - leftBound)*xArray;
                   
                   
                    newTimeSeries((i-1)*nPointsInInterval + 1: (i-1)*nPointsInInterval + nPointsInInterval) = interpolatedPoints;
                   
                end
                
                matchedTimeArray = tArray1;
                matchedTimeSeries1 = timeSeries1;
                matchedTimeSeries2 = newTimeSeries;
                
            end
            
            
        end
        
        
    end
    
    
    
end