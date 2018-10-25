function [path_strings,total_costs,answers] = best_path3(vec1,vec2,h3, db, relation, word,params)
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
    [summed_relations, sorted_values] = path_find_core_no_debug(vec1,vec2, db, range, relation, word,h3,params);
    %fprintf('\n');
    relation_list=[relation_list,range(summed_relations)];
    full_sorted=[full_sorted sorted_values];
    range = setdiff(1:length(db.fti1),relation_list);
end

first_indices=db.fti1(relation_list);
second_indices=db.fti2(relation_list);
near_end_indices=vec2ind(vec2,h3,50);
unique_indices=unique([first_indices, second_indices, near_end_indices']);
%unique_indices=unique([first_indices(1), second_indices(1), near_end_indices']);
%costs=unique_relation.fcost(full_summed_relation_list);
points=[h3(:,unique_indices),vec1,vec2];
%finds the actual distance between all head and tail terms
%pdist2 is in d:\matlab apps\edges (and piotr toolbox)\piotr_toolbox\toolbox\classify
dists_raw=real(pdist2(points',points','euclidean'));
%because of high dimensionality, we want to spread out the far terms so
%that a sum of two close terms may be more similar than one far term. This
%is a free parameter "exponent." It is multiplied by 2 because it has to be
%even.
dists=(dists_raw*2).^(2*params.exponent);
analogy_dists=zeros(size(dists));
%we prefer to take paths which have a higher weight in the sum, but any
%path is preferable to any non-path, so it is multiplied by .001
for ii=1:size(relation_list,2)
    head_idx=find(unique_indices==first_indices(ii));
    tail_idx=find(unique_indices==second_indices(ii));
    dists(head_idx,tail_idx)=.01*(1-full_sorted(ii));
    analogy_dists(head_idx,tail_idx)=.01*(1-full_sorted(ii));
end
%to prevent one-step answers, the maximum of start_to_point or point_to_end
%is set to a very high value.
start_to_points=dists(end-1,1:end-2);
points_to_end=dists(1:end-2,end)';
start_greater=(start_to_points>points_to_end);
start_greater2=start_greater*1000000000000;
dists(end-1,1:end-2)=dists(end-1,1:end-2)+start_greater2;
end_greater=(1-start_greater)*1000000000000;
dists(1:end-2,end)=dists(1:end-2,end)+end_greater';
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
    analogy_cost=0;
    dist=dists(path(1),path(2));
    analogy_dist=analogy_dists(path(1),path(2));
    last_word=word{unique_indices(path(end-1))};
    path_string=sprintf('%.3f ->',dist);
    total_cost=total_cost+dist;
    analogy_cost=analogy_cost+dist;
    for pathstep=2:size(path,2)-2
        aa=find(first_indices==unique_indices(path(pathstep)));
        bb=find(second_indices==unique_indices(path(pathstep+1)));
        current_relation=intersect(aa,bb);
        head_term=word{unique_indices(path(pathstep))};
        if size(current_relation,2)>0
            %case where a relation is defined
            current_relation=current_relation(1);
            relation_name=relation{db.ftir(relation_list(current_relation))};
            ft_index_list(pathstep)=relation_list(current_relation);
            nextpath=sprintf('%s|%s ',head_term,relation_name);
            path_string=[path_string nextpath];
        else
            %case where there is no relation between the head and tail
            nextpath=sprintf('%s ',head_term);
            path_string=[path_string nextpath];
        end
        dist=dists(path(pathstep),path(pathstep+1));
        analogy_dist=analogy_dists(path(pathstep),path(pathstep+1));
        nextpath=sprintf('%.3f ->',dist);
        path_string=[path_string nextpath];
        total_cost=total_cost+dist;
        analogy_cost=analogy_cost+analogy_dist;
    end
    total_cost=total_cost+dists(path(end-1),path(end));
    analogy_cost=analogy_cost*100000+dists(path(end-1),path(end));
    nextpath=sprintf('%s %.3f',last_word,dists(path(end-1),path(end)));
    path_string=[path_string nextpath];
    
    answers{solution_count}=last_word;
    path_strings{solution_count}=path_string;
    total_costs{solution_count}=total_cost;
    if total_cost>300
        solution_count=solution_limit;
    end
end

