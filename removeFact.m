function [db] =  removeFact(head,pred,tail,db, alphabetized_words,word_index)
predicates=db.relations;
headind=str2ind(head,alphabetized_words,word_index);
tailind=str2ind(tail,alphabetized_words,word_index);
IndexC = strcmp(predicates, pred);
predind=find(IndexC==1);
sameheads=db.fti1==headind;
sametails=db.fti2==tailind;
samepreds=db.ftir==predind;
allsame=find(sameheads.*sametails.*samepreds==1);
if size(allsame,2)==0
    fprintf('\nSorry, fact not in db.\n');
else
    if size(allsame,2)>1
        fprintf('\nThere appears to be two copies of the fact in the kb. This should never happen.\n');
    else
        db.fti1(allsame)=[];
        db.fti2(allsame)=[];
        db.ftir(allsame)=[];
    end
end
