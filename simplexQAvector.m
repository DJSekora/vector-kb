function [output_vector, tail_weights, tail_inds] = simplexQAvector(vec1,relation_term,predicates,db,h3,index,word)
%IndexC = strfind(predicates, relation_term);
%matches = find(not(cellfun('isempty', IndexC)));
IndexC = strcmp(predicates, relation_term);
matches = find(IndexC==1);
same_relation=find(ismember(db.ftir,matches));
[heads, ia, ic]=unique(db.fti1(same_relation),'stable');
if size(heads,2)==0
    fprintf('\n Sorry, I do not know the relation "%s."\n',relation_term);
end
head_vectors=h3(:,heads);
if size(heads,2)>1
    head_vector_index = flann_build_index(head_vectors,struct('algorithm','linear'));
    nearest_head_inds=vec2ind(vec1,head_vector_index,min(300,size(heads,2)));
    nearest_head_inds=unique(nearest_head_inds(nearest_head_inds<=size(heads,2)),'stable');
    nearest_head_inds=nearest_head_inds(nearest_head_inds>.5);
else
    nearest_head_inds=1;
end

[answer_projection, offset, tail_weights, tail_inds]=find_tails(nearest_head_inds,db,h3, ic, same_relation, head_vectors, vec1, word, heads);
if size(nearest_head_inds,1)>1
    nearest_head_inds2=nearest_head_inds(2:end);
else
    nearest_head_inds2=nearest_head_inds;
end
[answer_projection2, offset2, tail_weights2, tail_inds2]=find_tails(nearest_head_inds2,db,h3, ic, same_relation, head_vectors, vec1, word, heads);
output_vector=answer_projection2/4+3*answer_projection/4+1*offset2/10+3*offset/10;
