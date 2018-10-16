# vector-kb
This depends on two external packages: FLANN and DPC.
You can download FLANN from here:
https://www.cs.ubc.ca/research/flann/
Sometimes compiling a mex file can be a bit tricky so I have included the windows version nearest_neighbors.mexw64 in this package.

You can find DPC here:
http://dpc-screening.github.io/nnlasso.html
If you don't want to use DPC_nnLasso or have trouble getting it working, DPC_nnLasso(W,X,Y,Z) can be replaced with solsum=lsqnonneg(W,X).

run the script 'parse_db_text' to add the information in parsetext.txt to the knowledge base.
sentenceword is a small knowledge base consisting of definitions for words in the form of triples. This needs to be appended to your kb in order to use the relations "hasSubject" "hasPredicate" and "hasObject" effectively.
