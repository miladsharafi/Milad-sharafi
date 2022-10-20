clc
clear
close all

path('E:\Softwares\Salar\SVR\libsvm-3.22\matlab',path)

%% Input Data

filename='E:\Softwares\Salar\SVR\train.xls';
nn_inp_train=xlsread(filename,'Train','A:H')';
nn_trg_train=xlsread(filename,'Train','I:I')';
file2='E:\Softwares\Salar\SVR\test.xls';
nn_inp_test=xlsread(file2,'Test','A:H')';
nn_trg_test=xlsread(file2,'Test','I:I')';

[inp_train,inS]=mapminmax(nn_inp_train,-1,1);
[trg_train,outS]=mapminmax(nn_trg_train,-1,1);
inp_test=mapminmax('apply',nn_inp_test,inS);
trg_test=mapminmax('apply',nn_trg_test,outS);

%% Parameters Definiterion
% [C Gamma Epsilon]
lb= [0.9 0.01 0.001];
ub= [1.5 0.5 0.01];


maxiter=20;          % Maximum Number of iterations

npop=5;              % Number of Fireflies


L=1;
gamma=1./sqrt(L);            % Light Absorption Coefficient

beta0=2;                     % Attraction Coefficient Base Value

alpha=0.02;                   % Mutation Coefficient

alpha_RF=0.95;                %Radius Reduction Factor



%% Create Random Pop

for i=1:npop
    pop(i,:)=unifrnd(lb,ub);
    param = ['-q -s 3 -t 2', ' -c ', num2str(pop(i,1)), ' -g ', num2str(pop(i,2)), ' -p ', num2str(pop(i,3))];
    model = svmtrain(trg_train', inp_train', param);
    [predict_label, ~, ~] = svmpredict(trg_test', inp_test', model);
    
    er(i)=(mse(predict_label,trg_test'));
end

%% Main Loop

BEST=zeros(maxiter,1);
MEAN=zeros(maxiter,3);

for iter=1:maxiter
    iter
    
    k=0;
    
    for i=1:npop
        for j=1:npop
            if er(j)<=er(i)
                k=k+1;
                
                rij(i,1)=norm(pop(i,1)-pop(j,1),2);
                rij(i,2)=norm(pop(i,2)-pop(j,2),2);
                rij(i,3)=norm(pop(i,3)-pop(j,3),2);
                
                beta(i,1)=beta0*exp(-gamma*(rij(i,1))^2);
                beta(i,2)=beta0*exp(-gamma*(rij(i,2))^2);
                beta(i,3)=beta0*exp(-gamma*(rij(i,3))^2);
                
                E(i,:)=alpha*(unifrnd(-1,1,1,3).*(ub-lb)); %3 is the number of variables% %-1 va 1 mahdode baraye adade random hastand%
                
                newpop(i,1)=abs(pop(i,1)+beta(i,1)*(pop(j,1)-pop(i,1))+E(i,1));
                newpop(i,2)=abs(pop(i,2)+beta(i,2)*(pop(j,2)-pop(i,2))+E(i,2));
                newpop(i,3)=abs(pop(i,3)+beta(i,3)*(pop(j,3)-pop(i,3))+E(i,3));
                
                
                param = ['-q -s 3 -t 2', ' -c ', num2str(newpop(i,1)), ' -g ', num2str(newpop(i,2)), ' -p ', num2str(newpop(i,3))];
                model = svmtrain(trg_train', inp_train', param);
                [predict_label, ~, ~] = svmpredict(trg_test', inp_test', model);
                
                newer(i)=mse(predict_label,trg_test');
                newer(k)=newer(i);
                newpop(k,:)=newpop(i,:);
                
            end
        end
    end
    pop=[pop;newpop];
    er=[er';newer'];
    er=er';
    [~, ind]=sort(er);
    pop=pop(ind,:);
    er=er(ind);
    pop=pop(1:npop,:);
    er=er(1:npop);
    
    BEST(iter)=er(1);
    MEAN(iter,:)=pop(1,:);
    
    
    
    % Reduction Mutation Coefficient
    alpha=alpha*alpha_RF;
    
end

[~,ind3]=min(BEST);
Answer=MEAN(ind3,:);

%% Results

disp(' ')
disp([ ' BEST solution = '  num2str(Answer)]);
disp([ ' BEST fitness = '  num2str(min(BEST))]);

figure()
plot(BEST,'r','LineWidth',2)
hold on
xlabel(' Iteration ')
ylabel(' MSE ')
title('Firefly Algorithm')

%% Errors

param = ['-q -s 3 -t 2', ' -c ', num2str(Answer(1,1)), ' -g ', num2str(Answer(1,2)), ' -p ', num2str(Answer(1,3))];
model = svmtrain(trg_train', inp_train', param);
[predict_label, ~, ~] = svmpredict(trg_test', inp_test', model);
out_test=mapminmax('reverse',predict_label',outS);
R=corr(out_test',nn_trg_test')
MAE=mae(out_test,nn_trg_test)
RMSE=(mse(out_test,nn_trg_test))^0.5

% param = ['-q -s 3 -t 2', ' -c ', num2str(Answer(1,1)), ' -g ', num2str(Answer(1,2)), ' -p ', num2str(Answer(1,3))];
% model = svmtrain(trg_train', inp_train', param);
% [predict_label, ~, ~] = svmpredict(trg_train', inp_train', model);
% out_test=mapminmax('reverse',predict_label',outS);
% R=corr(out_test',nn_trg_train')
% MAE=mae(out_test,nn_trg_train)
% RMSE=(mse(out_test,nn_trg_train))^0.5

% xlswrite('E:\Softwares\Salar\SVR\prediction',out_test','1','A2');