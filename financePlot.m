% financePlot.m

% T = readtable( '.\transactions (2).csv' );
clear
% clc
close all
cd( 'C:\Users\Mondegreen\Documents\GitHub\personal' )
T = readtable( '.\transactions (3).csv' );
begin = datetime( 2016, 1, 1 );
T = T(datetime( T{:,1} )>begin,:);

numRows = size( T, 1 );

A = datetime( T{:, 1} );
[Y, E] = discretize( A, 'week', 'categorical' );
groupIndices = grp2idx( Y );
numWeeks = max( groupIndices );
eatingOutContainer = zeros( numWeeks, 1 );
groceriesContainer = zeros( numWeeks, 1 );
everythingContainer = zeros( numWeeks, 1 );

for week = 1:numWeeks
  tempTable = T(groupIndices==week, :);
  numTransactions = size( tempTable, 1 );
  for trans = 1:numTransactions
    if strcmp( tempTable{trans,'Category'}{1}, 'Restaurants' ) || ...
       strcmp( tempTable{trans,'Category'}{1}, 'Fast Food' ) 
      eatingOutContainer(week) = eatingOutContainer(week) + str2double( tempTable{trans, 'Amount'}{1} );
    end
    if strcmp( tempTable{trans,'Category'}{1}, 'Groceries' )
      groceriesContainer(week) = groceriesContainer(week) + str2double( tempTable{trans, 'Amount'}{1} );
    end
    everythingContainer(week) = everythingContainer(week) + str2double( tempTable{trans, 'Amount'}{1} );
  end
end

figure(1)
f1 = plot( E(1:end-1), eatingOutContainer, 'bo-' );
a1 = gca;
hold on
p1 = patch( [515 515 616 616], ...
            [1 max( a1.YLim )-1 max( a1.YLim )-1 1], [0.8 0.8 0.8] );
p1.EdgeAlpha = 0;
a1.Children = flipud( a1.Children );
title('Eating Out by Week')
f2 = figure(2);
plot( E(1:end-1), groceriesContainer, 'bo-' )
title('Grocery Purchases by Week')
f3 = figure(3);
plot( E(1:end-1), everythingContainer, 'bo-' );
title( 'all expenses' )