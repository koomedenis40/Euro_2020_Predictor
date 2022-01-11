%% Football Prediction Code 

%To run this code, it is necessary to have the following functions
%downloaded:

% Q.m
% R.m
% ExistenceCheck.m
% UniquenessCheck.m
% ResultProbs.m

%It is also necessary to set the value of the following variables (which
%can be done in the below four sections):

%path_to_results_csv
%KnockoutTiebreaker
%path_to_predictions_csv
%Start_Date
%End_Date
%RelevantTeams

%% Results Data CSV

%The results CSV should have the following format

%    DATE    %  HOME TEAM  %  AWAY TEAM  %  HOME SCORE  %  AWAY SCORE  %
% 01-01-1900 %   Bolton    %  Liverpool  %      7       %      0       %

path_to_results_csv = 'results.csv';

%% Results To Predict CSV

%The predictions CSV should have the following forma
%  HOME TEAM  %  AWAY TEAM  %  MATCH TYPE  %
%   England   %   Croatia   %    Group     %
%   England   %    Italy    %   Knockout   %

%Note that the keyword "Group" encompasses all matches that will end after
%90 minutes, and may end in a draw. The keyword "Knockout" encompasses
%matches that cannot end in a draw

KnockoutTiebreaker = 1;

%Use a 1 for extra time + penalties and a 2 for penalties only. Other
%formats may be added by editing the "Calculating Predictions" section.

path_to_predictions_csv = 'PredictionsToMake.csv';
%% Parameters

%Note that the function datetime(a,b,c) gives a date with the year being a,
%the month being b and the day being c

%Select the start and end dates for the dataset. Only results between these
%dates will be considered
Start_Date = datetime(2018,7,16); 
End_Date = datetime(2021,5,28);


%% Select Relevant Teams

%Teams in model - these are all the teams that will be given an offensive
%and defensive strength (all other teams in the results CSV will be
%ignored, as will matches containing only one relevant team)

%Note that for the Euro 2020 predictions, results in games containing San
%Marino were ignored.
RelevantTeams = categorical({
    'Albania'
    'Andorra'
    'Armenia'
    'Austria'
    'Azerbaijan'
    'Belarus'
    'Belgium'
    'Bosnia and Herzegovina'
    'Bulgaria'
    'Croatia'
    'Cyprus'
    'Czech Republic'
    'Denmark'
    'England'
    'Estonia'
    'Faroe Islands'
    'Finland'
    'France'
    'Georgia'
    'Germany'
    'Gibraltar'
    'Greece'
    'Hungary'
    'Iceland'
    'Republic of Ireland'
    'Israel'
    'Italy'
    'Kazakhstan'
    'Kosovo'
    'Latvia'
    'Liechtenstein'
    'Lithuania'
    'Luxembourg'
    'Malta'
    'Moldova'
    'Montenegro'
    'Netherlands'
    'North Macedonia'
    'Northern Ireland'
    'Norway'
    'Poland'
    'Portugal'
    'Romania'
    'Russia'
    'Scotland'
    'Serbia'
    'Slovakia'
    'Slovenia'
    'Spain'
    'Sweden'
    'Switzerland'
    'Turkey'
    'Ukraine'
    'Wales'});

%% Collect Data

% Import Data from Results CSV
opts = detectImportOptions(path_to_results_csv);
results = readtable(path_to_results_csv,opts);
Dates = results.(1);
HomeTeams = results.(2);
AwayTeams = results.(3);
HomeSc = results.(4);
AwaySc = results.(5);


%Find Start Date and End Date in the data
n = 1;
DateLength = length(Dates);
ForceEnd = 0;
while Dates(n) + ForceEnd < Start_Date
    %Prevent n becoming larger than number of dates:
    if n == DateLength
        ForceEnd = Start_Date;
        disp('Error: Start Date Later Than All Games In Dataset')
    end
    n = n+1;
end
Startn = n;
if ForceEnd == 0
    %Prevent n becoming larger than number of dates:
    while Dates(n) + ForceEnd < End_Date
        if n == DateLength
            ForceEnd = End_Date;
        end
        n = n +1;
    end
        
end
Endn = n;


