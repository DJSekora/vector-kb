function index = str2index(string,alphabetized_words, word_index)
try
    alphabetized_index=binSearch(string,alphabetized_words);
    if alphabetized_index>0 
        index=word_index(alphabetized_index);
    else index=0;
    end
catch
    index=0;
end
