function [ vector index_of_vector ] = str2vec( str, h3, alphabetized_words, word_index,dict )
%turns a string into the corresponding semantic vector
     str=char(strrep(str,' ','_'));
     %word_index=find(strcmp(str,word));
     index_of_vector=str2ind(str,alphabetized_words,word_index);
     vector_count=1;
     if size(index_of_vector,1)>0 && index_of_vector>1
         vector = h3(:,index_of_vector);
     else
         vector=zeros(size(h3,1),1);
         each_word=allwords(strrep(str,'_',' '));
         for current_word =1:size(each_word,2)
             thisword=each_word{1,current_word};
             if thisword=='i'
                 thisword='I';
             end
             if strcmp(thisword,'a')==0 && strcmp(thisword,'an')==0 && strcmp(thisword,'the')==0 && strcmp(thisword,'of')==0 
             
                 current_word_index=str2ind(each_word{1,current_word},alphabetized_words,word_index);
                 if current_word_index==1
                     current_vector=[];
                 else
                     if current_word_index>0
                        current_vector = h3(:,current_word_index);
                     else
                        fprintf('\nSorry, I do not know the word "%s."\n',str);
                     end
                 end
                 if size(current_vector,2)>1
                     current_vector=mean(current_vector,2);
                 end
                 if current_word==1 || exist('vector')==0
                    vector=current_vector;
                    vector_count=1;
                 else
                     if size(current_vector,2)>0 && size(vector,2)>0 && size(current_vector,1)>0 && size(vector,1)>0
                         vector=vector+current_vector;
                         vector_count=vector_count+1;
                     end
                 end
             end
         end
     end
     vector=vector./vector_count;
     if size(vector,2)>1
         vector=vector(:,1);
     end
     if size(vector,2)==0 && nargin==5
         synonym_list=synonyms(str,dict);
         for ii=1:size(synonym_list,2)
             a_word_index=strmatch(synonym_list{ii},alphabetized_words,'exact');
             index=word_index(a_word_index);
             if size(index,2)>0
                synonym_vector(:,ii)=h3(:,index);
             end
         end
         if exist('synomym_vector')
            vector=mean(synonym_vector,2);
         end
     else
         if size(vector,2)==0
             vector=zeros(300,1);
         else
            vector=vector(:,1);
         end
     end
end

