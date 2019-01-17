% This Prolog program illustrates a simple biological database about the order Pelecaniformes (Pelicans, Herons, Ibises, and allies)
%   in North America, as well as inference rules about the higher-order relationships among the terms and other details
% Authors (Team 33):
%   Bruce Laird
%   Calvin Lau
%   Matthew Armstrong
%   Michael de Grood
%   SanHa Kim

% Database of the pelecaniformes order
order(pelecaniformes).

% Families
family(pelecanidae).
family(ardeidae).
family(threskiornithidae).

% Genera
genus(pelecanus).
genus(botaurus).
genus(ixobrychus).
genus(ardea).
genus(egretta).
genus(bubulcus).
genus(butorides).
genus(nycticorax).
genus(nyctanassa).
genus(eudocimus).
genus(plegadis).
genus(platalea).

% Species
species(erythrorhynchos).
species(occidentalis).
species(lentiginosus).
species(exilis).
species(herodias).
species(alba).
species(thula).
species(caerulea).
species(tricolor).
species(rufescens).
species(ibis).
species(virescens).
species(nycticorax).
species(violacea).
species(albus).
species(falcinellus).
species(chihi).
species(ajaja).

% hasParent(?A, ?B)
% B is a direct parent of A
hasParent(X,pelecaniformes) :- family(X).
hasParent(pelecanus,pelecanidae).
hasParent(botaurus,ardeidae).
hasParent(ixobrychus,ardeidae).
hasParent(ardea,ardeidae).
hasParent(egretta,ardeidae).
hasParent(bubulcus,ardeidae).
hasParent(butorides,ardeidae).
hasParent(nycticorax,ardeidae).
hasParent(nyctanassa,ardeidae).
hasParent(eudocimus,threskiornithidae).
hasParent(plegadis,threskiornithidae).
hasParent(platalea,threskiornithidae).
hasParent(erythrorhynchos,pelecanus).
hasParent(occidentalis,pelecanus).
hasParent(lentiginosus,botaurus).
hasParent(exilis,ixobrychus).
hasParent(herodias,ardea).
hasParent(alba,ardea).
hasParent(thula,egretta).
hasParent(caerulea,egretta).
hasParent(tricolor,egretta).
hasParent(rufescens,egretta).
hasParent(ibis, bubulcus).
hasParent(virescens,butorides).
hasParent(nycticorax,nycticorax).
hasParent(violacea,nyctanassa).
hasParent(albus,eudocimus).
hasParent(falcinellus,plegadis).
hasParent(chihi,plegadis).
hasParent(ajaja,platalea).

% hasParent2(?A, ?B)
% B is a direct parent of A.  A must be an order, family, genus, or compound species name, and B must be a order, family, or genus name.
hasParent2(X,pelecaniformes) :- family(X).
hasParent2(pelecanus,pelecanidae).
hasParent2(botaurus,ardeidae).
hasParent2(ixobrychus,ardeidae).
hasParent2(ardea,ardeidae).
hasParent2(egretta,ardeidae).
hasParent2(bubulcus,ardeidae).
hasParent2(butorides,ardeidae).
hasParent2(nycticorax,ardeidae).
hasParent2(nyctanassa,ardeidae).
hasParent2(eudocimus,threskiornithidae).
hasParent2(plegadis,threskiornithidae).
hasParent2(platalea,threskiornithidae).
% hasParent2/2 with compound names
hasParent2(pelecanus_erythrorhynchos,pelecanus).
hasParent2(pelecanus_occidentalis,pelecanus).
hasParent2(botaurus_lentiginosus,botaurus).
hasParent2(ixobrychus_exilis,ixobrychus).
hasParent2(ardea_herodias,ardea).
hasParent2(ardea_alba,ardea).
hasParent2(egretta_thula,egretta).
hasParent2(egretta_caerulea,egretta).
hasParent2(egretta_tricolor,egretta).
hasParent2(egretta_rufescens,egretta).
hasParent2(bubulcus_ibis,bubulcus).
hasParent2(butorides_virescens,butorides).
hasParent2(nycticorax_nycticorax,nycticorax).
hasParent2(nyctanassa_violacea,nyctanassa).
hasParent2(eudocimus_albus,eudocimus).
hasParent2(plegadis_falcinellus,plegadis).
hasParent2(plegadis_chihi,plegadis).
hasParent2(platalea_ajaja,platalea).

