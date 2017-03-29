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

//server time  
        $.get('https://api.kraken.com/0/public/Time', function(data){
            var server_time = data.result//.rfc1123;
            //$(".kraken_server_time").text(server_time);
           console.log(server_time);
 
        });


//ticker kraken API to get new btc/eur value every 2 sec
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



//Client checking the status of its bet
    $( "#bet_status" ).click(function() {
        var value = document.getElementById("btc_address_status").value;
        alert(value);
    });

//Client clicking the Arrow up
    $( "#bet_up" ).click(function() {
        var client_btc_address_up = document.getElementById("client_btc_address_up").value;
        $.ajax({
            type: "GET",
            url: "/up",
            data: { parameter: client_btc_address_up },
            success: function (data) {
                $("#arrow_up_btc").empty();
                $("#arrow_up_btc").append("<p>Winning funds will be send to:" + client_btc_address_up + "</p>");
                $("#arrow_up_btc").append("<p>Send your bet to:" + data.bet_address + "</p>");
            }
        });
    });
//Client clicking the Arrow down
    $( "#bet_down" ).click(function() {
        var client_btc_address_down = document.getElementById("client_btc_address_down").value;
        $.ajax({
            type: "GET",
            url: "/down",
            data: { parameter: client_btc_address_down },
            success: function (data) {
                $("#arrow_down_btc").empty();
                $("#arrow_down_btc").append("<p>Winning funds will be send to:" + client_btc_address_down + "</p>");
                $("#arrow_down_btc").append("<p>Send your bet to:" + data.bet_address + "</p>");
            }
        });
    });

});