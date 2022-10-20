clc;
clear;
path('E:\Softwares\Salar\SVR\libsvm-3.22\matlab',path)

filename='E:\Softwares\Salar\SVR\train.xls';
nn_inp_train=xlsread(filename,'Train','A:H')';
nn_trg_train=xlsread(filename,'Train','I:I')';
file2='E:\Softwares\Salar\SVR\test.xls';
nn_inp_test=xlsread(file2,'Test','A:H')';
nn_trg_test=xlsread(file2,'Test','I:I')';

[inp_train,inS]=mapminmax(nn_inp_train,0,1);
[trg_train,outS]=mapminmax(nn_trg_train,0,1);
inp_test=mapminmax('apply',nn_inp_test,inS);
trg_test=mapminmax('apply',nn_trg_test,outS);

X_axis=20*rands(1,4);
Y_axis=20*rands(1,4);

maxgen=30;  
sizepop=10; 

for i=1:sizepop

X(i,:)=X_axis+2*rand()-1;
Y(i,:)=Y_axis+2*rand()-1;

D(i,1)=(X(i,1)^2+Y(i,1)^2)^0.5;
D(i,2)=(X(i,2)^2+Y(i,2)^2)^0.5;
D(i,3)=(X(i,3)^2+Y(i,3)^2)^0.5;
D(i,4)=(X(i,4)^2+Y(i,4)^2)^0.5;

S(i,1)=1/D(i,1);
S(i,2)=1/D(i,2);
S(i,3)=1/D(i,3);
S(i,4)=1/D(i,4);

g=0;
C=20*S(i,1);
e=S(i,2);
ga=S(i,3);
t=S(i,4);

  param = ['-q -s 3 -t 3', ' -c ', num2str(C), ' -g ', num2str(ga), ' -p ', num2str(e), ' -e ', num2str(t)];
  model = svmtrain(trg_train', inp_train', param);
  [predict_label, ~, ~] = svmpredict(trg_test', inp_test', model);
%    pred=mapminmax('reverse',predict_label',outS);
%        Smell(i)=(mse(pred,nn_trg_test))^0.5;
  Smell(i)=mse(predict_label,trg_test');
end

[bestSmell,bestindex]=min(Smell);

X_axis=X(bestindex,:);
Y_axis=Y(bestindex,:);
bestS=S(bestindex,:);
Smellbest=bestSmell;

for gen=1:maxgen

  for i=1:sizepop
  
  g=0;
  X(i,:)=X_axis+2*rand()-1;
  Y(i,:)=Y_axis+2*rand()-1;
  
  D(i,1)=(X(i,1)^2+Y(i,1)^2)^0.5;
  D(i,2)=(X(i,2)^2+Y(i,2)^2)^0.5;
  D(i,3)=(X(i,3)^2+Y(i,3)^2)^0.5;
  D(i,4)=(X(i,4)^2+Y(i,4)^2)^0.5;
  
  S(i,1)=1/D(i,1);
  S(i,2)=1/D(i,2);
  S(i,3)=1/D(i,3);
  S(i,4)=1/D(i,4);
 
  C=20*S(i,1);
  e=S(i,2);
  ga=S(i,3);
  t=S(i,4);

  param = ['-q -s 3 -t 3', ' -c ', num2str(C), ' -g ', num2str(ga), ' -p ', num2str(e), ' -e ', num2str(t)];
  model = svmtrain(trg_train', inp_train', param);
  [predict_label, ~, ~] = svmpredict(trg_test', inp_test', model);
%    pred=mapminmax('reverse',predict_label',outS);
%        Smell(i)=(mse(pred,nn_trg_test))^0.5;
  Smell(i)=mse(predict_label,trg_test');
end
 
  [bestSmell,bestindex]=min(Smell);
  
   if bestSmell<Smellbest
         X_axis=X(bestindex,:);
         Y_axis=Y(bestindex,:);
         bestS=S(bestindex,:);
         Smellbest=bestSmell;
         Cbest=20*S(bestindex,1);
         ebest=S(bestindex,2);
         gabest=S(bestindex,3);
         tbest=S(bestindex,4);
   end
  
   yy(gen)=Smellbest; 
   Xbest(gen,:)=X_axis;
   Ybest(gen,:)=Y_axis;
end

figure(1)
plot(yy)
title('Optimization process','fontsize',12)
xlabel('Iteration Number','fontsize',12);ylabel('MSE','fontsize',12);

% figure(2)
% plot(Xbest(:,1),Ybest(:,1),'b.');
% title('Fruit fly flying route','fontsize',14)
% xlabel('X-axis','fontsize',12);ylabel('Y-axis','fontsize',12);


param = ['-q -s 3 -t 3', ' -c ', num2str(Cbest), ' -g ', num2str(gabest), ' -p ', num2str(ebest), ' -e ', num2str(tbest)];
model = svmtrain(trg_train', inp_train', param);
[predict_label, accuracy, dec_values] = svmpredict(trg_test', inp_test', model);
out_test=mapminmax('reverse',predict_label',outS);
R=corr(out_test',nn_trg_test')
MAE=mae(out_test,nn_trg_test)
RMSE=(mse(out_test,nn_trg_test))^0.5

% xlswrite('E:\Softwares\Salar\SVR\prediction',out_test','1','A2');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',Cbest,'1','O12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',gabest,'1','P12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',ebest,'1','Q12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',tbest,'1','R12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',R,'1','S12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',RMSE','1','T12');
% xlswrite('C:\Users\Salar\Desktop\radiation\prediction',MAE','1','U12');