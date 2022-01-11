function [HomeWin,Draw,AwayWin] = ResultProbs(HomeAttack,HomeDefence,AwayAttack,AwayDefence)
    HomeMean = HomeAttack*AwayDefence;
    AwayMean = AwayAttack*HomeDefence;
    HomeWin = 0;
    Draw = 0;
    AwayWin = 0;
    for i = 0:15
        for j = 0:15
            if i > j
                HomeWin = HomeWin + (exp(-HomeMean)*(HomeMean^i)/(factorial(i)))*(exp(-AwayMean)*(AwayMean^j)/(factorial(j)));
            else
                if i == j
                    Draw = Draw + (exp(-HomeMean)*(HomeMean^i)/(factorial(i)))*(exp(-AwayMean)*(AwayMean^j)/(factorial(j)));
                else
                    AwayWin = AwayWin + (exp(-HomeMean)*(HomeMean^i)/(factorial(i)))*(exp(-AwayMean)*(AwayMean^j)/(factorial(j)));
                end
            end

        end
    end
end