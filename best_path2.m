function [relation_list, full_sorted, ft_index_list,total_costs,answers,paths] = best_path2(vec1,vec2,h3, db, relation, word,params,heads)
%given two vectors and a relation dictionary, this tries to find a single connected path between the
%head and the tail with low cost.


range=1:length(db.fti1);
relation_list=[];
full_sorted=[];
ft_index_list=[];
tail_term=[];

%there is a loop here in case we want to find more potentially useful
%terms.
for ii=1:params.attempts
    %this gets all the potential terms and relations.
    [summed_relations, sorted_values] = path_find_core3(vec1,vec2, db, range, relation, word,h3,params);
    %fprintf('\n');
    relation_list=[relation_list,range(summed_relations)];
    full_sorted=[full_sorted sorted_values];
    range = setdiff(1:length(db.fti1),relation_list);
    fprintf('\nrelations found\n');
end

head_indices=db.fti1(relation_list);
tail_indices=db.fti2(relation_list);
near_end_indices=vec2ind(vec2,h3,50);
unique_indices=unique([head_indices, tail_indices, near_end_indices']);
%%costs=unique_relation.fcost(full_summed_relation_list);

points=[h3(:,unique_indices),vec1,vec2];

%finds the actual distance between all head and tail terms
%pdist2 is in d:\matlab apps\edges (and piotr toolbox)\piotr_toolbox\toolbox\classify
dists_raw=real(pdist2(points',points','euclidean'));
%because of high dimensionality, we want to spread out the far terms so
%that a sum of two close terms may be more similar than one far term. This
%is a free parameter "exponent." It is multiplied by 2 because it has to be
%even.
dists=(dists_raw*2).^(2*params.exponent);
%we prefer to take paths which have a higher weight in the sum, but any
%path is preferable to any non-path, so it is multiplied by .001
for ii=1:size(relation_list,2)
    head_idx=find(unique_indices==head_indices(ii));
    tail_idx=find(unique_indices==tail_indices(ii));
    dists(head_idx,tail_idx)=.001*(100-full_sorted(ii));
end

%to prevent one-step answers, the heads are given a high distance from the
%end, and everything else is given a high distance from the start.
 start_to_points=dists(end-1,1:end-2);
 points_to_end=dists(1:end-2,end)';
 start_greater=(start_to_points>points_to_end);
 end_greater=1-start_greater;
 
real_heads=union(unique_indices(end_greater==1),heads); 
[chosen,heads_in_unique_indices]=intersect(unique_indices,real_heads);
[~,tails_in_unique_indices]=setdiff(unique_indices,chosen);
dists(heads_in_unique_indices,end)=100000000000;
dists(end-1,tails_in_unique_indices)=10000000000;

%the distance directly from term1 to term2 is set to a very high number so
%that this direct route is never taken.
dists(end-1,end)=1000000000000;

%set up the directed graph

solution_count=0;
solution_limit=1000;
while solution_count<solution_limit
    solution_count=solution_count+1;
    count=1;
    for jj=1:size(dists,1)
        for kk=1:size(dists,2)
            starts(count)=jj;
            ends(count)=kk;
            if solution_count==1
                
                weights(count)=dists(jj,kk);
            else
                if jj==pathend
                    %eliminate the last step in the path each time to get various possible
                    %answers.
                    weights(count)=1000000000000;
                end
            end
            count=count+1;
        end
    end
    
    
    term_graph=digraph(starts,ends,weights);
    
    %search the graph for the lowest cost path
    path =shortestpath(term_graph,size(points,2)-1,size(points,2));
    pathend=path(end-1);
    
    %print the lowest cost path
    total_cost=0;
    dist=dists(path(1),path(2));
    last_word=word{unique_indices(path(end-1))};
    fprintf('%-30s %.3f ->',last_word,dist);
    total_cost=total_cost+dist;
    for pathstep=2:size(path,2)-2
        aa=find(head_indices==unique_indices(path(pathstep)));
        bb=find(tail_indices==unique_indices(path(pathstep+1)));
        current_relation=intersect(aa,bb);
        head_term=word{unique_indices(path(pathstep))};
        if size(current_relation,2)>0
            %case where a relation is defined
            current_relation=current_relation(1);
            relation_name=relation{db.ftir(relation_list(current_relation))};
            ft_index_list(pathstep)=relation_list(current_relation);
            fprintf('%s|%s ',head_term,relation_name);
        else
            %case where there is no relation between the head and tail
            fprintf('%s ',head_term);
        end
        dist=dists(path(pathstep),path(pathstep+1));
        fprintf('%.3f ->',dist);
        total_cost=total_cost+dist;
    end
    total_cost=total_cost+dists(path(end-1),path(end));
    fprintf('%s %.3f / total:%.3f\n',last_word,dists(path(end-1),path(end)),total_cost);
    if total_cost>600
        solution_count=solution_limit;
    end
    answers{solution_count}=last_word;
    paths{solution_count}=unique_indices(path(2:end-1));
    total_costs{solution_count}=total_cost;
end

