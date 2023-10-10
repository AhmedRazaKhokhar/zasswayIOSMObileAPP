var threshold = 0.1;
document.addEventListener('keydown', function (event) {
    switch (event.keyCode) {
        case 68:  // alphabet d
            threshold -= 0.05;
            break;
        case 85:  // alphabet u
            threshold += 0.05;
            break;
    }
    threshold = Math.max(0.0, Math.min(1.0, threshold));
    var elements = document.getElementsByClassName('rect');
    for (var i = 0; i < elements.length; i++) {
        var value = parseFloat(elements[i].getAttribute('threshold'));
        if (value > threshold) {
            elements[i].style.visibility = 'visible';
        } else {
            elements[i].style.visibility = 'hidden';
        }
    }
});