% hasCommonName(?N, ?C)
% The taxonomical name N has a common name C
hasCommonName(pelecanus,pelican).
hasCommonName(pelecanus_erythrorhynchos,americanWhitePelican).
hasCommonName(pelecanus_occidentalis,brownPelican).
hasCommonName(botaurus,bittern).
hasCommonName(botaurus_lentiginosus,americanBittern).
hasCommonName(ixobrychus,bittern).
hasCommonName(ixobrychus_exilis,leastBittern).
hasCommonName(ardea,heron).
hasCommonName(ardea_herodias,greatBlueHeron).
hasCommonName(ardea_alba,greatEgret).
hasCommonName(egretta,heron).
hasCommonName(egretta,egret).
hasCommonName(egretta_thula,snowyEgret).
hasCommonName(egretta_caerulea,littleBlueHeron).
hasCommonName(egretta_tricolor,tricoloredHeron).
hasCommonName(egretta_rufescens,reddishEgret).
hasCommonName(bubulcus,egret).
hasCommonName(bubulcus_ibis,cattleEgret).
hasCommonName(butorides,heron).
hasCommonName(butorides_virescens,greenHeron).
hasCommonName(nycticorax,nightHeron).
hasCommonName(nycticorax_nycticorax,blackCrownedNightHeron).
hasCommonName(nyctanassa,nightHeron).
hasCommonName(nyctanassa_violacea,yellowCrownedNightHeron).
hasCommonName(eudocimus,ibis).
hasCommonName(eudocimus_albus,whiteIbis).
hasCommonName(plegadis,ibis).
hasCommonName(plegadis_falcinellus,glossyIbis).
hasCommonName(plegadis_chihi,whiteFacedIbis).
hasCommonName(platalea,spoonbill).
hasCommonName(platalea_ajaja,roseateSpoonbill).

% hasCommonName(?G, ?S, ?C)
% The species described by the genus G and raw species name S has a common name C
hasCommonName(pelecanus,erythrorhynchos,americanWhitePelican).
hasCommonName(pelecanus,occidentalis,brownPelican).
hasCommonName(botaurus,lentiginosus,americanBittern).
hasCommonName(ixobrychus,exilis,leastBittern).
hasCommonName(ardea,herodias,greatBlueHeron).
hasCommonName(ardea,alba,greatEgret).
hasCommonName(egretta,thula,snowyEgret).
hasCommonName(egretta,caerulea,littleBlueHeron).
hasCommonName(egretta,tricolor,tricoloredHeron).
hasCommonName(egretta,rufescens,reddishEgret).
hasCommonName(bubulcus,ibis,cattleEgret).
hasCommonName(butorides,virescens,greenHeron).
hasCommonName(nycticorax,nycticorax,blackCrownedNightHeron).
hasCommonName(nyctanassa,violacea,yellowCrownedNightHeron).
hasCommonName(eudocimus,albus,whiteIbis).
hasCommonName(plegadis,falcinellus,glossyIbis).
hasCommonName(plegadis,chihi,whiteFacedIbis).
hasCommonName(platalea,ajaja,roseateSpoonbill).

% rangesTo database
% Order, family, genus, or compound species name A's range extends to P, where P may be either canada or alberta
rangesTo(A, R) :- var(A) -> ((hasCompoundName(X,N,A), hasParent(N,X)), hasParent2(B,A), rangesTo(B, H)) ; hasParent2(B, A), rangesTo(B, R).
rangesTo(pelecanus_erythrorhynchos,alberta).
rangesTo(botaurus_lentiginosus,alberta).
rangesTo(ardea_herodias,alberta).
rangesTo(ardea_alba,canada).
rangesTo(bubulcus_ibis,canada).
rangesTo(butorides_virescens,canada).
rangesTo(nycticorax_nycticorax,alberta).
rangesTo(A,canada) :- (hasCompoundName(X,N,A), hasParent(N,X)),  rangesTo(A,alberta).

