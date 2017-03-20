// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require_tree .


$(document).ready(function(){
    var kraken_btc_eur_old = 0;

    setInterval(function(){

        $.get('https://api.kraken.com/0/public/Ticker?pair=XXBTZEUR', function(data){

            var kraken_btc_eur = data.result.XXBTZEUR.c[0];

            if (kraken_btc_eur_old > kraken_btc_eur) {
                // Change css
                $(".kraken_btc_eur").css('color', 'red').text(kraken_btc_eur);
            } else {
                $(".kraken_btc_eur").css('color', 'green').text(kraken_btc_eur);            	
            }

            kraken_btc_eur_old = kraken_btc_eur;
            $(".kraken_btc_eur").text(kraken_btc_eur);

        });

    }, 2000);

});