%Extract Relevant Data
TeamNumber = length(RelevantTeams);
%Matrix showing games played between each team:
GamesPlayed = zeros(TeamNumber,TeamNumber);
%Matrix where (i,j) entry is goals scored by team i against team j across
%all matches:
GoalsScoredMatrix  = zeros(TeamNumber,TeamNumber);
%Total goals scored by each team:
GoalsScored  = zeros(TeamNumber,1);
%Total goals conceded by each team
GoalsConc  = zeros(TeamNumber,1);
Indices = 1:TeamNumber;
n = Startn;
while n < Endn
    %Checking teams are relevant
    if sum((RelevantTeams == HomeTeams(n)) + (RelevantTeams == AwayTeams(n))) < 2
        n = n+1;
    else
        %Finding indices of teams
        Index1 = Indices(RelevantTeams == HomeTeams(n));
        Index2 = Indices(RelevantTeams == AwayTeams(n));
        %Updating matrices
        GamesPlayed(Index1,Index2) = GamesPlayed(Index1,Index2) + 1;
        GamesPlayed(Index2,Index1) = GamesPlayed(Index2,Index1) + 1;
        GoalsScoredMatrix(Index1,Index2)= GoalsScoredMatrix(Index1,Index2) + HomeSc(n);
        GoalsScoredMatrix(Index2,Index1)= GoalsScoredMatrix(Index2,Index1) + AwaySc(n);
        GoalsScored(Index1) = GoalsScored(Index1) + HomeSc(n);
        GoalsScored(Index2) = GoalsScored(Index2) + AwaySc(n);
        GoalsConc(Index1) = GoalsConc(Index1) + AwaySc(n);
        GoalsConc(Index2) = GoalsConc(Index2) + HomeSc(n);
        n = n + 1;
    end
end

%% Create Poisson Model

Checkcount = 1;
P = GamesPlayed;
GS = GoalsScoredMatrix;
%Checking that solutions to the maximum likelihood equations exist:
if categorical({ExistenceCheck(GS,P)})== categorical({'Existence'})
    %Checking that solutions to the maximum likelihood equations are
    %unique:
    if categorical({UniquenessCheck(GS,P)}) == categorical({'Unique'})
        f = GoalsScored;
        c = GoalsConc;
        %Creating equations (Objective(x) = 0 iff x is a solution)
        Objective = @(x) abs(([P zeros(54,54); zeros(54,54) P]*x).*[x(55:108);x(1:54)] - ([f;c]));
        %Initial estimates
        Values = [f/sum(f);c/sum(c)];
        %Solving equations
        while sum(Objective(Values).^2) > 0.001
            Values = fsolve(Objective,Values);
            disp(sum(Objective(Values).^2))
            Attacks = Values(55:108);
            Defences = Values(1:54);
        end
    else
        disp('Error: Solutions are not unique - more data is needed')
        
    end
else
    disp('Error: Solutions do not exist - more data is needed')
end

%% Calculate Predictions
%Extracting data
opts = detectImportOptions(path_to_predictions_csv);
preds = readtable(path_to_predictions_csv,opts);
Home_Team = preds.(1);
Away_Team = preds.(2);
Match_Type = preds.(3);

%Preallocating
Home_Win_Prob = zeros(length(Home_Team),1);
Draw_Prob = zeros(length(Home_Team),1);
Away_Win_Prob = zeros(length(Home_Team),1);

Indices = 1:TeamNumber;
for n = 1:length(Home_Team)
    %Checking that match is between relevant teams
    if sum((RelevantTeams == Home_Team(n)) + (RelevantTeams == Away_Team(n))) < 2
        Home_Win_Prob(n) = -1;
        Draw_Prob(n) = -1;
        Away_Win_Prob(n) = -1;
        disp(['Error in Predicting Match Number ', num2str(n)])
    else
        %Finding indices of teams
        Index1 = Indices(RelevantTeams == Home_Team(n));
        Index2 = Indices(RelevantTeams == Away_Team(n));
        %Predicting Result After 90 minutes
        [HomeWin,Draw,AwayWin] = ResultProbs(Attacks(Index1),Defences(Index1),Attacks(Index2),Defences(Index2));
        if categorical({'Knockout'}) == Match_Type(n)
            %Accounting for extra time
            if KnockoutTiebreaker == 1
                [HomeWinET,DrawET,AwayWinET] = ResultProbs(Attacks(Index1)/3,Defences(Index1)/3,Attacks(Index2)/3,Defences(Index2)/3);
                HomeWin = HomeWin + Draw*HomeWinET;
                AwayWin = AwayWin + Draw*AwayWinET;
                Draw = Draw*DrawET;
            end
            %Accounting for penalties
            HomeWin = HomeWin + 0.5*Draw;
            AwayWin = AwayWin + 0.5*Draw;
            Draw = 0;
        end
        Home_Win_Prob(n) = HomeWin;
        Away_Win_Prob(n) = AwayWin;
        Draw_Prob(n) = Draw;
    end
end

Output = table(Home_Team,Away_Team,Match_Type,Home_Win_Prob,Draw_Prob,Away_Win_Prob);
writetable(Output,'PredictionsMade.csv')