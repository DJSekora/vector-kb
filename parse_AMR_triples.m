%% Initialize variables.
filename = 'AMR.txt';
delimiter = ',';

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%q%q%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));


%% Split data into numeric and string columns.
rawNumericColumns = {};
rawStringColumns = string(raw(:, [1,2,3]));


%% Create output variable
AMR = raw;

%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawNumericColumns rawStringColumns new_word_list factcount AMR2;

% strip quotes
% strip periods
% strip -01, -02, etc from verbs (until you can get a version of word2vec
% with these special verbs)
% replace ARG0 with agent
% replace ARG1 with patient
% replace ARG2 with recipient
new_word_list{1}='junk';
new_word_count=1;
db=conceptnet;
db.relations{1,88}='agent';
db.relations{1,89}='patient';
db.relations{1,90}='recipient';
db.relations{1,91}='mod';
db.relations{1,92}='operator';
db.relations{1,93}='name';
db.relations{1,94}='quant';

dbsize=size(db.fti1,2);
wordsize=size(word,2);
predsize=size(db.relations,2);
clear factcount;
factcount(1:wordsize)=10;

prefix{1,1}='gas';prefix{1,2}='agent';prefix{1,3}='becomes';
prefix{2,1}='liquid';prefix{2,2}='patient';prefix{2,3}='becomes';
prefix{3,1}='gift';prefix{3,2}='recipient';prefix{3,3}='recipient';
prefix{4,1}='adjective';prefix{4,2}='mod';prefix{4,3}='noun';
prefix{5,1}='sum';prefix{5,2}='operator';prefix{5,3}='number';
prefix{6,1}='president';prefix{6,2}='name';prefix{6,3}='Obama';
prefix{7,1}='mice';prefix{7,2}='quant';prefix{7,3}='three';

for ii=1:size(AMR,1)
    fprintf('%d ',ii);
    for jj=1:3
        current_word=char(AMR{ii,jj});
        current_word=strrep(current_word,'ARG0','agent');
        current_word=strrep(current_word,'ARG1','patient');
        current_word=strrep(current_word,'ARG2','recipient');
        current_word=strrep(current_word,'have-rel-role','related');
        current_word=strrep(current_word,'op','operator');
        current_word=regexprep(current_word,'[".- \d]','');
        if regexp(current_word,'/')
            current_word=strrep(current_word,'/','-');
            location=find(strcmp(word,current_word));
            location2=find(strcmp(new_word_list,current_word));
            %  is this the first time you've seen this string?
            if size(location2,2)==0
                if size(location,2)==1
                    %this name is already in the dictionary, and not on the
                    %new word list
                else
                    %this word is neither in the dictionary nor the new
                    %word list
                    new_word_list{new_word_count}=current_word;
                    new_word_count=new_word_count+1;         
                    [token, remain] = strtok(current_word,'-');
                    parent=remain(2:end);
                    new_row{1,1}='add'; new_row{1,2}='term'; new_row{1,3}=char(current_word);
                    new_row{2,1}=char(current_word); new_row{2,2}='IsA'; new_row{2,3}= char(parent);
                    prefix=[new_row ; prefix];
                end
                
            end    
        end
        AMR2{ii,jj}=current_word;
    end
end

AMR2=[prefix; AMR2];

for ii=1:size(AMR2,1)
    head=AMR2{ii,1};
    pred=AMR2{ii,2};
    tail=AMR2{ii,3};
    if strcmp(head,'add')
        if strcmp(pred, 'term')
            %add term
           word{wordsize+1}=tail;
           [alphabetized_words, word_index]=sort(word);
           h3(:,wordsize+1)=.0577*randn(300,1);
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
