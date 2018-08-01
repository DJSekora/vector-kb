function [db, factcount, h3] = add_fact(head,pred,tail,h3, db, predicates, word,alphabetized_words, word_index, index, factcount)
dbsize=size(db.fti1,2);
reverse_db=db;
reverse_db.fti1=db.fti2;
reverse_db.fti2=db.fti1;
headind=str2ind(head,alphabetized_words,word_index);
tailind=str2ind(tail,alphabetized_words,word_index);
if headind==0
    fprintf('unknown head term %s',head);
end
if tailind==0
    fprintf('unknown tail term %s',tail);
end

IndexC = strcmp(predicates, pred);
predind=find(IndexC==1);
db.fti1(dbsize+1)=headind;
db.fti2(dbsize+1)=tailind;
db.ftir(dbsize+1)=predind;
if factcount(headind)<10
    [update_vector] = simplexQAvector(h3(:,tailind),pred,predicates,reverse_db,h3,index,word);
    a=(factcount(headind)*h3(:,headind)+update_vector)/(factcount(headind)+1);
    h3(:,headind)=a;
    index = flann_build_index(h3,struct('algorithm','linear'));
    factcount(headind)=factcount(headind)+1;
end
if factcount(tailind)<10
    [update_vector] = simplexQAvector(h3(:,headind),pred,predicates,db,h3,index,word);
    a=(factcount(tailind)*h3(:,tailind)+update_vector)/(factcount(tailind)+1);
    h3(:,tailind)=a;
    index = flann_build_index(h3,struct('algorithm','linear'));
    factcount(tailind)=factcount(tailind)+1;
end
