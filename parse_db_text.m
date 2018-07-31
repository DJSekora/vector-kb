clear word;
load word;
[alphabetized_words, word_index]=sort(word);

db=conceptnet;
reverse_db=reverse_conceptnet;
predicates=conceptnet.relations;
dbsize=size(db.fti1,2);
wordsize=size(word,2);
predsize=size(predicates,2);
factcount(1:wordsize)=10;
fileID = fopen('parsetext.txt');
TraceArray = textscan(fileID,'%s %s %s', 'delimiter', ' ', 'MultipleDelimsAsOne', 1);
fclose(fileID);
for ii=1:size(TraceArray{1},1)
    head=TraceArray{1}{ii,1};
    pred=TraceArray{2}{ii,1};
    tail=TraceArray{3}{ii,1};
    if strcmp(head,'add')
        if strcmp(pred, 'term')
           word{wordsize+1}=tail;
           [alphabetized_words, word_index]=sort(word);
           factcount(wordsize)=0;
           wordsize=wordsize+1;
        else
            %add predicate
           predicates{predsize+1}=tail;
           predsize=predsize+1;
        end
    else
        %add fact triple to KB
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
        dbsize=dbsize+1;
    end
end