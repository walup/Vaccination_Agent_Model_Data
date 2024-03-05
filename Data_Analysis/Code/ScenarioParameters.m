classdef ScenarioParameters
   properties
      scenario; 
      infectionPeakHeights;
      infectionPeakTimes;
      deathPeakHeights;
      deathPeakTimes;
   end
   
   methods
       function obj = ScenarioParameters(scenario, cutTimesDays)
          obj.scenario = scenario;
          obj = obj.extractScenarioParameters(cutTimesDays);
       end
       
       function obj = extractScenarioParameters(obj, cutTimesDays)
          minMaxCalculator = MinMaxCalculator();
          obj.infectionPeakHeights = [];
          obj.infectionPeakTimes = [];
          obj.deathPeakHeights = [];
          obj.deathPeakTimes = [];
          
          nCuts = size(cutTimesDays,1);
          tArraySEIRD = obj.scenario.tArraySEIRD;
          newCasesCurve = obj.scenario.newCasesSeries;
          newDeathsCurve = obj.scenario.newDeathsSeries;
          
          
          for i = 1:nCuts
              cutPair = cutTimesDays(i,:);
              dayStart = cutPair(1);
              dayEnd = cutPair(2);
              
              infectionIndexStart = -1;
              infectionIndexEnd = -1;
              
              for j = 1:length(tArraySEIRD)-1
               
                 if(tArraySEIRD(j) <= dayStart && tArraySEIRD(j+1)>= dayStart)
                     infectionIndexStart = j;
                 elseif(tArraySEIRD(j) <= dayEnd && tArraySEIRD(j+1) >= dayEnd)
                     infectionIndexEnd = j;
                     break;
                 end
              end
              
              if(infectionIndexStart == -1 || infectionIndexEnd == -1)
                 warning("Cuts provided are incorrect. Parameter extraction was interrupted");
                 break;
              end
              
              newCasesCut = newCasesCurve(infectionIndexStart:infectionIndexEnd);
              newDeathsCut = newDeathsCurve(infectionIndexStart:infectionIndexEnd);
              
              [maxIndexNewCases, maxValueNewCases] = minMaxCalculator.findGlobalMaxValue(newCasesCut);
              maxIndexNewCases = infectionIndexStart + (maxIndexNewCases - 1);
              
              [maxIndexNewDeaths, maxValueNewDeaths] = minMaxCalculator.findGlobalMaxValue(newDeathsCut);
              maxIndexNewDeaths = infectionIndexStart + (maxIndexNewDeaths - 1);
              
              obj.infectionPeakHeights = [obj.infectionPeakHeights, maxValueNewCases];
              obj.infectionPeakTimes = [obj.infectionPeakTimes, tArraySEIRD(maxIndexNewCases)];
              obj.deathPeakHeights = [obj.deathPeakHeights, maxValueNewDeaths];
              obj.deathPeakTimes = [obj.deathPeakTimes, tArraySEIRD(maxIndexNewDeaths)];
             
          end
          
       end
       
       
   end
    
    
    
    
    
end