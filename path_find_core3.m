function [summed_relations, sorted_values] = path_find_core3(vec1,vec2, db, range, relation,word,h3,params)
db.ftir=db.ftir(range);
db.fti1=db.fti1(range);
db.fti2=db.fti2(range);
db.relation_h3=.67*(h3(:,db.fti2)-h3(:,db.fti1));

%given a head and tail vector, and a dictionary of relations, this function
%tries to find relations that sum to form a chain between vec1 and vec2

%the relation between two terms is the vector between them
newvec=(vec2-vec1);

ub = 1; % the upper bound of the paramter values
lb = 0.01; % the lower bound of the parameter values
npar = 100; % the number of parameter values
delta_lambda = (log(ub) - log(lb))/(npar-1);
lambda = exp(log(lb):delta_lambda:log(ub)); % the paramter sequence
opts.tFlag=5;       % run .maxIter iterations
opts.maxIter=1000;   % maximum number of iterations. When the improvement is small, SLEP may stop without running opts.maxIter steps
opts.nFlag=0;       % without normalization
opts.rFlag=1;       % the input parameter 'lambda' is a ratio in (0, 1] % regularization
opts.fName = 'nnLeastR';  % compute a sequence of nonnegative lasso problems

%use Lasso for one-way relations, OMP for relations that can go either
%forward or backward. This line does the actual work, the rest is
%formatting outputs.
if params.pos == true
    Sol = DPC_nnLasso(db.relation_h3, newvec, lambda, opts);
    raw_summed_relations=zeros(size(db.fti1));
    solsum=sum(Sol,2);
    plausible=find(solsum>0);
    %for nn=1:size(plausible,1)
    %    raw_summed_relations(plausible(nn))=small_summed_relations(nn);
    %end
    for nn=1:size(plausible,1)
        raw_summed_relations(plausible(nn))=solsum(plausible(nn));
    end    
else
    raw_summed_relations = mexOMP(newvec,db.relation_h3,params);
end
for lambda_sample=[98:-20:1,1]
solutions_at_lambda=find(Sol(:,lambda_sample)>0);
[~,sort_order]=sort(Sol(solutions_at_lambda,lambda_sample),'descend');
solutions_at_lambda=solutions_at_lambda(sort_order);
relations = relation(db.ftir(solutions_at_lambda));
first_terms= word(db.fti1(solutions_at_lambda));
second_terms = word(db.fti2(solutions_at_lambda));
    for ii=1:size(solutions_at_lambda,1)
        p=Sol(solutions_at_lambda(ii),lambda_sample);
        triple{ii}=['( ' relations{ii} ' | '  first_terms{ii} ' | ' second_terms{ii} ' )'];
        if p>params.cutoff
          fprintf('%0.2f %s\n',p,triple{ii});
        end

    end
    fprintf('\n');
end

%we can ignore sufficiently low-weighted relations, since they are usually
%noise. The rest of this gets it into a unique sorted form.
summed_relations=find(abs(raw_summed_relations)>params.cutoff);

%we want to include anything whose first term matches the first term of the
%proof
term1=vec2ind(vec1, h3, 1);
matches_term1=find(db.fti1==term1(1));

%we want to include anything whose last term equals the last term of the
%proof. But we don't know what it is, so we instead include anything whose
%last term is near our estimate of the location of the last term.
term2=vec2ind(vec2, h3, 5);
matches_term2=[];
for gg=1:5
    matches_term2=[matches_term2 find(db.fti2==term2(gg))];
end
match_heads=db.fti1(matches_term2);
if size(match_heads,2)>500
    selected_matches=matches_term2(vec2ind(vec1,h3(:,match_heads),500));
else
    selected_matches=matches_term2;
end
raw_summed_relations(matches_term1)=max(.03,raw_summed_relations(matches_term1));
raw_summed_relations(matches_term2)=max(.03,raw_summed_relations(matches_term2));
summed_relations=[summed_relations matches_term1 selected_matches];
summed_relations=unique(summed_relations);
[sorted_values, sort_index] = sort(abs(raw_summed_relations(summed_relations)),'descend');
sorted_summed_relations=summed_relations(sort_index);

%this gets the strings associated with the terms and relations
relations = relation(db.ftir(sorted_summed_relations));
first_terms= word(db.fti1(sorted_summed_relations));
second_terms = word(db.fti2(sorted_summed_relations));
sorted_values=full(sorted_values);
%output the triples in sorted order
for ii=1:size(summed_relations,2)
    p=sorted_values(ii);
    triple{ii}=['( ' relations{ii} ' | '  first_terms{ii} ' | ' second_terms{ii} ' )'];
    if p>.3
        fprintf('%0.2f %s\n',p,triple{ii});
    end
    
end
summed_relations=summed_relations(sort_index);
