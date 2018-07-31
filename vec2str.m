function [ similar_words result ndists ] = vec2str( vector, h3, word, number_of_words)%, anno )
%turns a vector into the corresponding nearby words
%be sure to include the path to ann library and create nearest neighbors
%anno=ann(h3); 
%load word
 % [result, ndists] = flann_search(h3,vector,number_of_words,struct('algorithm','autotuned','checks',65536,'trees',4,'branching',32,'iterations',5,'centers_init','random','cb_index',0.4000));
   [result1, ndists] = flann_search(h3, vector, number_of_words, struct('algorithm','linear'));
   %[result ndists] = ksearch(anno,vector,number_of_words,1.0);
   result=unique(result1(result1<size(word,2)),'stable');
    similar_words=strrep(word(result),'_',' ');
end
