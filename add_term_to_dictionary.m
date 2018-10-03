function [dictionary, word]=add_term_to_dictionary(term,vector,word,dictionary)
dictionary_size=size(word,2);
word{dictionary_size+1}=term;
dictionary(:,dictionary_size+1)=vector;

