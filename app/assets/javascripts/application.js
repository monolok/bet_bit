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

//ticker kraken API to get new btc/eur value
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
            $(".kraken_btc_eur").text(parseFloat(kraken_btc_eur).toFixed(2));

        });

    }, 4000);

//bet counter before rake task
    setInterval(function(){
        var date = new Date;
        var minutes = 60 - date.getMinutes();
        var seconds = 60 - date.getSeconds();
        $(".counter").empty();
        $(".counter").append("<span>" + minutes + ":" + seconds + "</span>");
    }, 1000);

//current bet bitcoin bet
    setInterval(function(){
        $.ajax({
            type: "GET",
            url: "/current_btc",
            success: function (data) {
                $("#current_up").empty();
                $("#current_down").empty();
                $("#current_total").empty();

                $("#current_up").append("<span>" + data.up + "</span>");
                $("#current_down").append("<span>" + data.down +  "</span>");
                $("#current_total").append("<span>" + data.total +  "</span>");                               
            }
        });
    }, 60000);

//Client checking the status of its bet
    $( "#bet_status" ).click(function() {
        var client_btc_address_status = document.getElementById("btc_address_status").value;
        $.ajax({
            type: "GET",
            url: "/status",
            data: { parameter: client_btc_address_status },
            success: function (data) {
                $("#modal_status").empty();
                if (data.Bet.status == "Closed") {
                    $("#modal_status").append("<p>Bet " + data.Bet.id + "is closed</p>");
                    $("#modal_status").append("<p>Bet result was " + data.Bet.result + " </p>");
                    if (data.Gambler.up == true) {
                        $("#modal_status").append("<p>You bet on: up</p>");
                    }else{
                        $("#modal_status").append("<p>You bet on: down</p>");
                    };
                    if (data.Bet.result == "up" && data.Gambler.up == true) {
                        $("#modal_status").append("<p>Congratulation, your winning funds are sent</p>");   
                    }else if (data.Bet.result == "down" && data.Gambler.down == true){
                        $("#modal_status").append("<p>Congratulation, your winning funds are sent</p>");
                    }else{
                        $("#modal_status").append("<p>Hopefully next time...</p>");
                    };
                }else{
                    $("#modal_status").append("<p>Bet still active</p>");
                    if (data.BlockIo.data.pending_received_balance == 0 && data.BlockIo.data.available_balance == 0 ) {
                        $("#modal_status").append("<p>You did not bet any Bitcoins</p>");
                        $("#modal_status").append("<p>Bet number: " + data.Gambler.bet_id + "</p>");
                        $("#modal_status").append("<p>Winning address: " + data.Gambler.client_address + "</p>");
                        if (data.Gambler.up == true) {
                            $("#modal_status").append("<p>You bet on: up</p>");
                        }else{
                            $("#modal_status").append("<p>You bet on: down</p>");
                        };

                    }else{
                        $("#modal_status").append("<p>Bitcoin sent to: " + client_btc_address_status + "</p>");
                        if (data.BlockIo.data.available_balance != 0) {
                            $("#modal_status").append("<p>Your bet is " + data.BlockIo.data.available_balance + " Bitcoins</p>");
       
                        };
                        if (data.BlockIo.data.pending_received_balance != 0) {
                            $("#modal_status").append("<p>Waiting to receive " + data.BlockIo.data.pending_received_balance + " Bitcoins</p>");
                        };
                        $("#modal_status").append("<p>Bet number: " + data.Gambler.bet_id + "</p>");
                        $("#modal_status").append("<p>Winning address: " + data.Gambler.client_address + "</p>");
                        if (data.Gambler.up == true) {
                            $("#modal_status").append("<p>You bet on: up</p>");
                        }else{
                            $("#modal_status").append("<p>You bet on: down</p>");
                        };
                    };
                }
            }
        });
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