% habitat database
% A prefers a habitat of B, where B is lakePond, ocean, or marsh
habitat(A, H) :- var(A) -> ((hasCompoundName(X,N,A), hasParent(N,X)), hasParent2(B,A), habitat(B, H)) ; hasParent2(B, A), habitat(B, H).
habitat(pelecanus_erythrorhynchos,lakePond).
habitat(pelecanus_occidentalis,ocean).
habitat(botaurus_lentiginosus,marsh).
habitat(ixobrychus_exilis,marsh).
habitat(ardea_herodias,marsh).
habitat(ardea_alba,marsh).
habitat(egretta_thula,marsh).
habitat(egretta_caerulea,marsh).
habitat(egretta_tricolor,marsh).
habitat(egretta_rufescens,marsh).
habitat(bubulcus_ibis,marsh).
habitat(butorides_virescens,marsh).
habitat(nycticorax_nycticorax,marsh).
habitat(nyctanassa_violacea,marsh).
habitat(eudocimus_albus,marsh).
habitat(plegadis_falcinellus,marsh).
habitat(plegadis_chihi,marsh).
habitat(platalea_ajaja,marsh).

% food database
% A prefers to nest in B, where B is ground or tree
food(A, F) :- var(A) -> ((hasCompoundName(X,N,A), hasParent(N,X)), hasParent2(B,A), habitat(B, F)) ; hasParent2(B, A), food(B, F).
food(pelecanus_erythrorhynchos,fish).
food(pelecanus_occidentalis,fish).
food(botaurus_lentiginosus,fish).
food(ixobrychus_exilis,fish).
food(ardea_herodias,fish).
food(ardea_alba,fish).
food(egretta_caerulea,fish).
food(egretta_caerulea,fish).
food(egretta_tricolor,fish).
food(egretta_rufescens,fish).
food(bubulcus_ibis,insects).
food(butorides_virescens,fish).
food(nycticorax_nycticorax,fish).
food(nyctanassa_violacea,insects).
food(eudocimus_albus,insects).
food(plegadis_falcinellus,insects).
food(plegadis_chihi,insects).
food(platalea_ajaja,fish).

% nesting database
% A prefers to nest in B, where B is ground or tree
nesting(A, E) :- var(A) -> ((hasCompoundName(X,N,A), hasParent(N,X)), hasParent2(B,A), habitat(B, E)) ; hasParent2(B, A), nesting(B, E).
nesting(pelecanus_erythrorhynchos,ground).
nesting(pelecanus_occidentalis,tree).
nesting(botaurus_lentiginosus,ground).
nesting(ixobrychus_exilis,ground).
nesting(ardea_herodias,tree).
nesting(ardea_alba,tree).
nesting(egretta_thula,tree).
nesting(egretta_caerulea,tree).
nesting(egretta_tricolor,tree).
nesting(egretta_rufescens,tree).
nesting(bubulcus_ibis,tree).
nesting(butorides_virescens,tree).
nesting(nycticorax_nycticorax,tree).
nesting(nyctanassa_violacea,tree).
nesting(eudocimus_albus,tree).
nesting(plegadis_falcinellus,ground).
nesting(plegadis_chihi,ground).
nesting(platalea_ajaja,tree).

% conservation database
% A's conservation status is B, where B is lc (low concern) or nt (near threatened)
conservation(A, C) :- var(A) -> ((hasCompoundName(X,N,A), hasParent(N,X)), hasParent2(B,A), habitat(B, C)) ; hasParent2(B, A), conservation(B, C).
conservation(pelecanus_erythrorhynchos,lc).
conservation(pelecanus_occidentalis,lc).
conservation(botaurus_lentiginosus,lc).
conservation(ixobrychus_exilis,lc).
conservation(ardea_herodias,lc).
conservation(ardea_alba,lc).
conservation(egretta_thula,lc).
conservation(egretta_caerulea,lc).
conservation(egretta_tricolor,lc).
conservation(egretta_rufescens,nt).
conservation(bubulcus_ibis,lc).
conservation(butorides_virescens,lc).
conservation(nycticorax_nycticorax,lc).
conservation(nyctanassa_violacea,lc).
conservation(eudocimus_albus,lc).
conservation(plegadis_falcinellus,lc).
conservation(plegadis_chihi,lc).
conservation(platalea_ajaja,lc).

