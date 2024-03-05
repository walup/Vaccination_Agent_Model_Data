classdef MinMaxCalculator
    

    methods
        
        function [index, maxVal] = findGlobalMaxValue(obj,xArray)
            
            n = length(xArray);
            maxVal = -Inf;
            index = -1;
            for i = 1:n
               if (xArray(i) > maxVal)
                  maxVal = xArray(i);
                  index = i;
               end
            end
        end
        
        
        function [index, minVal] = findGlobalMinValue(obj,xArray)
           n = length(xArray);
           minVal = Inf;
           index = -1;
           for i = 1:n
              if(xArray(i) < minVal)
                 minVal = xArray(i);
                 index = i;
              end
           end
        end
        
        function [maxIndexes, maxValues] = findGlobalMaxValues(obj, xArray, n)
            if(n < length(xArray))
                maxValues = [];
                maxIndexes = [];
                maxIndex = -1;
                for i = 1:n
                    if(maxIndex > 0)
                        xArray(maxIndex) = [];
                    end
                    [maxIndex, maxValue] = obj.findGlobalMaxValue(xArray);
                    maxValues = [maxValues, maxValue];
                    maxIndexes = [maxIndexes,maxIndex];
                end
            else
                disp("Maximum number exceeds array length")
            end
        
        end
        
        function [minIndexes, minValues] = findGlobalMinValues(obj, xArray, n)
            if(n < length(xArray))
                minIndexes = [];
                minValues = [];
                minIndex = -1;
                for i = 1:n
                    if(minIndex > 0)
                       xArray(minIndex) = []; 
                    end
                    [minIndex, minValue] = obj.findGlobalMinValue(xArray);
                    minValues = [minValues, minValue];
                    minIndexes = [minIndexes, minIndex];
                end
            else
                disp("Minimum number exceeds array length")
            end
        end
        
    end
    
    
end
