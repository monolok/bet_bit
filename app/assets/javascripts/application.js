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
   


    function startTimer(duration, display) {
        var timer = duration, minutes, seconds;
        setInterval(function () {
            minutes = parseInt(timer / 60, 10);
            seconds = parseInt(timer % 60, 10);

            minutes = minutes < 10 ? "0" + minutes : minutes;
            seconds = seconds < 10 ? "0" + seconds : seconds;

            display.text(minutes + ":" + seconds);

            if (--timer < 0) {
                timer = duration;
            }
        }, 1000);
    };

    jQuery(function ($) {
        var fiveMinutes = 60 * 5,
            display = $('#counter');
        startTimer(fiveMinutes, display);
    });

    setInterval(function(){

        $.ajax({
          type: "POST",
          url: "/bets",
          data: { parameter: kraken_btc_eur_old },
          success: function (data) {
            //bets history table updated
            if (document.getElementById("bet_loop").children.length > 0 ) {
                $("#bet_loop").prepend("<tr id='bet_" + data.id + "'><th id='data_id'>" + data.id + "</th></tr>");
                $("#bet_" + data.id + "").append("<td id='data_date'>" + data.created_at + "</td>");
                $("#bet_" + data.id + "").append("<td id='data_base_price'>" + data.base_price + "</td>");
                $("#bet_" + data.id + "").append("<td class='kraken_btc_eur'></td>");
            
            } else {

                $("#bet_loop").append("<tr id='bet_" + data.id + "'><th id='data_id'>" + data.id + "</th></tr>");
                $("#bet_" + data.id + "").append("<td id='data_date'>" + data.created_at + "</td>");
                $("#bet_" + data.id + "").append("<td id='data_base_price'>" + data.base_price + "</td>");
                $("#bet_" + data.id + "").append("<td class='kraken_btc_eur'></td>");
            };

            
            //current bet updated
            $("#current_bet_id").html(data.id);
            $("#current_bet_base_price").html(data.base_price);

            var counter_bets = document.getElementById("bet_loop").getElementsByTagName("th").length;
            var remove_id = data.id - 5;
            //logic
            if (counter_bets > 5) {
                //removing oldest bet from bets hostory
                $("tr").remove("#bet_" + remove_id);
            };
           } // end of AJAX success call       
        });


    }, 60000);


});
