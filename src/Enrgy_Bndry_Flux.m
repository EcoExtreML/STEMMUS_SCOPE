function Enrgy_Bndry_Flux
global QET QEB SAVE TT NN

QET=SAVE(2,1,2)-SAVE(2,2,2)*TT(NN-1)-SAVE(2,3,2)*TT(NN);
QEB=-SAVE(1,1,2)+SAVE(1,2,2)*TT(1)+SAVE(1,3,2)*TT(2);