[alphabetized_words, word_index]=sort(word);
index = flann_build_index(h3,struct('algorithm','linear'));

word=word(1:1000000);
h3=h3(:,1:1000000);
db=conceptnet2;
dbsize=size(db.fti1,2);
wordsize=size(word,2);
predsize=size(db.relations,2);
clear factcount;
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
           h3(:,wordsize+1)=ones(300,1);
           index = flann_build_index(h3,struct('algorithm','linear'));
           factcount(wordsize+1)=0;
           wordsize=wordsize+1;
        else
            %add predicate
           db.relations{predsize+1}=tail;
           predsize=predsize+1;
        end
    else
        %add fact to database
        [db, factcount, h3] =add_fact(head,pred,tail,h3, db, db.relations, word,alphabetized_words, word_index, index, factcount);
        index = flann_build_index(h3,struct('algorithm','linear'));
        dbsize=dbsize+1;
    end
end
reverse_db=db;
reverse_db.fti1=db.fti2;
reverse_db.fti2=db.fti1;