// adapted from http://jekyll.tips/jekyll-casts/jekyll-search-using-lunr-js/
(function () {
    function displaySearchResults(searchTerm, results, store) {
        var searchResults = document.getElementById('search-results');
        if (results.length) {
            var appendString = '';
            for (var i = 0; i < results.length; ++i) {
                var item = store[results[i].ref];
                appendString += '<li><a href="' + item.url + '"><h3>' + item.title + '</h3></a>';
                // find first occurence with str.search(), get substring around that and highlight
                var termBegin = item.content.toLowerCase().search(searchTerm.toLowerCase());
                var termEnd = termBegin + searchTerm.length;
                var displayBegin = termBegin - 75;
                var displayEnd = termBegin + 75;
                appendString += '<p>';
                if (displayBegin < 0) {
                    displayEnd += -1 * displayBegin;
                    displayBegin = 0;
                } else {
                    appendString += '...'
                }
                appendString += item.content.substring(displayBegin, termBegin)
                    + "<span style='background-color: #fff085'>"
                    + item.content.substring(termBegin, termEnd)
                    + "</span>"
                    + item.content.substring(termEnd, displayEnd)
                    + '...</p></li>';
            }

            searchResults.innerHTML = appendString;
        } else {
            searchResults.innerHTML = '<li>No results found</li>';
        }
    }

    function getQueryVariable(variable) {
        var query = window.location.search.substring(1);
        var vars = query.split('&');

        for (var i = 0; i < vars.length; ++i) {
            var pair = vars[i].split('=');

            if (pair[0] === variable) {
                return decodeURIComponent(pair[1].replace(/\+/g, '%20'));
            }
        }
    }

    var searchTerm = getQueryVariable('query');

    if (searchTerm) {
        document.getElementById('search-box').setAttribute("value", searchTerm);

        // Initalize lunr with the fields it will be searching on. I've given title
        // a boost of 10 to indicate matches on this field are more important.
        var idx = lunr(function () {
            this.field('id');
            this.field('title', {boost: 10});
            this.field('content');
        });

        for (var key in window.store) { // Add the data to lunr
            idx.add({
                'id': key,
                'title': window.store[key].title,
                'content': window.store[key].content
            });

            var results = idx.search(searchTerm); // Get lunr to perform a search
            displaySearchResults(searchTerm, results, window.store);
        }
    }
})();
