% GetPhysData.m
% At this point in the homework I feel like things would be easier with a
% dedicated function for pulling up the physiology data, making any of the
% necessary changes, and returning it.

function [trainingPhysData, testPhysData] = GetPhysData()

csvFilename = fullfile( 'D:\Dropbox\GaTech CS Masters\Machine Learning', 'ratPhysiology.csv' );
physData = readtable( csvFilename );

% Data Cleanup
physData.RMP = []; 
physData.Species = []; % Only one value in this column
physData.Var1 = []; % Old unique row identifiers, not needed currently
physData.Var3 = [];

% Stratified Sampling
trainingPortion = 0.7;
physDataTypeOne = physData(physData.Type == 1, :);
physDataTypeTwo = physData(physData.Type == 2, :);
physDataTypeThree = physData(physData.Type == 3, :);
indexTrainingSetTypeOne = rand( 1, size(physDataTypeOne, 1) ) < trainingPortion;
indexTrainingSetTypeTwo = rand( 1, size(physDataTypeTwo, 1) ) < trainingPortion;
indexTrainingSetTypeThree = rand( 1, size(physDataTypeThree, 1) ) < trainingPortion;
trainingPhysDataTypeOne = physDataTypeOne(indexTrainingSetTypeOne, :);
trainingPhysDataTypeTwo = physDataTypeTwo(indexTrainingSetTypeTwo, :);
trainingPhysDataTypeThree = physDataTypeThree(indexTrainingSetTypeThree, :);
trainingPhysData = vertcat( trainingPhysDataTypeOne, trainingPhysDataTypeTwo, trainingPhysDataTypeThree );
testPhysDataTypeOne = physDataTypeOne(~indexTrainingSetTypeOne, :);
testPhysDataTypeTwo = physDataTypeTwo(~indexTrainingSetTypeTwo, :);
testPhysDataTypeThree = physDataTypeThree(~indexTrainingSetTypeThree, :);
testPhysData = vertcat( testPhysDataTypeOne, testPhysDataTypeTwo, testPhysDataTypeThree );

end