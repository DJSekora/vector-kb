term='llama';
no_of_sentences=10;
[output_vector1, tail_weights, tail_inds] = simplexQAunlimited(str2vec(term,h3,alphabetized_words,word_index),'hasSubject',conceptnet.relations,sentenceword,h3,index,word);
[output_vector2, tail_weights, tail_inds] = simplexQAunlimited(str2vec(term,h3,alphabetized_words,word_index),'hasPredicate',conceptnet.relations,sentenceword,h3,index,word);
[output_vector3, tail_weights, tail_inds] = simplexQAunlimited(str2vec(term,h3,alphabetized_words,word_index),'hasObject',conceptnet.relations,sentenceword,h3,index,word);
not_someone=-str2vec('someone', h3, alphabetized_words, word_index);
word1=vec2str(output_vector1+.4*not_someone,h3,word,no_of_sentences);
word2=vec2str(output_vector2,h3,word,no_of_sentences);
word3=vec2str(output_vector3+.4*not_someone,h3,word,no_of_sentences);

for ii=1:no_of_sentences
fprintf('%s %s %s.\n',word1{ii},word2{ii},word3{ii});
end
