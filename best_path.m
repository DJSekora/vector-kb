function [relation_list, full_sorted, ft_index_list,total_dist] = best_path(vec1,vec2,h3, db, relation, word,params)
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


first_points = h3(:,db.fti1(relation_list));
second_points = h3(:,db.fti2(relation_list));
%costs=unique_relation.fcost(full_summed_relation_list);
points=[first_points,second_points,vec1,vec2];
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
    dists(ii,size(relation_list,2)+ii)=.01*(1-full_sorted(ii));
end
%the distance directly from term1 to term2 is set to a very high number so
%that this direct route is never taken.
dists(size(relation_list,2)*2+1,size(relation_list,2)*2+2)=1000000000000;

matches_head=find(points(1,:)==points(1,size(relation_list,2)*2+1));
dists(matches_head,size(relation_list,2)*2+2)=1000000000000;

%the distance from all heads to the end are set to a high value: only tails
%are allowed to lead to the end.
dists(1:size(relation_list,2),size(relation_list,2)*2+2)=1000000000000;

%set up the directed graph

for solutions=1:5

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

%the labels either come from the heads, the tails, term1 or term2

current_index=-2;current_word='start';dist=0;total_dist=0;
for tt=2:size(path,2)
    past_index=current_index;past_word=current_word;
    if path(tt)<=size(relation_list,2)
        current_index = relation_list(path(tt));
        ft_index_list(tt,2)=1;
        ft_index_list(tt,1)=current_index;
        current_word=word{db.fti1(current_index)};
    elseif path(tt)>size(relation_list,2) && path(tt)<size(relation_list,2)*2+1
        current_index=relation_list(path(tt)-size(relation_list,2));
        ft_index_list(tt,2)=2;
        ft_index_list(tt,1)=current_index;
        current_word=word{db.fti2(current_index)};
    elseif path(tt)==size(relation_list,2)*2+1
        current_word='start';
        current_index=0;
    elseif path(tt)==size(relation_list,2)*2+2
        current_word='end';
        current_index=-1;
    end
    
    %print the path along with the costs for each step
    if tt<size(path,2)
        past_dist=dists(path(tt-1),path(tt));
        dist=dists(path(tt),path(tt+1));
        total_dist=total_dist+dist;
        if past_index==current_index
            fprintf('%s=%.6f|%s=>',past_word, past_dist, relation{db.ftir(past_index)});
        else
            if strcmp(past_word,current_word)
               % fprintf('-%.6f->',past_dist);
            else
                fprintf('%s-%.6f->',past_word, past_dist);
                
            end
        end
    else
        fprintf('%s-%.6f->%s',past_word,dist,current_word);
    end
    
end
fprintf('\n');
end


