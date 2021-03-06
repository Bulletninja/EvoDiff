function [mejorindividuo, mejorval, nfeval, difflb, diffub, vals] = EvoDif_scheduling(NP,Prob,CR,generaciones)
%Minimización con Evolución diferencial
%Salidas
%--------------------
%bestmem	: mejor solución
%nfeval		: número de evaluación de la función

%Entradas
%--------------------
%NP		: Número de individuos en la población
%M		: N�mero de m�quinas (y operaciones por trabajo)
%N		: N�mero de trabajos
%D		: M*N
%J      : Matriz de trabajos
%generaciones	: máximo número de generaciones
J=Prob.P;
[M,N]=size(J);
count=(1:(M*N))';
%-----Inicializar población------------------------------ 
poblacion = zeros(M*N, NP);
%Cada columna de la poblaci�n es una matriz de trabajos
for i=1:NP
	poblacion(:,i)=permutarTrabajos(J(:),M,N,orden);
end
poblacion_vieja		= zeros(size(poblacion));
val                 = zeros(NP,1);
mejorindividuo		= zeros(M*N,1);
mejorinditeracion	= zeros(M*N,1);
nfeval			=0;

%----Evaluación------------------------------------------
imejor	= 1; %índice del mejor
val(1)	= Makespan(poblacion(:,imejor),M,N);
mejorval= val(1);
nfeval	= nfeval+1;
for i=2:NP
	val(i)	= Makespan(poblacion(:,i),M,N);
	nfeval	= nfeval+1;
	if (val(i)<mejorval)
		imejor	= i;
		mejorval= val(i);
	end
end
mejorinditeracion=poblacion(:,imejor);
mejorvaliteracion=mejorval;

mejorindividuo	= mejorinditeracion;
%----Minimización---------------------------------------
%----Matrices de poblaciones---------------------------
mp1	=	zeros(M*N,NP);
mp2	=	zeros(M*N,NP);
% mp3	=	zeros(M*N,NP);
% mp4	=	zeros(M*N,NP);
% mp5	=	zeros(M*N,NP);
mi	=	zeros(M*N,NP);%Matriz de mejores individuos
ui	=	zeros(M*N,NP);%Vectores perturbados
% mui	=	zeros(NP,D);%"máscara" para la cruza
% mpo	=	zeros(NP,D);%"máscara" para la cruza
rot	=	(0:1:NP-1); %
rt	=	zeros(NP);
a1	=	zeros(NP);
a2	=	zeros(NP);
% a3	=	zeros(NP);
% a4	=	zeros(NP);
% a5	=	zeros(NP);
ind	=	zeros(4);

generacion=1;

while((generacion < generaciones))% && (mejorval>1.e-5))
%    generacion
	%poblacion_vieja = poblacion;
	%"barajar" población
	%ind	=	randperm(4);
%	a1	=	randperm(NP);
%	rt	=	rem(rot+ind(1),NP);
%	a2	=	a1(rt+1);
% 	rt	=	rem(rot+ind(2),NP);
% 	a3	=	a2(rt+1);
% 	rt	=	rem(rot+ind(3),NP);
% 	a4	=	a3(rt+1);
% 	rt	=	rem(rot+ind(4),NP);
% 	a5	=	a4(rt+1);
%	mp1	=	poblacion_vieja(:,a1);
%	mp2	=	poblacion_vieja(:,a2);
% 	mp3	=	poblacion_vieja(:,a3);
% 	mp4	=	poblacion_vieja(:,a4);
% 	mp5	=	poblacion_vieja(:,a5);
    for i=1:NP
        mp1(:,i)=permutarTrabajos(J,M,N,orden);
        mp2(:,i)=permutarTrabajos(J,M,N,orden);
    end
	for i=1:NP
		mi(:,i)=mejorinditeracion;
	end

	%mui	=	ran d(NP,D) < CR;%"Máscara" de los perturbados
	%mpv	=	mui < 0.5;	%ídem población vieja
    
%-----Elegir la estrategia----------------------
%----------Mutación/Perturbación----------------
    for i=1:NP
        %offsprings
        ui(:,i)=CruzayMutacion(mp1(:,i),mp2(:,i),M,N,NP,CR,orden);
    end
% 	if	(estrategia == 1)	% DE/best/1
% 		ui = mi+F*(mp1-mp2); 
% 	elseif	(estrategia == 2)	% DE/rand/1
% 		ui = mp3 + F*(mp1-mp2);
% 	elseif	(estrategia == 3)	% DE/rand-to-best/1
% 		ui = poblacion_vieja+F*(mi-poblacion_vieja) + F*(mp1-mp2);
% 	elseif	(estrategia == 4)	% DE/best/2
% 		ui = mi + F*(mp1-mp2 + mp3-mp4);
% 	else				% DE/rand/2
% 		ui = mp5 + F*(mp1-mp2 + mp3-mp4);
% 	end
%-----Cruza binomial-----------------------------
%	ui = poblacion_vieja.*mpv + ui.*mui;

%-----Elección de vectores de la nueva población---
vals=[vals mean(val)];
	for i=1:NP
		val_tmp	=	Makespan(ui(:,i),M,N);
		nfeval	=	nfeval+1;
		if (val_tmp <= val(i))
			poblacion(:,i)	= ui(:,i);
			val(i)		= val_tmp;
			if (val_tmp < mejorval)
				mejorval 	= val_tmp;
				mejorindividuo	= ui(:,i);
			end
		end
	end
	mejorinditeracion	= mejorindividuo;
%-----Salida---------------------------------------------
 	if (rem(generacion,20)==0)
 		fprintf(1,'Iteracion: %d, Mejor: %f, NP %d\n ',generacion, mejorval, NP);
		%Makespan(mejorindividuo,M,N)
%		Makespan(reshape(mejorindividuo,M,N))
 		%for n=1:(M*N)
 		%	fprintf(1,'Mejor(%d) = %f\n\n', n,mejorindividuo(n));
 		%end
 	end
%-----Plot-----------------------------------------------------------
generacion=generacion+1;
end%endwhile (generacion < generaciones)
mejorindividuo=mejorindividuo(:);
%mejorval=Makespan(mejorindividuo,M,N);
mejorindividuo=reshape(mejorindividuo,M,N);
difflb=mejorval-Prob.lb;
diffub=mejorval-Prob.ub;
end
