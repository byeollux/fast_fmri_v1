data = [];
SID = input('Subject ID (number)? ', 's');

savedir = fullfile(pwd, 'data');
data.a = load(fullfile(savedir, ['e_restingdata_sub' SID '.mat']));
data.b = load(fullfile(savedir, ['a_worddata_sub' SID '_sess1.mat']));
data.c = load(fullfile(savedir, ['a_worddata_sub' SID '_sess2.mat']));
data.d = load(fullfile(savedir, ['a_worddata_sub' SID '_sess3.mat']));
data.e = load(fullfile(savedir, ['a_worddata_sub' SID '_sess4.mat']));

XX = data.a.rest.rating;
XX{2,6} = 0;
XX{3,6} = 0;
XX(4:6,:) = data.b.wgdata.rest.rating;
XX(7:9,:) = data.c.wgdata.rest.rating;
XX(10:12,:) = data.d.wgdata.rest.rating;
XX(13:15,:) = data.e.wgdata.rest.rating;
XX(4:3:13,:)=[];

DD = zeros(5,12);
for j = 1:5
    for i = 1:6
        DD(j,i) = XX{2*j,i};
        DD(j,i+6) =  XX{2*j+1,i};
    end
end
        
%%
figure;
x=[1:5];
% plot(x, DD(:,1),'-r',x, DD(:,2),'-m',x, DD(:,3),'-y',x, DD(:,4),'-g',x, DD(:,5),'-b', x, DD(:,6),'k');
hold on
plot(x, DD(:,1),'-o','color',[1 0 0],'LineWidth',2,'markerfacecolor',[1 0 0]);
plot(x, DD(:,2),'-o','color',[1 0.4 0],'LineWidth',2,'markerfacecolor',[1 0.4 0]);
plot(x, DD(:,3),'-o','color',[242/255 203/255 97/255],'LineWidth',2,'markerfacecolor',[242/255 203/255 97/255]);
plot(x, DD(:,4),'-o','color',[152/255 193/255 56/255],'LineWidth',2,'markerfacecolor',[152/255 193/255 56/255]);
plot(x, DD(:,5),'-o','color',[0 130/255 153/255],'LineWidth',2,'markerfacecolor',[0 130/255 153/255]);
plot(x, DD(:,6),'-o','color',[59/255 0 219/255],'LineWidth',2,'markerfacecolor',[59/255 0 219/255]);
xlabel('resting order');
ylabel('rating');
title('resting answers');
legend('Valence','Self','Time','Vividness','Safe & Threat','word related','Location','southwest');



%%
