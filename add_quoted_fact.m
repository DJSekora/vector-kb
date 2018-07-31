function [db, factcount, h3] = add_quoted_fact(head,pred,quoted_head, quoted_pred, quoted_tail,new_fact, h3, db, predicates, word,alphabetized_words, word_index, index, factcount)
vector=zeros(300,1);
[h3, word]=add_term_to_dictionary(new_fact,vector,word,h3);
[db, factcount, h3] = add_fact(head,pred,new_fact,h3, db, predicates, word,alphabetized_words, word_index, index, factcount)
[db, factcount, h3] = add_fact(new_fact,'hasSubject',quoted_head,h3, db, predicates, word,alphabetized_words, word_index, index, factcount)
[db, factcount, h3] = add_fact(new_fact,'hasPredicate',quoted_pred,h3, db, predicates, word,alphabetized_words, word_index, index, factcount)
[db, factcount, h3] = add_fact(new_fact,'hasObject',quoted_tail,h3, db, predicates, word,alphabetized_words, word_index, index, factcount)