a = survey.words([2:41],:);
word = a(:);
rating = cell(160,4);

for i=1:4
    for j = 1:40
        rating{(i-1)*40+j,2} = survey.dat{j,i}{1,1}.rating;
        rating{(i-1)*40+j,3} = survey.dat{j,i}{1,2}.rating;
        rating{(i-1)*40+j,4} = rating{(i-1)*40+j,2}+rating{(i-1)*40+j,3};        
    end
end

for i=1:160
    rating{i,1} = word{i,1};
end
%%
ratingd = zeros(160,3);

for i=1:4
    for j = 1:40
        ratingd((i-1)*40+j,1) = survey.dat{j,i}{1,1}.rating;
        ratingd((i-1)*40+j,2) = survey.dat{j,i}{1,2}.rating;
        ratingd((i-1)*40+j,3) = sum(ratingd((i-1)*40+j,:));        
    end
end

%%
figure;
text(ratingd(:,2), ratingd(:,1), word);
ylabel('valence');
xlabel('self-relevance');
set(gca, 'xlim', [0 1.2], 'ylim', [-1 1.2]);


%%
[~, idself] = sort(ratingd(:,2));   %오름차순

% % lowest valence
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
