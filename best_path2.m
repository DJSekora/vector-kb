function [relation_list, full_sorted, ft_index_list,total_dist] = best_path2(vec1,vec2,h3, db, relation, word,params)
%given two vectors and a relation dictionary, this tries to find a single connected path between the
%head and the tail with low cost.

range=1:length(db.fti1);
relation_list=[];
full_sorted=[];

%there is a loop here in case we want to find more potentially useful
%terms.
for ii=1:params.attempts
    %this gets all the potential terms and relations.
    [summed_relations, sorted_values] = path_find_core2(vec1,vec2, db, range, relation, word,h3,params);
    %fprintf('\n');
    relation_list=[relation_list,range(summed_relations)];
    full_sorted=[full_sorted;sorted_values];
    range = setdiff(1:length(db.fti1),relation_list);
    fprintf(';');
end

first_indices=db.fti1(relation_list);
second_indices=db.fti2(relation_list);
first_points = h3(:,first_indices);
second_points = h3(:,second_indices);
unique_indices=unique([first_indices, second_indices]);
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
%we prefer to take paths which have a higher weight in the sum, but any
%path is preferable to any non-path, so it is multiplied by .001
for ii=1:size(relation_list,2)
    head_idx=find(unique_indices==first_indices(ii));
    tail_idx=find(unique_indices==second_indices(ii));
    dists(head_idx,tail_idx)=.01*(1-full_sorted(ii));
end
%the distance directly from term1 to term2 is set to a very high number so
%that this direct route is never taken.
dists(end-1,end)=1000000000000;

%set up the directed graph

solutions=0;
solution_limit=1000;
while solutions<solution_limit
    solutions=solutions+1;
    
    count=1;
    for jj=1:size(dists,1)
        for kk=1:size(dists,2)
            starts(count)=jj;
            ends(count)=kk;
            if solutions==1
                %eliminate the last step in the path to get various possible
                %answers.
                weights(count)=dists(jj,kk);
            else
                if jj==pathend
                    weights(count)=1000000000000;
                end
            end
            count=count+1;
        end
    end
    
    
    term_graph=digraph(starts,ends,weights);
    
    %search the graph for the shortest path
    path =shortestpath(term_graph,size(points,2)-1,size(points,2));
    pathend=path(end-1);
    fprintf('%');
    
    if size(path,2)>3
        fprintf('Start %.3f->',dists(path(1),path(2)));
        for pathstep=2:size(path,2)-2
            aa=find(first_indices==unique_indices(path(pathstep)));
            bb=find(second_indices==unique_indices(path(pathstep+1)));
            current_relation=intersect(aa,bb);
            if size(current_relation,2)>0
                relation_name=relation{db.ftir(relation_list(current_relation))};
                head_term=word{db.fti1(relation_list(current_relation))};
                tail_term=word{db.fti2(relation_list(current_relation))};
                ft_index_list(pathstep)=relation_list(current_relation);
                dist=dists(path(pathstep),path(pathstep+1));
                fprintf('%s|%s %.3f ->',head_term,relation_name,dist);
            end
        end
        fprintf('%s %.3f->End\n',tail_term,dists(path(end-1),path(end)));
    end
end

