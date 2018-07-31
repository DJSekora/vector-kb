function [db]=add_fact_to_db(head_term,relation_term,tail_term,db,h3,alphabetized_words,word_index)
db_size=size(db.fti1,2);
db.fti1(db_size+1)=str2ind(head_term,alphabetized_words,word_index);
db.fti2(db_size+1)=str2ind(tail_term,alphabetized_words,word_index);
IndexC = strcmp(db.relation, relation_term);
relation = find(IndexC==1);
db.ftir(db_size+1)=relation;
db.relation_h3=h3(:,db.fti2(:,:))-h3(:,db.fti1(:,:));
