function Output = ExistenceCheck(GoalsScored,GamesPlayed)
    OvLength = length(GoalsScored);
    K = 1:OvLength;
    KLength = length(K);
    Existence = 1;
    while KLength*Existence > 0
        S = KLength;
        Check = 0;
        while Check == 0
            if length(S) == OvLength
                K(KLength) = [];
                KLength = KLength - 1;
                Check = 1;
            else
                Queue = Q(S,GamesPlayed);
                Arr = R(Queue,GoalsScored);
                UniqueVals = unique([S,Arr]);
                if length(UniqueVals) == length(S)
                    if length(UniqueVals) > length(Arr)
                        K(KLength) = [];
                        KLength = KLength - 1;
                        Check = 1;
                    else
                        QueueNew = Q(setdiff(1:OvLength,S),GamesPlayed);
                        Intersection = intersect(Queue,QueueNew);
                        NewArr = R(Intersection,GoalsScored);
                        if isempty(NewArr) > 0
                            Check = 1;
                            Existence = 0;
                        else
                            K(KLength) = [];
                            KLength = KLength - 1;
                            Check = 1;
                        end
                    end
                else
                    S = UniqueVals;
                end
            end
        end
    end
    if Existence == 0
        Output = 'No Existence';
    else
        Output = 'Existence';
    end
end