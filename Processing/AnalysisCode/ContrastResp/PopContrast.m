function PopContrast(f0,orivec,contvec,bw)

% for i = 1:length(f0)
%    f0{i} = rand(size(f0{i})) ;
% end

oridom = unique(orivec);
contdom = unique(contvec);

idbw = find(bw(:));
for i = 1:length(f0)
    idori = find(oridom == orivec(i));
    idcont = find(contdom == contvec(i));
    contResp(idcont,idori) = norm(f0{i}(idbw));    
end

figure, plot(contResp,'-o'), 
ylabel('Population Norm'), xlabel('%contrast')
legend('ori1','ori2')

Nori = length(oridom); 
NoriCombos = sum(0:Nori-1);  %number of unique orientation pairs

figure
z = 1;
for i = 1:length(oridom)
    
    condsA = find(oridom(i) == orivec); %number of conditions should be number of contrasts
    Adum = 0;
    for k = 1:length(condsA);
        Adum = Adum + f0{condsA(k)}(idbw);  %Adum is summed responses across contrasts of oriA
    end
    
    for j = i+1:length(oridom)
        
        condsB = find(oridom(j) == orivec); %number of conditions should be number of contrasts
        Bdum = 0;
        for k = 1:length(condsB);
            Bdum = Bdum + f0{condsB(k)}(idbw);  %Bdum is summed responses across contrasts of oriB
        end
        
        [dum idma] = max([Adum'; Bdum']);
        Abest = find(idma == 1);  %pixels that respond more to ori A
        Bbest = find(idma == 2);  %pixels that respond more to ori B
               
        for k = 1:length(condsA);  %loop through each contrast
            id = find(contvec(condsA(k)) == contdom);           
            RespA{id} = f0{condsA(k)}(idbw);  %Response vector for orientation A at the loop contrast
        end
        for k = 1:length(condsB);
            id = find(contvec(condsB(k)) == contdom);
            RespB{id} = f0{condsB(k)}(idbw);  %Response vector for orientation B at the loop contrast
        end
       
        %Make vector A to have the minimum responses, and B the max
        %responses
        
        for k = 1:length(RespB) %loop through each contrast
            
            Opt(Abest) = RespA{k}(Abest);  %Get pop response to the best orienation for each pixel
            Opt(Bbest) = RespB{k}(Bbest);
            Orth(Abest) = RespB{k}(Abest);
            Orth(Bbest) = RespA{k}(Bbest);

            Optnorm(k) = norm(Opt);  %these are ordered in increasing contrast
            Orthnorm(k) = norm(Orth);            
            
        end
        
        
        subplot(NoriCombos,1,z)
        for q = 1:length(Optnorm)-1
            if q == 1                
                plot([Orthnorm(q) Orthnorm(q+1)],[Optnorm(q) Optnorm(q+1)],'-o')
            else
                plot([Orthnorm(q) Orthnorm(q+1)],[Optnorm(q) Optnorm(q+1)],'-or')
            end            
            hold on
        end
        xlabel('Best Ori')
        ylabel('Worst Ori')
        z = z+1;
    end
end




    
    