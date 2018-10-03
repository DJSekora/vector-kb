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
db.relations{1,92}='op';
db.relations{1,93}='name';

for ii=1:14
    fprintf('%d ',ii);
    for jj=1:3
        current_word=AMR{ii,jj};
        current_word=strrep(current_word,'ARG0','agent');
        current_word=strrep(current_word,'ARG1','patient');
        current_word=strrep(current_word,'ARG2','recipient');
        current_word=strrep(current_word,'have-rel-role','related');
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
    [db]=add_fact_to_db(AMR2{ii,1},AMR2{ii,2},AMR2{ii,3},db,h3,alphabetized_words,word_index);
end
