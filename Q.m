function Output = Q(TeamSet,GamesPlayed)
    TeamNum = length(TeamSet);
    TeamTot = length(GamesPlayed);
    Output = [];
    OutputComplement = 1:TeamTot;
    OutputLength = TeamTot;
    for i = 1:TeamNum
        InputTeam = TeamSet(i);
        TeamTicker = 1;
        while TeamTicker < OutputLength+1
            if GamesPlayed(InputTeam,OutputComplement(TeamTicker)) > 0
                Output = [Output,OutputComplement(TeamTicker)];
                OutputComplement(TeamTicker) = [];
                OutputLength = OutputLength - 1;
            else
                TeamTicker = TeamTicker + 1;
            end
        end
    end
    
                
                
end