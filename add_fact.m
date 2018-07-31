function [db, factcount, h3] = add_fact(head,pred,tail,h3, db, predicates, word,alphabetized_words, word_index, index, factcount)
dbsize=size(db.fti1,2);
headind=str2ind(head,alphabetized_words,word_index);
tailind=str2ind(tail,alphabetized_words,word_index);
IndexC = strcmp(predicates, pred);
predind=find(IndexC==1);
db.fti1(dbsize+1)=headind;
db.fti2(dbsize+1)=tailind;
db.ftir(dbsize+1)=predind;
if factcount(headind)<10
    [update_vector] = simplexQAunlimited(h3(:,tailind),pred,predicates,reverse_db,h3,index,word);
    h3(:,headind)=(factcount*h3(:,headind)+update_vector)/(factcount+1);
    factcount(headind)=factcount(headind)+1;
end
if factcount(tailind)<10
    [update_vector] = simplexQAunlimited(h3(:,headind),pred,predicates,db,h3,index,word);
    h3(:,tailind)=(factcount*h3(:,tailind)+update_vector)/(factcount+1);
    factcount(tailind)=factcount(tailind)+1;
end
