original_word=word;
[alphabetized_words, word_index]=sort(word);
index = flann_build_index(h3,struct('algorithm','linear'));

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
            %add term
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
        %add fact to database
        [db, factcount, h3] =add_fact(head,pred,tail,h3, db, predicates, word,alphabetized_words, word_index, index, factcount);
        dbsize=dbsize+1;
    end
end