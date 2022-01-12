function Output = UniquenessCheck(GoalsScored,GamesPlayed)
OvLength = length(GoalsScored);
f = sum(GoalsScored);
c = sum(GoalsScored');
F = 1:OvLength;
C = 1:OvLength;
F = F(f > 0);
C = C(c > 0);
Stop = 0;
KLength = length(F);
if KLength ==  0
    Output = 'Undetermined';
    Stop = 1;
end
if Stop == 0
    Fp = 1:OvLength;
    Fp = Fp(f == 0);
    FpLength = length(Fp);
    for i = 1:FpLength
        if isempty(intersect(Q(Fp(i),GamesPlayed),C))== 1
            Output = 'Non-unique';
            Stop = 2;
        end
    end
    Cp = 1:OvLength;
    Cp = Cp(c == 0);
    CpLength = length(Cp);
    for i = 1:CpLength
        if isempty(intersect(Q(Cp(i),GamesPlayed),F))== 1
            Output = 'Non-unique';
            Stop = 2;
        end
    end
end
if Stop == 0
    K = F;
    Uniqueness = 1;
    while KLength*Uniqueness >0
        Check = 1;
        S = K(KLength);
        while Check == 1
            
            Sdash = unique([intersect(Q(intersect(Q(S,GamesPlayed),C),GamesPlayed),F),S]);
            if length(Sdash) == length(F)
                Check = 0;
                K(KLength) = [];
                KLength = KLength - 1;
            elseif (length(intersect(S,Sdash)) == length(S)) && (length(S) == length(Sdash))
                Uniqueness = 0;
                Check = 0;
            else
                S = Sdash;
            end
        end
    end
    if Uniqueness == 0
        Output = 'Not Unique';
    else
        Output = 'Unique';
    end
end

    
       
