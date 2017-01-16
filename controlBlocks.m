
%%

% Determine which trials are rewarded and which not.
% NOTE: you should set path to file to be able to call functions
%       isSeqValid.m and getTrialSeq.m from within controlBlocks
cd('/Users/romanhuszar/Desktop/Thesis-materials/myWorkspace/myMATLABCode/rh_bicondCode');

myTrials = {'AX-', 'AY+', 'BY-', 'BY+'};
i = 4;

rew = [];       % rewarded trial types
for x = 1:size(myTrials,2)
    if myTrials{x}(3) == '+'
        rew = [rew x];
    end
end

%%

% Produce all possible unique permutations of blocks of trials

v = kron(1:i, [1,1]);   % make block of 8 trials - each of the 4 trial types is duplicated
A = perms(v);           % get all permutations of trial sequences within one block
A = unique(A, 'rows');  % keep the unique ones


tossRows = [];          % keep track of to-be-tossed rows from A
% visit all rows (trial blocks) of A

for x = 1:size(A,1)       
    
    plusFlag = 0;       % have I encountered a reinforced trial? 
    
    % is first trial reinforced, or not?
    if (A(x,1) == rew(1) || A(x,1) == rew(2))    
        plusFlag = 1; 
    end
    num = 1;        % number of reinforced/nonreinforced trials in a row
    
    % visit all columns (trials) in given row
    for y = 2:size(A, 2)
        % if too many reinforced/nonreinforced trials in a row, toss row
        if num > 1
            tossRows = [tossRows x];      % save indices of rows to toss
            break;
        end
        
        % is current trial reinforced?
        if (A(x,y) == rew(1) || A(x,y) == rew(2)) 
            if plusFlag         % if previous trial reinforced, 
                num = num + 1;  % update num
            else                
                plusFlag = 1;   % else reset flag and num
                num = 1;        
            end
        % current trial is nonreinforced..
        else 
            if plusFlag
                plusFlag = 0;
                num = 1;
            else
                num = num + 1;
            end
        end 
    end
end

% remove undesirable rows
A(tossRows, :) = [];

%%

% Another idea - define what it would take for two row vectors to be
%                sufficiently different, and keep only those seqs whose
%                row vectors are sufficiently different from one another.
%                (We consider 2 sufficiently similar sequences - according
%                to our rule - as equivalent to two identical sequences
%                from rat's perspective.) Sample from these sequences to
%                produce 50 sequences so that identical ones are far
%                enough from one another.
%
% Definition of similarity/distance - edit distance; All the sequences 
% have edit distance at least 4, meaning you need at least 4 operations
% (delete, replace, add) to make one trial sequence into another.

seed = A(20,:);
editCrit = 4;
B = [];
B = [B; seed];
myVec = mat2str(seed);   % convert seed vector to string

% find row vectors at least 'editCrit' edit distance away from seed
for x=1:size(A,1)
    if (EditDistance(myVec, mat2str(A(x,:))) >= editCrit)
        B = [B;A(x,:)];
    end
end

% prune down
pruning = 1;
editCrit = 4;
i = 2;
while(pruning)
    
    myVec = mat2str(B(i,:));
    toss = [];
    for x=(i+1):size(B,1)
        if(EditDistance(myVec, mat2str(B(x,:))) < editCrit)
              toss = [toss x];  % save indices of to-be-tossed rows
        end
    end
    
    B(toss,:)=[]; 
    % are we done pruning?
    if (i==size(B,1) || (i+1)==size(B,1))
        pruning = 0;
    else
        i=i+1;
    end


end



%%

% might be a useful idea to separate out sequences into rewarded and
% unrewarded pools - rewB & unrewB
rewB = [];
unrewB = [];
for x=1:size(B,1)
    if (B(x,1)==rew(1) || B(x,1)==rew(2))
        rewB = [rewB; B(x,:)];
    else
        unrewB = [unrewB; B(x,:)];
    end
end


%%

i = 1; % rewB
j = 1; % unrewB
rng shuffle;
flag = 1;       % 1 is rewarded, 0 is unrewarded
rewB = rewB(randperm(size(rewB,1)),:);
unrewB = unrewB(randperm(size(unrewB,1)),:);
finalSequences=[];

while size(finalSequences,1)<50
    
    x = 1;
    if (flag)
        % add 3 sequences starting with rewarded block
        while x<=3
            if (i == size(rewB,1))
                i = 1;
                rewB = rewB(randperm(size(rewB,1)),:);
            else
                finalSequences=[finalSequences; rewB(i,:)];
                i = i+1;
                x = x+1;
            end
        end
        flag=0;
    else
        % add 2 sequences starting with unrewarded block
        while x<=2
            if (j == size(unrewB,1))
                j = 1;
                unrewB = unrewB(randperm(size(unrewB,1)),:);
            else
                finalSequences=[finalSequences; unrewB(j,:)];
                j = j+1;
                x = x+1;
            end
        end
        flag=1;
    end
    
end

%%

finalSequences = repelem(finalSequences,1,4);

%%
mySequences = load('finalizedSequences.mat');

%%