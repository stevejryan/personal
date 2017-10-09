% financePlot.m

% T = readtable( '.\transactions (2).csv' );
clear
% clc
close all
cd( 'C:\Users\Mondegreen\Documents\GitHub\personal' )
% T = readtable( '.\transactions (3).csv' );
T = readtable( '.\transactions (4).csv' );
T{strcmp( T.AccountName, 'Discover it Card' ), 'AccountName' } = {'Discover'};
% brokerageAccount = readtable( '.\vanguardBrokerage.csv' );
% fourOhOneKay = readtable( '.\vanguard401k.csv' );
% T = vertcat( T, brokerageAccount, fourOhOneKay );
begin = datetime( 2016, 1, 1 );
T = T(datetime( T{:,1} )>begin,:);
T.Date = datetime( T.Date );
T = sortrows(T, 'Date', 'descend');

for i=1:size( T, 1 )
  T.Amount{i} = str2double( T.Amount{i} );
  if strcmp( T.TransactionType{i}, 'debit' )
    T.TransactionSign(i) = -1;
  elseif strcmp( T.TransactionType{i}, 'credit' )
    T.TransactionSign(i) = 1;
  else
    error();
  end
end
T.Amount = cell2mat( T.Amount );
% It's worth noting that I'm not sure what the starting balances for credit
% cards exactly mean, credit cards don't tend to have a running-balance
% column, but in this case I've calculated them so that the sum of that
% number plus all activity in the ledger equals the current balance, SO, it
% seems like the math works out.
% startingBalances = [ 34.09, 0, 3, 0, -964.47, -1014.97, 0, 0, 0, 0, 5547.53, 3462.93, 3820.75, Venmo]; 
startingBalances = [ -110.69, 0, 152.92, 0, -964.47, -1014.97, 0, 0, 0, 0, 5547.53, 3462.93, 3820.75, 0]; 
startingBalanceMap = containers.Map( unique( T.AccountName ), startingBalances );

numRows = size( T, 1 );
%%
A = datetime( T{:, 1} );
[Y, E] = discretize( A, 'week', 'categorical' );
groupIndices = grp2idx( Y );
numWeeks = max( groupIndices );
T.Week = Y;

eatingOut = vertcat( T(strcmp( T.Category, 'Restaurants' ), :), ...
                     T(strcmp( T.Category, 'Fast Food' ), :) );
groceries = vertcat( T(strcmp( T.Category, 'Groceries' ), :) );

[G, eoTID] = findgroups( eatingOut(:, 'Week') );
eoTID.Totals = splitapply( @sum, eatingOut.Amount, G );

[G, gTID] = findgroups( groceries(:, 'Week') );
gTID.Totals = splitapply( @sum, groceries.Amount, G );

% 
% eatingOutContainer = zeros( numWeeks, 1 );
% groceriesContainer = zeros( numWeeks, 1 );
% everythingContainer = zeros( numWeeks, 1 );
% 
% for week = 1:numWeeks
%   tempTable = T(groupIndices==week, :);
%   numTransactions = size( tempTable, 1 );
%   for trans = 1:numTransactions
%     if strcmp( tempTable{trans,'Category'}{1}, 'Restaurants' ) || ...
%        strcmp( tempTable{trans,'Category'}{1}, 'Fast Food' ) 
%       eatingOutContainer(week) = eatingOutContainer(week) + str2double( tempTable{trans, 'Amount'}{1} );
%     end
%     if strcmp( tempTable{trans,'Category'}{1}, 'Groceries' )
%       groceriesContainer(week) = groceriesContainer(week) + str2double( tempTable{trans, 'Amount'}{1} );
%     end
%     everythingContainer(week) = everythingContainer(week) + str2double( tempTable{trans, 'Amount'}{1} );
%   end
% end

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