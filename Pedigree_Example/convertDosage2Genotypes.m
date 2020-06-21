%% This script converts the matrix completion output back to genotypes.

load 'matrix_completion_exp.mat';

minor = importdata('alleles_minor.txt');
major = importdata('alleles_major.txt');
nLoci = length(minor);
symbols = cell(nLoci, 3);
for i = 1:nLoci
   symbols{i,1} = sprintf('%s/%s ', major{i}, major{i});
   y = sort([minor(i), major(i)]);
   symbols{i,2} = sprintf('%s/%s ', y{1}, y{2});
   symbols{i,3} = sprintf('%s/%s ', minor{i}, minor{i});
end

%% Map Z into {0,1,2}
X = round(max(0,min(2,Z)));

%% Merge the predictions with the known data entries.
Ped8c = csvread('Ped8c_geno_chr22_jpt+chb.unr_matlab.csv')';
% Copy over known data entries.
Zfinal = Ped8c;
% Fill in imputed values.
Zfinal(vset') = X(vset');

Zsym = cell(size(X));

for i = 1:nLoci
    Zsym(i,:) = symbols(i,Zfinal(i,:)+1);
end

Zfinal = cell2mat(Zsym');
fid = fopen('Ped8c_geno_chr22_jpt+chb.unr_matrix_impute.txt', 'w');
for i = 1:size(Zfinal,1)
    fprintf(fid, repmat('%s',1,size(Zfinal,2)), Zfinal(i,:));
    fprintf(fid, '\n');
end
fclose(fid);