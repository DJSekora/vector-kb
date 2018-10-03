function [db]=add_fact_to_db(head_term,relation_term,tail_term,db,h3,alphabetized_words,word_index)
db_size=size(db.fti1,2);
db.fti1(db_size+1)=str2ind(head_term,alphabetized_words,word_index);
db.fti2(db_size+1)=str2ind(tail_term,alphabetized_words,word_index);

IndexC = strcmp(db.relations, relation_term);
relation = find(IndexC==1);
db.ftir(db_size+1)=relation;
if db.fti1(db_size+1)==0 || db.ftir(db_size+1)==0 || db.fti2(db_size+1)==0
    fprintf('Fact not added due to unknown word: %s %s %s\n',head_term,relation_term,tail_term);
    db.fti1=db.fti1(1:db_size);
    db.ftir=db.ftir(1:db_size);
    db.fti2=db.fti2(1:db_size);
end

