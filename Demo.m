% Load the initial stuff (do this better later - this is hacky)
pdbtfilename = "master_preload.txt";
parse_db_text;
pdbtfilename = "mission_preload.txt";
parse_db_text;

% Load the first part of the scenario
pdbtfilename = "instruction1.txt";
parse_db_text;

% A query can be done asking what the current goal of the demo mission is.
removeFact('NewGoal1','CurrentGoalForMission','DemoMission1',db, alphabetized_words,word_index) 