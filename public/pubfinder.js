/* Pub Finder General */

$(document).ready(function(){
    var datetest = document.createElement("input");
    datetest.setAttribute("type", "date");
    if (datetest.type == "text") {
        $("#review_date").datepicker({ dateFormat: "yy-mm-dd" });
    }

    if ($("form.newpub").size() > 0) {
        if (navigator.geolocation) {
	    navigator.geolocation.getCurrentPosition(
                updateGeo, handleError);
        }
    }
});

function updateGeo(position) {
    $("form.newpub").append("<input type='hidden' name='pub[lat]' value='" + position.coords.latitude + "' />");
    $("form.newpub").append("<input type='hidden' name='pub[lon]' value='" + position.coords.longitude + "' />");
    $("#geowait").html("Found geolocation!");
}

function handleError(err) {
    alert ('Geolocation failed');
}
