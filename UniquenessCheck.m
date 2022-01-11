function Output = UniquenessCheck(GoalsScored,GamesPlayed)
OvLength = length(GoalsScored);
f = sum(GoalsScored);
c = sum(GoalsScored');
F = 1:OvLength;
C = 1:OvLength;
for i = 1:OvLength
    if f(i) == 0
        F(i) = [];
    end
    if c(i) == 0
        C(i) = [];
    end
end
KLength = length(F);
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

    
       
