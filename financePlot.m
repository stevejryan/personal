% financePlot.m

clear
close all
cd( 'C:\Users\Mondegreen\Documents\GitHub\personal' )
T = readtable( '.\transactions (4).csv' );
% For some reason there are two account names for Discover card, this fixes
T{strcmp( T.AccountName, 'Discover it Card' ), 'AccountName' } = {'Discover'};
% Eliminates some misleading transactions
T(contains( T.Description, 'Q State' ) & T.Date == datetime(2017, 09, 01), : ) = [];
T(strcmp( T.Category, 'Transfer' ), : ) = [];
% remove some useless columns
T.Labels = [];
T.Notes = [];
T.OriginalDescription = [];

brokerTable = readtable( '.\brokerage.csv' );
brokerTable.AccountNumber = [];
brokerTable.SettlementDate = [];
brokerTable.Symbol = [];


retireTable = readtable( '.\fourOhOne.csv' );

begin = datetime( 2016, 1, 3 );
T.Date = datetime( T.Date );
T = T(T.Date>begin,:);
T = sortrows(T, 'Date', 'ascend');
weekNum = floor( daysact( begin, T.Date ) / 7 );
T.Week = begin + weekNum*7;
transactionSign = zeros( height( T ), 1 );
transactionSign(strcmp( T.TransactionType, 'debit' ) ) = -1;
transactionSign(strcmp( T.TransactionType, 'credit' ) ) = 1;
T.TransactionSign = transactionSign;
T.Amount = cell2mat( cellfun( @(x) str2num( x ), T.Amount, 'UniformOutput', false ) );
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
% A = datetime( T{:, 1} );
% [Y, E] = discretize( A, 'week', 'categorical' );
% groupIndices = grp2idx( Y );
numWeeks = numel( unique( T.Week ) );
% T.Week = Y;

eatingOut = vertcat( T(strcmp( T.Category, 'Restaurants' ), :), ...
                     T(strcmp( T.Category, 'Fast Food' ), :) );
eatingOut = eatingOut(eatingOut.TransactionSign < 0, :);
groceries = vertcat( T(strcmp( T.Category, 'Groceries' ), :) );
groceries = groceries(groceries.TransactionSign < 0, :);

Tcredit = T(T.TransactionSign > 0, :);
Tdebit = T(T.TransactionSign < 0, :);

[G, eoTID] = findgroups( eatingOut(:, 'Week') );
eoTID.Totals = splitapply( @sum, eatingOut.Amount, G );

[G, gTID] = findgroups( groceries(:, 'Week') );
gTID.Totals = splitapply( @sum, groceries.Amount, G );

[G, eTID] = findgroups( Tdebit(:, 'Week') );
eTID.Totals = splitapply( @sum, Tdebit.Amount, G );

[G, iTID] = findgroups( Tcredit(:, 'Week') );
iTID.Totals = splitapply( @sum, Tcredit.Amount, G );

[G, tTID] = findgroups( T(:, 'Week') );
signedAmount = T.Amount .* T.TransactionSign;
tTID.Totals = splitapply( @sum, signedAmount, G );

%% Plotting

% define minor ticks
minorTicks = [datetime( 2016, 1, 1 ),  datetime( 2016, 2, 1 ),  datetime( 2016, 3, 1 ), ...
              datetime( 2016, 4, 1 ),  datetime( 2016, 5, 1 ),  datetime( 2016, 6, 1 ), ...
              datetime( 2016, 7, 1 ),  datetime( 2016, 8, 1 ),  datetime( 2016, 9, 1 ), ...
              datetime( 2016, 10, 1 ), datetime( 2016, 11, 1 ), datetime( 2016, 12, 1 ), ...
              datetime( 2017, 1, 1 ), datetime( 2017, 2, 1 ), datetime( 2017, 3, 1 ), ...
              datetime( 2017, 4, 1 ), datetime( 2017, 5, 1 ), datetime( 2017, 6, 1 ), ...
              datetime( 2017, 7, 1 ), datetime( 2017, 8, 1 ), datetime( 2017, 9, 1 ), ...
              datetime( 2017, 10, 1 ), datetime( 2017, 11, 1 ), datetime( 2017, 12, 1 )];

close all
f1 = figure(1);
eo = plot( eoTID.Week, eoTID.Totals, 'bo-' );
f1.Color = [1 1 1];
a1 = gca;
% a1.XTick = a1.XTick(1:5:end);
% a1.XTickLabelRotation = 45;
movedToBoston = daysact( begin, datetime( 2017, 06, 03 ) );
daysTillNow = daysact( begin, datetime( 'now' ) );
hold on
p1 = patch( [movedToBoston movedToBoston daysTillNow daysTillNow], ...
            [10 max( a1.YLim )-1 max( a1.YLim )-1 10], [0.9 0.9 0.9] );
p1.EdgeAlpha = 0;
a1.Children = flipud( a1.Children );
a1.XAxis.MinorTick = 'on';
a1.XAxis.MinorTickValues = minorTicks;
title('Eating Out by Week')

f2 = figure(2);
f2.Color = [1 1 1];
a2 = gca;
plot( gTID.Week, gTID.Totals, 'bo-' )
hold( a2, 'on' )
p2 = patch( a2, [movedToBoston movedToBoston daysTillNow daysTillNow], ...
            [10 max( a2.YLim )-1 max( a2.YLim )-1 10], [0.9 0.9 0.9] );
p2.EdgeAlpha = 0;
a2.Children = flipud( a2.Children );
% a2.XTick = a2.XTick(1:5:end);
% a2.XTickLabelRotation = 45;
a2.XAxis.MinorTick = 'on';
a2.XAxis.MinorTickValues = minorTicks;
title('Grocery Purchases by Week')

f3 = figure(3);
f3.Color = [1 1 1];
a3 = gca;
plot( eTID.Week, eTID.Totals, 'bo-' );
hold( a3, 'on' )
p3 = patch( a3, [movedToBoston movedToBoston daysTillNow daysTillNow], ...
            [100 max( a3.YLim )-100 max( a3.YLim )-100 100], [0.9 0.9 0.9] );
p3.EdgeAlpha = 0;
a3.Children = flipud( a3.Children );
% a3.XTick = a3.XTick(1:5:end);
% a3.XTickLabelRotation = 45;
a3.XAxis.MinorTick = 'on';
a3.XAxis.MinorTickValues = minorTicks;
ytickformat( a3, 'usd' )
title( 'all expenses' )

f4 = figure(4);
f4.Color = [1 1 1];
a4 = gca;
plot( eTID.Week, cumsum( eTID.Totals ), 'r-' )
hold( a4, 'on' )
plot( iTID.Week, cumsum( iTID.Totals ), 'b-' )

f5 = figure(5);
f5.Color = [1 1 1];
a5 = gca;
plot( tTID.Week, cumsum( tTID.Totals ), 'b-' )
hold( a5, 'on' )
zero = plot( [begin, datetime( 'yesterday' )], [0 0], 'r:' );
zero.LineWidth = 2;
