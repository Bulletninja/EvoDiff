function [mejorindividuo, mejorval, nfeval, difflb, diffub, mejores] = EvoDif_Programa(Prob,NP,generaciones,f, selectivo)
%MinimizaciÃ³n con EvoluciÃ³n diferencial
%Salidas
%--------------------
%bestmem	: mejor soluciÃ³n
%nfeval		: nÃºmero de evaluaciÃ³n de la funciÃ³n

%Entradas
%--------------------
%NP		: NÃºmero de individuos en la poblaciÃ³n
%M		: Número de máquinas (y operaciones por trabajo)
%N		: Número de trabajos
%D		: M*N
%J      : Matriz de trabajos
%generaciones	: mÃ¡ximo nÃºmero de generaciones
J=Prob.P;
[M,N]=size(J);
count=(1:(M*N))';
%vals=zeros(1,generaciones);
mejores=zeros(1,generaciones);

generacion=1;
%-----Inicializar población------------------------------ 
poblacion = zeros(M*N, NP);
%Cada columna de la población es una matriz de trabajos
for i=1:NP
	poblacion(:,i)=permutarTrabajos(J);
end
poblacion_vieja		= zeros(size(poblacion));
val                 = zeros(NP,1);
mejorindividuo		= zeros(M*N,1);
mejorinditeracion	= zeros(M*N,1);
nfeval              = 0;

%----Evaluación------------------------------------------
imejor	= 1; %Ã­ndice del mejor
val(1)	= feval(f,reshape(poblacion(:,imejor),M,N));%scheduleCost(poblacion(:,imejor),M,N);
%mejorval= val(1);
nfeval	= nfeval+1;
for i=2:NP
	val(i)	= feval(f,reshape(poblacion(:,i),M,N));%scheduleCost(poblacion(:,i),M,N);
	nfeval	= nfeval+1;
end
[val,SortIndex]=sort(val);
poblacion=poblacion(:,SortIndex);
mejorval= val(1);
mejorinditeracion=poblacion(:,imejor);
mejorvaliteracion=mejorval;

mejorindividuo	= mejorinditeracion;
%----MinimizaciÃ³n---------------------------------------
%----Matrices de poblaciones---------------------------
mp1	=	zeros(M*N,NP);
mp2	=	zeros(M*N,NP);

mi	=	zeros(M*N,NP);%Matriz de mejores individuos
ui	=	zeros(M*N,NP);%Vectores perturbados

rot	=	(0:1:NP-1); %
rt	=	zeros(NP);
a1	=	zeros(NP);
a2	=	zeros(NP);

ind	=	zeros(4);

mid=NP;
if  selectivo
  mid = ceil(0.5*NP);
end
while((generacion < generaciones) && (mejorval>1.e-5))
%if selectivo && (rem(generacion,10)==0)
%    mid=NP;
%end
%else
%    mid=ceil(0.5*NP);
%end
%vals(generacion)=mean(val);
mejores(generacion)=val(1);

  poblacion_vieja = poblacion;
	%"barajar població n
	ind	=	randperm(4);
	a1	=	randperm(NP);
	rt	=	rem(rot+ind(1),NP);
	a2	=	a1(rt+1);
 	rt	=	rem(rot+ind(2),NP);
 	a3	=	a2(rt+1);
 	rt	=	rem(rot+ind(3),NP);
 	a4	=	a3(rt+1);
 	rt	=	rem(rot+ind(4),NP);
 	a5	=	a4(rt+1);
	mp1	=	poblacion_vieja(:,a1);
	mp2	=	poblacion_vieja(:,a2);
 	mp3	=	poblacion_vieja(:,a3);
 	mp4	=	poblacion_vieja(:,a4);
 	mp5	=	poblacion_vieja(:,a5);

    
%-----Elegir la estrategia----------------------
%----------Mutación/Perturbación----------------
    for i=1:mid
        %offsprings
        ui(:,i)=CruzayMutacion2(mp1(:,i),mp2(:,i),M,N);
    end

%-----Elección de vectores de la nueva población---
	for i=1:mid
		val_tmp	=	feval(f,reshape(ui(:,i),M,N));
		nfeval	=	nfeval+1;
		if (val_tmp <= val(i))
			poblacion(:,i)	= ui(:,i);
			val(i)		= val_tmp;
		end
	end
	mejorinditeracion	= mejorindividuo;
%-----Salida---------------------------------------------
 	if (rem(generacion,100)==0)
 		fprintf('Generacion: %d, Mejor: %f, Mediana %f , Promedio %f\n ',generacion,val(1), median(val), mean(val))
    end
    
[val,SortIndex]=sort(val);
poblacion=poblacion(:,SortIndex);
%-----Plot-----------------------------------------------------------
generacion=generacion+1;
end%endwhile (generacion < generaciones)
%vals(generaciones)=mean(vals);
mejores(generaciones)=val(1);

mejorindividuo=reshape(mejorindividuo,M,N);
mejorval=val(1);

difflb=mejorval-Prob.lb;
diffub=mejorval-Prob.ub;
end
