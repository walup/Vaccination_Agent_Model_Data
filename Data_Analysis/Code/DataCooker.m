classdef DataCooker
    
   methods
       
       function normalizedData = normalizeSeries(obj,data)
          mu = mean(data);
          stdDev = std(data);
          normalizedData = (data - mu)/stdDev;
           
       end
       
       
   end
    
    
end