function ind = binSearch(key, cellstr)
    % BINSEARCH  that find index i such that cellstr(i)<= key <= cellstr(i+1)
    %
    % * Synopsis: ind = binSearch(key, cellstr)
    % * Input   : key = what to search for
    %           : cellstr = sorted cell-array of string (others might work, check strlexcmp())
    % * Output  : ind = index in x cellstr such that cellstr(i)<= key <= cellstr(i+1)
    % * Depends : strlexcmp() from Peter John Acklam’s string-utilities, 
    %             at: http://home.online.no/~pjacklam/matlab/software/util/strutil/
    %
    % Transcoded from a Java version at: http://googleresearch.blogspot.it/2006/06/extra-extra-read-all-about-it-nearly.html
    % ankostis, Aug 2013

    low = 1;
    high = numel(cellstr);

    while (low <= high)
        ind = fix((low + high) / 2);
        val = cellstr{ind};

        d = strlexcmp(val, key);
        if (d < 0)
            low = ind + 1;
        elseif (d > 0)
            high = ind - 1;
        else
            return;     %% Key found.
        end
    end
    ind = -(low);       %% Not found!
end