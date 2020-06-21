%% Load combined Mendel pedigree (Ped8c) and Hapmap phased genotypes
%  Hapmap JPT+CHB chr22
clear;
Ped8c = csvread('Ped8c_geno_chr22_jpt+chb.unr_matlab.csv')';

path(path,'../Functions');

%% Experiment parameters
% Number of replicates
nReps = 1;
% Window size
w = 100;
% Validation set parameters
vp = 0.1;
nval = floor(vp*numel(Ped8c));
seed = 12345;
stream = RandStream('mt19937ar','Seed',seed);
RandStream.setDefaultStream(stream);
times = zeros(nReps,1);
errors = zeros(nval,nReps);

%% Main loop
for iRep = 1:nReps
    fprintf('==========================\n');    
    fprintf('Beginning replicate %d\n', iRep);

    % Masked training set
    fprintf('Masking data set.\n');
    vset = randsample(1:numel(Ped8c), nval);
    X = Ped8c;
    X(vset) = NaN;
    [vix, vjx] = find(isnan(X));
    % Save coordinates in standard row/column format. Matlab stores
    % matrices in column major format.
    vc = [vjx, vix];
    filename = sprintf('Ped8c_geno_chr22_jpt+chb.unr_validation_coordinates_replicate_%d.csv', iRep);
    dlmwrite(filename, uint64(vc));
    filename = 'Ped8c_masked_matlab';
    save(filename, 'X', '-ascii');
    V = Ped8c;

    % Impute
    fprintf('Beginning imputation.\n');
    tic;
    [Z, stats] = Mendel_IMPUTE(filename, w);
    times(iRep) = toc;
    
    % Count errors
    miss = zeros(nval,1);
    disc = zeros(nval,2);
    for j = 1:nval
        m = round(max(0,min(2,Z(vset(j)))));
        v = V(vset(j));
        miss(j) = (m ~= v);
        disc(j,1) = m;
        disc(j,2) = v;
    end

    errors(:,iRep) = miss;
    
    fprintf('==========================\n');
    fprintf('Summary:\n');
    fprintf('Completed replicate %d\n', iRep);
    fprintf('Error rate: %g\n', sum(miss)/nval);
    fprintf('CPU time (sec): %g\n\n', times(iRep));
    
end

save('matrix_completion_exp.mat');