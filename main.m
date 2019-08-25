clc; clear all;

load DiseaseSimMat;
load DrugDisease;
load DrugSimMat1;
load DrugSimMat2;
load DrugTarget;
load SMat;
load TargetSimMat;


X = {}; % contain binary interaction of drug-disease and drug-target
Au = {};
Av = {};

X{1} = DrugDisease;
X{2} = DrugTarget;
Au{1} = DrugSimMat1;
Au{2} = DrugSimMat2;
Av{1} = DiseaseSimMat;
Av{2} = TargetSimMat;
S = SMat; % mapping matrix for two domain.

rank1 = 90;
rank2 = 70;
w = 1;
yy = X{1};
nfolds = 5;
positiveId = find(X{1});
crossval_id = crossvalind('Kfold',positiveId(:),nfolds);
AUPR = zeros(nfolds,1);

for fold = 1:nfolds
    X{1} = yy;
	PtrainID = positiveId(find(crossval_id~=fold));
	PtestID  = positiveId(find(crossval_id==fold));

    % sample equal amount of negative sample
    negativeID = find(X{1}==0);
	num = numel(negativeID);
    Nidx = randperm(num);
    NtestID = negativeID(Nidx(1:length(PtestID)));

    X{1}(PtestID) = 0; % mask out the test data

    tic
	[U, V, objs] = iDrug(X, w, Au, Av, S, rank1, rank2);
    time =toc;
    
    predX = U{1} * V{1}';
    testScore = [yy(PtestID); yy(NtestID)];
    pred = [predX(PtestID); predX(NtestID)];
    [~, aupr] = auc(testScore(:), pred(:), 1e-6);
    fprintf('The AUPR score of  %d - FOLD:  %d  with running time %f \n', fold, aupr, time);
    AUPR(fold,1) = aupr;

end


auprs = mean(AUPR);
fprintf('The averaqge of AUPR score: %d \n',  auprs);

figure(1)
% check the convergence
plot(objs);
xlabel('Number of Iteration');
ylabel('Objective value');










