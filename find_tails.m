function [answer_projection, offset, tail_weights, tail_inds]=find_tails(nearest_head_inds,db,h3, ic, same_relation, head_vectors, vec1, word, heads)

for ii=1:size(nearest_head_inds,1)
    current_vecs=db.fti2(same_relation(ic==nearest_head_inds(ii)));
    vectally(ii)=size(current_vecs,2);
    current_vec=mexNormalize(mean(h3(:,current_vecs),2));
    tail_simplex(:,ii)=current_vec;
end

head_simplex=head_vectors(:,nearest_head_inds);
[distance, projection] = distanceToSimplex(vec1',head_simplex');
offset=vec1-projection;
head_weights=barycentric(projection',head_simplex');
fprintf('\nH:');
[sorted_weights, head_sort_order]=sort(head_weights,'descend');
for ii=1:size(nearest_head_inds,1)
    if (abs(sorted_weights(ii))>.1)
        fprintf('%.0f %s ',sorted_weights(ii)*100,word{heads(nearest_head_inds(head_sort_order(ii)))});
    end
end
fprintf('\n');
vecout=mexNormalize(sum(bsxfun(@times,head_weights,tail_simplex),2));
[all_tails, ia, ic]=unique(db.fti2(same_relation),'stable');
all_tail_vectors = h3(:,all_tails);
tail_vector_index = flann_build_index(all_tail_vectors,struct('algorithm','linear'));
nearest_tail_inds=vec2ind(vecout,tail_vector_index,300);
nearest_tail_inds=unique(nearest_tail_inds(nearest_tail_inds<=size(all_tails,2)),'stable');
nearest_tail_inds=nearest_tail_inds(nearest_tail_inds>.5);
tail_inds=all_tails(nearest_tail_inds);
nearest_tail_simplex=h3(:,all_tails(nearest_tail_inds));

[answer_distance, answer_projection] = distanceToSimplex((vecout+0*offset)',nearest_tail_simplex');
%[answer_distance, answer_projection] = distanceToSimplex(vecout',nearest_tail_simplex');
tail_weights=barycentric(answer_projection',nearest_tail_simplex');
fprintf('T:');
[sorted_weights, tail_sort_order]=sort(tail_weights,'descend');
for ii=1:size(nearest_tail_inds,1)
    if (abs(sorted_weights(ii))>.05)
        fprintf('%.0f %s ',sorted_weights(ii)*100,word{all_tails(nearest_tail_inds(tail_sort_order(ii)))});
    end
end
fprintf('\n');
if answer_distance>0.0001
    new_simplex=[nearest_tail_simplex vec1];
    content=simplex_content(new_simplex);
else content=0;
end
tail_weights=sorted_weights(sorted_weights>.05);
tail_inds=all_tails(nearest_tail_inds(tail_sort_order(sorted_weights>.05)));