%% Initialize variables.
filename = 'D:\matlab apps\AMR.txt';
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
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawNumericColumns rawStringColumns;

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
                    new_words{new_word_count}=current_word;
                    new_word_count=new_word_count+1;         
                    [token, remain] = strtok(current_word,'-');
                    parent=remain(2:end);
                    try
                        vector=str2vec(parent,h3,alphabetized_words,word_index);    
                        % create a new term with this label
                        [h3, word]=add_term_to_dictionary(current_word,vector,word,h3);
                        [alphabetized_words, word_index]=sort(word);
                        [db]=add_fact_to_db(current_word,'IsA',parent,db,h3,alphabetized_words,word_index);    
                    catch
                    end
                end
                
            end    
        end
       
        AMR2{ii,jj}=current_word;
    end
    [alphabetized_words, word_index]=sort(word);
    [db]=add_fact_to_db(AMR2{ii,1},AMR2{ii,2},AMR2{ii,3},db,h3,alphabetized_words,word_index);
end
