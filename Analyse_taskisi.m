for i=1:4
taskdata.dat{1,i}.isi_starttime -taskdata.dat{1,i}.trial_starttime %wordT
taskdata.dat{1,i+1}.trial_starttime - taskdata.dat{1,i}.isi_starttime %isi
end


j=5;
taskdata.dat{1,j}.isi_starttime - taskdata.dat{1,j}.trial_starttime %wordT
taskdata.dat{1,j}.emotion_starttime - taskdata.dat{1,j}.isi_starttime % isi
taskdata.dat{1,j}.iti_starttime - taskdata.dat{1,j}.emotion_starttime % emotion rating +0.3
taskdata.dat{1,j+1}.trial_starttime - taskdata.dat{1,j}.emotion_starttime %rT+iti

j=20;
taskdata.dat{1,j}.isi_starttime - taskdata.dat{1,j}.trial_starttime %wordT
taskdata.dat{1,j}.concent_starttime - taskdata.dat{1,j}.isi_starttime %isi
taskdata.dat{1,j+1}.trial_starttime - taskdata.dat{1,j}.concent_starttime %cqT+iti

taskdata.dat{1,40}.trial_starttime-taskdata.dat{1,1}.trial_starttime

j=40;
taskdata.dat{1,j}.isi_starttime - taskdata.dat{1,j}.trial_starttime %wordT
taskdata.dat{1,j}.emotion_starttime - taskdata.dat{1,j}.isi_starttime % isi =5
taskdata.dat{1,j}.concent_starttime - taskdata.dat{1,j}.emotion_starttime %rT+iti

