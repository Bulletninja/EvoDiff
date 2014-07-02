function [mejorindividuo, nfeval] = EvoDif(fh, NP, D, F, CR,...
    generaciones, estrategia, cotainf, cotasup)
%Minimización con Evolución diferencial
%Salidas
%--------------------
%bestmem		: mejor solución
%nfeval		: número de evaluación de la función

%Entradas
%--------------------
%NP		: Número de individuos en la población
%D		: Número de parametros de la función objetivo
%F		: Tamaño de paso
%CR		: Probabilidad de cruza
%generaciones	: máximo número de generaciones
%estrategia	: 1 --> DE/best/1
%		  2 --> DE/rand/1
%		  3 --> DE/rand-to-best/1
%		  4 --> DE/best/2
%		  etc

%-----Inicializar población------------------------------ 
poblacion = zeros(NP, D);
cotainf=(cotainf(:))';
cotasup=(cotasup(:))';
for i=1:NP
	poblacion(i,:)=cotainf+rand(1,D).*(cotasup-cotainf);
end
poblacion_vieja		= zeros(size(poblacion));
val                 = zeros(1,NP);
mejorindividuo		= zeros(1,D);
mejorinditeracion	= zeros(1,D);
nfeval			=0;

%----Evaluación------------------------------------------
imejor	= 1; %índice del mejor
val(1)	= feval(fh,poblacion(imejor,:));
mejorval= val(1);
nfeval	= nfeval+1;
for i=2:NP
	val(i)	= feval(fh,poblacion(i,:));
	nfeval	= nfeval+1;
	if (val(i)<mejorval)
		imejor	= i;
		mejorval= val(i);
	end
end
mejorinditeracion=poblacion(imejor,:);
mejorvaliteracion=mejorval;

mejorindividuo	= mejorinditeracion;
%----Minimización---------------------------------------
%----Matrices de poblaciones---------------------------
mp1	=	zeros(NP,D);
mp2	=	zeros(NP,D);
mp3	=	zeros(NP,D);
mp4	=	zeros(NP,D);
mp5	=	zeros(NP,D);
mi	=	zeros(NP,D);%Matriz de mejores individuos
ui	=	zeros(NP,D);%Vectores perturbados
mui	=	zeros(NP,D);%"máscara" para la cruza
mpo	=	zeros(NP,D);%"máscara" para la cruza
rot	=	(0:1:NP-1); %
rt	=	zeros(NP);
a1	=	zeros(NP);
a2	=	zeros(NP);
a3	=	zeros(NP);
a4	=	zeros(NP);
a5	=	zeros(NP);
ind	=	zeros(4);

generacion=1;

while((generacion < generaciones) && (mejorval>1.e-5))
%    generacion
	poblacion_vieja = poblacion;
	%"barajar" población
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

	mp1	=	poblacion_vieja(a1,:);
	mp2	=	poblacion_vieja(a2,:);
	mp3	=	poblacion_vieja(a3,:);
	mp4	=	poblacion_vieja(a4,:);
	mp5	=	poblacion_vieja(a5,:);

	for i=1:NP
		mi(i,:)=mejorinditeracion;
	end

	mui	=	rand(NP,D) < CR;%"Máscara" de los perturbados
	mpv	=	mui < 0.5;	%ídem población vieja

%-----Elegir la estrategia----------------------
%----------Mutación/Perturbación----------------
	if	(estrategia == 1)	% DE/best/1
		ui = mi+F*(mp1-mp2); 
	elseif	(estrategia == 2)	% DE/rand/1
		ui = mp3 + F*(mp1-mp2);
	elseif	(estrategia == 3)	% DE/rand-to-best/1
		ui = poblacion_vieja+F*(mi-poblacion_vieja) + F*(mp1-mp2);
	elseif	(estrategia == 4)	% DE/best/2
		ui = mi + F*(mp1-mp2 + mp3-mp4);
	else				% DE/rand/2
		ui = mp5 + F*(mp1-mp2 + mp3-mp4);
	end
%-----Cruza binomial-----------------------------
	ui = poblacion_vieja.*mpv + ui.*mui;

%-----Elección de vectores de la nueva población---
	for i=1:NP
		val_tmp	=	feval(fh,ui(i,:));
		nfeval	=	nfeval+1;
		if (val_tmp <= val(i))
			poblacion(i,:)	= ui(i,:);
			val(i)		= val_tmp;
			if (val_tmp < mejorval)
				mejorval 	= val_tmp;
				mejorindividuo	= ui(i,:);
			end
		end
	end
	mejorinditeracion	= mejorindividuo;
%-----Salida---------------------------------------------
% 	if (rem(generacion,5)==0)
% 		fprintf(1,'Iteracion: %d, Mejor: %f, F: %f, CR %f, NP %d\n',generacion, mejorval, F, CR, NP);
% 		for n=1:D
% 			fprintf(1,'Mejor(%d) = %f\n', mejorindividuo(n));
% 		end
% 	end
%-----Plot-----------------------------------------------------------
generacion=generacion+1;
end%endwhile (generacion < generaciones)
mejorindividuo=mejorindividuo(:);
end
