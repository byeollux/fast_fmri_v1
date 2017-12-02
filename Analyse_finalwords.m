question_type = {'Valence','Self','Time','Vividness','Safe & Threat'};

a = survey.words([2:41],:);
word = a(:);
rating = cell(160,4);
x = [1:160];

for i=1:4
    for j = 1:40
        rating{(i-1)*40+j,2} = survey.dat{j,i}{1,1}.rating;
        rating{(i-1)*40+j,3} = survey.dat{j,i}{1,2}.rating;
        rating{(i-1)*40+j,4} = survey.dat{j,i}{1,3}.rating;
        rating{(i-1)*40+j,5} = survey.dat{j,i}{1,4}.rating;
        rating{(i-1)*40+j,6} = survey.dat{j,i}{1,5}.rating;
    end
end

for i=1:160
    rating{i,1} = word{i,1};
end

ratingd = zeros(160,5);

for i=1:4
    for j = 1:40
        ratingd((i-1)*40+j,1) = survey.dat{j,i}{1,1}.rating;
        ratingd((i-1)*40+j,2) = survey.dat{j,i}{1,2}.rating;
        ratingd((i-1)*40+j,3) = survey.dat{j,i}{1,3}.rating;
        ratingd((i-1)*40+j,4) = survey.dat{j,i}{1,4}.rating;
        ratingd((i-1)*40+j,5) = survey.dat{j,i}{1,5}.rating;
%         ratingd((i-1)*40+j,6) = sum(ratingd((i-1)*40+j,:));        
    end
end

%% Self-relevance & valence
figure;
text(ratingd(:,2), ratingd(:,1), word);
ylabel(question_type{1});
xlabel(question_type{2});
set(gca, 'xlim', [-0.05 1.1], 'ylim', [-1.1 1.1]);

%% line graph among the time
figure('position',[1,1,1200, 600]);
for i=1:5
    if mod(i,2)
        m = mean(ratingd(:,i));
        s = std(ratingd(:,i));
        subplot(2,3,(i+1)/2);
        plot(x,ratingd(:,i),'-b',x,m*ones(1,160),'-r');
        title(question_type{i});
        set(gca, 'xlim', [0 160], 'ylim', [-1.1 1.1]);
        ax = gca;
        lxy = [(ax.XLim(2)-ax.XLim(1))*0.1+ax.XLim(1),ax.YLim(2)*0.8];
        text(lxy(1),lxy(2), sprintf('m = %g',m),'FontSize',8);
        text(lxy(1),lxy(2)*0.8, sprintf('S.D = %g',s),'FontSize',8);

    else
        m = mean(ratingd(:,i));
        s = std(ratingd(:,i));
        subplot(2,3,3+i/2);
        plot(x,ratingd(:,i),'-b',x,m*ones(1,160),'-r');
        title(question_type{i});
        set(gca, 'xlim', [0 160], 'ylim', [-0.1 1.1]);
        ax = gca;
        lxy = [(ax.XLim(2)-ax.XLim(1))*0.1+ax.XLim(1),ax.YLim(2)*0.8];
        text(lxy(1),lxy(2), sprintf('m = %g',m),'FontSize',8);
        text(lxy(1),lxy(2)*0.9, sprintf('S.D = %g',s),'FontSize',8);

        
    end
end

%% Histogram
figure('position',[1,1,1200, 600]);
for i=1:5
    if mod(i,2)
        m = mean(ratingd(:,i));
        s = std(ratingd(:,i));
        subplot(2,3,(i+1)/2);   
        histogram(ratingd(:,i),20,'FaceColor','b');
        title(question_type{i});
        set(gca, 'xlim', [-1 1]);
        ax = gca;
        lxy = [(ax.XLim(2)-ax.XLim(1))*0.1+ax.XLim(1),ax.YLim(2)*0.8];
        text(lxy(1),lxy(2), sprintf('m = %g',m),'FontSize',8);
        text(lxy(1),lxy(2)*0.9, sprintf('S.D = %g',s),'FontSize',8);
    else
        m = mean(ratingd(:,i));
        s = std(ratingd(:,i));
        subplot(2,3,i/2+3 );
        histogram(ratingd(:,i),20,'FaceColor','b');
        title(question_type{i});
        set(gca, 'xlim', [0 1]);
        ax = gca;
        lxy = [(ax.XLim(2)-ax.XLim(1))*0.1+ax.XLim(1),ax.YLim(2)*0.8];
        text(lxy(1),lxy(2), sprintf('m = %g',m),'FontSize',8);
        text(lxy(1),lxy(2)*0.9, sprintf('S.D = %g',s),'FontSize',8);
    end
end

%%
figure;
scatter(ratingd(:,1),ratingd(:,5));
ylabel(question_type{5});
xlabel(question_type{1});

corr(ratingd(:,1), ratingd(:,5))


%% Valence _ Self 2D
figure;
plot(ratingd(:,2), ratingd(:,1))


%%
[~, idself] = sort(ratingd(:,2));   %오름차순

% 내림차순
word2 = flipud(word(idself));
ratingd2 = flipud(ratingd(idself,:));
m = max(ratingd2(:,2));

for k = 1:160
    if ratingd2(k,2) == m
        cut = k;
    end
end

% for j = 1:cut
%     if ratingd2(j,1) == median(ratingd2(1:cut,1))
%         vmed = j;
%     end
% end

for j = 1:cut
    if ratingd2(j,1) == max(ratingd2(1:cut,1))
        vmax = j;
    end
end

for j = 1:cut
    if ratingd2(j,1) == min(ratingd2(1:cut,1))
        vmin = j;
    end
end

clear i;
clear j;
clear k;
clear m;
word2(vmax,1)
% word2(vmed,1)
word2(vmin,1)

%%