function h_Bndry_Flux
global QMT QMB SAVE hh NN KT

QMT(KT)=SAVE(2,1,1)-SAVE(2,2,1)*hh(NN-1)-SAVE(2,3,1)*hh(NN);
QMB(KT)=-SAVE(1,1,1)+SAVE(1,2,1)*hh(1)+SAVE(1,3,1)*hh(2);