% behaviour database
% A exhibits feeding behavior B, where B is surfaceDive, aerialDive, stalking, groundForager, or probing
behavior(A, E) :- var(A) -> ((hasCompoundName(X,N,A), hasParent(N,X)), hasParent2(B,A), habitat(B, E)) ; hasParent2(B, A), behavior(B, E).
behavior(pelecanus_erythrorhynchos,surfaceDive).
behavior(pelecanus_occidentalis,aerialDive).
behavior(botaurus_lentiginosus,stalking).
behavior(ixobrychus_exilis,stalking).
behavior(ardea_herodias,stalking).
behavior(ardea_alba,stalking).
behavior(nycticorax_nycticorax,stalking).
behavior(nyctanassa_violacea,stalking).
behavior(eudocimus_albus,probing).
behavior(plegadis_falcinellus,probing).
behavior(plegadis_chihi,probing).
behavior(platalea_ajaja,probing).
behavior(egretta_thula,stalking).
behavior(egretta_caerulea,stalking).
behavior(egretta_tricolor,stalking).
behavior(egretta_rufescens,stalking).
behavior(bubulcus_ibis,groundForager).
behavior(butorides_virescens,stalking).
behavior(nycticorax_nycticorax,stalking).

% hasSciName(?C, ?N)
% N is a compound taxonomical name for some species that has a common name C; or N is an order, family, or genus that has a common name C.
hasSciName(C,N) :- hasCommonName(N,C).

% hasCompoundName(?G, ?S, ?N)
% N is the compound name for the genus G and species S.
hasCompoundName(G, S, N) :- hasCommonName(G, S, C), hasSciName(C, N).

% isaStrict(?A, ?B)
% B is an ancestor (the same as, parent, or parent of parent, or parent of parent of parent, or...) of A.
isaStrict(A, A) :- (hasCompoundName(X,N,A), hasParent(N,X)) ; genus(A); family(A); order(A).
isaStrict(A, B) :- hasParent2(A,B).
isaStrict(A, B) :- hasParent2(P,B), isaStrict(A,P), P\=A .

% isa(?A, ?B)
% B is an ancestor (the same as, parent, or parent of parent, or parent of parent of parent, or...) of A
isa(A,B) :- isaStrict(A,B).
isa(A,B) :- (nonvar(A), nonvar(B)) -> (hasCommonName(N1,A), hasCommonName(N2,B)), isaStrict(N1,N2).
isa(A,B) :- nonvar(B) -> (hasCommonName(N, B), isaStrict(A,N)).
isa(A,B) :- nonvar(A) -> (hasCommonName(N, A), isaStrict(N,B)).

% synonym(?A, ?B)
% A is common name of scientific name (an order name, a family name, a genus name, or a compound species name) B or vice versa; or both A and B are common names for a particular scientific name
synonym(A,B) :- hasCommonName(A,B), A\=B.
synonym(A,B) :- hasCommonName(B,A), A\=B.
synonym(A,B) :- hasCommonName(X,A), hasCommonName(X,B), A\=B.

% countSpecies(?A, -N)
% Order, family, genus, or species A has N species
countSpecies(A, 0) :- \+order(A), \+family(A), \+ genus(A), \+ (hasCompoundName(X,N,A), hasParent(N,X)).
countSpecies(A, 1) :- (hasCompoundName(X,M,A), hasParent(M,X)).
countSpecies(A, N) :- buildList(A, S), length(S, N).

% Helper predicate for countSpecies/2
buildList(A, N) :- findall(X, (isaStrict(X, A), hasCompoundName(Y,M,X), hasParent(M,Y)), N).
