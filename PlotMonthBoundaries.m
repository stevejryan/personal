function PlotMonthBoundaries( axisHandle )

WeekBoundaries = [ ...
                  5 + 1/7 ...
                  ];
                
numWeeks = numel( WeekBoundaries );
yDiff = diff( axisHandle.YLim );
yMin = axisHandle.YLim(1) + 0.1*yDiff;
yMax = axisHandle.YLim(2) - 0.1*yDiff;

plot( axisHandle, [WeekBoundaries, WeekBoundaries], [yMin yMax], 'r:' )
