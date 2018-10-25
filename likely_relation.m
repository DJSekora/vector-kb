function [relation_number, relation_name] = likely_relation(vec1,vec2, db, h3, relations, word)
% myvec=vec2-vec1;
% db_h3=h3(:,db.fti2)-h3(:,db.fti1);
% nearest=vec2ind(myvec,db_h3,100);
% first_terms=word(db.fti1(nearest));
% second_terms=word(db.fti2(nearest));
% found_relations=relations(db.ftir(nearest));
% relation_number=db.ftir(nearest(1));

[near_vec1, vec1_dists] = vec2ind(vec1,h3(:,db.fti1),10000);
[near_vec2, vec2_dists] = vec2ind(vec2,h3(:,db.fti2),10000);
[near_both, ind_1, ind_2]=intersect(near_vec1,near_vec2);
near_both_1=db.fti1(near_both);
near_both_2=db.fti2(near_both);
final_dists=max(vec1_dists(ind_1),vec2_dists(ind_2));
[sorted_dists, sorted_ind]=sort(final_dists,'ascend');
relation_number=db.ftir(near_both(sorted_ind(1)));
first_terms= word(near_both_1(sorted_ind));
second_terms = word(near_both_2(sorted_ind));
found_relations= relations(db.ftir(near_both(sorted_ind)));

for ii=1:20
     triple{ii}=['( ' found_relations{ii} ' | '  first_terms{ii} ' | ' second_terms{ii} ' )'];
    fprintf('%s\n',triple{ii});
end
relation_name=relations(relation_number);