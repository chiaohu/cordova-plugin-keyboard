document.addEventListener('deviceready', function() {
    cordova.plugins.KeyboardMinus.addMinusButton(function() {
        console.log('Minus button added to keyboard');
    }, function(error) {
        console.error('Error adding minus button: ', error);
    });
});
